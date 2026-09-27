// Technology-agnostic classical instruments, shared across qubit platforms.
// Each specialises a functional role from QuantumComputing::physicalLayerDefinitions.
package CommonInstruments {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;

    // ── Signal sources ───────────────────────────────────────────────
    part def awgFPGA :> signalSource;
    part def localOscillator :> signalSource;
    part def microwaveSource :> signalSource;
    part def powerSource :> signalSource;
    part def laserSource :> signalSource;

    // ── Transducers (cross-domain conversion) ────────────────────────
    part def digitalToAnalogConverter :> transducer;
    part def analogToDigitalConverter :> transducer;
    part def iqMixer :> transducer;
    part def electroOpticalModulator :> transducer;
    part def photodiode :> transducer;
    part def photonCountingCamera :> transducer;
    part def antenna :> transducer;
    part def gratingCoupler :> transducer;
    part def acoustoOpticDeflector :> transducer;
    part def electroOpticDeflector :> transducer;
    part def memsMirror :> transducer;
    part def wavelengthConverter :> transducer;

    // ── Amplifiers ───────────────────────────────────────────────────
    part def lowNoiseAmplifier :> amplifier;
    part def microwaveAmplifier :> amplifier;

    // ── Passive signal conditioners ──────────────────────────────────
    part def signalFilter :> signalConditioner;
    part def lowPassbandFilter;
    part def attenuator :> signalConditioner;
    part def lens :> signalConditioner;
    part def circulator :> signalConditioner;
    part def cavity :> signalConditioner;
    part def beamSplitter :> signalConditioner;

    // ── Transmission media ───────────────────────────────────────────
    part def waveguide :> transmissionMedium;
    part def coaxialCable :> transmissionMedium;
    part def opticalFiber :> transmissionMedium;
    part def nanophotonicWaveguide :> transmissionMedium;

    // ── Classical processing ─────────────────────────────────────────
    part def fieldProgrammableGateArrays :> classicalProcessor;
    part def physicalControlUnit :> classicalProcessor;
    part def computerFPGA :> classicalProcessor;

    // =====================================================================
    // Actions
    //
    // Technology-agnostic operations, each specialising a functional action
    // role. One definition per operation rather than per instrument: the
    // purpose of a particular occurrence is carried by the usage name, so
    // for example a cooling beam is declared as
    //     action generateCoolingBeam : GenerateLaserBeam;
    // =====================================================================

    // ── Signal generation ────────────────────────────────────────────
    action def GenerateEnvelope :> GenerateSignal {
        out item envelope : digitalData;
        attribute pulseAmplitude;
        attribute pulseDuration : DurationValue;
        attribute pulseShape;
    }
    action def GenerateCarrier :> GenerateSignal {
        out item carrier : microwaveSignal;
        attribute carrierFrequency : FrequencyValue;
    }
    action def GenerateMicrowaveDrive :> GenerateSignal {
        out item drive : microwaveSignal;
        attribute driveFrequency : FrequencyValue;
    }
    action def GenerateLaserBeam :> GenerateSignal {
        out item beam : opticalSignal;
        attribute wavelength;
    }
    action def SupplyBias :> GenerateSignal {
        out item bias : dcBias;
        attribute voltageStability;
    }
    action def IssueCommand :> GenerateSignal {
        out item command : digitalData;
    }

    // ── Transduction ─────────────────────────────────────────────────
    action def ConvertDigitalToAnalog :> ConvertSignal {
        in item digitalInput : digitalData;
        out item analogOutput : microwaveSignal;
        attribute precision;
        attribute updateRate : FrequencyValue;
    }
    action def ConvertAnalogToDigital :> ConvertSignal {
        in item analogInput : microwaveSignal;
        out item digitalOutput : digitalData;
        attribute resolution;
    }
    action def Upconvert :> ConvertSignal {
        in item baseband : signal;
        out item waveform : microwaveSignal;
        in item carrier : microwaveSignal;
    }
    action def Downconvert :> ConvertSignal {
        in item waveform : microwaveSignal;
        out item baseband : microwaveSignal;
        in item referenceCarrier : microwaveSignal;
    }
    action def RadiateBeam :> ConvertSignal {
        in item feed : microwaveSignal;
        out item beam : signal;
    }
    action def ReceiveBeam :> ConvertSignal {
        in item beam : signal;
        out item feed : microwaveSignal;
    }
    action def EncodeOntoOptical :> ConvertSignal {
        in item electricalInput : microwaveSignal;
        out item modulatedLight : opticalSignal;
        in item opticalCarrier : opticalSignal;
        attribute extinctionRatio;
        attribute insertionLoss;
        attribute powerConsumption;
        attribute modulationEfficiency;
    }
    action def RecoverElectricalSignal :> ConvertSignal {
        in item modulatedLight : opticalSignal;
        out item electricalOutput : microwaveSignal;
        in item bias : dcBias;
        attribute detectionWavelength;
        attribute outputImpedance;
        attribute bandwidth;
    }
    action def ConvertWavelength :> ConvertSignal {
        in item inputPhoton : opticalSignal;
        out item outputPhoton : opticalSignal;
        in item pumpBeam : opticalSignal;
    }
    action def SynthesiseWaveform :> ConvertSignal {
        // a signal generator driven by a digital command, as distinct from a
        // free-running source
        in item command : digitalData;
        out item waveform : microwaveSignal;
        attribute driveFrequency : FrequencyValue;
    }
    action def DeflectBeam :> ConvertSignal {
        in item light : opticalSignal;
        out item deflectedLight : opticalSignal;
        in item drive : microwaveSignal;
    }
    action def DetectPhotons :> ConvertSignal {
        in item light : opticalSignal;
        out item count : digitalData;
        attribute quantumEfficiency;
        attribute darkCountRate : FrequencyValue;
        attribute exposureTime : DurationValue;
    }

    // ── Amplification ────────────────────────────────────────────────
    action def Amplify :> AmplifySignal {
        in item weakSignal : microwaveSignal;
        out item amplifiedSignal : microwaveSignal;
    }

    // ── Signal conditioning ──────────────────────────────────────────
    action def FilterSignal :> ConditionSignal {
        in item unfiltered : signal;
        out item filtered : signal;
    }
    action def AttenuateSignal :> ConditionSignal {
        in item unattenuated : signal;
        out item attenuated : signal;
    }
    action def SteerBeam :> ConditionSignal {
        in item beam : opticalSignal;
        out item steeredBeam : opticalSignal;
        attribute steeringRange;
    }
    action def FocusBeam :> ConditionSignal {
        in item incomingBeam : signal;
        out item focusedBeam : signal;
        attribute beamDiameter;
    }
    action def CollectLight :> ConditionSignal {
        in item emittedLight : opticalSignal;
        out item collectedLight : opticalSignal;
        attribute collectionEfficiency;
        attribute transmission;
    }
    action def RouteSignal :> ConditionSignal {
        in item input : signal;
        out item output : signal;
    }
    action def Resonate :> ConditionSignal {
        in item input : microwaveSignal;
        out item output : microwaveSignal;
        attribute qualityFactor;
    }
    action def SplitBeam :> ConditionSignal {
        in item input : opticalSignal;
        out item outputA : opticalSignal;
        out item outputB : opticalSignal;
    }

    // ── Classical processing ─────────────────────────────────────────
    action def EvaluateMeasurement :> ProcessData {
        // intermediate evaluation whose result feeds a further action
        in item measurement : digitalData;
        out item result : digitalData;
    }
    action def AnalyseMeasurement :> ProcessData {
        // terminal analysis yielding the qubit state
        in item measurement : digitalData;
        out item qubitState : digitalData;
        attribute readoutFidelity;
        attribute detectionWindow : DurationValue;
    }
    action def ApplyFeedback :> ProcessData {
        in item measurement : digitalData;
        out item feedback : digitalData;
        attribute feedbackLatency : DurationValue;
    }
    action def BufferStream :> ProcessData {
        in item streamIn : digitalData;
        out item streamOut : digitalData;
    }
}
