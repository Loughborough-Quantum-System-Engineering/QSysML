package FunctionalElements {
    action def GenerateRandomNumbers {
        doc
        /* Y.3802: random number generation (RNG) function. RNG function supplying random numbers to both the quantum communication 
         * and key distillation functions. */
        out item randomNumbers : SignalsAndData::RandomBitString [1..*];
    }
    action def TransmitQuantumSignal {
        doc
        /* Y.3802: quantum communication function (reference point Qqc), transmitting side.
         * The transmitter prepares and sends quantum signals chosen with random numbers.
         * It is signal not a state because state is what is carried.
         * ETSI GS QKD 016 speaks of transporting quantum states. Signals carry the states.
         * Qubit is too narrow: it excludes continuous-variable QKD and weak coherent pulses.
         * rawKey: the transmitter's record of its own random preparation choices. */
        in item randomNumbers : SignalsAndData::RandomBitString [1..*] ordered;
        out item Qsignal : SignalsAndData::QuantumSignal [1..*] ordered;
        out item rawKey_T : SignalsAndData::RawKey;
        /* out means: it says what an action produces, not that the item leaves the QKD module (part). */
        assert constraint oneChoicePerSignal {
            doc /* The i-th random string prepares the i-th signal. */
            SequenceFunctions::size(randomNumbers) == SequenceFunctions::size(Qsignal)
        }
    }
    action def MeasureQuantumSignal {
        doc
        /* Y.3802 7.1: quantum communication function, measuring side. Measures received
         * quantum signals (Qqc). randomNumbers: basis choices, absent when the choice is
         * made passively by the optics. rawKey: the measurement record. */
        in item Qsignal : SignalsAndData::QuantumSignal [1..*] ordered;
        in item basisChoice : SignalsAndData::RandomBitString [0..*] ordered {
            doc
            /* Each one sets the basis for one signal before it arrives. The random bits do not
             * appear in the outcomes; their effect is recorded as each outcome's basis. */
        }
        out item rawKey_R : SignalsAndData::RawKey;
        assert constraint choicesMatchSignals {
            SequenceFunctions::size(basisChoice) == 0 or SequenceFunctions::size(basisChoice) == SequenceFunctions::size(Qsignal)
        }
        assert constraint oneOutcomePerSignal {
            doc /* Lost signals still count, as noDetection, so positions stay aligned. */
            SequenceFunctions::size(rawKey_R) == SequenceFunctions::size(Qsignal)
        }
    }
    alias TransmitQuantumStates for TransmitQuantumSignal {
        /* using alias means it is the other name of the elemnt not a new element or specialised from it because some standards used the 2 terms*/
    }
    alias ReceiveQuantumStates for MeasureQuantumSignal;
    action def SynchronizeQuantumChannel {
        doc
        /* Y.3802: quantum channel synchronization function, providing clock and
         * timing synchronization for the quantum channel. */
    }
    action def DistillKey {
        doc
        /* Y.3802: key distillation function (reference point Qdist). Sifting, error
         * correction and privacy amplification turn the raw key into an identical,
         * secure key in both QKD modules (steps as in Gisin et al., Rev. Mod. Phys.
         * 74, 145, 2002). */
    }
    action def SupplyQKDKey {
        doc
        /* Y.3802: QKD-key supply function, receiving QKD-key requests from a KMA and
         * supplying QKD-keys to it (reference point Kq-1). */
    }
    action def ControlAndManageQKDModule {
        doc
        /* Y.3802: QKD module control and management function, responsible for the
         * overall control and management of the functional elements in the QKD module
         * and communicating with the control and management layers
         * (ITU-T FG-QIT4N D2.3). */
    }
    action def SwitchOrSplitChannels {
        doc
        /* Y.3802: optical switching/splitting functional element of a QKD link. It
         * switches or splits the quantum channel and the classical channel for
         * synchronization, and optionally the classical channel for key distillation
         * when it is multiplexed in the same fibre. */
    }
    action def RelayQuantumSignals {
        doc
        /* Y.3800 / Y.3802: quantum relay point, relaying quantum signals;
         * no keys are generated or shared in it. */
    }
    action def StoreKeys { in item receivedKey : SignalsAndData::QKDKey; }
    action def RelayKeys {
        doc /* Relay keys end-to-end through KMA links; OTP is recommended by Y.3802. */
        in item inputKey : SignalsAndData::QKDKey;
        out item relayedKey : SignalsAndData::QKDKey;
    }
    action def ManageKeyLifeCycle {
        doc /* Manage key lifecycle and delete or preserve stored keys under policy. */
    }
    action def SupplyKeys {
        doc /* Synchronize/authenticate keys between KSAs and supply them on demand. */
        in item keyRequest : SignalsAndData::KeyRequest;
        out item suppliedKey : SignalsAndData::QKDKey;
    }
}
view 'general Behaviours' : DS_Views::SymbolicViews::gv;
