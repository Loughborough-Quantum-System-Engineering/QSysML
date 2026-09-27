package BB84_Protocol {
    public import QSysML::**;
    doc
    /* BB84 is one of the QKD protocols which is implemented in this study, single-particle prepare-and-measure.
     * is the first protocol that invented by Charles H.  Bennett and Gilles Brassard in 1984, 
     * was originally described using photon polarization states to transmit the Information.
     * BB84 protocol coding scheme uses four non-orthogonal polarization states (0°, 90°, 45° and - 45°). 
     * https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.85.441 */
    view Logical_BB84 : LogicalBlackView;
    part Logical_BB84 : QKDSystem {
        item AliceBasis : preperationBasis;
        item BobBasis : measurementBasis;
        attribute def QBER;
        part Alice : sender {
            perform action generateRandomBits;
            perform action chooseRandomBasis;
            perform action transmitQubits {
                /* the qubit here is the encoded state (it is unknonw, prepared randomly) */
            }
            perform action announcePreperationBasis;
            perform action siftAliceKey;
            perform action detectEve {
                /* calcaulate error rate from revealing random subset of kept bits */
            }
            perform action discardKey { in attribute rejectedQBER : QBER; }
            perform action acceptKey { in attribute acceptedQBER : QBER; }
            port QC;
            port CC;
            perform generateSecretKey.generateRandomBits;
            perform generateSecretKey.chooseRandomBasis;
            perform generateSecretKey.transmitQubits;
            perform generateSecretKey.announcePreperationBasis;
            perform generateSecretKey.siftAliceKey;
            perform generateSecretKey.detectEve;
            perform generateSecretKey.discardKey;
            perform generateSecretKey.acceptKey;
        }
        part Bob : receiver {
            perform action receiveQubits;
            perform action selectMeasuremntBasis;
            perform action measureQubits;
            perform action announceMeasurementBasis;
            perform action siftBobKey;
            port QC;
            port CC;
            perform generateSecretKey.receiveQubits;
            perform generateSecretKey.selectMeasuremntBasis;
            perform generateSecretKey.measureQubits;
            perform generateSecretKey.announceMeasurementBasis;
            perform generateSecretKey.siftBobKey;
        }
        item preparedQubit : Qubits {
            attribute randomBasis : prepration_Basis;
            attribute polarisation : encodingMethod;
        }
        connect Alice.QC to Bob.QC {
            flow LogicalQubit from Alice.QC to Bob.QC;
        }
        connect Alice.CC to Bob.CC {
            flow classicalBits from Bob.CC to Alice.CC;
            flow preperationBasis from Alice.CC to Bob.CC;
            flow measurementBasis from Bob.CC to Alice.CC;
        }
        perform action generateSecretKey {
            perform Alice::generateRandomBits;
            perform Alice::chooseRandomBasis;
            perform Alice::transmitQubits;
            perform Bob::receiveQubits;
            perform Bob::selectMeasuremntBasis;
            perform Bob::measureQubits;
            perform Alice::announcePreperationBasis;
            perform Bob::announceMeasurementBasis;
            perform Alice::siftAliceKey;
            perform Bob::siftBobKey;
            perform Alice::detectEve;
            perform Alice::discardKey;
            perform Alice::acceptKey;
            first start then MP1;
            first generateRandomBits then chooseRandomBasis;
            first chooseRandomBasis then transmitQubits;
            first transmitQubits then receiveQubits;
            first receiveQubits then selectMeasuremntBasis;
            first selectMeasuremntBasis then measureQubits;
            fork Fork1;
            first measureQubits then Fork1;
            first Fork1 then announceMeasurementBasis;
            first Fork1 then announcePreperationBasis;
            merge MP2;
            first siftAliceKey then MP2;
            first siftBobKey then MP2;
            first MP2 then detectEve;
            decide Decition {
                out attribute acceptedQBER;
                out attribute rejectedQBER;
            }
            first detectEve then Decition;
            first announcePreperationBasis then siftAliceKey;
            first announceMeasurementBasis then siftBobKey;
            merge MP1;
            first discardKey then MP1;
            first MP1 then generateRandomBits;
            first acceptKey then done;
            succession flow Decition.rejectedQBER to discardKey.rejectedQBER;
            succession flow Decition.acceptedQBER to acceptKey.acceptedQBER;
        }
    }
}
