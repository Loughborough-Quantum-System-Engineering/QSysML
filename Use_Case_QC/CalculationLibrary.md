# QSysML Calculation Library — Reference

Model library extending the mathematics available to QSysML models with
SysML v2 `calc def`s, written in the subset the SysML v2 Pilot
Implementation evaluates. The language defines what calculations *mean*
(sysmlv2.pdf 7.19; KerML 9.4); this library supplies the vocabulary the
standard libraries lack: complex arithmetic and (from layer 1) small
dense linear algebra. Layers: L0 `ScalarCalc` (implemented) —
L1 `LinCalc` (matrices, unitarity, tensor product) — L2
`QuantumStateCalc` (bridge to `quantum.sysml`'s
`(probability, relativePhase)` descriptions). Gate definitions stay in
the use case, consuming these layers.

Scope: this library and its reference serve the Use_Case_QC folder.

## 1. Conventions

| # | Convention |
|---|---|
| C1 | A complex number x + i y is the pair (x, y) as `Real[2]`: element 1 is the real part x, element 2 is the imaginary part y. i is never stored; it exists only as the operation rules (i^2 = -1 is the negative term of ComplexMultiply). |
| C2 | A quantum state IS a state vector relative to a basis (calculation-aligned, 6 Nov 2026; quantum.sysml `QuantumState.stateVector`): one (real part, imaginary part) pair per basis member, by index — a qubit state is `Real[4]` = (real part of alpha, imaginary part of alpha, real part of beta, imaginary part of beta); two-qubit states: four pairs in register order (member 1 = |00> ... member 4 = |11>). Basis membership carries its member VECTORS (`Basis.memberVector`: d member vectors of 2d reals each in the reference z convention; in C8 spelling the groups are the members). Group meaning is shape-specific: stateVector groups = amplitude pairs, memberVector groups = members, gate-matrix groups = rows. |
| C3 | Indexing is `#(n)`, **1-based** ("element n"). Matrix carriers are flat, **row-major**: entry (r, c) of a 2x2 is element 2(r-1)+c. |
| C4 | **Ambiguous-literal warning**: `((1,0),(0,0))` reads as the state |0> (pair of pairs) *or* as the matrix [[1,0],[0,0]] = |0><0|. Construct and read shapes only through §2's named calcs — never raw nested literals. |
| C5 | **Tolerance policy**: mathematical identities are asserted with `Close`/`StatesClose`, never `==`. Default eps = 1.0E-9 (rounding ~1E-16; chained arithmetic ~1E-15). `default` parameters may be overridden; bound (`=`) may not. |
| C6 | **Global phase** is carried inside the state vector (unobservable); `TimesI` states global-phase identities exactly. No phase ANGLE is stored anywhere (the (p, phi-angle) form is superseded): the angle needs atan2 (nonevaluable) — only the phase DIRECTION per member is computable (`CosRelativePhase` gives cos of it; `RelativePhaseDirection` deferred). |
| C7 | **Exact expressions only**: model source never contains rounded decimals (`1.0 / Sqrt(2.0)`, `pi / 4.0` — never 0.7071...). Decimals appear only in tolerance values (exact as written) and in *displayed evaluated results*. |
| C8 | **Nested authoring style (preferred)**: sequence constants and arguments are written with grouping parentheses exposing the intended structure — matrix rows `((a11, a12), (a21, a22))`, qubit states `((real part of alpha, imaginary part of alpha), (real part of beta, imaginary part of beta))`, two-qubit states as four amplitude groups, 4x4 matrices as four rows. Nesting flattens to the same flat carrier (validated); it is presentation only — the meaning of each group comes from the shape registry, and reading happens through the Entry accessors and shape calcs, never through the grouping. |
| C9 | **Call results splat inside tuple literals**: a calc invocation returning a sequence may be a *direct argument* (binds to the parameter's type — validated), but nested inside a larger tuple literal its result spreads element-wise into the sequence (`((0.0, 0.0, 0.0, ComplexExpI(pi/4.0)))` produced 5 elements, not 4). Build such values with constructors taking the call as an argument, or spell exact numbers. |
| C10 | **Import convention (project rule, 2026-11-05; binding text in the qsysml-qc-modelling-agreement)**: standard-library imports (`ScalarValues::*`, `TrigFunctions::*`, ISQ, SI, …) stay as `private import` at the package top; non-standard (project-local) libraries — `CalculationLibrary`, `Quantum`, `QuantumComputing`, sibling packages — are never imported; every reference is fully qualified inline (e.g. `CalculationLibrary::LinCalc::Matrix2x2RealProduct(...)`), the style of the pre-rewrite GateOperations.sysml. |

## 2. Shape registry

| Shape | Carrier | Meaning | Constructor | Accessors |
|---|---|---|---|---|
| Complex value | `Real[2]` | x + i y | raw literal | L0 operations |
| Qubit state | `Real[4]` | alpha\|0> + beta\|1> | `QubitState(alpha, beta)` (L2) | `QubitAlpha`, `QubitBeta` (L2) |
| Basis states | `Real[4]` | \|0>, \|1>, \|+>, \|-> | constants `Ket0`, `Ket1`, `KetPlus`, `KetMinus` (L2) | — |
| Two-qubit state | `Real[8]` | 4 amplitude pairs, register order | `TensorProduct(a, b)` (L1) | TBD (L2) |
| 2x2 real matrix | `Real[4]` | row-major operator | `Matrix2x2Real(a11, a12, a21, a22)` | `Matrix2x2RealEntry(m, row, column)` |
| 2x2 complex matrix | `Real[8]` | pair per entry, row-major | `Matrix2x2Complex(a11, a12, a21, a22)` (pairs) | `Matrix2x2ComplexEntry(m, row, column)` |
| 4x4 real matrix | `Real[16]` | two-qubit operators (CNOT) | `Matrix4x4Real(a11 ... a44)` | `Matrix4x4RealEntry(m, row, column)` |
| Qubit state vector | `Real[4]` | the QuantumState carrier (groups = amplitude pairs) | `Ket0`/`Ket1`/`KetPlus`/`KetMinus`, `QubitState(alpha, beta)` | `QubitAlpha`, `QubitBeta` |
| Two-qubit state vector | `Real[8]` | the composite carrier (groups = amplitude pairs) | `TensorProduct(a, b)` | TBD |
| Basis member vectors | `Real[2d^2]` | d member vectors in the reference convention (groups = members) | literal (C8) | `InnerProduct` for orthonormality |

## 3. Layer 0 — `CalculationLibrary::ScalarCalc` (implemented)

> **`Abs`** — `in x : Real` → `Real`. |x| via conditional.
> **`Sqrt`** — `in x : Real` → `Real`. Domain x >= 0; body `x ** 0.5`.
> **`Close`** — `in a, b : Real; in eps : Real default 1.0E-9` → `Boolean`. |a-b| < eps (C5).
> **`ComplexAdd`** — two `Real[2]` → `Real[2]`. (x+u, y+v).
> **`ComplexSubtract`** — two `Real[2]` → `Real[2]`. (x-u, y-v).
> **`ComplexScale`** — `Real`, `Real[2]` → `Real[2]`. (c·x, c·y).
> **`ComplexMultiply`** — two `Real[2]` → `Real[2]`. (xu−yv, xv+yu); the −yv term is i^2 = −1.
> **`ComplexConjugate`** — `Real[2]` → `Real[2]`. (x, −y).
> **`ComplexAbsSquared`** — `Real[2]` → `Real`. x^2 + y^2; the Born rule.
> **`ComplexExpI`** — `in theta : Real` → `Real[2]`. (cos θ, sin θ).

Worked examples (C7: expressions; decimals are display only):

| Expression | Value |
|---|---|
| `ComplexMultiply((0,1),(0,1))` | (−1, 0) — i·i = −1 |
| `ComplexExpI(pi / 4.0)` | (cos π/4, sin π/4) ≈ (0.70711, 0.70711) |
| `ComplexExpI(pi / 4.0)` applied twice | i = (0, 1) — exponent laws emerge from the C1 rules |
| `ComplexAbsSquared((3, -4))` | 25 |
| `Close(0.9999999999999998, 1.0)` / `Close(1.0, 1.1)` / `Close(1.0, 1.05, 0.1)` | true / false / true |

## 4. Layer 1 — `CalculationLibrary::LinCalc` (implemented)

General-purpose small dense matrices: any matrix the user supplies flows
through these operations — standard gates, user-defined operations, real
or complex entries. **Generality statement**: general over matrix
*content* (any entries); general over *size* via a declared pattern
instantiated at fixed sizes (2x2, 4x4) — generic sizes need loops, which
the Pilot does not evaluate; further sizes follow the same recipe.
Matrix product order: `Product(left, right)` means **apply right first,
then left**. A real matrix enters complex algebra through
`Matrix2x2RealAsComplex` (zero imaginary parts); no real-times-complex
multiplication variants exist — embed first.

**Identity constants**: `IdentityMatrix2x2Real`, `IdentityMatrix2x2Complex`,
`IdentityMatrix4x4Real`.

**2x2 real family** — storage, application, algebra, unitarity:

> `Matrix2x2Real(a11, a12, a21, a22)` → `Real[4]` ·
> `Matrix2x2RealEntry(m, row, column)` → `Real` ·
> `Matrix2x2RealTimesState(m, psi)` → state `Real[4]` ·
> `Matrix2x2RealProduct(left, right)` → `Real[4]` ·
> `Matrix2x2RealTranspose(m)` → `Real[4]` (real case: transpose = conjugate transpose) ·
> `Matrix2x2RealClose(left, right, eps)` → `Boolean` ·
> `IsUnitaryMatrix2x2Real(m)` → `Boolean`

**Real-to-complex bridge**:

> `Matrix2x2RealAsComplex(m)` — `Real[4]` → `Real[8]`

**2x2 complex family** (entries are (real part, imaginary part) pairs):

> `Matrix2x2Complex(a11, a12, a21, a22)` (four `Real[2]` pairs) → `Real[8]` ·
> `Matrix2x2ComplexEntry(m, row, column)` → pair `Real[2]` ·
> `Matrix2x2ComplexTimesState(m, psi)` → state `Real[4]` ·
> `Matrix2x2ComplexProduct(left, right)` → `Real[8]` ·
> `Matrix2x2ComplexConjugateTranspose(m)` → `Real[8]` (the dagger) ·
> `Matrix2x2ComplexScaledBy(s, m)` → `Real[8]` (global phase of an operator) ·
> `Matrix2x2ComplexClose(left, right, eps)` → `Boolean` ·
> `IsUnitaryMatrix2x2Complex(m)` → `Boolean`

**Tensor product**:

> `TensorProduct(a, b)` — two qubit states (`Real[4]`) → two-qubit state
> (`Real[8]`), member order \|00>, \|01>, \|10>, \|11>, a as the first qubit

**4x4 real family** — the CNOT class:

> `Matrix4x4Real(a11 ... a44)` → `Real[16]` ·
> `Matrix4x4RealEntry(m, row, column)` → `Real` ·
> `Matrix4x4RealTimesState(m, psi)` → two-qubit state `Real[8]` ·
> `Matrix4x4RealProduct(left, right)` → `Real[16]` ·
> `Matrix4x4RealTranspose(m)` → `Real[16]` ·
> `Matrix4x4RealClose(left, right, eps)` → `Boolean` ·
> `IsUnitaryMatrix4x4Real(m)` → `Boolean`

**Deferred to v2** (recorded needs): complex 4x4 family (first concrete
user need: user-defined controlled-phase operations); operator-level
tensor product (`TensorProductOfMatrices`, for H(x)I circuits); density
matrix conjugation (Realisation layer). **Excluded deliberately**: matrix
inverse (a unitary's inverse is its conjugate transpose), trace,
determinant, eigen-decomposition (external-solver territory).

### Defining your own operation (the recipe)

1. Define the matrix — constant or parameterized calc def:
   `calc def PhaseRotate { in theta : Real; return : Real[8] = Matrix2x2Complex((1.0,0.0),(0.0,0.0),(0.0,0.0),ComplexExpI(theta)); }`
2. Check it is a legal gate: `IsUnitaryMatrix2x2Complex(PhaseRotate(pi / 4.0))` → true.
3. Apply it to any state: `Matrix2x2ComplexTimesState(PhaseRotate(theta), psi)`.
4. Derive the measurement description: `BornProbabilities` / `CosRelativePhase` (L2).
No per-gate code beyond step 1; all services are generic.

## 5. Layer 2 — `CalculationLibrary::QuantumStateCalc` (implemented)

The qubit-state shape vocabulary and the bridge between the amplitude
layer and the native description of `quantum.sysml` (Born probabilities
and relative phase per basis member).

**Shape vocabulary and constants** (nested style, C8; `invSqrt2` constant):

> `QubitState(alpha, beta)` → state `Real[4]` ·
> `QubitAlpha(psi)` / `QubitBeta(psi)` → pair `Real[2]` ·
> constants `Ket0`, `Ket1`, `KetPlus`, `KetMinus`

**Measurement-description views** (computed on demand; since 6 Nov the
quantum.sysml state IS the state vector — `ToAmplitudes` is REMOVED):

> `BornProbabilities(psi)` → `(P(0), P(1))` as `Real[2]` — the Born rule,
> the probability view of a state ·
> `BornProbabilitiesTwoQubit(psi)` → `Real[4]`, register order \|00>..\|11> ·
> `CosRelativePhase(psi)` → cosine of the relative phase (no atan2 exists;
> meaningful only when both Born probabilities are nonzero)

**Inner products** (un-deferred 6 Nov: consumer = basis orthonormality):

> `InnerProduct(psi, phi)` → pair `Real[2]`: <psi|phi> = sum of
> conj(psi_k)·phi_k; zero pair = orthogonal, (1, 0) = normalized self

**Global phase** (C6):

> `TimesI(psi)` — the state multiplied by i

**Checks** (C5):

> `IsNormalised(psi, eps)` / `IsNormalisedTwoQubit(psi, eps)` → `Boolean` ·
> `StatesClose(u, w, eps)` / `StatesCloseTwoQubit(u, w, eps)` → `Boolean` ·
> `ProbabilitiesClose(p, q, eps)` → `Boolean`

**Still queued**: structured `attribute def` retest (needs an
instantiation-syntax probe first); `RelativePhaseDirection`
(deferred — direction pair beta/sqrt(P(1)), only when a consumer appears);
`SameState`/ray equality (deferred, see below).

## Section 8. Using with quantum.sysml (meeting-point contract, 6 Nov)

`Quantum::QuantumState` is now calculation-aligned: its `stateVector`
feature IS the Real[2d] vector the library operates on. Certified
patterns (kernel-evaluated): read `q.quantumState.stateVector` into any
gate/matrix calc; bind a computed view back (`attribute :>> stateVector
= Matrix2x2ComplexTimesState(GateOperations::TMatrix,
beforeGate.quantumState.stateVector)` across timeslices — the evaluated
overwrite). Usage kind: quantum states are declared `state :>> quantumState`
(QuantumState is a state def). Phase asymmetry: probabilities flow both
ways, the phase angle never leaves the vector. Load order: CalculationLibrary.sysml
before quantum.sysml (C10 inline references). The Pilot does not evaluate
constraint satisfaction — the Qubit normalization constraint is
parse-level there; evaluate normalization via `IsNormalised` when needed. **Deferred (designed, no current
consumer)**: `SameState(psi, phi, eps)` — ray-level equality,
`Close(|<psi|phi>|^2, 1.0, eps)`; needed only when a check must ignore
global phase (ray equality per Nielsen-Chuang ch02; its one motivating
case, Y up to global phase, is currently checked at matrix level via
`Matrix2x2ComplexScaledBy`). With it would come `InnerProduct(psi, phi)`
as the reusable building block.

## 6. Evaluation status

All Layer 0 calcs were evaluated on the Pilot 0.63.1 kernel (2026-11-05):
model load, the ten calcs, chained calls, and tolerance overrides — all
green. Exact values are the §3 examples.

| Construct | Status | Evidence |
|---|---|---|
| L0: tuple literals, `#` indexing, `**`, sin/cos/pi, chained fully-qualified calc calls | **validated** | kernel board, 2026-11-05; `ComplexMultiply((0,1),(0,1))` → (−1, 0) |
| L0: Boolean-returning calc (`Close`) | **validated** | `Close(0.9999999999999998,1.0)` → true |
| L0: `default` parameter in a calc def, overridden by caller | **validated** | `Close(1.0,1.05,0.1)` → true |
| L1: computed entry index `#((row-1)*n + column)`, n = 2 and 4, incl. pair positions | **validated** | `Matrix2x2RealEntry(H,2,2)` → −0.70711…; `Matrix4x4RealEntry(CNOT,3,4)` → 1.0; `Matrix2x2ComplexEntry(T,2,2)` → (cos π/4, sin π/4) |
| L1: long explicit bodies (64-term `Matrix4x4RealProduct`) | **validated** | `IsUnitaryMatrix4x4Real(CNOT)` → true; CNOT·CNOT = I → true |
| L1: real-to-complex bridge, tensor product, complex scaling | **validated** | `IsUnitaryMatrix2x2Complex(Matrix2x2RealAsComplex(H))` → true; `TensorProduct(Ket0, Ket1)` = \|01> |
| L1: the gate contract | **validated** | H, X, T, CNOT all `IsUnitary…` → true; H·H = I, T·T = S, CNOT·CNOT = I → true |
| L1: **user-defined operation recipe** | **validated** | `PhaseRotate(pi/4)`: unitarity → true; applied to \|+> → (0.70711, 0, 0.5, 0.5) as predicted |
| L2: shape vocabulary and constants (nested style) | **validated** | `QubitAlpha(Ket1)` = (0, 0); `QubitBeta(Ket1)` = (1, 0); constants flatten correctly from C8 groups |
| L2: the description bridge | **validated** | round trip `StatesClose(ToAmplitudes((0.5,0.5),0.0), KetPlus)` → true; `CosRelativePhase(KetPlus)` = 1.0, on the pi/4-rotated state = cos(pi/4); `BornProbabilitiesTwoQubit` on the Bell state = (0.5, 0, 0, 0.5) |
| L2: checks family | **validated** | `IsNormalised` (1q, 2q) → true; `StatesClose`, `StatesCloseTwoQubit`, `ProbabilitiesClose` → true |
| L2: cross-layer integration | **validated** | **Y = i·(X·Z) at matrix level → true** (`ScaledBy` + complex product); **Bell preparation** CNOT·(H\|0> ⊗ \|0>) = (|00>+|11>)/sqrt(2) → true; columns-equal-action H·\|0> = \|+> → true |
| Gate layer (GateOperations.sysml): verify targets are requirement **usages** | **validated** | `verify <RequirementDef>;` fails resolution ("reference to Feature") for all targets; the 7.24.6 pattern — usage typed by def, verify the usage — loads clean and verifies |
| Gate layer: complex-matrix row-grouping trap | **caught by the checks** | ZMatrix's entry(2,2) initially held -1 in the imaginary slot (that is diag(1, -i), not diag(1, -1)); the Z = T^4-close and Y = i·(X·Z) checks returned false and localized it. In C8 row groups each entry is a (real part, imaginary part) pair — check which slot a negative belongs in |
| Gate layer: Pilot does not flag multiplicity violations on attribute bindings | **known gap** | a 9-element value on a `Real[8]` attribute (the C9 splat) loaded silently; the downstream unitarity and identity checks caught it — the tolerance-check layer is the working safety net |
| Conditional expression `if c ? a else b` (body of `Abs`) | **valid; C-CLI grammar gap** | Pilot evaluated `Abs(-3.0)` → 3.0; Aliot clean; C CLI reports "expected '.', '('" — trust the Pilot per the sysml2-validate triage rules |
| Nested sequence literals | **evaluate, then flatten** | `((1,0),(1,0))` evaluates to the flat 4-sequence (1, 0, 1, 0); multilevel typing `Real[2][2]` is a parse error in Pilot 0.63.1, so no nested structure or double indexing exists — flat carriers (C3) are the language's actual semantics, nested spelling is authoring sugar only (C4) |
| Nested authoring sugar in attribute defaults and calc arguments | **validated** | `H` spelled as two rows → correct row-major `Real[4]`; nested literal as argument flattens and evaluates: `ApplyX(((0,0),(1,0)))` = X·\|1⟩ = \|0> |
| Structured `attribute def` results, chained | **known-broken** | recorded earlier; retest queued for the L2 round |
| `RealFunctions::sum` | **avoid** | returns wrong results (0.0 for (1,2,3)) |
| Tool divergence #4: Aliot RES001 on `attribute :>> stateVector` inside nested `state :>> quantumState` redefinitions | **Pilot is arbiter** | the Pilot loads example.sysml clean and evaluates the bound vectors; Aliot reports "does not exist on the current scope" — trust the Pilot per the sysml2-validate triage rules |
| quantum.sysml load order | **CalculationLibrary first** | quantum.sysml references `CalculationLibrary::ScalarCalc::Close` inline (C10); loading quantum first poisons the session |

## 7. Kernel usage notes (`%eval`)

Learned on the board runs; applies to every future `%eval` round:

1. **No spaces in expressions** — the magic splits arguments on
   whitespace: `Close(1.0, 1.1)` fails with "Too many positional
   arguments"; `Close(1.0,1.1)` evaluates.
2. **Fully qualify every call with its *defining* package** — `%eval`
   evaluates in the root namespace; an unqualified inner call fails
   resolution, and so does a call prefixed with the wrong package (e.g.
   prefixing a library calc with the board package that merely imports
   it). Write `CalculationLibrary::ScalarCalc::...` / `CalculationLibrary::LinCalc::...` on
   every call; arguments defined in a board package take that board
   prefix (`LinCalcBoard::H`).
3. **One session per run** — each notebook execution starts a fresh
   kernel; the model-definition cell must precede the `%eval` cells.
4. **Board packages import `ScalarValues::*` explicitly** — a star
   import of a library package does not re-export the standard types
   (`Real` came back unresolved through `ScalarCalc::*` alone).
5. **Negative zero (`-0.0`) appears from negation** (e.g. `TimesI` on a
   zero component) — harmless: every comparison goes through `Close`
   (C5), and `-0.0 = 0.0` numerically.
6. **Conjunctions cannot be evaluated in one `%eval`** — `A and B`
   requires grammatical spaces, which the magic parser forbids
   (rule 1); evaluate each conjunct in its own cell.
