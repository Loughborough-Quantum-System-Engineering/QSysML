"""QSysML kernel: the Python-side semantic algebra realizing the
kernel-realized calcs of brain_storm.sysml (Defs).

Mapping (B1): model Complex = NATIVE python complex; rect/polar mirror
the standard functions (KerML 9.4.8). Kernel values:
    Vector = tuple of complex          (E-coordinates)
    Matrix = namedtuple(columns)       columns = tuple of Vectors
    Basis  = namedtuple(dimension, members)
    State  = namedtuple(basis, coefficients)   coefficient i <-> members[i]

Layering: the model STATES each property (assert constraints); this
kernel REALIZES it; the contract suite VERIFIES the realization.
Comparisons are tolerance-based (ULP discipline): the model writes
ideal math (cos(pi/4) + i sin(pi/4)), floats are its evaluation.
"""
import math
from collections import namedtuple

Matrix = namedtuple("Matrix", "columns")
Basis = namedtuple("Basis", "dimension members left right",
                   defaults=(None, None))
State = namedtuple("State", "basis coefficients")

TOL = 1e-12          # absolute tolerance for algebraic identities


# ---- the standard complex constructors (mirror KerML 9.4.8) ----

def rect(re, im):
    return complex(re, im)


def polar(magnitude, angle):
    return magnitude * complex(math.cos(angle), math.sin(angle))


# ---- algebra (the column convention) ----

def apply_matrix(U, V):
    """W = U . V = SUM_k U.columns[k] * V.c[k] -- ApplyMatrix."""
    rows = len(U[0])
    W = []
    for i in range(rows):
        acc = 0 + 0j
        for k in range(len(U)):
            acc += U[k][i] * V[k]
        W.append(acc)
    return tuple(W)


def frame_to_E(coefficients, members):
    """psi_E = SUM_i coefficients[i] . members[i] -- ApplyMatrix with the
    basis itself as the matrix (the coordinate map INTO E)."""
    return apply_matrix(members, coefficients)


def reexpress(vector_E, members):
    """coefficients in the basis whose columns are `members`:
    c_i = <member_i | v_E> (conjugate-linear first argument). Valid
    because Basis.orthonormal guarantees members are an orthonormal
    set, so M^-1 = conjugate transpose."""
    c = []
    for col in members:
        acc = 0 + 0j
        for r in range(len(col)):
            acc += col[r].conjugate() * vector_E[r]
        c.append(acc)
    return tuple(c)


def tensor_basis(left, right):
    """Composite basis (TensorBasis): Kronecker member order, position
    p (1-based) = (i-1)*right.dimension + j -- member i of left
    tensored with member j of right. The subsystem cut is queryable
    via left/right (carried on the result)."""
    members = []
    for a in left.members:
        for b in right.members:
            members.append(tuple(x * y for x in a for y in b))
    return Basis(left.dimension * right.dimension, tuple(members),
                 left, right)


def norm_squared(xs):
    return sum(z.real * z.real + z.imag * z.imag for z in xs)


def _inner(a, b):
    return sum(a[r].conjugate() * b[r] for r in range(len(a)))


# ---- the six realized predicates (assert-constraint acceptance) ----

def is_unitary(theColumns, tol=TOL):
    """U . Ut = I in column form: columns pairwise orthonormal."""
    n = len(theColumns)
    for j in range(n):
        if abs(norm_squared(theColumns[j]) - 1.0) > tol:
            return False
        for k in range(j + 1, n):
            if abs(_inner(theColumns[j], theColumns[k])) > tol:
                return False
    return True


def is_orthonormal(theMembers, tol=TOL):
    """<m_j|m_k> = delta_jk for all pairs."""
    return is_unitary(theMembers, tol)


def is_normalised(theCoefficients, tol=TOL):
    """SUM_i |c_i|^2 == 1 (no square root)."""
    return abs(norm_squared(theCoefficients) - 1.0) <= tol


def norms_equal(firstVector, secondVector, tol=TOL):
    return abs(norm_squared(firstVector) - norm_squared(secondVector)) <= tol


def state_norms_equal(firstState, secondState, tol=TOL):
    return norms_equal(firstState.coefficients, secondState.coefficients, tol)


def is_canonical(theCoefficients, tol=TOL):
    """The FIRST nonzero coefficient has im == 0 and re > 0. Every ray
    has exactly one canonical writing, so physical-state equality
    becomes plain structural equality; relative phases preserved."""
    for z in theCoefficients:
        if abs(z) > tol:
            return abs(z.imag) <= tol and z.real > 0
    return True


