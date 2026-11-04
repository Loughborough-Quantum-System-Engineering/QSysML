// General quantum-domain vocabulary: definitions that hold for any
// engineered quantum system, not only quantum computing. Terms and
// meanings come from the Quantum Conceptual Model (BS ISO/IEC 4879), referred
// to only, never re-modelled. Quantum computing specific definitions
// (logical qubit, quantum operation, quantum gate, gate sets) stay in
// QuantumComputing.sysml, package quantumOperationDefinitions.

package Quantum {
    private import ScalarValues::*;
    private import CollectionFunctions::*;
    private import RealFunctions::*;

    item def QuantumSystem {
        state quantumState : QuantumState;
    }

    item def CompositeQuantumSystem :> QuantumSystem {
        doc /* A quantum system that names its subsystems: a composite
               system whose joint description lives on the composite,
               with subsystems referencing the parts wherever they sit
               in the containment tree.
               Source: Nielsen-Chuang sec 1.3.5, composite systems;
               Quantum Conceptual Model (BS ISO/IEC 4879), quantum system. */
        ref item subsystem : QuantumSystem[2..*] ordered;
        // dimension law: a composite system's basis dimension is the
        // product of its subsystems' basis dimensions
        constraint { quantumState.basis.dimension == product(subsystem.quantumState.basis.dimension) }
    }


    abstract state def BasisState;

    attribute def Basis {
        doc /* A basis: the set of outcome states that defines a measurement.
               Member i is the state of certain outcome i in this basis;
               membership is the member's definition, so a member carries no
               values and its own basis feature is unset by convention.
               Indices order the outcomes; member names are optional reader
               aid. Dimension: 2 for a single qubit, 2^n for an n-qubit
               register, d for a qudit. Superposition is relative to a
               basis: a state definite in one basis is a combination in
               another.
               Source: Quantum Conceptual Model (BS ISO/IEC 4879), basis and basis
               states; Qiskit Textbook, ch01; MIT OCW 8.04, ch01. */
        attribute dimension : Integer;
        ref state memberState : BasisState[0..*] ordered;
        constraint { size(memberState) == dimension }
    }

    state def QuantumState {
        doc /* The state of a quantum system, expressed relative to a basis:
               one Born probability per basis member, by index, plus the
               relative phases of the other members' components relative to
               member 1, in radians: probability[i] corresponds to
               basis.memberState[i] by index, and relativePhase[i] is the
               phase of basis member i+1 relative to member 1 (so the
               collection has basis.dimension - 1 entries). Probabilities with the relative phase determine a
               pure state up to global phase; the global phase and the
               amplitudes stay in the native model. The same state has
               different probability descriptions in different bases. The
               probabilities are normalized: their sum is 1 (Born rule).
               A state that is a basis member is defined by its membership
               and sets none of these features.
               Source: Quantum Conceptual Model (BS ISO/IEC 4879), quantum state;
               Qiskit Textbook, ch01. */
        attribute basis : Basis;
        attribute probability : Real[0..*] ordered;
        attribute relativePhase : Real[0..*] ordered;
        attribute entanglement : Entanglement[0..*];
        constraint { size(probability) == basis.dimension }
        constraint { size(relativePhase) == basis.dimension - 1 }
        constraint { sum(probability) == 1.0 }
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
        ref item spannedSubsystems : QuantumSystem[0..*] ordered;
        attribute entangled : Boolean;
        constraint { size(spannedSubsystems) >= 2 or entangled == false }
    }


    item def Qubit :> QuantumSystem {
        // dimension law: a qubit's basis is 2-dimensional; a composite
        // of n qubits inherits 2^n through the composite product law
        constraint { quantumState.basis.dimension == 2 }
    }

    item def Qutrit :> QuantumSystem {
        // dimension law: a qutrit's basis is 3-dimensional; a composite
        // of n qutrits inherits 3^n through the composite product law
        constraint { quantumState.basis.dimension == 3 }
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
