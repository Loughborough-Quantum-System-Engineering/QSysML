package SingleFluxQuantumInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import SuperconductingCommon::*;
    public import ISQ::*;
    public import SI::*;
    part sfqControlSystem : classicalControlSystem {
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
        part dcSfqBias : powerSource {
            port biasOut : dcBiasPort;
        }
        port triggerToneOut : microwavePort;
        port dcSfqBiasOut : dcBiasPort;
        flow controlAWGFPGA.envelopeOut to dac.digitalIn;
        flow dac.analogOut to controlIqMixer.ifIn;
        flow controlLocalOscillator.carrierOut to controlIqMixer.loIn;
        flow controlIqMixer.rfOut to controlFilter.filterIn;
        flow controlFilter.filterOut to triggerToneOut;
        flow dcSfqBias.biasOut to dcSfqBiasOut;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        port triggerToneIn : ~microwavePort;
        port dcSfqBiasIn : ~dcBiasPort;
        port sfqDcBiasIn : ~dcBiasPort;
        port readoutOut : microwavePort;
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part dcSfqBiasFilter {
                port filterIn : ~dcBiasPort;
                port filterOut : dcBiasPort;
            }
            part sfqDcBiasFilter {
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
            part controlSfqChip {
                port triggerToneIn : ~microwavePort;
                port biasIn : ~dcBiasPort;
                port pulseTrainOut : sfqPort;
            }
            part qpu : QPU {
                attribute redefines technology = qubitTechnology::superconducting;
                port pulseTrainIn : ~sfqPort;
                port cavityOut : microwavePort;
            }
            part cavity {
                port qubitIn : ~microwavePort;
                port photonOut : microwavePort;
            }
            part josephsonPhotomultiplier {
                port photonIn : ~microwavePort;
                port circulatingCurrentOut : magneticFieldPort;
            }
            part josephsonTransmissionLine {
                port circulatingCurrentIn : ~magneticFieldPort;
                port fluxonOut : sfqPort;
            }
            part readoutSfqChip {
                port fluxonIn : ~sfqPort;
                port biasIn : ~dcBiasPort;
                port readoutOut : microwavePort;
            }
            flow controlSfqChip.pulseTrainOut to qpu.pulseTrainIn;
            flow qpu.cavityOut to cavity.qubitIn;
            flow cavity.photonOut to josephsonPhotomultiplier.photonIn;
            flow josephsonPhotomultiplier.circulatingCurrentOut to josephsonTransmissionLine.circulatingCurrentIn;
            flow josephsonTransmissionLine.fluxonOut to readoutSfqChip.fluxonIn;
        }
        flow triggerToneIn to sixthLayer.controlSfqChip.triggerToneIn;
        flow dcSfqBiasIn to thirdLayer.dcSfqBiasFilter.filterIn;
        flow thirdLayer.dcSfqBiasFilter.filterOut to sixthLayer.controlSfqChip.biasIn;
        flow sfqDcBiasIn to thirdLayer.sfqDcBiasFilter.filterIn;
        flow thirdLayer.sfqDcBiasFilter.filterOut to sixthLayer.readoutSfqChip.biasIn;
        flow sixthLayer.readoutSfqChip.readoutOut to thirdLayer.lowNoiseAmplifier.ampIn;
        flow thirdLayer.lowNoiseAmplifier.ampOut to readoutOut;
    }
    part sfqReadoutSystem : classicalReadoutSystem {
        part lowNoiseAmplifier {
            port ampIn : ~microwavePort;
            port ampOut : microwavePort;
        }
        part readoutLocalOscillator : localOscillator {
            port carrierOut : microwavePort;
        }
        part readoutIqMixer : iqMixer {
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
        part sfqDcBias : powerSource {
            port biasOut : dcBiasPort;
        }
        port readoutIn : ~microwavePort;
        port sfqDcBiasOut : dcBiasPort;
        flow readoutIn to lowNoiseAmplifier.ampIn;
        flow lowNoiseAmplifier.ampOut to readoutIqMixer.rfIn;
        flow readoutLocalOscillator.carrierOut to readoutIqMixer.loIn;
        flow readoutIqMixer.ifOut to readoutFilter.filterIn;
        flow readoutFilter.filterOut to adc.analogIn;
        flow adc.digitalOut to computerFpga.resultIn;
        flow sfqDcBias.biasOut to sfqDcBiasOut;
    }
    flow sfqControlSystem.triggerToneOut to dilutionRefrigeratorEnv.triggerToneIn;
    flow sfqControlSystem.dcSfqBiasOut to dilutionRefrigeratorEnv.dcSfqBiasIn;
    flow sfqReadoutSystem.sfqDcBiasOut to dilutionRefrigeratorEnv.sfqDcBiasIn;
    flow dilutionRefrigeratorEnv.readoutOut to sfqReadoutSystem.readoutIn;
}
