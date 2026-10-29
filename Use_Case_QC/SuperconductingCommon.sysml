// Superconducting-specific definitions shared across the superconducting
// interface models (conventional, SFQ, cryo-CMOS, optical, wireless).
package SuperconductingCommon {
    private import ISQ::*;
    private import SI::*;

    // ── Environment ──────────────────────────────────────────────────
    part def dilutionRefrigerator :> QuantumComputing::physicalLayerDefinitions::qubitEnvironment;

    // ── Superconducting quantum devices ──────────────────────────────
    part def josephsonParametricAmplifier :> QuantumComputing::physicalLayerDefinitions::amplifier;
    part def josephsonPhotomultiplier :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def josephsonTransmissionLine :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def sfqConverter :> QuantumComputing::physicalLayerDefinitions::transducer;          // dc-SFQ / SFQ logic chip
    part def cryoCMOSProcessor :> QuantumComputing::physicalLayerDefinitions::classicalProcessor;

    // ── SFQ signal + port ────────────────────────────────────────────
    item def sfqPulse :> QuantumComputing::physicalLayerDefinitions::signal;
    port def sfqPort { out item payload : sfqPulse; }

    // ── Circulating current (Josephson photomultiplier readout) ──────
    item def circulatingCurrent :> QuantumComputing::physicalLayerDefinitions::signal;
    port def circulatingCurrentPort { out item payload : circulatingCurrent; }

    // =====================================================================
    // Actions
    // =====================================================================


    // ── Dispersive readout chain ─────────────────────────────────────
    action def DispersiveInteraction :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item probeTone : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item stateDependentResponse : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        in item qubitCoupling : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
    }
    action def SuppressBackaction :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item incoming : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item forwarded : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
    }
    action def AmplifyQuantumLimited :> CommonInstruments::Amplify;

    // ── Pulse engineering ────────────────────────────────────────────
    enum def pulseProtocol {
        doc 
        /* Advanced protocols with complex pulse sequences, employed to reduce
         * the unwanted side effects of anharmonicity and environment noise in
         * real qubit devices, aiming to improve the fidelity of the control
         * operation. The reference names these two.
         *
         * Source: p.4, right column, paragraph 1.
         */
        derivativeRemovalByAdiabaticGate;
        dynamicalDecoupling;
    }
    action def ApplyPulseProtocol :> QuantumComputing::physicalLayerDefinitions::ProcessData {
        in item envelope : QuantumComputing::physicalLayerDefinitions::digitalData;
        out item shapedEnvelope : QuantumComputing::physicalLayerDefinitions::digitalData;
        attribute protocol : pulseProtocol;
        attribute controlFidelity;
    }
    action def SynchroniseClock {
        attribute clockDelay : DurationValue;
    }

    // ── Qubit operation ──────────────────────────────────────────────
    action def ManipulateQubitState :> QuantumComputing::physicalLayerDefinitions::OperateOnQubit {
        doc 
        /* Drive the qubit to a target state. By engineering the amplitude,
         * duration and shape of the microwave pulse it is possible to achieve
         * any arbitrary state on the Bloch sphere, within a timescale of tens
         * of nanoseconds.
         *
         * The achieved state is recorded as an attribute rather than an out
         * parameter, because it is not transferred to a following action; the
         * readout chain observes it indirectly through the dispersive
         * interaction with the on-chip resonator.
         *
         * Source: p.4, right column, paragraph 1.
         */
        in item controlWaveform : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        in item biasSupply : QuantumComputing::physicalLayerDefinitions::dcBias;
        out item qubitResponse : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        attribute blochSphereState;
        attribute gateDuration : DurationValue;
    }

    // ── Single flux quantum chain ────────────────────────────────────
    action def GenerateSfqPulseTrain :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item triggerTone : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item pulseTrain : sfqPulse;
        in item biasSupply : QuantumComputing::physicalLayerDefinitions::dcBias;
        attribute fluxQuantum;
        attribute pulseArea;
        attribute minimumPulseInterval : DurationValue;
        attribute pulseAmplitude;
        attribute pulseSeparation;
    }
    action def MapStateToPhotonOccupation :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item qubitCoupling : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item photonOccupation : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
    }
    action def DetectPhotonToCurrent :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item photonOccupation : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item storedResult : circulatingCurrent;
    }
    action def ModulateFluxonArrival :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item storedResult : circulatingCurrent;
        out item fluxon : sfqPulse;
        attribute arrivalTimeDeviation;
    }
    action def ConvertToSfqLogic :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item fluxon : sfqPulse;
        out item logicSignal : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        in item biasSupply : QuantumComputing::physicalLayerDefinitions::dcBias;
        attribute clockSpeed : FrequencyValue;
        attribute bitSwitchEnergy;
    }
}
