// General quantum-domain vocabulary: definitions that hold for any
// engineered quantum system, not only quantum computing. Terms and
// meanings come from the Quantum Ontology (BS ISO/IEC 4879), referred
// to only, never re-modelled. Quantum computing specific definitions
// (logical qubit, quantum operation, quantum gate, gate sets) stay in
// QuantumComputing.sysml, package quantumOperationDefinitions.

package Quantum {
    private import ScalarValues::*;
    private import CollectionFunctions::*;
    private import RealFunctions::*;

    abstract item def QuantumSystem { }


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
               Source: Quantum Ontology (BS ISO/IEC 4879), basis and basis
               states; Qiskit Textbook, ch01; MIT OCW 8.04, ch01. */
        attribute dimension : Integer;
        ref state memberState : QuantumState[0..*] ordered;
        constraint { size(memberState) == dimension }
    }

    state def QuantumState {
        doc /* The state of a quantum system, expressed relative to a basis:
               one Born probability per basis member, by index, plus the
               relative phase of member 2's component relative to member 1,
               in radians. probability[i] corresponds to basis.memberState[i]
               by index. Probabilities with the relative phase determine a
               pure state up to global phase; the global phase and the
               amplitudes stay in the native model. The same state has
               different probability descriptions in different bases. The
               probabilities are normalized: their sum is 1 (Born rule).
               A state that is a basis member is defined by its membership
               and sets none of these features.
               Source: Quantum Ontology (BS ISO/IEC 4879), quantum state;
               Qiskit Textbook, ch01. */
        attribute basis : Basis;
        attribute probability : Real[0..*] ordered;
        attribute relativePhase : Real;
        constraint { size(probability) == basis.dimension }
        constraint { sum(probability) == 1.0 }
    }

    item def Qubit :> QuantumSystem {
        state quantumState : QuantumState {
            attribute :>> basis {
                attribute :>> dimension = 2;
            }
        }
    }

    item def Qutrit :> QuantumSystem {
        state quantumState : QuantumState {
            attribute :>> basis {
                attribute :>> dimension = 3;
            }
        }
    }


    attribute def Entanglement {
        doc /* The entanglement of an EntangleSystem's two subsystems:
               measured by the Schmidt rank of the joint state across the
               two-subsystem cut; 1 = separable, 2 or more = entangled.
               Source: Nielsen-Chuang sec 1.3.6, ch 2.5. */
        attribute schmidtRank : Integer;
    }

    item def EntangleSystem :> QuantumSystem {
        doc /* A quantum system consisting of two subsystems whose joint
               state is described by quantumState; entanglement records
               the Schmidt rank across the two-subsystem cut.
               Source: Quantum Ontology (BS ISO/IEC 4879), quantum system. */
        item state1 : QuantumSystem;
        item state2 : QuantumSystem;
        state quantumState : QuantumState;
        attribute entanglement : Entanglement;
    }


    abstract attribute def QuantumOperator {
        doc /* Mathematical description of a quantum operator.
               Source: Quantum Ontology (BS ISO/IEC 4879). */
    }

    attribute def UnitaryOperator :> QuantumOperator {
        doc /* A quantum operator that is unitary.
               Source: Quantum Ontology (BS ISO/IEC 4879). */
    }
}
