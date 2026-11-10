// Gate operations for the universal gate set {H, T, CNOT}: gates as
// matrix data (C8, C7). This set is all the data there is — everything
// else in quantum computing is generated from it (S = T^2, Z = T^4,
// X = H T^4 H, Y = i X Z): the live generations are demonstrated in
// StateComputationExamples.sysml. Requirements/verification: removed
// 6 Nov (decision #36), preserved in PhD/QSysML/GateOperations
// requirements snapshot 2026-11-06.md. Full record: CalculationLibrary.md.

package GateOperations {
    private import ScalarValues::*;
    private import TrigFunctions::*;

    // H: interchanges the z and x basis views.
    // Source: Qiskit Textbook, ch01.
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
}
