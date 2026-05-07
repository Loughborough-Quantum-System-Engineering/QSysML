package QuantumComputing {
    package physicalLayerDefinitions {
        part def physicalControlUnit;
        part def fieldProgrammableGateArrays;
        part def digitalToAnalogConverter;
        part def analogToDigitalConverter;
        part def lowPassbandFilter;
        part def microwaveSource;
        part def iqMixer;
        port def errorCorrectionPortIn {
            in result;
        }
        port def errorCorrectionPortOut {
            out parameter;
        }
        port def controlUnitPortIn {
            in parameter;
        }
        port def controlUnitPortOut {
            out microwavePulse;
        }
        port def readOutPort {
            inout result;
        }
        port def cryogenicPortIn {
            in microwavePulse;
        }
        port def cryogenicPortOut {
            out result;
        }
    }
    package logicalLayerDefinitions {
        attribute def gate;
        part def logicalControlUnit;
        attribute def quantumAlgorithm;
    }
    package actions {
        action generateMicrowavePulses;
        action performErrorCorrection;
        action pulseAttenuation;
        action pulseFiltering;
        action cryogenicAmplification;
        action quantumInformationProcessing;
        action logicalOperations;
    }
}
