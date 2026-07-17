package QuantumComputing {
    package physicalLayerDefinitions {
        part def classicalControlSystem;
        part def classicalReadoutSystem;
        part def physicalControlUnit;
        part def fieldProgrammableGateArrays;
        part def digitalToAnalogConverter;
        part def analogToDigitalConverter;
        part def lowPassbandFilter;
        part def microwaveSource;
        part def iqMixer;
        part def awgFPGA;
        part def powerSource;
        part def localOscillator;
        part def dilutionRefrigerator;
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
        part def QPU;
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
