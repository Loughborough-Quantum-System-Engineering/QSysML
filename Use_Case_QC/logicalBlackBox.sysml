package logicalBlackBox {
    public import logicalLayerAction::**;
    public import physicalBlackBox::**;
    attribute def gate;
    part def logicalControlUnit;
    attribute def quantumAlgorithm;
    part logicalLayer {
        part logicalQPU {
            attribute instruction;
            attribute output;
            port QPUIn {
                in instruction;
                in attribute attribute1;
            }
            port QPUOut {
                out output;
                out attribute attribute1;
            }
        }
        part control : logicalControlUnit {
            attribute algorithm : quantumAlgorithm;
            attribute instruction;
            attribute gateSet {
                attribute H : gate;
                attribute S : gate;
                attribute T : gate;
                attribute CNOT : gate;
            }
            port controlIn {
                in algorithm;
                in attribute attribute1;
            }
            port controlOut {
                out instruction;
                out attribute attribute1;
            }
        }
        part readout {
            attribute measurement;
            attribute result;
            port readoutIn {
                in measurement;
                in attribute attribute1;
            }
            port readoutOut {
                out result;
                out attribute attribute1;
            }
        }
        part quantumAlgorithm {
            attribute algorithm : quantumAlgorithm;
            attribute result;
            port algorithmOut {
                out algorithm;
                out attribute attribute1;
            }
            port algorithmIn {
                in result;
                in attribute attribute1;
            }
        }
        connect logicalBlackBox::physicalLayer to logicalQPU;
        flow quantumAlgorithm.algorithmOut.attribute1 to control.controlIn.attribute1;
        flow control.controlOut.attribute1 to logicalQPU.QPUIn.attribute1;
        flow logicalQPU.QPUOut.attribute1 to readout.readoutIn.attribute1;
        flow readout.readoutOut.attribute1 to quantumAlgorithm.algorithmIn.attribute1;
    }
}
view LogicalLayer : DS_Views::SymbolicViews::gv;
