// Model for the first increment of the quantum computing vertical
// slice: the universal gate set {H, T, CNOT} and its gate operations on
// a logical qubit. The gate definitions of the chosen set live here,
// with this use case, rather than in the general library. The CNOT
// operation is deferred until the two-qubit coupling construct is
// settled (open decision D-8).
//
// General definitions (quantum state, logical qubit, quantum operation,
// quantum gate, operators) live in QuantumComputing.sysml, package
// quantumOperationDefinitions.
//
// Extensibility pattern: every single-qubit gate of the set specialises
// SingleQubitGateApplication, which fixes the acted-on multiplicity.
// Case usages state the state transition across the gate with the two
// standard slices beforeGate and afterGate, setting the qubit state's
// three values (probabilityOfZero, probabilityOfOne, relativePhase)
// per phase. States are values, not kinds: name a state at the slice
// with a named usage when a label helps (plusState), and promote a
// recurring name to a pinned definition only when it is shared. Adding
// or swapping a gate means: one gate definition plus its case usages.

package GateOperations {
    public import QuantumComputing::quantumOperationDefinitions::*;

    abstract action def SingleQubitGateApplication :> QuantumGate {
        doc /* Common pattern for gates of the universal set acting on one
               qubit: fixes the acted-on multiplicity to one and the
               standard slice names (beforeGate, afterGate) used by case
               usages to state the state transition.
               Source: QSysML gate-level mapping. */
        ref item redefines actsOn[1];
    }

    action def HadamardGate :> SingleQubitGateApplication {
        doc /* Single-qubit gate; the Hadamard operator interchanges the
               computational (z) and x basis views of the qubit.
               Operator: 1/sqrt(2) times the matrix with rows (1, 1)
               and (1, -1). Exact action on the basis states:
               (1, 0, 0) maps to (0.5, 0.5, 0), the plus state
               |+> = (|0> + |1>)/sqrt(2); (0, 1, 0) maps to
               (0.5, 0.5, pi), the minus state |-> = (|0> - |1>)/sqrt(2).
               General action on the probabilities:
               p0' = 1/2 + sqrt(p0 p1) cos(phi) and
               p1' = 1/2 - sqrt(p0 p1) cos(phi); the output relative
               phase follows from the output amplitudes and stays in
               the native model. The mapping is self-inverse.
               Source: Qiskit Textbook, ch01. */
    }

    action def TGate :> SingleQubitGateApplication {
        doc /* Single-qubit gate; the T gate, also called the pi/8 gate
               (T equals exp(i pi/8) times a z rotation by pi/4, up to
               global phase). Operator: diag(1, exp(i pi/4)). General
               action in this model's representation: both probabilities
               are unchanged and pi/4 is added to the relative phase,
               (p0, p1, phi) maps to (p0, p1, phi + pi/4). On basis
               states this is a global phase only, so the states are
               unchanged; on a superposition it is the visible phase
               effect: H-T-H on |0> yields measurement probabilities of
               about (0.854, 0.146), versus (1, 0) without the T.
               Source: Qiskit Textbook, ch01. */
    }

    action def CNOTGate :> QuantumGate {
        doc /* Two-qubit gate; the controlled-NOT operator applies NOT to
               the target qubit conditioned on the state of the control
               qubit.
               Source: Qiskit Textbook, ch02. */
        ref item redefines actsOn[2];
    }

    part def QuantumComputer {
        doc /* The quantum computer at the logical level: the performer of
               quantum operations on its logical qubits. The mapping to the
               physical qubit hardware is out of scope at this stage.
               Source: Quantum Ontology (BS ISO/IEC 4879), quantum computer. */
        item logicalQubit : LogicalQubit;

        // general operations: what the computer performs on its qubit
        action applyHadamard : HadamardGate {
            ref item :>> actsOn = logicalQubit;
        }

        action applyT : TGate {
            ref item :>> actsOn = logicalQubit;
        }

        // case usages: the state transition across each gate, stated as
        // beforeGate and afterGate phases of the qubit; each state is
        // given by its three values, named locally where a label helps
        action applyHadamardToZero : HadamardGate {
            ref item :>> actsOn = logicalQubit {
                timeslice beforeGate {
                    item zeroState :>> quantumState {
                        attribute :>> probabilityOfZero = 1.0;
                        attribute :>> probabilityOfOne = 0.0;
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    item plusState :>> quantumState {
                        attribute :>> probabilityOfZero = 0.5;
                        attribute :>> probabilityOfOne = 0.5;
                        attribute :>> relativePhase = 0.0;
                    }
                }
            }
        }

        action applyHadamardToOne : HadamardGate {
            ref item :>> actsOn = logicalQubit {
                timeslice beforeGate {
                    item oneState :>> quantumState {
                        attribute :>> probabilityOfZero = 0.0;
                        attribute :>> probabilityOfOne = 1.0;
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    item minusState :>> quantumState {
                        attribute :>> probabilityOfZero = 0.5;
                        attribute :>> probabilityOfOne = 0.5;
                        attribute :>> relativePhase = 3.141592653589793;
                    }
                }
            }
        }

        // T on basis states: a global phase only, values unchanged
        action applyTToZero : TGate {
            ref item :>> actsOn = logicalQubit {
                timeslice beforeGate {
                    item zeroState :>> quantumState {
                        attribute :>> probabilityOfZero = 1.0;
                        attribute :>> probabilityOfOne = 0.0;
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    item zeroState :>> quantumState {
                        attribute :>> probabilityOfZero = 1.0;
                        attribute :>> probabilityOfOne = 0.0;
                        attribute :>> relativePhase = 0.0;
                    }
                }
            }
        }

        action applyTToOne : TGate {
            ref item :>> actsOn = logicalQubit {
                timeslice beforeGate {
                    item oneState :>> quantumState {
                        attribute :>> probabilityOfZero = 0.0;
                        attribute :>> probabilityOfOne = 1.0;
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    item oneState :>> quantumState {
                        attribute :>> probabilityOfZero = 0.0;
                        attribute :>> probabilityOfOne = 1.0;
                        attribute :>> relativePhase = 0.0;
                    }
                }
            }
        }

        // the case where T's action is visible: probabilities unchanged,
        // relative phase advanced by pi/4
        action applyTToPlus : TGate {
            ref item :>> actsOn = logicalQubit {
                timeslice beforeGate {
                    item plusState :>> quantumState {
                        attribute :>> probabilityOfZero = 0.5;
                        attribute :>> probabilityOfOne = 0.5;
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    item tOnPlusState :>> quantumState {
                        attribute :>> probabilityOfZero = 0.5;
                        attribute :>> probabilityOfOne = 0.5;
                        attribute :>> relativePhase = 0.7853981633974483;
                    }
                }
            }
        }
    }
}
