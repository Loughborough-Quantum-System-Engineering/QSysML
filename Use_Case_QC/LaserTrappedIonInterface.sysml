// reference
// @article{monroe2013scaling,
//   title={Scaling the ion trap quantum processor},
//   author={Monroe, Christopher and Kim, Jungsang},
//   journal={Science},
//   volume={339},
//   number={6124},
//   pages={1164--1169},
//   year={2013},
//   publisher={American Association for the Advancement of Science}
// }

package LaserTrappedIonInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part laserControlSystem : classicalControlSystem {
        part addressingLaser {
            port beamOut : opticalPort;
        }
        part beamSteeringOptics {
            part memsMirror {
                port beamIn : ~opticalPort;
                port beamOut : opticalPort;
            }
            part electroOpticDeflector {
                port beamIn : ~opticalPort;
                port beamOut : opticalPort;
            }
            part acoustoOpticDeflector {
                port beamIn : ~opticalPort;
                port beamOut : opticalPort;
            }
            port beamIn : ~opticalPort;
            port beamOut : opticalPort;
            flow beamIn to memsMirror.beamIn;
            flow memsMirror.beamOut to beamOut;
        }
        part projectionOptics {
            port beamIn : ~opticalPort;
            port beamOut : opticalPort;
        }
        part dopplerCoolingLaser {
            port beamOut : opticalPort;
        }
        part photoionisationLaser {
            port beamOut : opticalPort;
        }
        part rfDriveSource {
            port rfOut : microwavePort;
        }
        port addressingBeamOut : opticalPort;
        port coolingBeamOut : opticalPort;
        port photoionisationBeamOut : opticalPort;
        port rfTrapDriveOut : microwavePort;
        flow addressingLaser.beamOut to beamSteeringOptics.beamIn;
        flow beamSteeringOptics.beamOut to projectionOptics.beamIn;
        flow projectionOptics.beamOut to addressingBeamOut;
        flow dopplerCoolingLaser.beamOut to coolingBeamOut;
        flow photoionisationLaser.beamOut to photoionisationBeamOut;
        flow rfDriveSource.rfOut to rfTrapDriveOut;
    }
    part vacuumChamberEnv {
        attribute pressure : PressureUnit;
        port addressingBeamIn : ~opticalPort;
        port coolingBeamIn : ~opticalPort;
        port photoionisationBeamIn : ~opticalPort;
        port rfTrapDriveIn : ~microwavePort;
        port readoutExcitationIn : ~opticalPort;
        port fluorescenceOut : opticalPort;
        port communicationPhotonOut : opticalPort;
        part viewport {
            port beamIn : ~opticalPort;
            port beamOut : opticalPort;
        }
        part vacuumPump;
        part elementaryLogicUnit {
            part qpu : QPU {
                attribute redefines technology = qubitTechnology::trappedIon;
                port addressingBeamIn : ~opticalPort;
                port coolingBeamIn : ~opticalPort;
                port photoionisationBeamIn : ~opticalPort;
                port rfTrapIn : ~microwavePort;
                port readoutExcitationIn : ~opticalPort;
                port fluorescenceOut : opticalPort;
                port communicationPhotonOut : opticalPort;
            }
            part opticalInterfaceCavity {
                port photonIn : ~opticalPort;
                port photonOut : opticalPort;
            }
            port addressingBeamIn : ~opticalPort;
            port coolingBeamIn : ~opticalPort;
            port photoionisationBeamIn : ~opticalPort;
            port rfTrapIn : ~microwavePort;
            port readoutExcitationIn : ~opticalPort;
            port fluorescenceOut : opticalPort;
            port communicationPhotonOut : opticalPort;
            flow addressingBeamIn to qpu.addressingBeamIn;
            flow coolingBeamIn to qpu.coolingBeamIn;
            flow photoionisationBeamIn to qpu.photoionisationBeamIn;
            flow rfTrapIn to qpu.rfTrapIn;
            flow readoutExcitationIn to qpu.readoutExcitationIn;
            flow qpu.fluorescenceOut to fluorescenceOut;
            flow qpu.communicationPhotonOut to opticalInterfaceCavity.photonIn;
            flow opticalInterfaceCavity.photonOut to communicationPhotonOut;
        }
        flow addressingBeamIn to viewport.beamIn;
        flow viewport.beamOut to elementaryLogicUnit.addressingBeamIn;
        flow coolingBeamIn to elementaryLogicUnit.coolingBeamIn;
        flow photoionisationBeamIn to elementaryLogicUnit.photoionisationBeamIn;
        flow rfTrapDriveIn to elementaryLogicUnit.rfTrapIn;
        flow readoutExcitationIn to elementaryLogicUnit.readoutExcitationIn;
        flow elementaryLogicUnit.fluorescenceOut to fluorescenceOut;
        flow elementaryLogicUnit.communicationPhotonOut to communicationPhotonOut;
    }
    part photonicInterconnect {
        part opticalFiber {
            port photonIn : ~opticalPort;
            port photonOut : opticalPort;
        }
        part nonlinearWavelengthConverter {
            port photonIn : ~opticalPort;
            port pumpIn : ~opticalPort;
            port telecomPhotonOut : opticalPort;
        }
        part pumpLaser {
            port beamOut : opticalPort;
        }
        part opticalCrossconnectSwitch {
            port photonIn : ~opticalPort;
            port photonOut : opticalPort;
        }
        part beamSplitter {
            port photonIn : ~opticalPort;
            port photonOutA : opticalPort;
            port photonOutB : opticalPort;
        }
        part coincidenceDetector {
            port photonInA : ~opticalPort;
            port photonInB : ~opticalPort;
            port heraldOut : digitalPort;
        }
        port communicationPhotonIn : ~opticalPort;
        port heraldOut : digitalPort;
        flow communicationPhotonIn to opticalFiber.photonIn;
        flow opticalFiber.photonOut to nonlinearWavelengthConverter.photonIn;
        flow pumpLaser.beamOut to nonlinearWavelengthConverter.pumpIn;
        flow nonlinearWavelengthConverter.telecomPhotonOut to opticalCrossconnectSwitch.photonIn;
        flow opticalCrossconnectSwitch.photonOut to beamSplitter.photonIn;
        flow beamSplitter.photonOutA to coincidenceDetector.photonInA;
        flow beamSplitter.photonOutB to coincidenceDetector.photonInB;
        flow coincidenceDetector.heraldOut to heraldOut;
    }
    part laserReadoutSystem : classicalReadoutSystem {
        part readoutExcitationLaser {
            port beamOut : opticalPort;
        }
        part imagingOptics {
            port photonIn : ~opticalPort;
            port photonOut : opticalPort;
        }
        part photonCountingImager {
            port photonIn : ~opticalPort;
            port resultOut : digitalPort;
        }
        port readoutExcitationOut : opticalPort;
        port fluorescenceIn : ~opticalPort;
        flow readoutExcitationLaser.beamOut to readoutExcitationOut;
        flow fluorescenceIn to imagingOptics.photonIn;
        flow imagingOptics.photonOut to photonCountingImager.photonIn;
    }
    flow laserControlSystem.addressingBeamOut to vacuumChamberEnv.addressingBeamIn;
    flow laserControlSystem.coolingBeamOut to vacuumChamberEnv.coolingBeamIn;
    flow laserControlSystem.photoionisationBeamOut to vacuumChamberEnv.photoionisationBeamIn;
    flow laserControlSystem.rfTrapDriveOut to vacuumChamberEnv.rfTrapDriveIn;
    flow laserReadoutSystem.readoutExcitationOut to vacuumChamberEnv.readoutExcitationIn;
    flow vacuumChamberEnv.fluorescenceOut to laserReadoutSystem.fluorescenceIn;
    flow vacuumChamberEnv.communicationPhotonOut to photonicInterconnect.communicationPhotonIn;
}
