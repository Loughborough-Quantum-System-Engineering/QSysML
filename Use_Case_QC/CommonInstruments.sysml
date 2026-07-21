// Technology-agnostic classical instruments, shared across qubit platforms.
// Each specialises a functional role from QuantumComputing::physicalLayerDefinitions.
package CommonInstruments {
    public import QuantumComputing::physicalLayerDefinitions::*;

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
    part def filter :> signalConditioner;
    part def lowPassbandFilter :> filter;
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
}
