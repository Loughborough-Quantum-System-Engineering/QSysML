package NeutralAtomInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part neutralAtomControlSystem : classicalControlSystem {
        part realTimeControlBackend {
            part armProcessor {
                port configOut : digitalPort;
            }
            part imageProcessingModule {
                port imageIn : ~digitalPort;
                port configIn : ~digitalPort;
                port occupancyOut : digitalPort;
                port emissionsOut : digitalPort;
            }
            part atomRearrangementEngine {
                part dataLoader;
                part stateArrayBram;
                part targetGeometryBram;
                part rearrangementCore {
                    part neighborhoodScanner;
                    part channelComparator;
                }
                part moveEncoder;
                port occupancyIn : ~digitalPort;
                port geometryIn : ~digitalPort;
                port movesOut : digitalPort;
            }
            part controlInterfaceModule {
                port configIn : ~digitalPort;
            }
            part axiStreamFifo {
                port movesIn : ~digitalPort;
                port movesOut : digitalPort;
            }
            port imageIn : ~digitalPort;
            port occupancyToRearrange : digitalPort;
            port movesOut : digitalPort;
            port emissionsOut : digitalPort;
            flow armProcessor.configOut to imageProcessingModule.configIn;
            flow armProcessor.configOut to atomRearrangementEngine.geometryIn;
            flow imageIn to imageProcessingModule.imageIn;
            flow imageProcessingModule.occupancyOut to atomRearrangementEngine.occupancyIn;
            flow atomRearrangementEngine.movesOut to axiStreamFifo.movesIn;
            flow axiStreamFifo.movesOut to movesOut;
            flow imageProcessingModule.emissionsOut to emissionsOut;
        }
        part controlProcessor {
            port gateInstrOut : digitalPort;
            port measResultIn : ~digitalPort;
        }
        part signalGenerator {
            port moveDataIn : ~digitalPort;
            port gateInstrIn : ~digitalPort;
            port rfToneOut : microwavePort;
            port microwaveGateOut : microwavePort;
        }
        part acoustoOpticDeflector {
            port rfIn : ~microwavePort;
            port trapLightIn : ~opticalPort;
            port tweezerOut : opticalPort;
        }
        part laserSystem {
            part trappingLaser {
                port beamOut : opticalPort;
            }
            part rydbergGateLaser {
                port beamOut : opticalPort;
            }
            part coolingLaser {
                port beamOut : opticalPort;
            }
            part imagingLaser {
                port beamOut : opticalPort;
            }
            port trapOut : opticalPort;
            port rydbergOut : opticalPort;
            port coolingOut : opticalPort;
            port imagingOut : opticalPort;
            flow trappingLaser.beamOut to trapOut;
            flow rydbergGateLaser.beamOut to rydbergOut;
            flow coolingLaser.beamOut to coolingOut;
            flow imagingLaser.beamOut to imagingOut;
        }
        port fluorescenceImageIn : ~digitalPort;
        port tweezerOut : opticalPort;
        port microwaveGateOut : microwavePort;
        port rydbergBeamOut : opticalPort;
        port coolingBeamOut : opticalPort;
        port imagingBeamOut : opticalPort;
        port emissionsOut : digitalPort;
        port measResultIn : ~digitalPort;
        flow fluorescenceImageIn to realTimeControlBackend.imageIn;
        flow realTimeControlBackend.movesOut to signalGenerator.moveDataIn;
        flow controlProcessor.gateInstrOut to signalGenerator.gateInstrIn;
        flow signalGenerator.rfToneOut to acoustoOpticDeflector.rfIn;
        flow laserSystem.trapOut to acoustoOpticDeflector.trapLightIn;
        flow acoustoOpticDeflector.tweezerOut to tweezerOut;
        flow signalGenerator.microwaveGateOut to microwaveGateOut;
        flow laserSystem.rydbergOut to rydbergBeamOut;
        flow laserSystem.coolingOut to coolingBeamOut;
        flow laserSystem.imagingOut to imagingBeamOut;
        flow realTimeControlBackend.emissionsOut to emissionsOut;
        flow measResultIn to controlProcessor.measResultIn;
    }
    part vacuumChamberEnv {
        attribute pressure : PressureUnit;
        port tweezerIn : ~opticalPort;
        port microwaveGateIn : ~microwavePort;
        port rydbergIn : ~opticalPort;
        port coolingIn : ~opticalPort;
        port imagingIn : ~opticalPort;
        port imageOut : digitalPort;
        part viewport;
        part vacuumPump;
        part qpu : QPU {
            attribute redefines technology = qubitTechnology::neutralAtom;
            port tweezerIn : ~opticalPort;
            port microwaveGateIn : ~microwavePort;
            port rydbergIn : ~opticalPort;
            port coolingIn : ~opticalPort;
            port imagingIn : ~opticalPort;
            port fluorescenceOut : opticalPort;
        }
        part camera {
            port fluorescenceIn : ~opticalPort;
            port imageOut : digitalPort;
        }
        flow tweezerIn to qpu.tweezerIn;
        flow microwaveGateIn to qpu.microwaveGateIn;
        flow rydbergIn to qpu.rydbergIn;
        flow coolingIn to qpu.coolingIn;
        flow imagingIn to qpu.imagingIn;
        flow qpu.fluorescenceOut to camera.fluorescenceIn;
        flow camera.imageOut to imageOut;
    }
    part neutralAtomReadoutSystem : classicalReadoutSystem {
        part stateReadoutEvaluation {
            port emissionsIn : ~digitalPort;
            port resultOut : digitalPort;
        }
        part conditionalFeedback {
            port resultIn : ~digitalPort;
            port feedbackOut : digitalPort;
        }
        port emissionsIn : ~digitalPort;
        port feedbackOut : digitalPort;
        flow emissionsIn to stateReadoutEvaluation.emissionsIn;
        flow stateReadoutEvaluation.resultOut to conditionalFeedback.resultIn;
        flow conditionalFeedback.feedbackOut to feedbackOut;
    }
    flow neutralAtomControlSystem.tweezerOut to vacuumChamberEnv.tweezerIn;
    flow neutralAtomControlSystem.microwaveGateOut to vacuumChamberEnv.microwaveGateIn;
    flow neutralAtomControlSystem.rydbergBeamOut to vacuumChamberEnv.rydbergIn;
    flow neutralAtomControlSystem.coolingBeamOut to vacuumChamberEnv.coolingIn;
    flow neutralAtomControlSystem.imagingBeamOut to vacuumChamberEnv.imagingIn;
    flow vacuumChamberEnv.imageOut to neutralAtomControlSystem.fluorescenceImageIn;
    flow neutralAtomControlSystem.emissionsOut to neutralAtomReadoutSystem.emissionsIn;
    flow neutralAtomReadoutSystem.feedbackOut to neutralAtomControlSystem.measResultIn;
}
