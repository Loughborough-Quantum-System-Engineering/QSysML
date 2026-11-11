package Enumerations {
    /* An enumeration definition is a kind of attribute definition whose values are limited to the listed ones.
     * So an attribute typed by an enum def is valid, and the attribute can only take one of those values. */
    enum def QKDNodeRole {
        userNode;
        accessNode;
        relayNode;
    }
    enum def QuantumChannelMedium {
        opticalFiber;
        freeSpace;
        Hybrid;
    }
    enum def LinkConfiguration {
        doc /* QKD link implementation cases of ITU-T Y.3802, Annex A. */
        noIntermediateElement;
        opticalSwitchingSplitting;
        measurementStationRelay;
        entanglementSourceRelay;
        quantumRepeaterRelay;
    }
    enum def QKDModuleRole {
        transmitter;
        receiver;
    }
    enum def ProtocolScheme {
        prepareAndMeasure;
        measurementAssisted;
        entanglementBased;
    }
    enum def QKDProtocols {
        discreteVariable_DV;
        continuousVariable_CV;
    }
    enum def EncodingType {
        polarization;
        phase;
        timeBin;
    }
    enum def photonSourceType {
        weakCoherentPulse;
        heraldedSinglePhoton;
        entangledPhotonPair;
    }
    enum def DetectionScheme {
        singlePhotonDetection;
        homodyne;
        heterodyne;
    }
    enum def MeasurementResult {
        doc /* Classical result of measuring one quantum signal (discrete-variable QKD). */
        bit0;
        bit1;
        noDetection;
    }
    enum def RNGType {
        physicalNoiseBased;
        quantumNoiseBased;
    }
    enum def KeyDeliveryMode {
        push;
        pull;
    }
}
