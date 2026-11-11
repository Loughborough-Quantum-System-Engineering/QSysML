package LinksAndPorts {
    /* Here are the connections and interfaces between the nodes */
    connection def QKDLink {
        doc
        /* ITU describes the functional elements of the QKD link including optical switching/splitting and quantum relay points.
         * Relay point placed within the link, at an intermediate point of the quantum channel (ITU-T Y.3802). */
        end part moduleA : LogicalEntities::QKDModule;
        end part moduleB : LogicalEntities::QKDModule;
        ref part relayPoint : LogicalEntities::QuantumRelayPoint [0..1] {
            /* Formally, a connection definition is a specialization of a part definition, so it can own parts, attributes, ports and actions like any other part.*/
        }
        /* The classical channel is connected once here because, for every protocol, it
         * runs directly between the two key-generating modules (ITU-T Y.3800). Its
         * structure never changes, so all specializations inherit it unchanged.
         * The quantum channel is only declared here and connected in each specialization,
         * because its path depends on the protocol: one direct segment for prepare-and-
         * measure (BB84), or two segments through a quantum relay point for MDI-QKD and
         * entanglement-based QKD. */
        /* here because we need to specify a specific feature, we used :>> that 
         * can specify the multiplicity or adding a new information like in the quantum channel */
        interface classicalChannel : ClassicalChannel connect moduleA.CC to moduleB.CC;
        /* Quantum channel: depends on the protocol, so it is connected in the specializations.*/
        interface quantumChannel : QuantumChannel [1..2];
    }
    interface def QuantumChannel {
        end QC_tx : QuantumPort;
        end QC_rx : ~QuantumPort;
        flow of SignalsAndData::QuantumSignal from QC_tx.signal to QC_rx.signal;
    }
    interface def ClassicalChannel {
        end CC_tx : ClassicalPort;
        end CC_rx : ClassicalPort;
        /* here the item flowed between nodes can be different things: measurment basis, sync message, or ...  */
    }
    port def QuantumPort {
        /* Sending side of the quantum channel. Receivers use ~QuantumPort. */
        out item signal : SignalsAndData::QuantumSignal;
    }
    port def ClassicalPort {
        /* Classical channel port. Bidirectional (inout), so it is never conjugated. */
        inout item msg : SignalsAndData::DistillationMessage;
        inout item timeing : SignalsAndData::SyncSignal;
    }
}
