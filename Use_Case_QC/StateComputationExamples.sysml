// Worked example: every CalculationLibrary computation applied to one
// quantum state. The state under study is psi = (3/5)|0> + (4i/5)|1>:
// both Born probabilities nonzero, genuinely imaginary, normalized
// (9/25 + 16/25 = 1), relative phase pi/2. Every attribute below is an
// evaluated binding (conventions C1-C10; record: CalculationLibrary.md).

package StateComputationExamples {
    private import ScalarValues::*;
    private import TrigFunctions::*;

    // ---- the state under study ------------------------------------------

    attribute theState : Real[4] ordered nonunique =
        ((3.0 / 5.0, 0.0), (0.0, 4.0 / 5.0));

    // ---- L2 shape vocabulary ---------------------------------------------

    attribute stateViaConstructor : Real[4] ordered nonunique =
        CalculationLibrary::QuantumStateCalc::QubitState(
            (3.0 / 5.0, 0.0), (0.0, 4.0 / 5.0));                  // == theState

    attribute stateAlpha : Real[2] ordered nonunique =
        CalculationLibrary::QuantumStateCalc::QubitAlpha(theState);   // (0.6, 0)

    attribute stateBeta : Real[2] ordered nonunique =
        CalculationLibrary::QuantumStateCalc::QubitBeta(theState);    // (0, 0.8)

    // ---- L0 scalar and pair computations on the state's parts ------------

    attribute betaSquared : Real =
        CalculationLibrary::ScalarCalc::ComplexAbsSquared(
            CalculationLibrary::QuantumStateCalc::QubitBeta(theState));   // 0.64: the Born rule by hand

    attribute betaConjugate : Real[2] ordered nonunique =
        CalculationLibrary::ScalarCalc::ComplexConjugate(
            CalculationLibrary::QuantumStateCalc::QubitBeta(theState));   // (0, -0.8)

    attribute betaTimesTwo : Real[2] ordered nonunique =
        CalculationLibrary::ScalarCalc::ComplexScale(2.0,
            CalculationLibrary::QuantumStateCalc::QubitBeta(theState));   // (0, 1.6)

    attribute alphaPlusBeta : Real[2] ordered nonunique =
        CalculationLibrary::ScalarCalc::ComplexAdd(
            CalculationLibrary::QuantumStateCalc::QubitAlpha(theState),
            CalculationLibrary::QuantumStateCalc::QubitBeta(theState));   // (0.6, 0.8)

    attribute alphaMinusBeta : Real[2] ordered nonunique =
        CalculationLibrary::ScalarCalc::ComplexSubtract(
            CalculationLibrary::QuantumStateCalc::QubitAlpha(theState),
            CalculationLibrary::QuantumStateCalc::QubitBeta(theState));   // (0.6, -0.8)

    attribute alphaTimesBeta : Real[2] ordered nonunique =
        CalculationLibrary::ScalarCalc::ComplexMultiply(
            CalculationLibrary::QuantumStateCalc::QubitAlpha(theState),
            CalculationLibrary::QuantumStateCalc::QubitBeta(theState));   // (0, 0.48)

    attribute betaPhaseDirection : Real[2] ordered nonunique =
        CalculationLibrary::ScalarCalc::ComplexExpI(pi / 2.0);        // (0, 1): the direction of beta

    attribute amplitudeMagnitude : Real =
        CalculationLibrary::ScalarCalc::Sqrt(
            CalculationLibrary::QuantumStateCalc::BornProbabilities(theState)#(1));   // 0.6 = real part of alpha

    attribute stateNorm : Real =
        CalculationLibrary::ScalarCalc::Sqrt(
            CalculationLibrary::ScalarCalc::ComplexAbsSquared(
                CalculationLibrary::QuantumStateCalc::QubitAlpha(theState)) +
            CalculationLibrary::ScalarCalc::ComplexAbsSquared(
                CalculationLibrary::QuantumStateCalc::QubitBeta(theState)));  // 1.0

    attribute normIsOne : Boolean =
        CalculationLibrary::ScalarCalc::Close(stateNorm, 1.0);        // true

    // ---- L2 measurement-description views ---------------------------------

    attribute bornView : Real[2] ordered nonunique =
        CalculationLibrary::QuantumStateCalc::BornProbabilities(theState);   // (0.36, 0.64)

    attribute bornViewChecked : Boolean =
        CalculationLibrary::QuantumStateCalc::ProbabilitiesClose(bornView,
            (9.0 / 25.0, 16.0 / 25.0));                               // true

    attribute normalised : Boolean =
        CalculationLibrary::QuantumStateCalc::IsNormalised(theState);  // true

    attribute cosRelativePhase : Real =
        CalculationLibrary::QuantumStateCalc::CosRelativePhase(theState);   // 0.0 (phi = pi/2)

    attribute globalPhaseI : Real[4] ordered nonunique =
        CalculationLibrary::QuantumStateCalc::TimesI(theState);       // i . psi: same physics, carried phase

    attribute selfInnerProduct : Real[2] ordered nonunique =
        CalculationLibrary::QuantumStateCalc::InnerProduct(theState, theState);   // (1, 0): normalized

    // ---- L1: gate matrices applying to the state (real path) --------------

    attribute afterHadamard : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2RealTimesState(
            GateOperations::HadamardMatrix, theState);                // ((0.18, 0.32), (0.18, -0.32)) pairs

    attribute afterHadamardBorn : Real[2] ordered nonunique =
        CalculationLibrary::QuantumStateCalc::BornProbabilities(afterHadamard);   // (0.1352, 0.8648)

    attribute hadamardTwice : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2RealTimesState(
            GateOperations::HadamardMatrix, afterHadamard);

    attribute hadamardIsInvolution : Boolean =
        CalculationLibrary::QuantumStateCalc::StatesClose(hadamardTwice, theState);   // true: H . H = I on a general state

    attribute hadamardUnitary : Boolean =
        CalculationLibrary::LinCalc::IsUnitaryMatrix2x2Real(
            GateOperations::HadamardMatrix);                          // true: the gate contract

    // ---- gates generated from the universal set ---------------------------
    // The set {H, T, CNOT} is all the data: S, Z, X, Y are computed from
    // it, live. Z = T^4; X = H . T^4 . H; Y = i . (X . Z).

    attribute zGenerated : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(
            GateOperations::TMatrix,
            CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(
                GateOperations::TMatrix,
                CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(
                    GateOperations::TMatrix, GateOperations::TMatrix)));

    attribute xGenerated : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(
            CalculationLibrary::LinCalc::Matrix2x2RealAsComplex(GateOperations::HadamardMatrix),
            CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(zGenerated,
                CalculationLibrary::LinCalc::Matrix2x2RealAsComplex(GateOperations::HadamardMatrix)));

    attribute yGenerated : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexScaledBy((0.0, 1.0),
            CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(xGenerated, zGenerated));

    attribute zCanonical : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2Complex((1.0, 0.0), (0.0, 0.0),
            (0.0, 0.0), (-1.0, 0.0));

    attribute zEqualsTFourth : Boolean =
        CalculationLibrary::LinCalc::Matrix2x2ComplexClose(zGenerated, zCanonical);   // true

    // ---- L1: gate matrices applying to the state (complex path) -----------

    attribute afterT : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(
            GateOperations::TMatrix, theState);                       // beta rotated by pi/4: (-0.2828..., 0.5657...)

    attribute afterTThenH : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(
            GateOperations::TMatrix, afterHadamard);                  // composition by chaining calls

    attribute afterX : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(
            xGenerated, theState);                                    // (0, 0.8) on member 1

    attribute afterY : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(
            yGenerated, theState);                                    // (-0.8, 0) on member 1

    attribute afterZ : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexTimesState(
            zGenerated, theState);                                    // beta sign-flipped: (0, -0.8)

    // ---- L1: matrix-level computations around the state --------------------

    attribute hadamardEntry : Real =
        CalculationLibrary::LinCalc::Matrix2x2RealEntry(
            GateOperations::HadamardMatrix, 1, 2);                    // invSqrt2

    attribute hadamardTransposed : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2RealTranspose(
            GateOperations::HadamardMatrix);                          // H is symmetric: == H

    attribute hadamardSquared : Real[4] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2RealProduct(
            GateOperations::HadamardMatrix, GateOperations::HadamardMatrix);

    attribute hadamardSquaredIsIdentity : Boolean =
        CalculationLibrary::LinCalc::Matrix2x2RealClose(hadamardSquared,
            CalculationLibrary::LinCalc::IdentityMatrix2x2Real);      // true

    attribute hadamardAsComplex : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2RealAsComplex(
            GateOperations::HadamardMatrix);

    attribute tEntry : Real[2] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexEntry(
            GateOperations::TMatrix, 2, 2);                           // (cos pi/4, sin pi/4)

    attribute tDagger : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexConjugateTranspose(
            GateOperations::TMatrix);                                 // diag(1, e^{-i pi/4})

    attribute tScaledByI : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix2x2ComplexScaledBy((0.0, 1.0),
            GateOperations::TMatrix);

    attribute tUnitary : Boolean =
        CalculationLibrary::LinCalc::IsUnitaryMatrix2x2Complex(
            GateOperations::TMatrix);                                 // true

    attribute ySquaredIsIdentity : Boolean =
        CalculationLibrary::LinCalc::Matrix2x2ComplexClose(
            CalculationLibrary::LinCalc::Matrix2x2ComplexProduct(
                yGenerated, yGenerated),
            CalculationLibrary::LinCalc::IdentityMatrix2x2Complex);   // true

    // ---- L1/L2: two-qubit computations on a composite state -----------------

    attribute twoQubitState : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::TensorProduct(theState,
            CalculationLibrary::QuantumStateCalc::Ket0);              // psi (x) |0>: (0.6,0),(0,0),(0,0.8),(0,0)

    attribute twoQubitNormalised : Boolean =
        CalculationLibrary::QuantumStateCalc::IsNormalisedTwoQubit(twoQubitState);   // true

    attribute twoQubitAfterCNOT : Real[8] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix4x4RealTimesState(
            GateOperations::CNOTMatrix, twoQubitState);               // (0.6,0),(0,0),(0,0),(0,0.8): entangled

    attribute twoQubitBorn : Real[4] ordered nonunique =
        CalculationLibrary::QuantumStateCalc::BornProbabilitiesTwoQubit(twoQubitAfterCNOT);   // (0.36, 0, 0, 0.64)

    attribute twoQubitEntangled : Boolean =
        CalculationLibrary::QuantumStateCalc::ProbabilitiesClose(twoQubitBorn,
            (9.0 / 25.0, 0.0, 0.0, 16.0 / 25.0));                     // true: Bell-like correlations

    attribute cnotUnitary : Boolean =
        CalculationLibrary::LinCalc::IsUnitaryMatrix4x4Real(
            GateOperations::CNOTMatrix);                              // true

    attribute cnotEntry : Real =
        CalculationLibrary::LinCalc::Matrix4x4RealEntry(
            GateOperations::CNOTMatrix, 3, 4);                        // 1.0

    attribute cnotTransposed : Real[16] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix4x4RealTranspose(
            GateOperations::CNOTMatrix);

    attribute cnotSquared : Real[16] ordered nonunique =
        CalculationLibrary::LinCalc::Matrix4x4RealProduct(
            GateOperations::CNOTMatrix, GateOperations::CNOTMatrix);

    attribute cnotSelfInverse : Boolean =
        CalculationLibrary::LinCalc::Matrix4x4RealClose(cnotSquared,
            CalculationLibrary::LinCalc::IdentityMatrix4x4Real);      // true
}
