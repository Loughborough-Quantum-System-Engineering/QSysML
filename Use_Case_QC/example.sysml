// Example models for the generalized entanglement vocabulary of
// quantum.sysml (package Quantum). Usage-level examples only; the
// general definitions live there. All references to user libraries
// are fully qualified per the project style rule.
//
// States are calculation-aligned (6 Nov 2026): each quantum state
// carries its state vector — one (real part, imaginary part) pair per
// basis member (conventions C1/C2). Conversion from the former
// (probability, relativePhase) values: member k amplitude pair =
// (sqrt(p_k) cos(phi_k), sqrt(p_k) sin(phi_k)); all member phases here
// are 0 or pi, so the pairs are purely real.

package Example {
    private import ScalarValues::*;

    // ────────────────────────────────────────────────────────────
    // Example 1: an entangled state, Bell Phi+ on two qubits
    // ────────────────────────────────────────────────────────────

    attribute computationalBasis4 : Quantum::Basis {
        doc /* Two-qubit computational basis; index convention:
               1 = |00>, 2 = |01>, 3 = |10>, 4 = |11>. */
        attribute :>> dimension = 4;
    }

    item q1 : Quantum::Qubit;
    item q2 : Quantum::Qubit;

    item entangledPair : Quantum::CompositeQuantumSystem {
        doc /* Entangled: Bell Phi+ = (|00> + |11>)/sqrt(2), rank 2
               across the {q1} | {q2} cut. The qubits carry no
               descriptions of their own: their reduced states are
               mixed, and mixtures are not QuantumStates. Measuring
               either qubit yields 0 or 1 with probability 0.5, and
               the other qubit's outcome is then fully determined
               (non-local correlation). */
        ref item side1 :>> subsystem = q1;
        ref item side2 :>> subsystem = q2;

        state :>> quantumState {
            attribute :>> basis = computationalBasis4;
            attribute :>> stateVector =
                ((CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0), (0.0, 0.0),
                 (0.0, 0.0), (CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0));
            attribute :>> entanglement {
                ref item bellSide1 :>> spannedSubsystems = q1;
                ref item bellSide2 :>> spannedSubsystems = q2;
                attribute :>> entangled = true;
            }
        }
    }

    // ────────────────────────────────────────────────────────────
    // Example 2: the separable contrast, |0> x |+>
    // ────────────────────────────────────────────────────────────

    item separablePair : Quantum::CompositeQuantumSystem {
        doc /* Separable: q3 in |0> and q4 in |+>. Each subsystem
               carries its own pure description, and the joint
               description is their product. No entanglement record
               is asserted (the rank would be 1). */
        item q3 : Quantum::QuantumSubSystem subsets subsystem {
            state :>> quantumState {
                attribute :>> basis {
                    attribute :>> dimension = 2;
                }
                attribute :>> stateVector =
                    ((1.0, 0.0), (0.0, 0.0));
            }
        }
        item q4 : Quantum::QuantumSubSystem subsets subsystem {
            state :>> quantumState {
                attribute :>> basis {
                    attribute :>> dimension = 2;
                }
                attribute :>> stateVector =
                    ((CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0),
                     (CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0));
            }
        }
        state :>> quantumState {
            attribute :>> basis {
                attribute :>> dimension = 4;
            }
            attribute :>> stateVector =
                ((CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0),
                 (CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0),
                 (0.0, 0.0), (0.0, 0.0));
        }
    }

    // ────────────────────────────────────────────────────────────
    // Example 3: entanglement distribution (entanglement-based QKD)
    // ────────────────────────────────────────────────────────────

    part def Station {
        attribute operatorName : String;
        item interfaceQubit : Quantum::Qubit;
    }

    part def AliceStation :> Station {
        attribute :>> operatorName = "Alice";
    }

    part def BobStation :> Station {
        attribute :>> operatorName = "Bob";
    }

    part def QkdLink :> Quantum::QuantumSubSystem {
        doc /* Entanglement-based QKD: an entangled photon pair is
               distributed, one photon to each station. The stations
               are ordinary parts with their own attributes; the pair
               is a CompositeQuantumSystem whose subsystems reference the two
               photons where they live; the correlation is carried by
               the joint state and the entanglement record, and does
               not weaken with the separation. */

        item alice : AliceStation;
        item bob : BobStation;

        item distributedPair : Quantum::CompositeQuantumSystem {
            doc /* The entangled photon pair after distribution. The
                   subsystems reference the interface qubits in Alice's
                   and Bob's stations. */
            ref item sideA :>> subsystem = alice.interfaceQubit;
            ref item sideB :>> subsystem = bob.interfaceQubit;

            state :>> quantumState {
                attribute :>> basis {
                    attribute :>> dimension = 4;
                }
                attribute :>> stateVector =
                    ((CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0), (0.0, 0.0),
                     (0.0, 0.0), (CalculationLibrary::QuantumStateCalc::invSqrt2, 0.0));
                attribute :>> entanglement {
                    ref item aliceSide :>> spannedSubsystems = alice.interfaceQubit;
                    ref item bobSide :>> spannedSubsystems = bob.interfaceQubit;
                    attribute :>> entangled = true;
                }
            }
        }
    }
}
