package physicalBlackBox {
    public import physicalLayerAction::**;
    public import ISQ::*;
    public import SI::*;
    part def physicalControlUnit;
    part def logicalControlUnit;
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
    part physicalLayer {
        part quantumErrorCorrection {
            attribute algorithm;
            perform action performErrorCorrection;
            port portIn : errorCorrectionPortIn {
                in attribute result;
            }
            port portOut : errorCorrectionPortOut {
                out attribute parameter;
            }
        }
        part controlUnit : physicalControlUnit {
            attribute microwavePulse : microwavePulse;
            perform action generateMicrowavePulses;
            port portIn : controlUnitPortIn {
                in attribute parameter;
            }
            port portOut : controlUnitPortOut {
                out attribute microwavePulse;
            }
        }
        part readoutUnit {
            attribute result;
            port portInOut : readOutPort {
                out attribute result;
                in attribute result;
            }
        }
        action cryogenicAction {
            action pulseAttenuation;
            action pulseFiltering;
            action quantumInformationProcessing;
            action cryogenicAmplification;
            first start then pulseAttenuation;
            first pulseAttenuation then pulseFiltering;
            first pulseFiltering then quantumInformationProcessing;
            first quantumInformationProcessing then cryogenicAmplification;
            first cryogenicAmplification then done;
        }
        part dilutionRefrigerator {
            attribute temp : ThermodynamicTemperatureUnit;
            assert constraint {
                temp >= 0.015 [K] and temp <= 4 [K]
            }
            port portIn : cryogenicPortIn {
                in attribute attribute1;
            }
            port portOut : cryogenicPortOut {
                out attribute attribute1;
            }
            perform cryogenicAction;
            part microwavePulse {
                perform cryogenicAction.pulseAttenuation;
                perform cryogenicAction.pulseFiltering;
            }
            part readOut {
                perform cryogenicAction.cryogenicAmplification;
            }
            part physicalQPU {
                attribute operationTemparture : ThermodynamicTemperatureValue = 0.015 [K];
                perform cryogenicAction.quantumInformationProcessing;
            }
        }
        flow quantumErrorCorrection.portOut.parameter to controlUnit.portIn.parameter;
        flow readoutUnit.portInOut.result to quantumErrorCorrection.portIn.result;
        flow dilutionRefrigerator.portOut.result to readoutUnit.portInOut.result;
        flow controlUnit.portOut.microwavePulse to dilutionRefrigerator.portIn.microwavePulse;
    }
    view PhysicalLayer : DS_Views::SymbolicViews::gv;
}
