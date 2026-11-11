package LogicalEntities {
    doc /* Network and nodes (ITU-T Y.3800, 3.2.11, 3.2.14, 8.2; ITU-T Y.3802, clause 9) */
    part def QKDNode;
    part def QKDModule {
        doc
        /* a QKD module is a set of hardware and software components that implements cryptographic functions 
         * and quantum optical processes, including QKD protocols, synchronization and distillation for key generation 
         * there are two types of QKD modules, the transmitters (QC-Tx) and the receivers (QC-Rx). */
        port CC : LinksAndPorts::ClassicalPort;
        perform action synchronise : FunctionalElements::SynchronizeQuantumChannel;
        perform action distill : FunctionalElements::DistillKey;
        perform action supply : FunctionalElements::SupplyQKDKey;
    }
    part def Transmitter :> QKDModule {
        doc /* ETSI defines it as a QKD module that is capable of transmitting quantum states in the quantum channel. */
        port QC_tx : LinksAndPorts::QuantumPort;
        perform action transmitState : FunctionalElements::TransmitQuantumSignal;
    }
    part def Receiver :> QKDModule {
        doc /* ETSI defines it as a QKD module that us capable of receiving quantum states in quntum channel. */
        port QC_rx : ~LinksAndPorts::QuantumPort;
        perform action receiveState : FunctionalElements::MeasureQuantumSignal;
    }
    part def Transceiver :> QKDModule, Transmitter, Receiver {
        doc
        /* ETSI also defines a module capable of both transmitting and receiving quantum states, and notes that a transceiver counts as both
         * a QKD transmitter and a QKD receiver. Because it inherits the transmitter and receiver so it already can have all they have */
    }
    part def QuantumRelayPoint {
        doc
        /* The relay point sits on the quantum channel of a QKD link, between the two modules. 
         * Y.3802 describes it this way: a quantum relay point functional element is used for some QKD protocols 
         * or it acts as a quantum repeater for fully quantum networking. It also defines the interfaces between it and the modules. 
         * Qqc and Qsync are reference points between the QKD module and the quantum relay point.
         * it is not necessarily trusted, so no keys are generated or shared in the quantum relay point.*/
    }
    part def KeyManger;
}
