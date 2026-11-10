// General quantum-domain vocabulary: definitions that hold for any
// engineered quantum system, not only quantum computing. Terms and
// meanings come from the Quantum Conceptual Model (BS ISO/IEC 4879), referred
// to only, never re-modelled. Quantum computing specific definitions
// (logical qubit, quantum operation, quantum gate, gate sets) stay in
// QuantumComputing.sysml, package quantumOperationDefinitions.
//
// Representation: calculation-aligned (6 Nov 2026, decision #37) —
// states are state vectors; the rationale is recorded in
// PhD/QSysML/Model doc records 2026-11-06.md (second brain).
// The superseded pre-restructure version: archive_quantum.sysml (archive).

package Quantum {
    private import ScalarValues::*;
    private import CollectionFunctions::*;
    private import RealFunctions::*;

    item def QuantumSubSystem {
        state quantumState : QuantumState;
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


    abstract state def BasisState;

    attribute def Basis {
        doc /* A basis: d ordered orthonormal member states; the math is
               memberVector (d member vectors of 2d reals, reference z
               convention, C8 groups = members). Record: Model doc
               records 2026-11-06.md. Source: Nielsen-Chuang sec 1.2. */
        attribute dimension : Integer;
        ref state memberState : BasisState[0..*] ordered;
        attribute memberVector : Real[0..*] ordered;
        constraint { size(memberState) == dimension }
        constraint { size(memberVector) == 2 * dimension * dimension }
    }

    state def QuantumState {
        doc /* The state: a complex state vector relative to a basis —
               one (real part, imaginary part) pair per basis member,
               by index (C1/C2). Gate matrices act on it directly;
               Born probabilities are a derived view (BornProbabilities);
               no phase angle is stored (atan2 wall). Record: Model doc
               records 2026-11-06.md. Source: Nielsen-Chuang sec 1.2. */
        attribute basis : Basis;
        attribute stateVector : Real[0..*] ordered;
        attribute entanglement : Entanglement[0..*];
        constraint { size(stateVector) == 2 * basis.dimension }
    }

    attribute def Entanglement {
        doc /* An entanglement relation of a quantum system: names the
               subsystems that are entangled with each other
               (spannedSubsystems), and asserts whether the joint state
               is entangled across their cut (true) or separable
               (false). The named subsystems are the partition the
               statement is relative to; the record is stated on the
               joint state description, typically carried by the common
               ancestor of the named subsystems, wherever they sit in
               the containment tree. Naming no subsystems is allowed
               only for a denial: the statement is then about the
               description as a whole.
               Source: Quantum Conceptual Model (BS ISO/IEC 4879);
               Nielsen-Chuang sec 1.3.6, ch 2.5. */
        ref item spannedSubsystems : QuantumSubSystem[0..*] ordered;
        attribute entangled : Boolean;
        constraint { size(spannedSubsystems) >= 2 or entangled == false }
    }


    item def Qubit :> QuantumSubSystem {
        // dimension law: a qubit's basis is 2-dimensional
        constraint { quantumState.basis.dimension == 2 }
        constraint { size(quantumState.stateVector) == 4 }
        constraint {
            // Born normalization (C5); explicit additions: sum is broken.
            CalculationLibrary::ScalarCalc::Close(
                quantumState.stateVector#(1) * quantumState.stateVector#(1) +
                quantumState.stateVector#(2) * quantumState.stateVector#(2) +
                quantumState.stateVector#(3) * quantumState.stateVector#(3) +
                quantumState.stateVector#(4) * quantumState.stateVector#(4),
                1.0)
        }
    }

    item def Qutrit :> QuantumSubSystem {
        // dimension law: a qutrit's basis is 3-dimensional
        constraint { quantumState.basis.dimension == 3 }
        constraint { size(quantumState.stateVector) == 6 }
        // Born normalization: same recipe over the six components,
        // to state when a qutrit calculation need exists.
    }

    abstract attribute def QuantumOperator {
        doc /* Mathematical description of a quantum operator.
               Source: Quantum Conceptual Model (BS ISO/IEC 4879). */
    }

    attribute def UnitaryOperator :> QuantumOperator {
        doc /* A quantum operator that is unitary.
               Source: Quantum Conceptual Model (BS ISO/IEC 4879). */
    }
}
