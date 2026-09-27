// Definitions shared across the atomic platforms (trapped ion + neutral atom).
package AtomicCommon {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import ISQ::*;
    public import SI::*;

    // ── Environment ──────────────────────────────────────────────────
    part def vacuumChamber :> qubitEnvironment;

    // ── Magnetic-field control (gradient-based multiqubit gates) ─────
    item def magneticField :> signal;
    port def magneticFieldPort { out item payload : magneticField; }

    // =====================================================================
    // Actions
    // =====================================================================

    // ── Trapping and preparation ─────────────────────────────────────
    action def GenerateTrapDrive :> GenerateSignal {
        out item rfDrive : microwaveSignal;
        attribute driveFrequency : FrequencyValue;
        attribute driveVoltage;
    }
    action def LoadIon :> OperateOnQubit {
        in item ionisationBeam : opticalSignal;
        attribute loadingRate;
    }
    action def CoolAtom :> OperateOnQubit {
        in item coolingBeam : opticalSignal;
        attribute coolingRate;
        attribute steadyStatePhononNumber;
    }

    // ── Ion transport and well shaping ───────────────────────────────
    action def TransportIon :> OperateOnQubit {
        in item electrodePotential : dcBias;
        attribute shuttlingTime : DurationValue;
        attribute cycleTime : DurationValue;
    }
    action def MergeWells :> OperateOnQubit {
        in item electrodePotential : dcBias;
        attribute mergeTime : DurationValue;
    }
    action def SplitWells :> OperateOnQubit {
        in item electrodePotential : dcBias;
        attribute splitTime : DurationValue;
    }
    action def RearrangeAtoms :> OperateOnQubit {
        in item movableTweezers : opticalSignal;
        attribute transferTime : DurationValue;
        attribute transportSpeed;
        attribute moveExecutionTime : DurationValue;
    }

    // ── Readout and interconnect ─────────────────────────────────────
    action def ShelveQubit :> OperateOnQubit {
        in item shelvingBeam : opticalSignal;
        out item shelvedState : opticalSignal;
    }
    action def ExciteCommunicationQubit :> OperateOnQubit {
        in item excitationPulse : opticalSignal;
        out item communicationPhoton : opticalSignal;
        attribute excitationProbability;
    }
    action def HeraldEntanglement :> ProcessData {
        in item photonA : opticalSignal;
        in item photonB : opticalSignal;
        out item herald : digitalData;
        attribute connectionRate : FrequencyValue;
        attribute detectorEfficiency;
    }

    // ── Magnetic field control ───────────────────────────────────────
    action def GenerateFieldGradient :> ConvertSignal {
        in item current : dcBias;
        out item gradient : magneticField;
        attribute gradientStrength;
        attribute wireCurrent;
        attribute ionHeight;
        attribute wireInductance;
        attribute rampTime : DurationValue;
    }
    action def AdjustLocalMagneticField :> ConvertSignal {
        in item current : dcBias;
        out item offsetField : magneticField;
        attribute coilInductance;
    }
}
