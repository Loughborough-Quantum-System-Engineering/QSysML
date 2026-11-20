// Gate operations: the QC gate vocabulary (h, t, cnot), the derived x
// basis, the famous x-basis member states, the kernel-realized flow
// contracts (UnitaryEvolution, ApplyMatrix), and the certified
// scenarios. Decisions #65-#89 (QC modelling decisions 2026-11-18/19).
//
// Style: references to Quantum are FULLY QUALIFIED inline (project
// style rule) -- no wildcard import of user libraries.
//
// Superseded 19 Nov (the swap): the Real-tuple matrices
// (HadamardMatrix/TMatrix/CNOTMatrix -- CNOT's data lives on as
// `cnot`), the ToolExecution calcs (ApplyNamedGate/ApplyMatrix2x2 --
// their runner gate_sim.py was retired) and the NamedGateApplication
// analysis (-> the scenario packages below, which carry the same
// write-back records).

package GateOperations {
    private import ScalarValues::*;
    private import ComplexFunctions::*;     // rect, polar (9.4.8)
    private import TrigFunctions::*;        // pi (9.4.13)
    private import RealFunctions::*;        // sqrt (9.4.9)
    private import SequenceFunctions::*;    // size() on sequences (9.4.14)

    // h: interchanges the z and x basis views (Hadamard).
    // Source: Qiskit Textbook, ch01.
    attribute h : Quantum::MathExpression::UnitaryMatrix {
        doc /* (1/sqrt(2)) [[1, 1], [1, -1]] in COLUMN convention: the
             columns are the plus and minus vectors themselves, i.e.
             h's columns ARE plus and minus; a unitary's columns are
             the transformed basis. */
        :>> columns =
            (Quantum::MathExpression::Vector(c =
                (rect(1.0 / sqrt(2.0), 0.0), rect(1.0 / sqrt(2.0), 0.0))),
             Quantum::MathExpression::Vector(c =
                (rect(1.0 / sqrt(2.0), 0.0), rect(-1.0 / sqrt(2.0), 0.0))));
    }

    // t: diag(1, e^{i pi/4}) -- the |1> amplitude gains relative phase
    // pi/4. Source: Qiskit Textbook, ch01; Nielsen-Chuang sec 4.2.
    attribute t : Quantum::MathExpression::UnitaryMatrix {
        doc /* polar(1, pi/4) = cos(pi/4) + i sin(pi/4) = e^{i pi/4}. */
        :>> columns =
            (Quantum::MathExpression::Vector(c =
                (rect(1.0, 0.0), rect(0.0, 0.0))),
             Quantum::MathExpression::Vector(c =
                (rect(0.0, 0.0), polar(1.0, pi / 4.0))));
    }

    // cnot: control = first qubit. COLUMN convention: columns are
    // (e0, e1, e3, e2) -- the last two computational-basis amplitudes
    // swap. Ported from the superseded CNOTMatrix data.
    // Source: Qiskit Textbook, ch02.
    attribute cnot : Quantum::MathExpression::UnitaryMatrix {
        doc /* control = first qubit: columns are (e0, e1, e3, e2) --
             the last two computational-basis amplitudes swap. */
        :>> columns =
            (Quantum::MathExpression::Vector(c =
                (rect(1.0, 0.0), rect(0.0, 0.0),
                 rect(0.0, 0.0), rect(0.0, 0.0))),
             Quantum::MathExpression::Vector(c =
                (rect(0.0, 0.0), rect(1.0, 0.0),
                 rect(0.0, 0.0), rect(0.0, 0.0))),
             Quantum::MathExpression::Vector(c =
                (rect(0.0, 0.0), rect(0.0, 0.0),
                 rect(0.0, 0.0), rect(1.0, 0.0))),
             Quantum::MathExpression::Vector(c =
                (rect(0.0, 0.0), rect(0.0, 0.0),
                 rect(1.0, 0.0), rect(0.0, 0.0))));
    }

    // ---------- kernel-realized flow contracts -------------------------
    // The model declares the contracts; Python (pytools/kernel.py, via
    // the M2M binding) owns the computation; completed results are
    // written back into the scenario packages below.

    calc def ApplyMatrix {
        doc /* W = U . V = SUM_k U.columns[k] * V.c[k] -- the column
             convention's definitional formula; raw linear algebra on
             E-coordinates, no frame logic. Kernel-realized. */
        in U : Quantum::MathExpression::UnitaryMatrix;
        in V : Quantum::MathExpression::Vector;
        return W : Quantum::MathExpression::Vector;
        assert constraint shapeCoherent {
            doc /* the product is defined only when the vector length
                 matches the operator's column count. */
            size(V.c) == size(U.columns)
        }
        assert constraint normPreserving {
            doc /* unitarity's algebraic property, meaningful here
                 because V need not be normalized. Algebraic check is
                 kernel-realized. */
            Quantum::MathExpression::normsEqual(W, V)
        }
    }

    calc def UnitaryEvolution {
        doc /* phi = operation . psi -- kernel-realized (no body here).
             The M2M binds this signature to the kernel operation:
             frame (psi_E = M_B . c), apply (phi_E = U . psi_E),
             re-express (result returned in psi's own basis by
             default). */
        attribute operation : Quantum::MathExpression::UnitaryMatrix;
        in psi : Quantum::A::QuantumState;
        return phi : Quantum::A::QuantumState;
        assert constraint domainCoherent {
            doc /* the operator acts on exactly the state's space. */
            size(operation.columns) == psi.basis.dimension
        }
        assert constraint sameFrame {
            doc /* the contract default: the result is expressed in the
                 input state's frame. */
            phi.basis == psi.basis
        }
        assert constraint normPreserved {
            doc /* the evolution postulate, stated explicitly; implied
                 by the QuantumState type constraints on both ends, but
                 asserted here as the model's own physics claim.
                 Algebraic check is kernel-realized. */
            Quantum::MathExpression::stateNormsEqual(phi, psi)
        }
    }

    // ---------- certified scenarios -------------------------------------
    // Completed 18 Nov by the M2M (kernel.py + m2m.py); re-running the
    // M2M is a no-op (UPDATE-not-append).

    calc tOnOne : UnitaryEvolution {
        in operation = t;
        in psi = Quantum::A::one;
        return phi = Quantum::A::one;
    }

    calc tOnPlus : UnitaryEvolution {
        in operation = t;
        in psi = plus;
        return phi = Quantum::A::QuantumState(basis = xBasis,
            coefficients = (rect(cos(pi / 8.0), 0.0),
                            rect(0.0, -sin(pi / 8.0))));
    }
}
