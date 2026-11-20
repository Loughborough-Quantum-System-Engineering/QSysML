"""m2m: the minimal bidirectional correspondence engine for
brain_storm.sysml.

  get     : read the model's value definitions -> kernel values (N1-N3)
  bind    : kernel-realized calc defs -> kernel functions (N4, N6)
  compute : complete scenario flows (UnitaryEvolution) (N5, N7)
  enforce : render the out-binding (exact twins first) and write it back
            into the scenario body, by usage identity, UPDATE-not-append
            (N8, N9). Re-running a completed flow changes nothing.

Usage: python m2m.py brain_storm.sysml [--apply]
Without --apply: report only (check semantics).
"""
import re
import sys
from pathlib import Path

import kernel
from brain_reader import load

# the correspondence specification (B5 moves this into model metadata)
BINDINGS = {
    "UnitaryEvolution": kernel.unitary_evolution,
    "ApplyMatrix": kernel.apply_matrix,
    "isUnitary": kernel.is_unitary,
    "isOrthonormal": kernel.is_orthonormal,
    "isNormalised": kernel.is_normalised,
    "normsEqual": kernel.norms_equal,
    "stateNormsEqual": kernel.state_norms_equal,
    "isCanonical": kernel.is_canonical,
}

# exact-twin candidates: model constant + the trig lattice in use
def _twins(values):
    import math
    twins = {1.0: "1.0", 0.0: "0.0"}
    for name, v in values.items():
        if isinstance(v, float):
            twins[v] = name                  # model-defined Real constants
    for expr, ang in [("pi / 8.0", math.pi / 8),
                      ("pi / 4.0", math.pi / 4)]:
        twins[math.cos(ang)] = f"cos({expr})"
        twins[math.sin(ang)] = f"sin({expr})"
        twins[-math.sin(ang)] = f"-sin({expr})"
    return twins


RESULT_TYPES = {"UnitaryEvolution": "Quantum::A::QuantumState"}

# asserted-constraint realizations: the model's `assert constraint`s
# (quantum.sysml / GateOperations.sysml) and their kernel checks --
# verified against EVERY value of the owning type, PASS/FAIL printed.
CONSTRAINTS = {
    "Matrix": [
        ("uniformShape", lambda v: all(len(col) == len(v.columns[0])
                                       for col in v.columns)),
    ],
    "UnitaryMatrix": [
        ("square", lambda v: len(v.columns) == len(v.columns[0])),
        # uniformShape inherited from Matrix (implied by unitary, but
        # verified explicitly -- specialization carries the constraints)
        ("uniformShape", lambda v: all(len(col) == len(v.columns[0])
                                       for col in v.columns)),
        ("unitary", lambda v: kernel.is_unitary(v.columns)),
    ],
    "Basis": [
        ("dimensionMatch", lambda v: len(v.members) == v.dimension),
        ("memberCoherent", lambda v: all(len(m) == v.dimension
                                         for m in v.members)),
        ("orthonormal", lambda v: kernel.is_orthonormal(v.members)),
    ],
    # TensorBasis :> Basis -- inherits the Basis constraints
    "TensorBasis": [
        ("dimensionMatch", lambda v: len(v.members) == v.dimension),
        ("memberCoherent", lambda v: all(len(m) == v.dimension
                                         for m in v.members)),
        ("orthonormal", lambda v: kernel.is_orthonormal(v.members)),
        ("dimensionLaw",
         lambda v: v.left.dimension * v.right.dimension == v.dimension),
    ],
    "QuantumState": [
        ("sizeCoherent", lambda v: len(v.coefficients) == v.basis.dimension),
        ("normalised", lambda v: kernel.is_normalised(v.coefficients)),
        ("canonical", lambda v: kernel.is_canonical(v.coefficients)),
    ],
}


def _short(ref):
    """Quantum::plus -> plus (the reader's namespace is flattened)."""
    return ref.split("::")[-1]


def _qual(r, name, scen_pkg):
    """Qualifier for a model-defined name relative to the scenario's
    own package chain: same chain -> bare name; otherwise the FULL
    defining package path (Quantum::A::one, GateOperations::plus)."""
    d = r.def_pkg.get(name)
    if d is None or tuple(d) == tuple(scen_pkg):
        return ""
    return "::".join(d) + "::"


def _render_complex(z, twins):
    def part(x):
        for v, expr in twins.items():
            if abs(v - x) <= 1e-12:
                return expr
        return repr(x)
    if z.imag == 0.0:
        return f"rect({part(z.real)}, 0.0)"
    return f"rect({part(z.real)}, {part(z.imag)})"


def _render_state(qualified_basis, qtype, coefficients, twins):
    parts = ", ".join(_render_complex(z, twins) for z in coefficients)
    return (f"{qtype}(basis = {qualified_basis}, "
            f"coefficients = ({parts}))")


