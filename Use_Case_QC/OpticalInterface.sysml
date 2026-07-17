package OpticalInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part opticalControlSystem : classicalControlSystem {
        part controlAWGFPGA : awgFPGA;
        part dac : digitalToAnalogConverter;
        part controlIqMixer : iqMixer;
        part controlLocalOscillator : localOscillator;
        part controlFilter;
        part controlElectroOpticalModulator;
        part controlLaserSource;
        part pdBias : powerSource;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part biasFilter;
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part qpu : QPU;
            part controlPhotodiode;
            part lowNoiseAmplifier;
            part readoutElectroOpticalModulator;
        }
    }
    part opticalReadoutSystem : classicalReadoutSystem {
        part computerFpga;
        part adc : analogToDigitalConverter;
        part readoutIqMixer : iqMixer;
        part readoutLocalOscillator : localOscillator;
        part readoutFilter;
        part readoutPhotodiode;
        part readoutLaserSource;
    }
}
