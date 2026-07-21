// reference
// @article{brennan2025classical,
//  title={Classical interfaces for controlling cryogenic quantum computing technologies},
//  author={Brennan, Jack C and Barbosa, Jo{\~a}o and Li, Chong and Ahmad, Meraj and Imroze, Fiheon and Rose, Calum and Karar, Wridhdhisom and Stanley, Manoj and Heidari, Hadi and Ridler, Nick M and others},
//  journal={APL Quantum},
// volume={2},
//  number={4},
//  year={2025},
//  publisher={AIP Publishing}
// }

package CryoCMOSInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import SuperconductingCommon::*;
    public import ISQ::*;
    public import SI::*;
    part cryoCMOSControlSystem : classicalControlSystem {
        part controlPowerSource : powerSource {
            port powerOut : dcBiasPort;
        }
        part preLoadedData {
            port sequenceOut : digitalPort;
        }
        port powerOut : dcBiasPort;
        port sequenceOut : digitalPort;
        flow controlPowerSource.powerOut to powerOut;
        flow preLoadedData.sequenceOut to sequenceOut;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        port controlPowerIn : ~dcBiasPort;
        port sequenceIn : ~digitalPort;
        port readoutPowerIn : ~dcBiasPort;
        port resultOut : digitalPort;
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part cryoCMOSProcessor {
                port controlPowerIn : ~dcBiasPort;
                port readoutPowerIn : ~dcBiasPort;
                port sequenceIn : ~digitalPort;
                port driveOut : microwavePort;
                port readoutIn : ~microwavePort;
                port resultOut : digitalPort;
            }
            part qpu : QPU {
                attribute redefines technology = qubitTechnology::superconducting;
                port driveIn : ~microwavePort;
                port readoutOut : microwavePort;
            }
            flow cryoCMOSProcessor.driveOut to qpu.driveIn;
            flow qpu.readoutOut to cryoCMOSProcessor.readoutIn;
        }
        flow controlPowerIn to sixthLayer.cryoCMOSProcessor.controlPowerIn;
        flow sequenceIn to sixthLayer.cryoCMOSProcessor.sequenceIn;
        flow readoutPowerIn to sixthLayer.cryoCMOSProcessor.readoutPowerIn;
        flow sixthLayer.cryoCMOSProcessor.resultOut to resultOut;
    }
    part cryoCMOSReadoutSystem : classicalReadoutSystem {
        part readoutPowerSource : powerSource {
            port powerOut : dcBiasPort;
        }
        part postProcessingElectronics {
            port resultIn : ~digitalPort;
        }
        port powerOut : dcBiasPort;
        port resultIn : ~digitalPort;
        flow readoutPowerSource.powerOut to powerOut;
        flow resultIn to postProcessingElectronics.resultIn;
    }
    flow cryoCMOSControlSystem.powerOut to dilutionRefrigeratorEnv.controlPowerIn;
    flow cryoCMOSControlSystem.sequenceOut to dilutionRefrigeratorEnv.sequenceIn;
    flow cryoCMOSReadoutSystem.powerOut to dilutionRefrigeratorEnv.readoutPowerIn;
    flow dilutionRefrigeratorEnv.resultOut to cryoCMOSReadoutSystem.resultIn;
}
