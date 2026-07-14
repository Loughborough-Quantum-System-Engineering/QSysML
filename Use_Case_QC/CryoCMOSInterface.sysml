package CryoCMOSInterface {
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import ISQ::*;
    public import SI::*;
    part cryoCMOSControlSystem : classicalControlSystem {
        part controlPowerSource : powerSource;
        part preLoadedData;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            part qpu : QPU;
            part cryoCMOSProcessor;
        }
    }
    part cryoCMOSReadoutSystem : classicalRTeadoutSystem {
        part readoutPowerSource : powerSource;
        part postProcessingElectronics;
    }
}
