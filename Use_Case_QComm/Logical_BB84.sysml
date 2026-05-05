package Logical_BB84 {
    public import QSysML::**;
    doc
    /* BB84 is one of the QKD protocols which is implemented in this study,
     * is the first protocol that invented by Charles H.  Bennett and Gilles Brassard in 1984, 
     * was originally described using photon polarization states to transmit the Information.
     * BB84 protocol coding scheme uses four non-orthogonal polarization states (0°, 90°, 45° and - 45°). */
    view Logical_BlackBox : LogicalBlackView;
    part Logical_Layer : QKDSystem {
        part Alice : sender {
            perform action generateRandomBits;
            perform action encodeBits;
            perform action transmitQubits;
            perform action siftKey;
            port QC;
            port CC;
            perform generateSecretKey.generateRandomBits;
            perform generateSecretKey.encodeBits;
            perform generateSecretKey.transmitQubits;
            perform generateSecretKey.siftKey;
        }
        part Bob : receiver {
            perform action receiveQubits;
            perform action selectMeasureemntBasis;
            perform action measureQubits;
            perform action announceMeasurementBasis;
            port QC;
            port CC;
            perform generateSecretKey.receiveQubits;
            perform generateSecretKey.selectMeasureemntBasis;
            perform generateSecretKey.measureQubits;
            perform generateSecretKey.announceMeasurementBasis;
            perform generateSecretKey.announceMeasurementBasis;
        }
        item LogicalQubit : Qubits {
            attribute random : preprationBasis;
            attribute polarisation : encodingMethod;
        }
        connect Alice.QC to Bob.QC {
            flow LogicalQubit from Alice.QC to Bob.QC;
        }
        connect Alice.CC to Bob.CC {
            flow classicalBits from Bob.CC to Alice.QC;
        }
        perform action generateSecretKey {
            perform Alice::generateRandomBits;
            perform Alice::encodeBits;
            perform Alice::transmitQubits;
            perform Bob::receiveQubits;
            perform Bob::selectMeasureemntBasis;
            perform Bob::measureQubits;
            perform Bob::announceMeasurementBasis;
            first start then generateRandomBits;
            first generateRandomBits then encodeBits;
            first encodeBits then transmitQubits;
            first transmitQubits then receiveQubits;
            first receiveQubits then selectMeasureemntBasis;
            first selectMeasureemntBasis then measureQubits;
            perform Alice::siftKey;
            perform Bob::announceMeasurementBasis;
            first measureQubits then generateSecretKey::announceMeasurementBasis;
            first generateSecretKey::announceMeasurementBasis then siftKey;
            first siftKey then done;
        }
    }
}
