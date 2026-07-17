package SingleFluxQuantumInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part sfqControlSystem : classicalControlSystem {
        part controlAWGFPGA : awgFPGA;
        part dac : digitalToAnalogConverter;
        part dcSfqBias : powerSource;
        part controlIqMixer : iqMixer;
        part controlLocalOscillator : localOscillator;
        part controlFilter;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part waveguide;
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part waveguide;
            part controlFilter;
            part lowNoiseAmplifier;
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part waveguide;
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part qpu : QPU;
            part cavity;
            part controlSfqChip;
            part josephsonPhotomultiplier;
            part josephsonTransmissionLine;
            part readoutSfqChip;
        }
    }
    part sfqReadoutSystem : classicalReadoutSystem {
        part readoutFilter;
        part lowNoiseAmplifier;
        part readoutIqMixer : iqMixer;
        part readoutLocalOscillator : localOscillator;
        part adc : analogToDigitalConverter;
        part computerFpga;
        part sfqDcBias : powerSource;
    }
}
