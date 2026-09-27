// Superconducting-specific definitions shared across the superconducting
// interface models (conventional, SFQ, cryo-CMOS, optical, wireless).
package SuperconductingCommon {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import ISQ::*;
    public import SI::*;

    // ── Environment ──────────────────────────────────────────────────
    part def dilutionRefrigerator :> qubitEnvironment;

    // ── Superconducting quantum devices ──────────────────────────────
    part def josephsonParametricAmplifier :> amplifier;
    part def josephsonPhotomultiplier :> transducer;
    part def josephsonTransmissionLine :> transducer;
    part def sfqConverter :> transducer;          // dc-SFQ / SFQ logic chip
    part def cryoCMOSProcessor :> classicalProcessor;

    // ── SFQ signal + port ────────────────────────────────────────────
    item def sfqPulse :> signal;
    port def sfqPort { out item payload : sfqPulse; }

    // ── Circulating current (Josephson photomultiplier readout) ──────
    item def circulatingCurrent :> signal;
    port def circulatingCurrentPort { out item payload : circulatingCurrent; }

    // =====================================================================
    // Actions
    // =====================================================================


    // ── Dispersive readout chain ─────────────────────────────────────
    action def DispersiveInteraction :> ConvertSignal {
        in item probeTone : microwaveSignal;
        out item stateDependentResponse : microwaveSignal;
        in item qubitCoupling : microwaveSignal;
    }
    action def SuppressBackaction :> ConditionSignal {
        in item incoming : microwaveSignal;
        out item forwarded : microwaveSignal;
    }
    action def AmplifyQuantumLimited :> Amplify;

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
    action def ApplyPulseProtocol :> ProcessData {
        in item envelope : digitalData;
        out item shapedEnvelope : digitalData;
        attribute protocol : pulseProtocol;
        attribute controlFidelity;
    }
    action def SynchroniseClock {
        attribute clockDelay : DurationValue;
    }

    // ── Qubit operation ──────────────────────────────────────────────
    action def ManipulateQubitState :> OperateOnQubit {
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
        in item controlWaveform : microwaveSignal;
        in item biasSupply : dcBias;
        out item qubitResponse : microwaveSignal;
        attribute blochSphereState;
        attribute gateDuration : DurationValue;
    }

    // ── Single flux quantum chain ────────────────────────────────────
    action def GenerateSfqPulseTrain :> ConvertSignal {
        in item triggerTone : microwaveSignal;
        out item pulseTrain : sfqPulse;
        in item biasSupply : dcBias;
        attribute fluxQuantum;
        attribute pulseArea;
        attribute minimumPulseInterval : DurationValue;
        attribute pulseAmplitude;
        attribute pulseSeparation;
    }
    action def MapStateToPhotonOccupation :> ConvertSignal {
        in item qubitCoupling : microwaveSignal;
        out item photonOccupation : microwaveSignal;
    }
    action def DetectPhotonToCurrent :> ConvertSignal {
        in item photonOccupation : microwaveSignal;
        out item storedResult : circulatingCurrent;
    }
    action def ModulateFluxonArrival :> ConvertSignal {
        in item storedResult : circulatingCurrent;
        out item fluxon : sfqPulse;
        attribute arrivalTimeDeviation;
    }
    action def ConvertToSfqLogic :> ConvertSignal {
        in item fluxon : sfqPulse;
        out item logicSignal : microwaveSignal;
        in item biasSupply : dcBias;
        attribute clockSpeed : FrequencyValue;
        attribute bitSwitchEnergy;
    }
}
