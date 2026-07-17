package EQCTrappedIonInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part eqcControlSystem : classicalControlSystem {
        part rfWaveformGenerator : microwaveSource {
            port waveformOut : microwavePort;
        }
        part fpga : fieldProgrammableGateArrays {
            port dacDriveOut : digitalPort;
        }
        part dac : digitalToAnalogConverter {
            port digitalIn : ~digitalPort;
            port electrodeVoltageOut : dcBiasPort;
        }
        part laserSystem {
            part photoionisationLaser {
                port beamOut : opticalPort;
            }
            part statePreparationLaser {
                port beamOut : opticalPort;
            }
            part dopplerCoolingLaser {
                port beamOut : opticalPort;
            }
            part sidebandCoolingLaser {
                port beamOut : opticalPort;
            }
            part sympatheticCoolingLaser {
                port beamOut : opticalPort;
            }
            port laserOut : opticalPort;
            flow photoionisationLaser.beamOut to laserOut;
        }
        port gateWaveformOut : microwavePort;
        port electrodeVoltageOut : dcBiasPort;
        port laserOut : opticalPort;
        flow rfWaveformGenerator.waveformOut to gateWaveformOut;
        flow fpga.dacDriveOut to dac.digitalIn;
        flow dac.electrodeVoltageOut to electrodeVoltageOut;
        flow laserSystem.laserOut to laserOut;
    }
    part vacuumChamberEnv {
        attribute pressure : PressureUnit;
        port gateWaveformIn : ~microwavePort;
        port electrodeVoltageIn : ~dcBiasPort;
        port laserIn : ~opticalPort;
        port readoutExcitationIn : ~opticalPort;
        port fluorescenceOut : opticalPort;
        part loadingChip {
            port photoionisationIn : ~opticalPort;
        }
        part qccdChip {
            attribute temp : ThermodynamicTemperatureUnit;
            part qpu : QPU {
                attribute redefines technology = qubitTechnology::trappedIon;
                port gateFieldIn : ~microwavePort;
                port electrodeVoltageIn : ~dcBiasPort;
                port laserIn : ~opticalPort;
                port readoutExcitationIn : ~opticalPort;
                port fluorescenceOut : opticalPort;
            }
            part antennaLayer {
                part gateRfAntenna {
                    port feedIn : ~microwavePort;
                    port nearFieldOut : microwavePort;
                }
                port feedIn : ~microwavePort;
                port nearFieldOut : microwavePort;
                flow feedIn to gateRfAntenna.feedIn;
                flow gateRfAntenna.nearFieldOut to nearFieldOut;
            }
            part photonicLayer {
                part nanophotonicWaveguide {
                    port lightIn : ~opticalPort;
                    port lightOut : opticalPort;
                }
                part outputGratingCoupler {
                    port lightIn : ~opticalPort;
                    port beamOut : opticalPort;
                }
                port lightIn : ~opticalPort;
                port beamOut : opticalPort;
                flow lightIn to nanophotonicWaveguide.lightIn;
                flow nanophotonicWaveguide.lightOut to outputGratingCoupler.lightIn;
                flow outputGratingCoupler.beamOut to beamOut;
            }
            part readoutPhotonicLayer {
                part nanophotonicWaveguide {
                    port lightIn : ~opticalPort;
                    port lightOut : opticalPort;
                }
                part outputGratingCoupler {
                    port lightIn : ~opticalPort;
                    port beamOut : opticalPort;
                }
                port lightIn : ~opticalPort;
                port beamOut : opticalPort;
                flow lightIn to nanophotonicWaveguide.lightIn;
                flow nanophotonicWaveguide.lightOut to outputGratingCoupler.lightIn;
                flow outputGratingCoupler.beamOut to beamOut;
            }
            part collectingLens {
                port photonIn : ~opticalPort;
                port photonOut : opticalPort;
            }
            port gateWaveformIn : ~microwavePort;
            port electrodeVoltageIn : ~dcBiasPort;
            port laserIn : ~opticalPort;
            port readoutExcitationIn : ~opticalPort;
            port fluorescenceOut : opticalPort;
            flow gateWaveformIn to antennaLayer.feedIn;
            flow antennaLayer.nearFieldOut to qpu.gateFieldIn;
            flow electrodeVoltageIn to qpu.electrodeVoltageIn;
            flow laserIn to photonicLayer.lightIn;
            flow photonicLayer.beamOut to qpu.laserIn;
            flow readoutExcitationIn to readoutPhotonicLayer.lightIn;
            flow readoutPhotonicLayer.beamOut to qpu.readoutExcitationIn;
            flow qpu.fluorescenceOut to collectingLens.photonIn;
            flow collectingLens.photonOut to fluorescenceOut;
        }
        flow gateWaveformIn to qccdChip.gateWaveformIn;
        flow electrodeVoltageIn to qccdChip.electrodeVoltageIn;
        flow laserIn to qccdChip.laserIn;
        flow readoutExcitationIn to qccdChip.readoutExcitationIn;
        flow qccdChip.fluorescenceOut to fluorescenceOut;
    }
    part eqcReadoutSystem : classicalReadoutSystem {
        part shelvingLaser {
            port beamOut : opticalPort;
        }
        part excitationLaser {
            port beamOut : opticalPort;
        }
        part photodetector {
            port photonIn : ~opticalPort;
            port countOut : digitalPort;
        }
        part thresholdDiscriminator {
            port countIn : ~digitalPort;
            port resultOut : digitalPort;
        }
        port readoutExcitationOut : opticalPort;
        port fluorescenceIn : ~opticalPort;
        flow excitationLaser.beamOut to readoutExcitationOut;
        flow fluorescenceIn to photodetector.photonIn;
        flow photodetector.countOut to thresholdDiscriminator.countIn;
    }
    flow eqcControlSystem.gateWaveformOut to vacuumChamberEnv.gateWaveformIn;
    flow eqcControlSystem.electrodeVoltageOut to vacuumChamberEnv.electrodeVoltageIn;
    flow eqcControlSystem.laserOut to vacuumChamberEnv.laserIn;
    flow eqcReadoutSystem.readoutExcitationOut to vacuumChamberEnv.readoutExcitationIn;
    flow vacuumChamberEnv.fluorescenceOut to eqcReadoutSystem.fluorescenceIn;
}
