package WirelessInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import SuperconductingCommon::*;
    public import ISQ::*;
    public import SI::*;
    part wirelessControlSystem : classicalControlSystem {
        part ghzThzSource {
            port toneOut : microwavePort;
        }
        part roomTempTransmitAntenna {
            port feedIn : ~microwavePort;
            port beamOut : microwavePort;
        }
        port downlinkBeamOut : microwavePort;
        flow ghzThzSource.toneOut to roomTempTransmitAntenna.feedIn;
        flow roomTempTransmitAntenna.beamOut to downlinkBeamOut;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        port downlinkBeamIn : ~microwavePort;
        port uplinkBeamOut : microwavePort;
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part downlinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
            part uplinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part downlinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
            part uplinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part downlinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
            part uplinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
            part downlinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
            part uplinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part downlinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
            part uplinkLens {
                port beamIn : ~microwavePort;
                port beamOut : microwavePort;
            }
            part cryogenicReceiveAntenna {
                port beamIn : ~microwavePort;
                port feedOut : microwavePort;
            }
            part cryogenicTransmitAntenna {
                port feedIn : ~microwavePort;
                port beamOut : microwavePort;
            }
            part qpu : QPU {
                attribute redefines technology = qubitTechnology::superconducting;
                port driveIn : ~microwavePort;
                port readoutOut : microwavePort;
            }
            flow cryogenicReceiveAntenna.feedOut to qpu.driveIn;
            flow qpu.readoutOut to cryogenicTransmitAntenna.feedIn;
        }
        flow downlinkBeamIn to secondLayer.downlinkLens.beamIn;
        flow secondLayer.downlinkLens.beamOut to thirdLayer.downlinkLens.beamIn;
        flow thirdLayer.downlinkLens.beamOut to fourthLayer.downlinkLens.beamIn;
        flow fourthLayer.downlinkLens.beamOut to fifthLayer.downlinkLens.beamIn;
        flow fifthLayer.downlinkLens.beamOut to sixthLayer.downlinkLens.beamIn;
        flow sixthLayer.downlinkLens.beamOut to sixthLayer.cryogenicReceiveAntenna.beamIn;
        flow sixthLayer.cryogenicTransmitAntenna.beamOut to sixthLayer.uplinkLens.beamIn;
        flow sixthLayer.uplinkLens.beamOut to fifthLayer.uplinkLens.beamIn;
        flow fifthLayer.uplinkLens.beamOut to fourthLayer.uplinkLens.beamIn;
        flow fourthLayer.uplinkLens.beamOut to thirdLayer.uplinkLens.beamIn;
        flow thirdLayer.uplinkLens.beamOut to secondLayer.uplinkLens.beamIn;
        flow secondLayer.uplinkLens.beamOut to uplinkBeamOut;
    }
    part wirelessReadoutSystem : classicalReadoutSystem {
        part roomTempReceiveAntenna {
            port beamIn : ~microwavePort;
            port feedOut : microwavePort;
        }
        part signalAnalyser {
            port signalIn : ~microwavePort;
        }
        port uplinkBeamIn : ~microwavePort;
        flow uplinkBeamIn to roomTempReceiveAntenna.beamIn;
        flow roomTempReceiveAntenna.feedOut to signalAnalyser.signalIn;
    }
    flow wirelessControlSystem.downlinkBeamOut to dilutionRefrigeratorEnv.downlinkBeamIn;
    flow dilutionRefrigeratorEnv.uplinkBeamOut to wirelessReadoutSystem.uplinkBeamIn;
}
