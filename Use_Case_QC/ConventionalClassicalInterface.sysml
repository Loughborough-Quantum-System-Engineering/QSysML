package ConventionalClassicalInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part conventionalControlSystem : classicalControlSystem {
        part controlAWGFPGA : awgFPGA;
        part dac : digitalToAnalogConverter;
        part powerSource : powerSource;
        part controlIqMixer : iqMixer;
        part controlLocalOscillator : localOscillator;
        part controlFilter;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part waveguide;
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part waveguide;
            part controlFilter;
            part lowNoiseAmplifier;
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part waveguide;
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part qpu : QPU;
            part cavity;
            part circulator;
            part josephsonParametricAmplifier;
        }
    }
    part conventionalReadoutSystem : classicalRTeadoutSystem {
        part readoutFilter;
        part lowNoiseAmplifier;
        part readoutIqMixer1 : iqMixer;
        part readoutIqMixer2 : iqMixer;
        part readoutLocalOscillator : localOscillator;
        part adc : analogToDigitalConverter;
        part readoutAWGFPGA : awgFPGA;
        part computerFpga;
    }
}
