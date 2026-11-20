// Example.sysml -- every basis and state IMPLEMENTED, plus gate
// application examples (19 Nov, decisions #65-#89).
//
// Reading guide, per basis:
//   1. the members (what the basis is);
//   2. the member states written in their own basis (positional
//      coefficients -- position i pairs with members[i]);
//   3. the same states written over the OTHER basis (basis-relativity:
//      one ray, different numbers -- verified identical when framed
//      to E by the kernel).
//
// The gate flows at the end were declared INCOMPLETE and are now
// COMPLETED by the M2M
//   pytools/m2m.py ../quantum.sysml ../QuantumComputing.sysml \
//                  ../GateOperations.sysml ../Example.sysml --apply
// (computes each flow in the kernel, writes the completed return
// bindings back into this file, UPDATE-not-append -- re-running is a
// no-op). Flows live DIRECTLY in this package (no per-flow wrapper
// packages). To add a flow: declare it WITHOUT return bindings, run
// --apply.

package Example {
    private import ScalarValues::*;
    private import ComplexFunctions::*;     // rect (9.4.8)
    private import RealFunctions::*;        // sqrt (9.4.9)

    // ═══ 1. the COMPUTATIONAL basis (z), states 0 and 1 ═════════════

    attribute computationalBasis : Quantum::A::Basis {
        :>> dimension = 2;
        :>> members =
            (Quantum::MathExpression::Vector(c =
                (rect(1.0, 0.0), rect(0.0, 0.0))),                  // member 1 = |0>
             Quantum::MathExpression::Vector(c =
                (rect(0.0, 0.0), rect(1.0, 0.0))));                 // member 2 = |1>
    }

    // member states, written in their own basis: the coefficient at
    // position i IS members[i] -- a basis state is its own position.
    attribute stateZero : Quantum::A::QuantumState {
        :>> basis = computationalBasis;
        :>> coefficients = (rect(1.0, 0.0), rect(0.0, 0.0));        // = |0>
    }
    attribute stateOne : Quantum::A::QuantumState {
        :>> basis = computationalBasis;
        :>> coefficients = (rect(0.0, 0.0), rect(1.0, 0.0));        // = |1>
    }

    // ═══ 2. the HADAMARD basis (x), states + and - ══════════════════

    attribute hadamardBasis : Quantum::A::Basis {
        :>> dimension = 2;
        :>> members =
            (Quantum::MathExpression::Vector(c =
                (rect(1.0 / sqrt(2.0), 0.0), rect(1.0 / sqrt(2.0), 0.0))),   // member 1 = |+>
             Quantum::MathExpression::Vector(c =
                (rect(1.0 / sqrt(2.0), 0.0), rect(-1.0 / sqrt(2.0), 0.0)))); // member 2 = |->
    }

    // member states, written in their own basis: position 1 is |+>,
    // position 2 is |-> -- the writing a z-reader would not recognize.
    attribute statePlus : Quantum::A::QuantumState {
        :>> basis = hadamardBasis;
        :>> coefficients = (rect(1.0, 0.0), rect(0.0, 0.0));        // = |+>
    }
    attribute stateMinus : Quantum::A::QuantumState {
        :>> basis = hadamardBasis;
        :>> coefficients = (rect(0.0, 0.0), rect(1.0, 0.0));        // = |->
    }

    // the same states over the COMPUTATIONAL basis -- the numbers the
    // x-writing hides: |+> = (1/sqrt(2))(|0> + |1>), |-> = (1/sqrt(2))(|0> - |1>)
    attribute statePlusComputational : Quantum::A::QuantumState {
        :>> basis = computationalBasis;
        :>> coefficients =
            (rect(1.0 / sqrt(2.0), 0.0), rect(1.0 / sqrt(2.0), 0.0));
    }
    attribute stateMinusComputational : Quantum::A::QuantumState {
        :>> basis = computationalBasis;
        :>> coefficients =
            (rect(1.0 / sqrt(2.0), 0.0), rect(-1.0 / sqrt(2.0), 0.0));
    }

    // and the reverse view: the z states written over the HADAMARD
    // basis -- |0> = (1/sqrt(2))(|+> + |->), |1> = (1/sqrt(2))(|+> - |->)
    attribute stateZeroHadamard : Quantum::A::QuantumState {
        :>> basis = hadamardBasis;
        :>> coefficients =
            (rect(1.0 / sqrt(2.0), 0.0), rect(1.0 / sqrt(2.0), 0.0));
    }
    attribute stateOneHadamard : Quantum::A::QuantumState {
        :>> basis = hadamardBasis;
        :>> coefficients =
            (rect(1.0 / sqrt(2.0), 0.0), rect(-1.0 / sqrt(2.0), 0.0));
    }

    // ═══ 3. the two-qubit COMPOSITE basis ═══════════════════════════
    // Tensor composition of the computational basis with itself:
    // dimension 4; positions (1-based Kronecker) 1 = |00>, 2 = |01>,
    // 3 = |10>, 4 = |11>. The members are DERIVED by the kernel
    // (Kronecker products of the factor members) -- not written out.
    // The subsystem cut is queryable: left/right = the factors.
    attribute twoQubitBasis : Quantum::A::TensorBasis {
        :>> left = computationalBasis;
        :>> right = computationalBasis;
    }

    // ---------- composite member states ---------------------------------
    // The computational basis states of the composite, written
    // positionally (position i pairs with members[i]):
    //   ket00 = position 1, ket01 = position 2,
    //   ket10 = position 3, ket11 = position 4.
    attribute ket00 : Quantum::A::QuantumState {
        :>> basis = twoQubitBasis;
        :>> coefficients =
            (rect(1.0, 0.0), rect(0.0, 0.0),
             rect(0.0, 0.0), rect(0.0, 0.0));
    }
    attribute ket01 : Quantum::A::QuantumState {
        :>> basis = twoQubitBasis;
        :>> coefficients =
            (rect(0.0, 0.0), rect(1.0, 0.0),
             rect(0.0, 0.0), rect(0.0, 0.0));
    }
    attribute ket10 : Quantum::A::QuantumState {
        :>> basis = twoQubitBasis;
        :>> coefficients =
            (rect(0.0, 0.0), rect(0.0, 0.0),
             rect(1.0, 0.0), rect(0.0, 0.0));
    }
    attribute ket11 : Quantum::A::QuantumState {
        :>> basis = twoQubitBasis;
        :>> coefficients =
            (rect(0.0, 0.0), rect(0.0, 0.0),
             rect(0.0, 0.0), rect(1.0, 0.0));
    }

    // the entanglement seed: |+>|0> -- a PRODUCT state (one writing)
    attribute plusZero : Quantum::A::QuantumState {
        :>> basis = twoQubitBasis;
        :>> coefficients =
            (rect(1.0 / sqrt(2.0), 0.0), rect(0.0, 0.0),
             rect(1.0 / sqrt(2.0), 0.0), rect(0.0, 0.0));
    }

    // ═══ 4. the BELL basis, one of the Bell states ══════════════════
    // The four Bell members, in computational (E) coordinates:
    //   Phi+ = (|00> + |11>)/sqrt(2)
    //   Phi- = (|00> - |11>)/sqrt(2)
    //   Psi+ = (|01> + |10>)/sqrt(2)
    //   Psi- = (|01> - |10>)/sqrt(2)
    // Every member is ENTANGLED across the q1|q2 cut -- the basis does
    // NOT factor, which is why it is declared a plain Basis, not a
    // TensorBasis. Orthonormality is asserted on Basis and
    // kernel-verified.
    attribute bellBasis : Quantum::A::Basis {
        :>> dimension = 4;
        :>> members =
            (Quantum::MathExpression::Vector(c =
                (rect(1.0 / sqrt(2.0), 0.0), rect(0.0, 0.0),
                 rect(0.0, 0.0), rect(1.0 / sqrt(2.0), 0.0))),      // member 1 = Phi+
             Quantum::MathExpression::Vector(c =
                (rect(1.0 / sqrt(2.0), 0.0), rect(0.0, 0.0),
                 rect(0.0, 0.0), rect(-1.0 / sqrt(2.0), 0.0))),     // member 2 = Phi-
             Quantum::MathExpression::Vector(c =
                (rect(0.0, 0.0), rect(1.0 / sqrt(2.0), 0.0),
                 rect(1.0 / sqrt(2.0), 0.0), rect(0.0, 0.0))),      // member 3 = Psi+
             Quantum::MathExpression::Vector(c =
                (rect(0.0, 0.0), rect(1.0 / sqrt(2.0), 0.0),
                 rect(-1.0 / sqrt(2.0), 0.0), rect(0.0, 0.0))));    // member 4 = Psi-
    }

    // ONE of the Bell states -- Phi+, written in ITS OWN basis:
    // position 1 carries the whole description (coefficient 1), the
    // rest zero -- canonical by construction.
    attribute phiPlus : Quantum::A::QuantumState {
        :>> basis = bellBasis;
        :>> coefficients =
            (rect(1.0, 0.0), rect(0.0, 0.0),
             rect(0.0, 0.0), rect(0.0, 0.0));
    }

    // the SAME physical state, written over the two-qubit COMPUTATIONAL
    // basis -- basis-relativity: one ray, two writings, verified
    // identical when framed to E by the kernel.
    attribute phiPlusComputational : Quantum::A::QuantumState {
        :>> basis = twoQubitBasis;
        :>> coefficients =
            (rect(1.0 / sqrt(2.0), 0.0), rect(0.0, 0.0),
             rect(0.0, 0.0), rect(1.0 / sqrt(2.0), 0.0));
    }

    // ═══ gate flows (COMPLETED by the M2M) ══════════════════════════
    // Declared directly in this package -- one flow, one calc usage;
    // no per-flow wrapper packages.

    calc hOnZero : Quantum::UnitaryEvolution {
        in operation = GateOperations::h;
        in psi = stateZero;
        return phi = statePlus;
    }

    calc hOnMinus : Quantum::UnitaryEvolution {
        in operation = GateOperations::h;
        in psi = stateMinus;
        return phi = stateOne;
    }

    calc tOnStatePlus : Quantum::UnitaryEvolution {
        in operation = GateOperations::t;
        in psi = statePlus;
        return phi = Quantum::A::QuantumState(basis = hadamardBasis, coefficients = (rect(cos(pi / 8.0), 0.0), rect(0.0, -sin(pi / 8.0))));
    }

    calc cnotOnTen : Quantum::UnitaryEvolution {
        in operation = GateOperations::cnot;
        in psi = ket10;
        return phi = ket11;
    }

    calc cnotOnEleven : Quantum::UnitaryEvolution {
        in operation = GateOperations::cnot;
        in psi = ket11;
        return phi = ket10;
    }

    calc bellPrep : Quantum::UnitaryEvolution {
        in operation = GateOperations::cnot;
        in psi = plusZero;
        return phi = phiPlus;
    }
}
