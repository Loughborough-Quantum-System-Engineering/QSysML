package Examples {
    public import QuantumCoreOntology::*;
    public import QunantumCoreUtility::*;
    /* Photon example to show the state */
    attribute def PolarisationState :> QuantumState {
        doc /* Pure polarisation state: a vector of two complex amplitudes, on H and on V. */
        attribute amplitudes : ScalarValues::Complex [2] ordered nonunique;
    }
    attribute h : PolarisationState {
        attribute :>> amplitudes = (1.0, 0.0);
    }
    attribute d : PolarisationState {
        attribute :>> amplitudes = (0.7071, 0.7071);
    }
    attribute transmitting;
    attribute measurementBasis : MeasurementBasis;
    part Photon : QuantumSystem {
        attribute quantumState : QuantumState [0..1];
        exhibit state life {
            entry;
            then created;
            state created;
            accept h : PolarisationState do assign quantumState := h then polarised;
            state polarised;
            accept transmitting do action Transmit then inTransit;
            state inTransit;
            accept x : MeasurementBasis do assign measurementBasis := x then measured;
            state measured;
            then absorbed;
            state absorbed {
                entry assign quantumState := null;
            }
        }
    }
    part def Polariser {
        action usePolariser {
            in item photon : Photon;
            send h to photon;
        }
    }
}
