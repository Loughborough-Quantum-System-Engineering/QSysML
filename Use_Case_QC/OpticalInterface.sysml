package OpticalInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part opticalControlSystem : classicalControlSystem {
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
        part controlLaserSource {
            port carrierOut : opticalPort;
        }
        part controlElectroOpticalModulator {
            port rfIn : ~microwavePort;
            port carrierIn : ~opticalPort;
            port modulatedOut : opticalPort;
        }
        part pdBias : powerSource {
            port biasOut : dcBiasPort;
        }
        port driveOpticalOut : opticalPort;
        port pdBiasOut : dcBiasPort;
        flow controlAWGFPGA.envelopeOut to dac.digitalIn;
        flow dac.analogOut to controlIqMixer.ifIn;
        flow controlLocalOscillator.carrierOut to controlIqMixer.loIn;
        flow controlIqMixer.rfOut to controlFilter.filterIn;
        flow controlFilter.filterOut to controlElectroOpticalModulator.rfIn;
        flow controlLaserSource.carrierOut to controlElectroOpticalModulator.carrierIn;
        flow controlElectroOpticalModulator.modulatedOut to driveOpticalOut;
        flow pdBias.biasOut to pdBiasOut;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        port driveOpticalIn : ~opticalPort;
        port pdBiasIn : ~dcBiasPort;
        port readoutCarrierIn : ~opticalPort;
        port readoutOpticalOut : opticalPort;
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
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part controlPhotodiode {
                port opticalIn : ~opticalPort;
                port biasIn : ~dcBiasPort;
                port rfOut : microwavePort;
            }
            part qpu : QPU {
                attribute redefines technology = qubitTechnology::superconducting;
                port driveIn : ~microwavePort;
                port readoutOut : microwavePort;
            }
            part lowNoiseAmplifier {
                port ampIn : ~microwavePort;
                port ampOut : microwavePort;
            }
            part readoutElectroOpticalModulator {
                port rfIn : ~microwavePort;
                port carrierIn : ~opticalPort;
                port modulatedOut : opticalPort;
            }
            flow controlPhotodiode.rfOut to qpu.driveIn;
            flow qpu.readoutOut to lowNoiseAmplifier.ampIn;
            flow lowNoiseAmplifier.ampOut to readoutElectroOpticalModulator.rfIn;
        }
        flow driveOpticalIn to sixthLayer.controlPhotodiode.opticalIn;
        flow pdBiasIn to thirdLayer.biasFilter.filterIn;
        flow thirdLayer.biasFilter.filterOut to sixthLayer.controlPhotodiode.biasIn;
        flow readoutCarrierIn to sixthLayer.readoutElectroOpticalModulator.carrierIn;
        flow sixthLayer.readoutElectroOpticalModulator.modulatedOut to readoutOpticalOut;
    }
    part opticalReadoutSystem : classicalReadoutSystem {
        part readoutLaserSource {
            port carrierOut : opticalPort;
        }
        part readoutPhotodiode {
            port opticalIn : ~opticalPort;
            port rfOut : microwavePort;
        }
        part readoutFilter {
            port filterIn : ~microwavePort;
            port filterOut : microwavePort;
        }
        part readoutLocalOscillator : localOscillator {
            port carrierOut : microwavePort;
        }
        part readoutIqMixer : iqMixer {
            port rfIn : ~microwavePort;
            port loIn : ~microwavePort;
            port ifOut : microwavePort;
        }
        part adc : analogToDigitalConverter {
            port analogIn : ~microwavePort;
            port digitalOut : digitalPort;
        }
        part computerFpga {
            port resultIn : ~digitalPort;
        }
        port readoutCarrierOut : opticalPort;
        port readoutOpticalIn : ~opticalPort;
        flow readoutLaserSource.carrierOut to readoutCarrierOut;
        flow readoutOpticalIn to readoutPhotodiode.opticalIn;
        flow readoutPhotodiode.rfOut to readoutFilter.filterIn;
        flow readoutFilter.filterOut to readoutIqMixer.rfIn;
        flow readoutLocalOscillator.carrierOut to readoutIqMixer.loIn;
        flow readoutIqMixer.ifOut to adc.analogIn;
        flow adc.digitalOut to computerFpga.resultIn;
    }
    flow opticalControlSystem.driveOpticalOut to dilutionRefrigeratorEnv.driveOpticalIn;
    flow opticalControlSystem.pdBiasOut to dilutionRefrigeratorEnv.pdBiasIn;
    flow opticalReadoutSystem.readoutCarrierOut to dilutionRefrigeratorEnv.readoutCarrierIn;
    flow dilutionRefrigeratorEnv.readoutOpticalOut to opticalReadoutSystem.readoutOpticalIn;
}
