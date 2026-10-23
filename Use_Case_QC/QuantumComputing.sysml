package QuantumComputing {
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
            out item signal : signal;
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

    item def QuantumState {
        doc /* The state of a quantum system, defining the probability
               distribution of possible outcomes of measurements on it.
               In this model a pure single-qubit state is carried by
               three values relative to the computational (z) basis:
               the |0> and |1> outcome probabilities (Born rule:
               probability = squared amplitude) and the relative phase
               phi between the |1> and |0> components, with the
               convention |psi> proportional to |0> + exp(i phi)|1>;
               phi is in radians. The basis states are the values
               (1, 0) and (0, 1); the phase is conventional (taken as
               0) when one component is absent. Probabilities together
               with the relative phase determine a pure state up to
               global phase (the Bloch sphere parameters); the global
               phase and the amplitudes stay in the native model.
               Source: Quantum Ontology (BS ISO/IEC 4879), quantum
               state; Qiskit Textbook, ch01. */
        attribute probabilityOfZero : Real;
        attribute probabilityOfOne : Real;
        attribute relativePhase : Real;
    }

    item def LogicalQubit {
        doc /* The qubit at the logical level: the carrier that the gates of
               the universal gate set act on. Its mapping to physical qubits
               (error correction) is out of scope at this stage.
               Source: Quantum Ontology (BS ISO/IEC 4879). */
        item quantumState : QuantumState;
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

}
}
