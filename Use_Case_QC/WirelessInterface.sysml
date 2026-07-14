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
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part lens;
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part lens;
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part lens;
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part qpu : QPU;
            part cryogenicTransmitAntenna;
            part cryogenicReceiveAntenna;
            part lens;
            part waveguide;
        }
    }
    part wirelessReadoutSystem : classicalRTeadoutSystem {
        part signalAnalyser;
        part roomTempReceiveAntenna;
    }
}
