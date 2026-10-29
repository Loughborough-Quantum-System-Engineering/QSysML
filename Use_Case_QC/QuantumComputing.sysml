package QuantumComputing {
    private import ScalarValues::*;
    private import CollectionFunctions::*;

    package physicalLayerDefinitions {
        // ── Subsystem roles ──────────────────────────────────────────
        abstract part def classicalInterfaceSystem;
        part def classicalControlSystem :> classicalInterfaceSystem;
        part def classicalReadoutSystem :> classicalInterfaceSystem;
        part def interconnectSystem :> classicalInterfaceSystem;

        // ── Functional component roles ───────────────────────────────
        abstract part def signalSource;
        abstract part def transducer;          // converts signal across domains
        abstract part def amplifier;           // boosts signal, same domain
        abstract part def signalConditioner;   // passive same-domain shaping
        abstract part def transmissionMedium;  // carries signal between locations
        abstract part def classicalProcessor;  // digital computation / control
        abstract part def qubitEnvironment;    // physical enclosure holding the QPU

        // ── Signal vocabulary ────────────────────────────────────────
        item def signal;
        item def digitalData :> signal;
        item def microwaveSignal :> signal;    // RF through mm-wave / THz
        item def opticalSignal :> signal;
        item def dcBias :> signal;

        // ── Port definitions (conjugate style; payload typed) ─────────
        port def digitalPort { out item payload : digitalData; }
        port def microwavePort { out item payload : microwaveSignal; }
        port def opticalPort { out item payload : opticalSignal; }
        port def dcBiasPort { out item payload : dcBias; }

        // ── Functional action roles ──────────────────────────────────
        // One abstract action per component role above. Every concrete
        // action in the library specialises one of these, so that the
        // question "what does this kind of component do" has a single
        // answer independent of qubit technology.
        abstract action def GenerateSignal {
            out item signal : QuantumComputing::physicalLayerDefinitions::signal;
        }
        abstract action def ConvertSignal {
            in item input : signal;
            out item output : signal;
        }
        abstract action def AmplifySignal {
            in item weakSignal : signal;
            out item amplifiedSignal : signal;
        }
        abstract action def ConditionSignal {
            in item input : signal;
            out item output : signal;
        }
        abstract action def TransmitSignal {
            in item input : signal;
            out item output : signal;
        }
        abstract action def ProcessData {
            in item input : digitalData;
            out item output : digitalData;
        }
        abstract action def OperateOnQubit;
        abstract action def RegulateEnvironment;

        // ── Qubit technology + QPU ───────────────────────────────────
        enum def qubitTechnology {
            superconducting;
            trappedIon;
            neutralAtom;
            photonic;
            spinQubit;
            quantumDot;
        }
        part def QPU {
            attribute technology : qubitTechnology;
        }

        // ── Legacy black-box ports (used by physicalBlackBox / logicalBlackBox) ──
        port def errorCorrectionPortIn {
            in result;
        }
        port def errorCorrectionPortOut {
            out parameter;
        }
        port def controlUnitPortIn {
            in parameter;
        }
        port def controlUnitPortOut {
            out microwavePulse;
        }
        port def readOutPort {
            inout result;
        }
        port def cryogenicPortIn {
            in microwavePulse;
        }
        port def cryogenicPortOut {
            out result;
        }
    }
    package logicalLayerDefinitions {
        attribute def gate;
        part def logicalControlUnit;
        attribute def quantumAlgorithm;
    }
    package actions {
        action generateMicrowavePulses;
        action performErrorCorrection;
        action pulseAttenuation;
        action pulseFiltering;
        action cryogenicAmplification;
        action quantumInformationProcessing;
        action logicalOperations;
    }

    // reference
// @standard{bsisoiec4879,
//   title = {...},  // completed once you give the exact edition
// }

package quantumOperationDefinitions {

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
               different probability descriptions in different bases. A
               state that is a basis member is defined by its membership
               and sets none of these features.
               Source: Quantum Ontology (BS ISO/IEC 4879), quantum state;
               Qiskit Textbook, ch01. */
        attribute basis : Basis;
        attribute probability : Real[0..*] ordered;
        attribute relativePhase : Real;
        constraint { size(probability) == basis.dimension }
    }

    item def LogicalQubit {
        doc /* The qubit at the logical level: the carrier that the gates of
               the universal gate set act on. Its mapping to physical qubits
               (error correction) is out of scope at this stage. The state
               feature makes the qubit an exhibitor of its quantum state.
               Source: Quantum Ontology (BS ISO/IEC 4879). */
        state quantumState : QuantumState;
    }

    abstract attribute def QuantumOperator {
        doc /* Mathematical description of a quantum operator.
               Source: Quantum Ontology (BS ISO/IEC 4879). */
    }

    attribute def UnitaryOperator :> QuantumOperator {
        doc /* A quantum operator that is unitary.
               Source: Quantum Ontology (BS ISO/IEC 4879). */
    }

    abstract action def QuantumOperation :> physicalLayerDefinitions::OperateOnQubit {
        doc /* A quantum operation acts on one or more quantum systems and is
               represented by one or more quantum operators, justified by the
               Kraus representation. State preparation, quantum gates,
               Hamiltonian evolution and quantum measurement specialise it.
               Source: Quantum Ontology (BS ISO/IEC 4879). */
        ref item actsOn : LogicalQubit[1..*];
        attribute representedBy : QuantumOperator[1..*];
    }

    abstract action def QuantumGate :> QuantumOperation {
        doc /* A quantum operation represented by exactly one unitary operator.
               Source: Quantum Ontology (BS ISO/IEC 4879). */
        attribute : UnitaryOperator[1] :>> representedBy;
    }

    abstract action def GateSet {
        doc /* A gate set: a named collection of gates. Modeled as an
               action def because its members are gates, and this
               toolchain accepts action-typed members only in action
               defs.
               Source: Quantum Ontology (BS ISO/IEC 4879), gate set. */
        ref action memberGate : QuantumGate[0..*];
    }

    action def UniversalGateSet :> GateSet {
        doc /* A universal gate set: a gate set from which any unitary
               can be approximated to any accuracy. Universality is a
               theorem about a set, not a structural property; the
               members carry it.
               Source: Quantum Ontology (BS ISO/IEC 4879), universal
               gate set; Qiskit Textbook, ch02; Nielsen-Chuang, ch04. */
    }

}
}
