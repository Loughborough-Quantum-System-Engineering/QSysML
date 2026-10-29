// Technology-agnostic classical instruments, shared across qubit platforms.
// Each specialises a functional role from QuantumComputing::physicalLayerDefinitions.
package CommonInstruments {
    private import ISQ::*;
    private import SI::*;

    // ── Signal sources ───────────────────────────────────────────────
    part def awgFPGA :> QuantumComputing::physicalLayerDefinitions::signalSource;
    part def localOscillator :> QuantumComputing::physicalLayerDefinitions::signalSource;
    part def microwaveSource :> QuantumComputing::physicalLayerDefinitions::signalSource;
    part def powerSource :> QuantumComputing::physicalLayerDefinitions::signalSource;
    part def laserSource :> QuantumComputing::physicalLayerDefinitions::signalSource;

    // ── Transducers (cross-domain conversion) ────────────────────────
    part def digitalToAnalogConverter :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def analogToDigitalConverter :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def iqMixer :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def electroOpticalModulator :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def photodiode :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def photonCountingCamera :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def antenna :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def gratingCoupler :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def acoustoOpticDeflector :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def electroOpticDeflector :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def memsMirror :> QuantumComputing::physicalLayerDefinitions::transducer;
    part def wavelengthConverter :> QuantumComputing::physicalLayerDefinitions::transducer;

    // ── Amplifiers ───────────────────────────────────────────────────
    part def lowNoiseAmplifier :> QuantumComputing::physicalLayerDefinitions::amplifier;
    part def microwaveAmplifier :> QuantumComputing::physicalLayerDefinitions::amplifier;

    // ── Passive signal conditioners ──────────────────────────────────
    part def signalFilter :> QuantumComputing::physicalLayerDefinitions::signalConditioner;
    part def lowPassbandFilter;
    part def attenuator :> QuantumComputing::physicalLayerDefinitions::signalConditioner;
    part def lens :> QuantumComputing::physicalLayerDefinitions::signalConditioner;
    part def circulator :> QuantumComputing::physicalLayerDefinitions::signalConditioner;
    part def cavity :> QuantumComputing::physicalLayerDefinitions::signalConditioner;
    part def beamSplitter :> QuantumComputing::physicalLayerDefinitions::signalConditioner;

    // ── Transmission media ───────────────────────────────────────────
    part def waveguide :> QuantumComputing::physicalLayerDefinitions::transmissionMedium;
    part def coaxialCable :> QuantumComputing::physicalLayerDefinitions::transmissionMedium;
    part def opticalFiber :> QuantumComputing::physicalLayerDefinitions::transmissionMedium;
    part def nanophotonicWaveguide :> QuantumComputing::physicalLayerDefinitions::transmissionMedium;

    // ── Classical processing ─────────────────────────────────────────
    part def fieldProgrammableGateArrays :> QuantumComputing::physicalLayerDefinitions::classicalProcessor;
    part def physicalControlUnit :> QuantumComputing::physicalLayerDefinitions::classicalProcessor;
    part def computerFPGA :> QuantumComputing::physicalLayerDefinitions::classicalProcessor;

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
    action def GenerateEnvelope :> QuantumComputing::physicalLayerDefinitions::GenerateSignal {
        out item envelope : QuantumComputing::physicalLayerDefinitions::digitalData;
        attribute pulseAmplitude;
        attribute pulseDuration : DurationValue;
        attribute pulseShape;
    }
    action def GenerateCarrier :> QuantumComputing::physicalLayerDefinitions::GenerateSignal {
        out item carrier : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        attribute carrierFrequency : FrequencyValue;
    }
    action def GenerateMicrowaveDrive :> QuantumComputing::physicalLayerDefinitions::GenerateSignal {
        out item drive : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        attribute driveFrequency : FrequencyValue;
    }
    action def GenerateLaserBeam :> QuantumComputing::physicalLayerDefinitions::GenerateSignal {
        out item beam : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        attribute wavelength;
    }
    action def SupplyBias :> QuantumComputing::physicalLayerDefinitions::GenerateSignal {
        out item bias : QuantumComputing::physicalLayerDefinitions::dcBias;
        attribute voltageStability;
    }
    action def IssueCommand :> QuantumComputing::physicalLayerDefinitions::GenerateSignal {
        out item command : QuantumComputing::physicalLayerDefinitions::digitalData;
    }

    // ── Transduction ─────────────────────────────────────────────────
    action def ConvertDigitalToAnalog :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item digitalInput : QuantumComputing::physicalLayerDefinitions::digitalData;
        out item analogOutput : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        attribute precision;
        attribute updateRate : FrequencyValue;
    }
    action def ConvertAnalogToDigital :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item analogInput : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item digitalOutput : QuantumComputing::physicalLayerDefinitions::digitalData;
        attribute resolution;
    }
    action def Upconvert :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item baseband : QuantumComputing::physicalLayerDefinitions::signal;
        out item waveform : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        in item carrier : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
    }
    action def Downconvert :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item waveform : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item baseband : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        in item referenceCarrier : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
    }
    action def RadiateBeam :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item feed : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item beam : QuantumComputing::physicalLayerDefinitions::signal;
    }
    action def ReceiveBeam :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item beam : QuantumComputing::physicalLayerDefinitions::signal;
        out item feed : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
    }
    action def EncodeOntoOptical :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item electricalInput : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item modulatedLight : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        in item opticalCarrier : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        attribute extinctionRatio;
        attribute insertionLoss;
        attribute powerConsumption;
        attribute modulationEfficiency;
    }
    action def RecoverElectricalSignal :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item modulatedLight : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        out item electricalOutput : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        in item bias : QuantumComputing::physicalLayerDefinitions::dcBias;
        attribute detectionWavelength;
        attribute outputImpedance;
        attribute bandwidth;
    }
    action def ConvertWavelength :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item inputPhoton : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        out item outputPhoton : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        in item pumpBeam : QuantumComputing::physicalLayerDefinitions::opticalSignal;
    }
    action def SynthesiseWaveform :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        // a signal generator driven by a digital command, as distinct from a
        // free-running source
        in item command : QuantumComputing::physicalLayerDefinitions::digitalData;
        out item waveform : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        attribute driveFrequency : FrequencyValue;
    }
    action def DeflectBeam :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item light : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        out item deflectedLight : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        in item drive : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
    }
    action def DetectPhotons :> QuantumComputing::physicalLayerDefinitions::ConvertSignal {
        in item light : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        out item count : QuantumComputing::physicalLayerDefinitions::digitalData;
        attribute quantumEfficiency;
        attribute darkCountRate : FrequencyValue;
        attribute exposureTime : DurationValue;
    }

    // ── Amplification ────────────────────────────────────────────────
    action def Amplify :> QuantumComputing::physicalLayerDefinitions::AmplifySignal {
        in item weakSignal : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item amplifiedSignal : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
    }

    // ── Signal conditioning ──────────────────────────────────────────
    action def FilterSignal :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item unfiltered : QuantumComputing::physicalLayerDefinitions::signal;
        out item filtered : QuantumComputing::physicalLayerDefinitions::signal;
    }
    action def AttenuateSignal :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item unattenuated : QuantumComputing::physicalLayerDefinitions::signal;
        out item attenuated : QuantumComputing::physicalLayerDefinitions::signal;
    }
    action def SteerBeam :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item beam : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        out item steeredBeam : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        attribute steeringRange;
    }
    action def FocusBeam :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item incomingBeam : QuantumComputing::physicalLayerDefinitions::signal;
        out item focusedBeam : QuantumComputing::physicalLayerDefinitions::signal;
        attribute beamDiameter;
    }
    action def CollectLight :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item emittedLight : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        out item collectedLight : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        attribute collectionEfficiency;
        attribute transmission;
    }
    action def RouteSignal :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item input : QuantumComputing::physicalLayerDefinitions::signal;
        out item output : QuantumComputing::physicalLayerDefinitions::signal;
    }
    action def Resonate :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item input : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        out item output : QuantumComputing::physicalLayerDefinitions::microwaveSignal;
        attribute qualityFactor;
    }
    action def SplitBeam :> QuantumComputing::physicalLayerDefinitions::ConditionSignal {
        in item input : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        out item outputA : QuantumComputing::physicalLayerDefinitions::opticalSignal;
        out item outputB : QuantumComputing::physicalLayerDefinitions::opticalSignal;
    }

    // ── Classical processing ─────────────────────────────────────────
    action def EvaluateMeasurement :> QuantumComputing::physicalLayerDefinitions::ProcessData {
        // intermediate evaluation whose result feeds a further action
        in item measurement : QuantumComputing::physicalLayerDefinitions::digitalData;
        out item result : QuantumComputing::physicalLayerDefinitions::digitalData;
    }
    action def AnalyseMeasurement :> QuantumComputing::physicalLayerDefinitions::ProcessData {
        // terminal analysis yielding the qubit state
        in item measurement : QuantumComputing::physicalLayerDefinitions::digitalData;
        out item qubitState : QuantumComputing::physicalLayerDefinitions::digitalData;
        attribute readoutFidelity;
        attribute detectionWindow : DurationValue;
    }
    action def ApplyFeedback :> QuantumComputing::physicalLayerDefinitions::ProcessData {
        in item measurement : QuantumComputing::physicalLayerDefinitions::digitalData;
        out item feedback : QuantumComputing::physicalLayerDefinitions::digitalData;
        attribute feedbackLatency : DurationValue;
    }
    action def BufferStream :> QuantumComputing::physicalLayerDefinitions::ProcessData {
        in item streamIn : QuantumComputing::physicalLayerDefinitions::digitalData;
        out item streamOut : QuantumComputing::physicalLayerDefinitions::digitalData;
    }
}
