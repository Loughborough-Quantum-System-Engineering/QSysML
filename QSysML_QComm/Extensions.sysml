package Extensions {
    /* The metadata needed for adding elements with a semantic meaning */
    private import ModelingMetadata;
    /* Metadata lets you add meaning, classification, provenance and domain vocabulary without changing what the system is. It is used for TermDefinition, DomainTrace, or
     * ModellingDecision */
    abstract metadata def QKDNLayerElement {
        doc /* QKDN layer of the annotated element (ITU-T Y.3800, 8.2). */
        :> annotatedElement : SysML::Systems::Definition;
        :> annotatedElement : SysML::Systems::Usage;
    }
    metadata def <quantumLayer> QuantumLayerElement :> QKDNLayerElement;
    metadata def <keyManagementLayer> KeyManagementLayerElement :> QKDNLayerElement;
    metadata def <qkdnControlLayer> QKDNControlLayerElement :> QKDNLayerElement;
    metadata def <qkdnManagementLayer> QKDNManagementLayerElement :> QKDNLayerElement;
    metadata def TrustAssumption {
        doc
        /* Trust assumption the standards state: QKD nodes are trusted (ITU-T Y.3800, 8.1);
         * quantum relay points are not necessarily trusted (ITU-T Y.3800, 6.2). */
        :> annotatedElement : SysML::Systems::Definition;
        :> annotatedElement : SysML::Systems::Usage;
    }
    metadata def <trusted> TrustedElement :> TrustAssumption;
    metadata def <notNecessarilyTrusted> NotNecessarilyTrustedElement :> TrustAssumption;
    metadata def quantumState;
    metadata def PhysicalParams {
        :> annotatedElement : SysML::Systems::PartDefinition;
        :> annotatedElement : SysML::Systems::PartUsage;
        attribute calibrated : ScalarValues::Boolean;
    }
}
