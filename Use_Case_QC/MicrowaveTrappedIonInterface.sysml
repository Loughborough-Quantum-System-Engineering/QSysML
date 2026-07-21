// reference
// @article{lekitsch2017blueprint,
//  title={Blueprint for a microwave trapped ion quantum computer},
//  author={Lekitsch, Bjoern and Weidt, Sebastian and Fowler, Austin G and M{\o}lmer, Klaus and Devitt, Simon J and Wunderlich, Christof and Hensinger, Winfried K},
//  journal={Science Advances},
//  volume={3},
//  number={2},
//  pages={e1601540},
//  year={2017},
//  publisher={American Association for the Advancement of Science}
// }

package MicrowaveTrappedIonInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import ISQ::*;
    public import SI::*;
    part microwaveControlSystem : classicalControlSystem {
        part globalFrequencyGenerator : microwaveSource {
            port toneOut : microwavePort;
        }
        part microwaveAmplifier {
            port ampIn : ~microwavePort;
            port ampOut : microwavePort;
        }
        part radiationEmitter {
            port feedIn : ~microwavePort;
            port globalFieldOut : microwavePort;
        }
        part rfFrequencySource {
            port rfOut : microwavePort;
        }
        part helicalResonator {
            part variableCapacitor;
            port rfIn : ~microwavePort;
            port rfOut : microwavePort;
        }
        part digitalController {
            port controlOut : digitalPort;
        }
        part globalLaserSystem {
            part photoionisationLaser {
                port beamOut : opticalPort;
            }
            part dopplerCoolingLaser {
                port beamOut : opticalPort;
            }
            part statePreparationLaser {
                port beamOut : opticalPort;
            }
            part sympatheticCoolingLaser {
                port beamOut : opticalPort;
            }
            part inVacuumBeamSteeringOptics {
                port photoionisationIn : ~opticalPort;
                port coolingIn : ~opticalPort;
                port statePrepIn : ~opticalPort;
                port sympatheticIn : ~opticalPort;
                port sheetOut : opticalPort;
            }
            port laserSheetOut : opticalPort;
            flow photoionisationLaser.beamOut to inVacuumBeamSteeringOptics.photoionisationIn;
            flow dopplerCoolingLaser.beamOut to inVacuumBeamSteeringOptics.coolingIn;
            flow statePreparationLaser.beamOut to inVacuumBeamSteeringOptics.statePrepIn;
            flow sympatheticCoolingLaser.beamOut to inVacuumBeamSteeringOptics.sympatheticIn;
            flow inVacuumBeamSteeringOptics.sheetOut to laserSheetOut;
        }
        port globalMicrowaveOut : microwavePort;
        port rfTrapDriveOut : microwavePort;
        port laserSheetOut : opticalPort;
        port digitalControlOut : digitalPort;
        flow globalFrequencyGenerator.toneOut to microwaveAmplifier.ampIn;
        flow microwaveAmplifier.ampOut to radiationEmitter.feedIn;
        flow radiationEmitter.globalFieldOut to globalMicrowaveOut;
        flow rfFrequencySource.rfOut to helicalResonator.rfIn;
        flow helicalResonator.rfOut to rfTrapDriveOut;
        flow globalLaserSystem.laserSheetOut to laserSheetOut;
        flow digitalController.controlOut to digitalControlOut;
    }
    part vacuumChamberEnv {
        attribute pressure : PressureUnit;
        port globalMicrowaveIn : ~microwavePort;
        port rfTrapDriveIn : ~microwavePort;
        port laserSheetIn : ~opticalPort;
        port digitalControlIn : ~digitalPort;
        port readoutExcitationIn : ~opticalPort;
        port photonCountOut : digitalPort;
        part viewport {
            port beamIn : ~opticalPort;
            port beamOut : opticalPort;
        }
        part readoutViewport {
            port beamIn : ~opticalPort;
            port beamOut : opticalPort;
        }
        part vacuumPump;
        part liquidNitrogenHeatShield;
        part electricalFeedthrough {
            port signalIn : ~digitalPort;
            port signalOut : digitalPort;
        }
        part steelFrame;
        part quantumComputerModule {
            attribute temp : ThermodynamicTemperatureUnit = 72 [K];
            part qpu : QPU {
                attribute redefines technology = qubitTechnology::trappedIon;
                port globalMicrowaveIn : ~microwavePort;
                port rfTrapIn : ~microwavePort;
                port gradientIn : ~magneticFieldPort;
                port electrodeVoltageIn : ~dcBiasPort;
                port laserSheetIn : ~opticalPort;
                port readoutExcitationIn : ~opticalPort;
                port fluorescenceOut : opticalPort;
            }
            part gradientWire {
                port currentIn : ~dcBiasPort;
                port gradientOut : magneticFieldPort;
            }
            part localBFieldCoil {
                port currentIn : ~dcBiasPort;
                port offsetFieldOut : magneticFieldPort;
            }
            part itoElectrode {
                port photonIn : ~opticalPort;
                port photonOut : opticalPort;
            }
            part embeddedPhotonCounter {
                attribute temp : ThermodynamicTemperatureUnit = 77 [K];
                port photonIn : ~opticalPort;
                port countOut : digitalPort;
            }
            part electronicsLayer {
                part fpga : fieldProgrammableGateArrays {
                    port controlIn : ~digitalPort;
                    port dacDriveOut : digitalPort;
                }
                part inVacuumDac : digitalToAnalogConverter {
                    port digitalIn : ~digitalPort;
                    port coilCurrentOut : dcBiasPort;
                    port electrodeVoltageOut : dcBiasPort;
                }
                part rcFilter {
                    port filterIn : ~dcBiasPort;
                    port filterOut : dcBiasPort;
                }
                part throughSiliconVia;
                port controlIn : ~digitalPort;
                port coilCurrentOut : dcBiasPort;
                port electrodeVoltageOut : dcBiasPort;
                flow controlIn to fpga.controlIn;
                flow fpga.dacDriveOut to inVacuumDac.digitalIn;
                flow inVacuumDac.coilCurrentOut to coilCurrentOut;
                flow inVacuumDac.electrodeVoltageOut to rcFilter.filterIn;
                flow rcFilter.filterOut to electrodeVoltageOut;
            }
            part controlUnit : physicalControlUnit {
                port countIn : ~digitalPort;
                port resultOut : digitalPort;
            }
            part microchannelCooler {
                attribute coolantTemp : ThermodynamicTemperatureUnit = 65 [K];
                part coolantTubing;
            }
            part supportStructure {
                part piezoActuator;
                part diffractionGrating;
            }
            port globalMicrowaveIn : ~microwavePort;
            port rfTrapIn : ~microwavePort;
            port laserSheetIn : ~opticalPort;
            port readoutExcitationIn : ~opticalPort;
            port digitalControlIn : ~digitalPort;
            port resultOut : digitalPort;
            flow globalMicrowaveIn to qpu.globalMicrowaveIn;
            flow rfTrapIn to qpu.rfTrapIn;
            flow laserSheetIn to qpu.laserSheetIn;
            flow readoutExcitationIn to qpu.readoutExcitationIn;
            flow digitalControlIn to electronicsLayer.controlIn;
            flow electronicsLayer.coilCurrentOut to gradientWire.currentIn;
            flow electronicsLayer.coilCurrentOut to localBFieldCoil.currentIn;
            flow electronicsLayer.electrodeVoltageOut to qpu.electrodeVoltageIn;
            flow gradientWire.gradientOut to qpu.gradientIn;
            flow localBFieldCoil.offsetFieldOut to qpu.gradientIn;
            flow qpu.fluorescenceOut to itoElectrode.photonIn;
            flow itoElectrode.photonOut to embeddedPhotonCounter.photonIn;
            flow embeddedPhotonCounter.countOut to controlUnit.countIn;
            flow controlUnit.resultOut to resultOut;
        }
        flow globalMicrowaveIn to quantumComputerModule.globalMicrowaveIn;
        flow rfTrapDriveIn to quantumComputerModule.rfTrapIn;
        flow laserSheetIn to viewport.beamIn;
        flow viewport.beamOut to quantumComputerModule.laserSheetIn;
        flow readoutExcitationIn to readoutViewport.beamIn;
        flow readoutViewport.beamOut to quantumComputerModule.readoutExcitationIn;
        flow digitalControlIn to electricalFeedthrough.signalIn;
        flow electricalFeedthrough.signalOut to quantumComputerModule.digitalControlIn;
        flow quantumComputerModule.resultOut to photonCountOut;
    }
    part microwaveReadoutSystem : classicalReadoutSystem {
        part readoutExcitationLaser {
            port beamOut : opticalPort;
        }
        part detectionSystem {
            port countIn : ~digitalPort;
            port resultOut : digitalPort;
        }
        part readoutControlUnit {
            port resultIn : ~digitalPort;
        }
        port readoutExcitationOut : opticalPort;
        port photonCountIn : ~digitalPort;
        flow readoutExcitationLaser.beamOut to readoutExcitationOut;
        flow photonCountIn to detectionSystem.countIn;
        flow detectionSystem.resultOut to readoutControlUnit.resultIn;
    }
    flow microwaveControlSystem.globalMicrowaveOut to vacuumChamberEnv.globalMicrowaveIn;
    flow microwaveControlSystem.rfTrapDriveOut to vacuumChamberEnv.rfTrapDriveIn;
    flow microwaveControlSystem.laserSheetOut to vacuumChamberEnv.laserSheetIn;
    flow microwaveControlSystem.digitalControlOut to vacuumChamberEnv.digitalControlIn;
    flow microwaveReadoutSystem.readoutExcitationOut to vacuumChamberEnv.readoutExcitationIn;
    flow vacuumChamberEnv.photonCountOut to microwaveReadoutSystem.photonCountIn;
}
