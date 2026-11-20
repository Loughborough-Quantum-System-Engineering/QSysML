// General quantum-domain vocabulary: definitions that hold for any
// engineered quantum system, not only quantum computing. Terms and
// meanings come from the Quantum Conceptual Model (BS ISO/IEC 4879),
// referred to only, never re-modelled. Quantum computing specific
// definitions (logical qubit, quantum operation, quantum gate, gate
// sets) live in QuantumComputing.sysml; the gate values, flow
// contracts and scenarios live in GateOperations.sysml.
//
// Package organization (19 Nov, per Kyon's qsysml.sysml draft):
//   Quantum::MathExpression -- the math representation layer (Vector,
//     Matrix, UnitaryMatrix, the kernel-realized predicates,
//     tensorBasis);
//   Quantum::A -- the quantum application types (Basis, TensorBasis,
//     QuantumState) and the z-basis vocabulary (e0/e1/zBasis/zero/one).
// Cross-subpackage references are fully QUALIFIED inline
// (A::QuantumState, MathExpression::Vector) -- project style rule;
// standard libraries keep wildcard imports.
//
// Representation (19 Nov 2026, decisions #65-#88): DECLARATIVE +
// KERNEL-REALIZED. States are complex coefficient vectors relative to
// an explicitly declared basis (dense: coefficient i pairs with
// members[i], 1-based natively). The linear algebra is owned by the
// Python kernel (pytools/kernel.py) through the kernel-realized
// predicates: the model STATES each property, Python REALIZES it, the
// contract suite VERIFIES the realization. Comparisons are
// tolerance-based (ULP discipline): the model writes ideal math.
//
// Superseded 19 Nov (the swap): the 6 Nov calculation-aligned encoding
// (stateVector as Real pairs; Basis.memberVector/memberState;
// BasisState) and Quantum::UnitaryOperator (retyped to
// UnitaryMatrix). Old versions recoverable from git history; the
// pre-restructure file remains archived as archive_quantum.sysml.
// The entanglement vocabulary is COMMENTED OUT below (Kyon: will work
// with it later).

