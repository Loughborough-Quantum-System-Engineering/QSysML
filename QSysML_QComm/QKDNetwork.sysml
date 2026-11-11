package QKDNetwork {
    connection def BB84Link :> LinksAndPorts::QKDLink {
        end part :>> moduleA : LogicalEntities::Transmitter;
        end part :>> moduleB : LogicalEntities::Receiver;
        ref part :>> relayPoint [0] : LogicalEntities::QuantumRelayPoint;
        interface :>> quantumChannel : LinksAndPorts::QuantumChannel connect moduleA.QC_tx to moduleB.QC_rx;
    }
    connection def MDILink :> LinksAndPorts::QKDLink {
        /* an example of connection def for MDI-QKD prtocol */
        end part :>> moduleA : LogicalEntities::Transmitter;
        end part :>> moduleB : LogicalEntities::Transmitter;
        ref part :>> relayPoint [1] : BSM_Station;
        interface qcA : LinksAndPorts::QuantumChannel :> quantumChannel connect moduleA.QC_tx to relayPoint.QC_inA;
        interface qcB : LinksAndPorts::QuantumChannel :> quantumChannel connect moduleB.QC_tx to relayPoint.QC_inB;
    }
    connection def EntanglementLink :> LinksAndPorts::QKDLink {
        /* an example of connection def for E91 protocol */
        end part :>> moduleA : LogicalEntities::Receiver;
        end part :>> moduleB : LogicalEntities::Receiver;
        ref part :>> relayPoint [1] : EntanglementSourceNode;
        interface qcA : LinksAndPorts::QuantumChannel :> quantumChannel connect moduleA.QC_rx to relayPoint.QC_outA;
        interface qcB : LinksAndPorts::QuantumChannel :> quantumChannel connect moduleB.QC_rx to relayPoint.QC_outB;
    }
    part def BSM_Station :> LogicalEntities::QuantumRelayPoint {
        /* MDI / TF middle node, t is modeled here so in the instance it will just be reused and all part features inherits the part def*/
        port QC_inA : ~LinksAndPorts::QuantumPort;
        /* receives from moduleA */
        port QC_inB : ~LinksAndPorts::QuantumPort;
        /* receives from moduleB */
        perform action measureQuantumSignals : FunctionalElements::RelayQuantumSignals;
    }
    part def EntanglementSourceNode :> LogicalEntities::QuantumRelayPoint {
        /* E91 middle source node*/
        port QC_outA : LinksAndPorts::QuantumPort;
        /* sends one photon of each pair to moduleA*/
        port QC_outB : LinksAndPorts::QuantumPort;
        /* sends the other photon to moduleB */
        perform action prepareQuantumSignal : FunctionalElements::RelayQuantumSignals;
    }
}
