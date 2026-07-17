package WirelessInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part wirelessControlSystem : classicalControlSystem {
        part ghzThzSource;
        part roomTempTransmitAntenna;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part downlinkLens;
            part uplinkLens;
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part downlinkLens;
            part uplinkLens;
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part downlinkLens;
            part uplinkLens;
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
            part downlinkLens;
            part uplinkLens;
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part qpu : QPU;
            part cryogenicTransmitAntenna;
            part cryogenicReceiveAntenna;
            part downlinkLens;
            part uplinkLens;
            part waveguide;
        }
    }
    part wirelessReadoutSystem : classicalReadoutSystem {
        part signalAnalyser;
        part roomTempReceiveAntenna;
    }
}
