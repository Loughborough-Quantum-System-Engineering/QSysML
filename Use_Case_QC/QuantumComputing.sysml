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
}
