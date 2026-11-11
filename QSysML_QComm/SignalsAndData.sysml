package SignalsAndData {
    doc /* Things that flow between QKD actions, ports, and through interfaces. */
    item def QuantumSignal {
        doc /* The carrier of quantum states exchanged over the quantum channel. */
    }
    item def Qubit {
        doc /* Quantum information represented by a two-level quantum system */
    }
    item def RandomBitString {
        doc
        /* Random numbers from the RNG function, used for preparation, basis choices and
         * key distillation. */
    }
    item def MeasurementOutcome {
        doc /* Result of measuring one quantum signal: one of the "results of the quantum stage". */
        attribute basis : Parameters::MeasurementBasis;
        attribute value : Enumerations::MeasurementResult {
            doc /* noDetection when the signal was lost or not registered. */
        }
    }
    item def SyncSignal {
        doc /* Information exchanged for quantum channel synchronization (Qsync, ITU-T Y.3802, 8.1). */
    }
    item def RawKey {
        doc
        /* Record kept by each QKD module before distillation: the transmitter's preparation
         * choices or the receiver's measurement results. */
    }
    item def SiftedKey {
        doc /* Raw key after sifting to match modulation and/or measurement bases (ITU-T Y.3802, 7.1 a). */
    }
    item def CorrectedKey {
        doc /* Sifted key after error correction (ITU-T Y.3802, 7.1 c). */
    }
    item def QKDKey {
        doc /* Final secret key after privacy amplification (ITU-T Y.3802, 7.1 c). */
    }
    item def DistillationMessage {
        doc
        /* Information on sifting, parameter estimation, error correction and privacy
         * amplification exchanged over Qdist (ITU-T Y.3802, 8.1). */
    }
    item def QKDLinkParameters {
        doc
        /* QKD link parameters, e.g. QBER, from parameter estimation; sent to the KM over
         * Kq-2 (ITU-T Y.3802, 8.2) and towards the QKDN manager (ITU-T Y.3800, 8.2.1). */
    }
    item def QKDKeyRequest {
        doc /* QKD-key request from a KMA to the QKD-key supply function (Kq-1, ITU-T Y.3802, 7.1). */
    }
    item def KeyRequest {
        doc /* Key request from a cryptographic application to a KSA (Ak, ITU-T Y.3802, 8.6). */
    }
    item def KeyRelayRoute {
        doc /* Key relay route provisioned by the routing control function (ITU-T Y.3802, 7.3). */
    }
    item def ControlInformation {
        doc
        /* Control information exchanged with the QKDN controller (Ck, Cq, Cops, Cqrp, Cx,
         * ITU-T Y.3802, 8.3) and over Kq-2. */
    }
    item def ManagementInformation {
        doc
        /* Management information exchanged with the QKDN manager (Mq, Mops, Mqrp, Mk, Mc, Mu,
         * ITU-T Y.3802, 8.4). */
    }
}
