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
        in item qubitCoupling : microwaveSignal;
        out item stateDependentResponse : microwaveSignal;
    }
    action def SuppressBackaction :> ConditionSignal {
        in item incoming : microwaveSignal;
        out item forwarded : microwaveSignal;
    }
    action def AmplifyQuantumLimited :> Amplify;

    // ── Pulse engineering ────────────────────────────────────────────
    action def ApplyPulseProtocol :> ProcessData {
        in item envelope : digitalData;
        out item shapedEnvelope : digitalData;
        attribute protocol;
        attribute controlFidelity;
    }
    action def SynchroniseClock :> ProcessData {
        attribute clockDelay : DurationValue;
    }

    // ── Single flux quantum chain ────────────────────────────────────
    action def GenerateSfqPulseTrain :> ConvertSignal {
        in item triggerTone : microwaveSignal;
        in item biasSupply : dcBias;
        out item pulseTrain : sfqPulse;
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
        in item biasSupply : dcBias;
        out item logicSignal : microwaveSignal;
        attribute clockSpeed : FrequencyValue;
        attribute bitSwitchEnergy;
    }
}
