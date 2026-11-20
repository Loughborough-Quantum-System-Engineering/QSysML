# pytools — QSysML M2M pack

The Python side of the QSysML <-> Python model-to-model transformation
(decisions #65-#88, see the QC modelling decisions record 2026-11-18).
Architecture: the model declares (types, asserted constraints,
kernel-realized predicates, value definitions); this pack computes; the
M2M completes the model's input-output flows by writing computed
bindings back.

## Files

| file | role |
|---|---|
| `kernel.py` | the semantic algebra: native-python complex (library Complex mapping), column-convention matrix application, frame -> apply -> re-express -> canonicalize pipeline, the 6 realized predicates (`isUnitary`, `isOrthonormal`, `isNormalised`, `normsEqual`, `stateNormsEqual`, `isCanonical`), ray-match naming, 12 goldens self-check |
| `brain_reader.py` | the M2M front-end: reads value definitions and scenario usages from `brain_storm.sysml`; evaluates the model's constructor sublanguage (`rect`, `polar`, `sqrt`, `pi`, chains, sequences) into kernel values |
| `m2m.py` | the correspondence engine: binding table (kernel-realized calc defs -> kernel functions), flow completion, acceptance asserts, exact-twin rendering, write-back by usage identity, UPDATE-not-append |
| `../quantum.sysml`, `../QuantumComputing.sysml`, `../GateOperations.sysml` | the models (the M2M takes a file list; the namespace merges across files): `Quantum` (representation layer, predicates, z-basis vocabulary), `Utility` (action layer, Kyon), `GateOperations` (gate values h/t/cnot, xBasis, plus/minus, flow contracts, certified scenarios) |

## Run

```bash
QPY=/opt/homebrew/Caskroom/miniconda/base/envs/qsysml/bin/python
$QPY kernel.py                                  # goldens (12 checks)
$QPY m2m.py ../quantum.sysml ../QuantumComputing.sysml ../GateOperations.sysml ../Example.sysml                # report (check semantics)
$QPY m2m.py ../quantum.sysml ../QuantumComputing.sysml ../GateOperations.sysml ../Example.sysml --apply        # complete flows (idempotent)
```

## Verified (18 Nov 2026)

- kernel goldens: 12/12 PASS.
- `tOnOne`: ray match -> `return phi = one;` (naming-success policy).
- `tOnPlus`: no ray match -> anonymous bind with exact-expression twins
  `coefficients = (rect(cos(pi / 8.0), 0.0), rect(0.0, -sin(pi / 8.0)))`.
- Re-apply idempotent (UPDATE-not-append; GetPut law operational).

## Layering rule

Structural checks (sizes, ranges, frame identity) are model-expressed
inline; linear-algebraic checks are model-named and Python-owned
(kernel-realized predicate calcs); the model writes ideal math
(`cos(pi/4) + i sin(pi/4)`), the kernel owns evaluation, and every
comparison is tolerance-based (ULP discipline).