def canonicalize(theCoefficients, tol=TOL):
    """Rotate the global phase so the first nonzero coefficient is
    real-positive, then snap residue. Constructive-when-possible:
    known lattice results emerge already snapped."""
    first = next((z for z in theCoefficients if abs(z) > tol), None)
    if first is None:
        return tuple(theCoefficients)
    if first.imag == 0.0 and first.real > 0:
        return tuple(theCoefficients)
    rot = first.conjugate() / abs(first)          # e^{-i arg(first)}
    out = []
    for z in theCoefficients:
        w = z * rot
        if abs(w.imag) <= tol:
            w = complex(w.real, 0.0)
        if abs(w) <= tol:
            w = complex(0.0, 0.0)
        out.append(w)
    return tuple(out)


# ---- the flow contract (UnitaryEvolution) ----

def unitary_evolution(operation, psi):
    """phi = operation . psi: frame -> apply -> re-express -> canonicalize.
    The result stays in psi's own frame (sameFrame contract default)."""
    psi_E = frame_to_E(psi.coefficients, psi.basis.members)
    phi_E = apply_matrix(operation, psi_E)
    phi_c = reexpress(phi_E, psi.basis.members)
    return canonicalize(phi_c)


def name_of(vector_E, named, tol=TOL):
    """Ray-match a canonical E-frame vector against named writings.
    Returns the name, or None (anonymous bind -- never force a name)."""
    for name, ref in named.items():
        if len(ref) == len(vector_E) and all(
                abs(a - b) <= tol for a, b in zip(vector_E, ref)):
            return name
    return None


# ---- goldens: the contract suite's kernel layer (self-check) ----

def _goldens():
    s = 1.0 / math.sqrt(2.0)
    H = Matrix(columns=((rect(s, 0), rect(s, 0)),
                        (rect(s, 0), rect(-s, 0))))
    T = Matrix(columns=((rect(1, 0), rect(0, 0)),
                        (rect(0, 0), polar(1.0, math.pi / 4.0))))
    zBasis = Basis(2, (e0 := (rect(1, 0), rect(0, 0)),
                       e1 := (rect(0, 0), rect(1, 0))))
    ONE = State(zBasis, (rect(0, 0), rect(1, 0)))
    PLUS = State(Basis(2, H.columns), (rect(1, 0), rect(0, 0)))
    named = {"zero": frame_to_E((rect(1, 0), rect(0, 0)), zBasis.members),
             "one": frame_to_E(ONE.coefficients, zBasis.members),
             "plus": frame_to_E(PLUS.coefficients, PLUS.basis.members),
             "minus": frame_to_E((rect(0, 0), rect(-1, 0)), H.columns)}

    checks = [
        ("h is unitary", is_unitary(H.columns)),
        ("t is unitary", is_unitary(T.columns)),
        ("zBasis orthonormal", is_orthonormal(zBasis.members)),
        ("one normalised", is_normalised(ONE.coefficients)),
        ("plus normalised", is_normalised(PLUS.coefficients)),
        ("plus canonical", is_canonical(PLUS.coefficients)),
    ]
    phi_one = unitary_evolution(T.columns, ONE)
    checks.append(("T.one canonical == one writing",
                   phi_one == canonicalize(ONE.coefficients)))
    nm_one = name_of(frame_to_E(phi_one, ONE.basis.members), named)
    checks.append(("T.one named 'one'", nm_one == "one"))
    checks.append(("T.one norm preserved",
                   state_norms_equal(State(ONE.basis, phi_one), ONE)))

    phi_plus = unitary_evolution(T.columns, PLUS)
    nm_plus = name_of(frame_to_E(phi_plus, PLUS.basis.members), named)
    checks.append(("T.plus anonymous (no ray match)", nm_plus is None))
    c8, s8 = math.cos(math.pi / 8.0), math.sin(math.pi / 8.0)
    checks.append(("T.plus == cos(pi/8)|+> - i sin(pi/8)|->",
                   all(abs(a - b) <= TOL for a, b in
                       zip(phi_plus, (complex(c8, 0.0), complex(0.0, -s8))))))
    checks.append(("T.plus norm preserved",
                   state_norms_equal(State(PLUS.basis, phi_plus), PLUS)))

    ok = True
    for label, passed in checks:
        print(("PASS  " if passed else "FAIL  ") + label)
        ok = ok and passed
    print("kernel goldens:", "ALL PASS" if ok else "FAILURES")
    return ok


if __name__ == "__main__":
    raise SystemExit(0 if _goldens() else 1)