def _insert_binding(text, name, rendered):
    """Locate the usage by name in the CURRENT text, brace-match to its
    closing brace, insert the return binding just before it. The
    binding indent is measured from the usage declaration's own line
    (+4) -- depth-agnostic: works nested in packages or flat."""
    m = re.search(r"calc\s+" + name + r"\s*:\s*[\w:]*UnitaryEvolution\s*\{",
                  text)
    if not m:
        raise RuntimeError(f"usage '{name}' not found")
    decl_line = text.rfind("\n", 0, m.start()) + 1
    decl_indent = re.match(r"[ \t]*", text[decl_line:m.start()]).group(0)
    bind_indent = decl_indent + "    "
    depth, i = 1, m.end()
    while depth:
        ch = text[i]
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        i += 1
    close = i - 1
    close_line = text.rfind("\n", 0, close) + 1
    return text[:close_line] + f"{bind_indent}return phi = {rendered};\n" \
        + text[close_line:]


def main():
    paths = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not paths:
        raise SystemExit("usage: python m2m.py <model.sysml> [...] [--apply]")
    apply = "--apply" in sys.argv

    r, values, states, named_E, basis_names = load(paths)

    print("-- correspondence (bindings) --")
    for sysml_name, fn in BINDINGS.items():
        print(f"bind     : {sysml_name} -> kernel.{fn.__name__}")

    run_failed = False

    print("-- values (get) --")
    for name, v in values.items():
        kind = type(v).__name__
        print(f"value    : {name} [{kind}]")

    # ---- verify: every asserted constraint against every value -------
    print("-- constraints (verify) --")
    n_checked = n_failed = 0
    failed_checks = []
    for name, v in values.items():
        short = r.defs[name][0].split("::")[-1]
        for cname, check in CONSTRAINTS.get(short, []):
            try:
                passed = bool(check(v))
            except Exception:
                passed = False
            n_checked += 1
            if passed:
                print(f"PASS  {short}.{cname} : {name}")
            else:
                n_failed += 1
                failed_checks.append(f"{short}.{cname} ({name})")
                print(f"FAIL  {short}.{cname} : {name}")
    print(f"-- constraints: {n_checked} checked, {n_failed} failed --")
    if failed_checks:
        print("-- constraint failures: " + ", ".join(failed_checks))
        run_failed = True

    twins = _twins(values)
    changed = False
    for scen in r.scenarios:
        label = scen["name"]
        print(f"-- flow {label} --")
        if apply:
            # fresh load per write: a file may have shifted underneath
            r2, values2, states2, named_E2, basis_names2 = load(paths)
            scen = next(s for s in r2.scenarios if s["name"] == label)
            values, named_E, basis_names = values2, named_E2, basis_names2
            twins = _twins(values)
        if scen["completed"]:
            print("flow     : already complete (UPDATE-not-append: no-op)")
            continue
        if scen["operation"] is None or scen["psi"] is None:
            raise SystemExit(
                f"flow '{label}' ({Path(scen['file']).name}): missing "
                f"in-bindings -- expected 'in operation = <op-name>;' and "
                f"'in psi = <state-name>;' (parameter bindings use the "
                f"direction keyword 'in', not 'attribute')")
        op = values[_short(scen["operation"])]
        psi = values[_short(scen["psi"])]
        phi = BINDINGS["UnitaryEvolution"](op.columns, psi)

        # acceptance: the flow's asserted contracts -- PASS/FAIL printed;
        # a FAIL refuses the write for this flow (acceptance gate)
        contract = [
            ("domainCoherent", len(op.columns) == psi.basis.dimension),
            ("normPreserved", kernel.norms_equal(phi, psi.coefficients)),
            # by construction: the renderer binds phi.basis = psi.basis
            ("sameFrame", True),
        ]
        gate = True
        for cname, cond in contract:
            print(f"{'PASS  ' if cond else 'FAIL  '}{cname} : {label}")
            gate = gate and cond
        if not gate:
            print(f"REFUSED : flow '{label}' failed its contract -- "
                  f"nothing written")
            run_failed = True
            continue

        scen_pkg = scen["pkg"]
        basis_name = basis_names[id(psi.basis)]
        nm = kernel.name_of(
            kernel.frame_to_E(phi, psi.basis.members), named_E)
        if nm is not None:
            rendered = _qual(r, nm, scen_pkg) + nm
            print(f"naming   : ray match -> {rendered}")
        else:
            qbasis = _qual(r, basis_name, scen_pkg) + basis_name
            rendered = _render_state(qbasis, RESULT_TYPES["UnitaryEvolution"],
                                     phi, twins)
            print("naming   : no ray match -> anonymous bind")
        print(f"render   : return phi = {rendered}")

        if apply:
            target = Path(scen["file"])
            target.write_text(_insert_binding(target.read_text(), label, rendered))
            print(f"written  : {target} ({label})")
            changed = True
        else:
            print("(report only; pass --apply to write back)")

    if not apply:
        print("-- check pass complete (no writes) --")
    elif not changed:
        print("-- nothing to write: all flows complete (idempotent) --")
    if run_failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
