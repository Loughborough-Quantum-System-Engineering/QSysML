package ConventionalClassicalInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part conventionalControlSystem : classicalControlSystem {
        part controlAWGFPGA : awgFPGA {
            port envelopeOut : digitalPort;
        }
        part dac : digitalToAnalogConverter {
            port digitalIn : ~digitalPort;
            port analogOut : microwavePort;
        }
        part controlLocalOscillator : localOscillator {
            port carrierOut : microwavePort;
        }
        part controlIqMixer : iqMixer {
            port ifIn : ~microwavePort;
            port loIn : ~microwavePort;
            port rfOut : microwavePort;
        }
        part controlFilter {
            port filterIn : ~microwavePort;
            port filterOut : microwavePort;
        }
        part qubitBias : powerSource {
            port biasOut : dcBiasPort;
        }
        port driveOut : microwavePort;
        port qubitBiasOut : dcBiasPort;
        flow controlAWGFPGA.envelopeOut to dac.digitalIn;
        flow dac.analogOut to controlIqMixer.ifIn;
        flow controlLocalOscillator.carrierOut to controlIqMixer.loIn;
        flow controlIqMixer.rfOut to controlFilter.filterIn;
        flow controlFilter.filterOut to driveOut;
        flow qubitBias.biasOut to qubitBiasOut;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        port driveIn : ~microwavePort;
        port biasIn : ~dcBiasPort;
        port probeIn : ~microwavePort;
        port readoutOut : microwavePort;
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part biasFilter {
                port filterIn : ~dcBiasPort;
                port filterOut : dcBiasPort;
            }
            part lowNoiseAmplifier {
                port ampIn : ~microwavePort;
                port ampOut : microwavePort;
            }
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part qpu : QPU {
                attribute redefines technology = qubitTechnology::superconducting;
                port driveIn : ~microwavePort;
                port biasIn : ~dcBiasPort;
                port cavityOut : microwavePort;
            }
            part cavity {
                port qubitIn : ~microwavePort;
                port probeIn : ~microwavePort;
                port probeOut : microwavePort;
            }
            part circulator {
                port cavityIn : ~microwavePort;
                port jpaOut : microwavePort;
                port jpaIn : ~microwavePort;
                port readoutOut : microwavePort;
            }
            part josephsonParametricAmplifier {
                port signalIn : ~microwavePort;
                port signalOut : microwavePort;
            }
            flow qpu.cavityOut to cavity.qubitIn;
            flow cavity.probeOut to circulator.cavityIn;
            flow circulator.jpaOut to josephsonParametricAmplifier.signalIn;
            flow josephsonParametricAmplifier.signalOut to circulator.jpaIn;
        }
        flow driveIn to sixthLayer.qpu.driveIn;
        flow biasIn to thirdLayer.biasFilter.filterIn;
        flow thirdLayer.biasFilter.filterOut to sixthLayer.qpu.biasIn;
        flow probeIn to sixthLayer.cavity.probeIn;
        flow sixthLayer.circulator.readoutOut to thirdLayer.lowNoiseAmplifier.ampIn;
        flow thirdLayer.lowNoiseAmplifier.ampOut to readoutOut;
    }
    part conventionalReadoutSystem : classicalReadoutSystem {
        part readoutAWGFPGA : awgFPGA {
            port envelopeOut : digitalPort;
        }
        part readoutLocalOscillator : localOscillator {
            port carrierOut : microwavePort;
        }
        part readoutIqMixer1 : iqMixer {
            port ifIn : ~digitalPort;
            port loIn : ~microwavePort;
            port rfOut : microwavePort;
        }
        part lowNoiseAmplifier {
            port ampIn : ~microwavePort;
            port ampOut : microwavePort;
        }
        part readoutIqMixer2 : iqMixer {
            port rfIn : ~microwavePort;
            port loIn : ~microwavePort;
            port ifOut : microwavePort;
        }
        part readoutFilter {
            port filterIn : ~microwavePort;
            port filterOut : microwavePort;
        }
        part adc : analogToDigitalConverter {
            port analogIn : ~microwavePort;
            port digitalOut : digitalPort;
        }
        part computerFpga {
            port resultIn : ~digitalPort;
        }
        port probeOut : microwavePort;
        port readoutIn : ~microwavePort;
        flow readoutAWGFPGA.envelopeOut to readoutIqMixer1.ifIn;
        flow readoutLocalOscillator.carrierOut to readoutIqMixer1.loIn;
        flow readoutIqMixer1.rfOut to probeOut;
        flow readoutIn to lowNoiseAmplifier.ampIn;
        flow lowNoiseAmplifier.ampOut to readoutIqMixer2.rfIn;
        flow readoutLocalOscillator.carrierOut to readoutIqMixer2.loIn;
        flow readoutIqMixer2.ifOut to readoutFilter.filterIn;
        flow readoutFilter.filterOut to adc.analogIn;
        flow adc.digitalOut to computerFpga.resultIn;
    }
    flow conventionalControlSystem.driveOut to dilutionRefrigeratorEnv.driveIn;
    flow conventionalControlSystem.qubitBiasOut to dilutionRefrigeratorEnv.biasIn;
    flow conventionalReadoutSystem.probeOut to dilutionRefrigeratorEnv.probeIn;
    flow dilutionRefrigeratorEnv.readoutOut to conventionalReadoutSystem.readoutIn;
}
