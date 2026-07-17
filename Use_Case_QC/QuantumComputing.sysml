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
        item def signal;
        item def digitalData :> signal;
        item def microwaveSignal :> signal;
        item def opticalSignal :> signal;
        item def sfqPulse :> signal;
        item def dcBias :> signal;
        item def magneticField :> signal;
        port def digitalPort {
            out item digitalData;
        }
        port def microwavePort {
            out item microwaveSignal;
        }
        port def opticalPort {
            out item opticalSignal;
        }
        port def sfqPort {
            out item sfqPulse;
        }
        port def dcBiasPort {
            out item dcBias;
        }
        port def magneticFieldPort {
            out item magneticField;
        }
        enum def qubitTechnology {
            superconducting;
            trappedIon;
            neutralAtom;
            photonic;
            spinQubit;
            quantumDot;
        }
        part def QPU {
            attribute technology : qubitTechnology;
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
