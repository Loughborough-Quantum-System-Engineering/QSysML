// Gate operations for the universal gate set {H, T, CNOT}, described as
// SysML v2 calculations. This file supersedes the archived version
// (archive/Use_Case_QC/GateOperations.sysml): the gate descriptions move
// from prose and hand-written case usages to machine-checkable
// requirements on an evaluated calculation substrate.
//
// Architecture (gates as data, services as generic calculations):
//   1. Each gate is a matrix constant in nested spelling (convention C8,
//      exact expressions, convention C7).
//   2. Gates derived from the universal set (Z, X, Y) are checked against
//      their canonical matrices by requirements, not asserted in prose.
//   3. All identities and gate actions are requirement definitions over
//      the CalculationLibrary layers (complex pairs, matrices, states),
//      compared within tolerance (convention C5, never ==).
//   4. A verification case groups the requirements.
// Full conventions and evaluation status: CalculationLibrary.md.
// The relation to the action-level ontology (QuantumComputing::
// quantumOperationDefinitions::QuantumGate) is recorded in the doc of
// each gate; wiring that specialization back in is a follow-up decision.

package GateOperations {
    private import ScalarValues::*;
    private import TrigFunctions::*;

    // ---- the gate set as data ------------------------------------------
    // Complex matrices are Real[8]: four (real part, imaginary part)
    // entry pairs, row-major; nested groups are rows (convention C8).

    attribute HadamardMatrix : Real[4] ordered nonunique =
        ((CalculationLibrary::QuantumStateCalc::invSqrt2,  CalculationLibrary::QuantumStateCalc::invSqrt2),
         (CalculationLibrary::QuantumStateCalc::invSqrt2, -CalculationLibrary::QuantumStateCalc::invSqrt2));

    // T = diag(1, e^{i pi/4}): adds pi/4 to the relative phase.
    // Built with the constructor: a call result may be a direct argument,
    // but splats if nested inside a larger tuple literal (convention C9).
    // Source: Qiskit Textbook, ch01; Nielsen-Chuang sec 4.2.
    attribute TMatrix : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2Complex((1.0, 0.0), (0.0, 0.0), (0.0, 0.0),
            CalculationLibrary::ScalarCalc::ComplexExpI(pi / 4.0));

    // Controlled-NOT, control = first register qubit: the |10> and |11>
    // amplitudes swap. Source: Qiskit Textbook, ch02.
    attribute CNOTMatrix : Real[16] ordered nonunique =
        ((1.0, 0.0, 0.0, 0.0),
         (0.0, 1.0, 0.0, 0.0),
         (0.0, 0.0, 0.0, 1.0),
         (0.0, 0.0, 1.0, 0.0));

    // Canonical Pauli matrices - the targets the derived-gate requirements
    // check against (convention C8 groups are rows; each entry of a
    // Real[8] matrix is a (real part, imaginary part) pair).

    attribute ZMatrix : Real[8] ordered nonunique =
        ((1.0, 0.0,  0.0,  0.0),
         (0.0, 0.0, -1.0,  0.0));

    attribute XMatrix : Real[8] ordered nonunique =
        ((0.0, 0.0,  1.0, 0.0),
         (1.0, 0.0,  0.0, 0.0));

    attribute YMatrix : Real[8] ordered nonunique =
        ((0.0, 0.0,  0.0, -1.0),
         (0.0, 1.0,  0.0,  0.0));

    // ---- gates derived from the universal set --------------------------
    // T^4 and T^8, the powers the identity requirements consume.

    attribute TMatrixFourthPower : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(TMatrix,
            CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(TMatrix,
                CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(TMatrix, TMatrix)));

    attribute TMatrixEighthPower : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(TMatrixFourthPower, TMatrixFourthPower);

    // ---- the unitarity contract ----------------------------------------
    // A quantum gate is a unitary operator; every matrix of the set is
    // checked (Source: Nielsen-Chuang sec 2.1.8, sec 4.1).

    requirement def HadamardMatrixIsUnitary {
        require constraint { CalculationLibrary::LinCalc::IsUnitaryMatrix2x2Real(HadamardMatrix) }
    }

    requirement def TMatrixIsUnitary {
        require constraint { CalculationLibrary::LinCalc::IsUnitaryMatrix2x2Complex(TMatrix) }
    }

    requirement def CNOTMatrixIsUnitary {
        require constraint { CalculationLibrary::LinCalc::IsUnitaryMatrix4x4Real(CNOTMatrix) }
    }

    // ---- identities of the gate set -------------------------------------

    requirement def HadamardSelfInverse {
        doc /* H . H = I. */
        require constraint {
            CalculationLibrary::LinCalc::Matrix2x2RealClose(
                CalculationLibrary::LinCalc::Matrix2x2RealProduct(HadamardMatrix, HadamardMatrix),
                CalculationLibrary::LinCalc::IdentityMatrix2x2Real)
        }
    }

    requirement def TEighthPowerIsIdentity {
        doc /* T^8 = I; S = T^2 and Z = T^4 follow by construction below. */
        require constraint {
            CalculationLibrary::LinCalc::Matrix2x2ComplexClose(TMatrixEighthPower,
                CalculationLibrary::LinCalc::IdentityMatrix2x2Complex)
        }
    }

    requirement def ZIsTFourthPower {
        doc /* Z = T^4, exact: T^4 = diag(1, e^{i pi}) = diag(1, -1). */
        require constraint {
            CalculationLibrary::LinCalc::Matrix2x2ComplexClose(TMatrixFourthPower, ZMatrix)
        }
    }

    requirement def XIsHTFourthH {
        doc /* X = H . T^4 . H, realized from the universal set. */
        require constraint {
            CalculationLibrary::LinCalc::Matrix2x2ComplexClose(
                CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(
                    CalculationLibrary::LinCalc::Matrix2x2RealAsComplex(HadamardMatrix),
                    CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(TMatrixFourthPower,
                        CalculationLibrary::LinCalc::Matrix2x2RealAsComplex(HadamardMatrix))),
                XMatrix)
        }
    }

    requirement def YUpToGlobalPhase {
        doc /* Y = i . (X . Z): the composition of the realized gates
               equals the canonical Y up to the global phase i, stated
               exactly at matrix level (convention C6). X and Z are
               already complex matrices, so they enter the product
               directly. */
        require constraint {
            CalculationLibrary::LinCalc::Matrix2x2ComplexClose(
                CalculationLibrary::LinCalc::Matrix2x2ComplexScaledBy((0.0, 1.0),
                    CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(XMatrix, ZMatrix)),
                YMatrix)
        }
    }

    requirement def YSquareIsIdentity {
        require constraint {
            CalculationLibrary::LinCalc::Matrix2x2ComplexClose(
                CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(YMatrix, YMatrix),
                CalculationLibrary::LinCalc::IdentityMatrix2x2Complex)
        }
    }

    requirement def CNOTSelfInverse {
        doc /* CNOT . CNOT = I. */
        require constraint {
            CalculationLibrary::LinCalc::Matrix4x4RealClose(
                CalculationLibrary::LinCalc::Matrix4x4RealProduct(CNOTMatrix, CNOTMatrix),
                CalculationLibrary::LinCalc::IdentityMatrix4x4Real)
        }
    }

    // ---- gate actions on basis states ------------------------------------
    // The checked truth-table view: matrix action on the basis states.

    requirement def HadamardInterchangesBasisStates {
        doc /* H maps |0> to |+> and |1> to |->: it interchanges the
               computational (z) and x basis views.
               Source: Qiskit Textbook, ch01. */
        require constraint {
            CalculationLibrary::QuantumStateCalc::StatesClose(
                CalculationLibrary::LinCalc::Matrix2x2RealTimesState(HadamardMatrix, CalculationLibrary::QuantumStateCalc::Ket0), CalculationLibrary::QuantumStateCalc::KetPlus) and
            CalculationLibrary::QuantumStateCalc::StatesClose(
                CalculationLibrary::LinCalc::Matrix2x2RealTimesState(HadamardMatrix, CalculationLibrary::QuantumStateCalc::Ket1), CalculationLibrary::QuantumStateCalc::KetMinus)
        }
    }

    requirement def TAdvancesRelativePhase {
        doc /* T leaves |0> unchanged and maps |+> to the state with Born
               probabilities (0.5, 0.5) and relative phase pi/4 - built
               here with the L2 bridge. On basis states T is a global
               phase only, invisible in the description. */
        require constraint {
            CalculationLibrary::QuantumStateCalc::StatesClose(
                CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(TMatrix, CalculationLibrary::QuantumStateCalc::Ket0), CalculationLibrary::QuantumStateCalc::Ket0) and
            CalculationLibrary::QuantumStateCalc::StatesClose(
                CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(TMatrix, CalculationLibrary::QuantumStateCalc::KetPlus),
                CalculationLibrary::QuantumStateCalc::ToAmplitudes((0.5, 0.5), pi / 4.0))
        }
    }

    requirement def CNOTFlipsTargetOnBasisControl {
        doc /* Control |1>, target |0> -> |11>; reversible classical
               logic on basis states.
               Source: Qiskit Textbook, ch02. */
        require constraint {
            CalculationLibrary::QuantumStateCalc::StatesCloseTwoQubit(
                CalculationLibrary::LinCalc::Matrix4x4RealTimesState(CNOTMatrix,
                    CalculationLibrary::LinCalc::TensorProduct(CalculationLibrary::QuantumStateCalc::Ket1, CalculationLibrary::QuantumStateCalc::Ket0)),
                CalculationLibrary::LinCalc::TensorProduct(CalculationLibrary::QuantumStateCalc::Ket1, CalculationLibrary::QuantumStateCalc::Ket1))
        }
    }

    // ---- the two-qubit scenarios of the set -------------------------------

    requirement def BellPreparationFromTheGateSet {
        doc /* CNOT after H on the control prepares Bell Phi+ =
               (|00> + |11>)/sqrt(2): the entangling scenario. */
        require constraint {
            CalculationLibrary::QuantumStateCalc::StatesCloseTwoQubit(
                CalculationLibrary::LinCalc::Matrix4x4RealTimesState(CNOTMatrix,
                    CalculationLibrary::LinCalc::TensorProduct(
                        CalculationLibrary::LinCalc::Matrix2x2RealTimesState(HadamardMatrix, CalculationLibrary::QuantumStateCalc::Ket0),
                        CalculationLibrary::QuantumStateCalc::Ket0)),
                ((CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0), (0.0, 0.0),
                 (0.0, 0.0), (CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0)))
        }
    }

    requirement def PhaseKickbackOnXEigenstateTarget {
        doc /* CNOT with the target in |-> (an X eigenstate): the joint
               state is unchanged and the control's phase flips |+> to
               |-> - the phase kickback, product throughout.
               Source: Qiskit Textbook, ch02. */
        require constraint {
            CalculationLibrary::QuantumStateCalc::StatesCloseTwoQubit(
                CalculationLibrary::LinCalc::Matrix4x4RealTimesState(CNOTMatrix,
                    CalculationLibrary::LinCalc::TensorProduct(CalculationLibrary::QuantumStateCalc::KetPlus, CalculationLibrary::QuantumStateCalc::KetMinus)),
                CalculationLibrary::LinCalc::TensorProduct(CalculationLibrary::QuantumStateCalc::KetMinus, CalculationLibrary::QuantumStateCalc::KetMinus))
        }
    }

    // ---- the description bridge -------------------------------------------
    // What a measurement description sees: Born probabilities per basis
    // member (convention C6: relative phase only through CosRelativePhase).

    requirement def TLeavesBornProbabilitiesUnchanged {
        doc /* T on |+>: both Born probabilities stay (0.5, 0.5) - T acts
               on the phase, invisible to measurement on this input. */
        require constraint {
            CalculationLibrary::QuantumStateCalc::ProbabilitiesClose(
                CalculationLibrary::QuantumStateCalc::BornProbabilities(
                    CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(TMatrix, CalculationLibrary::QuantumStateCalc::KetPlus)),
                (0.5, 0.5))
        }
    }

    requirement def TVisibleThroughInterference {
        doc /* H . T . H on |0>: the phase T planted becomes visible
               through the second Hadamard - P(0) = (1 + cos(pi/4))/2 =
               (1 + 1/sqrt(2))/2, about 0.854, versus 1 without T. */
        require constraint {
            CalculationLibrary::QuantumStateCalc::ProbabilitiesClose(
                CalculationLibrary::QuantumStateCalc::BornProbabilities(
                    CalculationLibrary::LinCalc::Matrix2x2RealTimesState(HadamardMatrix,
                        CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(TMatrix,
                            CalculationLibrary::LinCalc::Matrix2x2RealTimesState(HadamardMatrix, CalculationLibrary::QuantumStateCalc::Ket0)))),
                ((1.0 + CalculationLibrary::QuantumStateCalc::invSqrt2) / 2.0, (1.0 - CalculationLibrary::QuantumStateCalc::invSqrt2) / 2.0))
        }
    }

    // ---- requirement usages (the verification targets) --------------------
    // The Pilot resolves verify targets as requirement usages (SysML v2
    // 7.24.6); each usage is typed by its definition above.

    requirement hadamardMatrixIsUnitary : HadamardMatrixIsUnitary;
    requirement tMatrixIsUnitary : TMatrixIsUnitary;
    requirement cnotMatrixIsUnitary : CNOTMatrixIsUnitary;
    requirement hadamardSelfInverse : HadamardSelfInverse;
    requirement tEighthPowerIsIdentity : TEighthPowerIsIdentity;
    requirement zIsTFourthPower : ZIsTFourthPower;
    requirement xIsHTFourthH : XIsHTFourthH;
    requirement yUpToGlobalPhase : YUpToGlobalPhase;
    requirement ySquareIsIdentity : YSquareIsIdentity;
    requirement cnotSelfInverse : CNOTSelfInverse;
    requirement hadamardInterchangesBasisStates : HadamardInterchangesBasisStates;
    requirement tAdvancesRelativePhase : TAdvancesRelativePhase;
    requirement cnotFlipsTargetOnBasisControl : CNOTFlipsTargetOnBasisControl;
    requirement bellPreparationFromTheGateSet : BellPreparationFromTheGateSet;
    requirement phaseKickbackOnXEigenstateTarget : PhaseKickbackOnXEigenstateTarget;
    requirement tLeavesBornProbabilitiesUnchanged : TLeavesBornProbabilitiesUnchanged;
    requirement tVisibleThroughInterference : TVisibleThroughInterference;

    // ---- verification case --------------------------------------------------

    verification def GateSetVerification {
        doc /* Verification case grouping the gate-set checks. Method:
               analysis - the requirements are evaluated calculations
               (SysML v2 7.24); the verdict is pass when every verified
               requirement holds within eps = 1.0E-9 (convention C5). */
        objective {
            verify hadamardMatrixIsUnitary;
            verify tMatrixIsUnitary;
            verify cnotMatrixIsUnitary;
            verify hadamardSelfInverse;
            verify tEighthPowerIsIdentity;
            verify zIsTFourthPower;
            verify xIsHTFourthH;
            verify yUpToGlobalPhase;
            verify ySquareIsIdentity;
            verify cnotSelfInverse;
            verify hadamardInterchangesBasisStates;
            verify tAdvancesRelativePhase;
            verify cnotFlipsTargetOnBasisControl;
            verify bellPreparationFromTheGateSet;
            verify phaseKickbackOnXEigenstateTarget;
            verify tLeavesBornProbabilitiesUnchanged;
            verify tVisibleThroughInterference;
        }
    }

    verification gateSetChecks : GateSetVerification;
}
