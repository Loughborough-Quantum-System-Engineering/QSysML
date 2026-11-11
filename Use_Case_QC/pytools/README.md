# pytools — file-based ToolExecution runner for SysML v2

`run_tools.py` executes SysML v2 calculations with Python tools, using
the file-based ToolExecution pattern: a `calc def` (or action def)
annotated with `ToolExecution` metadata and `@ToolVariable` parameters
is performed by an ordinary Python function named in the metadata's
`uri`. The model initiates: an `analysis` case declares which bound
calc usages to run; the runner performs them and writes the results
back into the model text.

No Jupyter, no kernel, no API server: the runner works on `.sysml`
textual notation directly.

## 1. Environment

Create a dedicated Python environment (Python 3.11+). Either restore
the pinned environment:

```bash
conda env create -f environment.yml
conda activate qsysml
```

or build it step by step:

```bash
conda create --override-channels -c conda-forge -y -n qsysml python=3.11 numpy
conda activate qsysml
pip install sysml sympy qutip
```

| Package | Role |
|---|---|
| numpy | numeric linear algebra inside tool functions |
| sympy | exact symbolic computation - tools return exact expressions ("pi/4", "Sqrt(2)/2") paired with numeric values |
| qutip | quantum states/gates as Qobj for the symbolic-state tools |
| sysml | the SysML v2 SDK - reads the interchange JSON (spec-shaped access) |

Notes:
- `sysml` needs Python >= 3.10; on first use it downloads (~11 MB) and
  caches the standard-library payload, SHA-256 verified. Offline use:
  set `SYSML_LIBRARY_JSON`.
- `qutip` is only needed by tool modules that use it (the runner
  itself is stdlib-only).

## 2. The model side (what the runner reads)

A model is executable when it has:

1. a `calc def` carrying ToolExecution metadata and ToolVariable
   parameters, e.g.

```sysml
calc def ApplyT {
    metadata ToolExecution { toolName = "Python"; uri = "qubit_tools.py#apply_t"; }
    in initialState : NamedState { @ToolVariable { name = "initial_state"; } }
    return stateKet : String { @ToolVariable { name = "state_ket"; } }
    out finalState : NamedState { @ToolVariable { name = "final_state"; } }
    out globalPhaseExpr : String { @ToolVariable { name = "global_phase_expr"; } }
    out globalPhase : Real { @ToolVariable { name = "global_phase"; } }
    out amplitudes : Real[4] ordered { @ToolVariable { name = "amplitudes"; } }
}
```

2. a `calc` usage binding the inputs:

```sysml
calc tOnOne : ApplyT { in initialState = NamedState::one; }
```

3. an `analysis def` listing the calc usages and an `analysis` usage
   performing it:

```sysml
analysis def NamedStateAnalysis {
    return finalStateResult : NamedState;
    calc tOnOne : ApplyT { in initialState = NamedState::one; }
}
analysis namedStateStudy : NamedStateAnalysis;
```

The runner pairs every meaningful string output with its numeric twin
(`globalPhaseExpr = "pi/4"` + `globalPhase = 0.7853981633974483`):
strings carry the meaning, numbers keep results composable.
A `calc def` has ONE distinguished `return`; additional results are
`out` parameters (SSM081).

## 3. The interchange JSON (the runner's model input)

The runner reads the model structure from a full-form interchange JSON
cached beside the model: `<model-stem>.json` (e.g. `GateRun.json`
beside `GateRun.sysml`). Produce it once per model revision:

- from the SysML v2 Pilot Jupyter kernel: `%export <Package>` (the
  JSON arrives as a base64 data URI in the cell output - decode and
  save), or
- from any SysML v2 tool's interchange export.

The reader auto-detects both the wrapped `%export` form
(`{payload, identity}` entries) and the flat interchange form. If the
JSON is absent or unreadable, the runner falls back to a textual
(regex) reader - same results for supported models, but the SDK/JSON
path is the dependable one.

## 4. Running

```bash
python run_tools.py <model.sysml>                     # perform every analysis case
python run_tools.py GateRun.sysml namedStateStudy     # one analysis case
python run_tools.py GateRun.sysml tOnOne --apply      # one usage, write results
```

- without `--apply`: report-only (values computed, nothing written).
- write-back: results are written into the usage as value bindings at
  full precision, UPDATE-not-append; enum-typed results are written as
  qualified member references and validated against the enum members
  (non-member values skip the write with a message).

Tool root resolution for the `uri` file part: `QSYSML_TOOLS` env var,
then `tools.json` (`{"toolRoot": "..."}` beside the runner), then the
model's own directory.

## 5. Writing tool modules

A tool module is an ordinary Python file named in the uri
(`file.py#function`). The function receives one keyword argument per
input `@ToolVariable` name and returns a dict keyed by the output
`@ToolVariable` names:

```python
import numpy as np
import qutip

NAMED = {
    "zero":  qutip.basis(2, 0),
    "one":   qutip.basis(2, 1),
    "plus":  (qutip.basis(2, 0) + qutip.basis(2, 1)).unit(),
    "minus": (qutip.basis(2, 0) - qutip.basis(2, 1)).unit(),
}

def apply_t(initial_state):
    T = qutip.Qobj(np.array([[1, 0], [0, np.exp(1j * np.pi / 4)]]))
    out = T @ NAMED[initial_state]
    return {"state_ket": str(out), "final_state": "one",
            "global_phase_expr": "pi/4", "global_phase": np.pi / 4,
            "amplitudes": [[float(np.real(out[0, 0])), float(np.imag(out[0, 0]))],
                           [float(np.real(out[1, 0])), float(np.imag(out[1, 0]))]]}
```

Convention: pair every meaningful string output with its numeric twin
(`*_expr` string + bare number) so results stay composable.

## 6. Input expression subset (textual evaluation)

Input bindings are evaluated per the KerML arithmetic subset: numeric
literals, `pi`, unary `-`, binary `+ - * / **`, parentheses, and
same-file attribute bindings. Not supported textually: function calls,
qualified references, cross-file resolution. (The SDK expression-tree
route covers more; the textual evaluator is the fallback.)

## 7. Known constraints

- Enum member references must be QUALIFIED in bindings
  (`NamedState::one`, not `one`) - unqualified members fail name
  resolution (probe-verified, Pilot 0.63.1 + Aliot).
- SysML string literals are DOUBLE-quoted; single quotes parse as name
  references (probe-verified).
- A `calc def` has one distinguished `return`; additional results are
  `out` parameters (SSM081).
- `%export` JSON and the SDK payload form differ in wrapping; the
  runner auto-detects both. The Pilot `%export` payload carries no
  `qualifiedName` fields - structure comes from `@type`/`@id`.