package Quantum {
    private import ScalarValues::*;         // Boolean (predicate results)
    private import CollectionFunctions::*;  // product() (CompositeQuantumSystem)
    private import SequenceFunctions::*;    // size() (Qubit/Qutrit laws)

    item def QuantumSubSystem {
        state quantumState : A::QuantumState;
    }

    item def CompositeQuantumSystem :> QuantumSubSystem {
        doc /* A quantum system that names its subsystems: a composite
               system whose joint description lives on the composite,
               with subsystems referencing the parts wherever they sit
               in the containment tree.
               Source: Nielsen-Chuang sec 1.3.5, composite systems;
               Quantum Conceptual Model (BS ISO/IEC 4879), quantum system. */
        ref item subsystem : QuantumSubSystem[2..*] ordered;
        // dimension law: a composite system's basis dimension is the
        // product of its subsystems' basis dimensions
        constraint { quantumState.basis.dimension == product(subsystem.quantumState.basis.dimension) }
    }

    item def Qubit :> QuantumSubSystem {
        // dimension law: a qubit's basis is 2-dimensional
        constraint { quantumState.basis.dimension == 2 }
        constraint { size(quantumState.coefficients) == 2 }
        // Born normalization (C5) -- kernel-realized (ULP tolerance)
        constraint { MathExpression::isNormalised(quantumState.coefficients) }
    }

    item def Qutrit :> QuantumSubSystem {
        // dimension law: a qutrit's basis is 3-dimensional
        constraint { quantumState.basis.dimension == 3 }
        constraint { size(quantumState.coefficients) == 3 }
        constraint { MathExpression::isNormalised(quantumState.coefficients) }
    }

    // ---------- MathExpression: the math representation layer --------

    package MathExpression {
        private import ScalarValues::*;         // Complex, Boolean
        private import SequenceFunctions::*;    // size() on sequences
        private import ControlFunctions::*;     // ->forAll iterators

        attribute def Vector {
            doc /* raw coordinates in the standard basis E -- the fixed
                 point of the coordinate map: coordinates in E are the
                 vector. */
            attribute c : Complex[1..*] ordered;
        }

        attribute def Matrix {
            doc /* a matrix as its ordered COLUMNS, each a Vector of
                 standard-basis coordinates. column k = image of e_k;
                 M . v = SUM_k columns[k] * v.c[k]. The order is
                 load-bearing: column k corresponds to basis index k. */
            attribute columns : Vector[2..*] ordered;
            assert constraint uniformShape {
                /* every column carries the same coordinate count */
                columns->forAll { in col : Vector;
                    size(col.c) == size((columns#(1)).c) }
            }
        }

        abstract attribute def QuantumOperator {
            doc /* Mathematical description of a quantum operator.
                 Source: Quantum Conceptual Model (BS ISO/IEC 4879). */
        }

        attribute def UnitaryMatrix :> Matrix, QuantumOperator {
            doc /* a square matrix that preserves inner products:
                 U . Ut = I. Its columns ARE an orthonormal basis --
                 every unitary is also a change of basis. Supersedes
                 Quantum::UnitaryOperator (the ISO 4879 concept, kept as
                 a specialization). */
            assert constraint square {
                /* row count == column count */
                size(columns) == size((columns#(1)).c)
            }
            assert constraint unitary {
                /* U . Ut = I -- in column form: the columns are
                   pairwise orthonormal. Algebraic check is
                   kernel-realized (Python owns the linear algebra). */
                isUnitary(columns)
            }
        }

        // ---------- kernel-realized predicates --------------------------
        // CONSTRAINT LAYERING: structural checks (sizes, ranges, frame
        // identity) are model-expressed inline; LINEAR-ALGEBRAIC checks
        // are delegated to these predicates -- the model states the
        // property, Python (pytools/kernel.py, via the M2M binding)
        // owns the math, and the contract suite verifies each
        // realization on the goldens.

        calc def isUnitary {
            doc /* true iff U . Ut = I: columns pairwise orthonormal
                 (diagonal <c_j|c_j> = 1; off-diagonal <c_j|c_k> = 0,
                 both parts). */
            in theColumns : Vector[2..*] ordered;
            return result : Boolean;
        }

        calc def isOrthonormal {
            doc /* true iff <m_j|m_k> = delta_jk for all pairs. */
            in theMembers : Vector[2..*] ordered;
            return result : Boolean;
        }

        calc def isNormalised {
            doc /* true iff SUM_i |theCoefficients[i]|^2 == 1
                 (no square root -- exactness-friendly). */
            in theCoefficients : Complex[2..*] ordered;
            return result : Boolean;
        }

        calc def normsEqual {
            doc /* true iff ||firstVector||^2 == ||secondVector||^2 --
                 unitarity's norm preservation on arbitrary
                 (unnormalized) vectors. */
            in firstVector : Vector;
            in secondVector : Vector;
            return result : Boolean;
        }

        calc def stateNormsEqual {
            doc /* true iff the two states carry equal coefficient
                 norms -- frame-invariant (basis change preserves it). */
            in firstState : A::QuantumState;
            in secondState : A::QuantumState;
            return result : Boolean;
        }

        calc def isCanonical {
            doc /* true iff the FIRST nonzero coefficient (in position
                 order) has re > 0 and im == 0 -- the ray convention
                 that makes state writing deterministic. Every ray has
                 exactly one canonical writing, so physical-state
                 equality becomes plain structural equality. Relative
                 phases are preserved (only the unobservable global
                 phase is fixed). */
            in theCoefficients : Complex[2..*] ordered;
            return result : Boolean;
        }

        calc def tensorBasis {
            doc /* the composite basis of two factor bases: dimension =
                 left.dimension * right.dimension; members ordered
                 Kronecker-style, position p (1-based) = (i-1) *
                 right.dimension + j -- member i of left tensored with
                 member j of right. Kernel-realized; the result is an
                 A::TensorBasis, so the subsystem cut is queryable. */
            in left : A::Basis;
            in right : A::Basis;
            return b : A::TensorBasis;
        }
    }

    // ---------- A: the quantum application types ----------------------

    package A {
        private import ScalarValues::*;         // Complex
        private import ComplexFunctions::*;     // rect (9.4.8)
        private import SequenceFunctions::*;    // size() on sequences
        private import ControlFunctions::*;     // ->forAll iterators

        attribute def Basis {
            doc /* the frame for interpreting QuantumState.coefficients:
                 the coefficient at position i pairs with members[i].
                 Linear-algebraically: an ordered set of member vectors
                 spanning the state space; orthonormality is the quantum
                 refinement (asserted -- measurement/Born requires it). */
            attribute dimension : Integer;
            attribute members : MathExpression::Vector[2..*] ordered;
            assert constraint dimensionMatch {
                doc /* size(members) == dimension -- a basis that
                     disagrees with its own declared dimension is
                     invalid. */
                size(members) == dimension
            }
            assert constraint memberCoherent {
                doc /* every member actually lives in the declared
                     dimension. */
                members->forAll { in m : MathExpression::Vector;
                    size(m.c) == dimension }
            }
            assert constraint orthonormal {
                /* <m_j|m_k> = delta_jk (orthonormality implies linear
                   independence, so no separate det check). Algebraic
                   check is kernel-realized. */
                MathExpression::isOrthonormal(members)
            }
        }

        attribute def TensorBasis :> Basis {
            doc /* a basis PROVEN to be the tensor product of two factor
                 bases -- the subsystem cut is queryable data, not a
                 convention. Position p (1-based) = (i-1) *
                 right.dimension + j: member i of left tensored with
                 member j of right. Produced by
                 MathExpression::tensorBasis. */
            attribute left : Basis;
            attribute right : Basis;
            assert constraint dimensionLaw {
                dimension == left.dimension * right.dimension
            }
        }

        attribute def QuantumState {
            doc /* psi = SUM_i coefficients[i] . basis.members[i] -- the
                 coefficient at position i pairs with basis.members[i]
                 (1-based natively on both sides); dense form: every
                 member carries a coefficient, zeros explicit. Identity
                 is the RAY convention (see
                 MathExpression::isCanonical): two writings of one
                 state are equal up to global phase. Source:
                 Nielsen-Chuang sec 1.2. */
            attribute basis : Basis;
            attribute coefficients : Complex[2..*] ordered;
            assert constraint sizeCoherent {
                doc /* size(coefficients) == basis.dimension -- the
                     state spans its declared frame completely (dense
                     form). */
                size(coefficients) == basis.dimension
            }
            /* no wellFormed constraint: positions cannot be duplicated
               or out of range -- the failures it guarded against are
               structurally impossible without an index field. */
            assert constraint normalised {
                /* SUM |c_i|^2 == 1 -- algebraic check is
                   kernel-realized. */
                MathExpression::isNormalised(coefficients)
            }
            assert constraint canonical {
                /* first nonzero coefficient real-positive (ray
                   convention) -- positional logic is kernel-realized. */
                MathExpression::isCanonical(coefficients)
            }
            // entanglement vocabulary COMMENTED OUT 19 Nov (Kyon: will
            // need to work with it later):
            // attribute entanglement : Entanglement[0..*];
        }

        // ---------- the z and x basis vocabulary (general) ---------------

        attribute e0 : MathExpression::Vector {
            :>> c = (rect(1.0, 0.0), rect(0.0, 0.0));
        }

        attribute e1 : MathExpression::Vector {
            :>> c = (rect(0.0, 0.0), rect(1.0, 0.0));
        }

        attribute h1 : MathExpression::Vector {
            :>> c = (rect(1 / sqrt(2), 0.0), rect(1 / sqrt(2), 0.0));
        }

        attribute h2 : MathExpression::Vector {
            :>> c = (rect(1 / sqrt(2), 0.0), rect(-1 / sqrt(2), 0.0));
        }

        attribute zBasis : Basis {
            :>> dimension = 2;
            :>> members = (e0, e1);
        }

        attribute xBasis : Basis {
            :>> dimension = 2;
            :>> members = (h1, h2);
        }

        attribute zero : QuantumState {
            :>> basis = zBasis;
            :>> coefficients = (rect(1.0, 0.0), rect(0.0, 0.0));
        }

        attribute one : QuantumState {
            :>> basis = zBasis;
            :>> coefficients = (rect(0.0, 0.0), rect(1.0, 0.0));
        }

        attribute plus : QuantumState {
            :>> basis = xBasis;
            :>> coefficients = (rect(1.0, 0.0), rect(0.0, 0.0));
        }

        attribute minus : QuantumState {
            :>> basis = xBasis;
            :>> coefficients = (rect(0.0, 0.0), rect(1.0, 0.0));
        }
    }

    // abstract state def BasisState -- COMMENTED OUT 19 Nov (the swap):
    // basis membership is positional (Basis.members); no member type.

    // attribute def Entanglement -- COMMENTED OUT 19 Nov (Kyon: will
    // need to work with it later). Recoverable from git history / QC
    // modelling decisions 2026-11-18.md:
    //   ref item spannedSubsystems : QuantumSubSystem[0..*] ordered;
    //   attribute entangled : Boolean;
    //   constraint { size(spannedSubsystems) >= 2 or entangled == false }
}
