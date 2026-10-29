// Model for the first increment of the quantum computing vertical
// slice: the universal gate set {H, T, CNOT} and its gate operations on
// a logical qubit. The gate definitions of the chosen set live here,
// with this use case, rather than in the general library. The CNOT
// operation is deferred until the two-qubit coupling construct is
// settled (open decision D-8).
//
// General quantum-domain definitions (basis, quantum state, quantum
// operator, unitary operator) live in quantum.sysml, package Quantum.
// Quantum computing definitions (logical qubit, quantum operation,
// quantum gate, gate sets) live in QuantumComputing.sysml, package
// quantumOperationDefinitions. The basis is defined first; a
// quantum state is always expressed as its own description relative to
// a basis (the basis, probabilities by member index, relative phase),
// never as a reference to a basis member.
//
// Extensibility pattern: every single-qubit gate of the set specialises
// SingleQubitGateApplication, which fixes the acted-on multiplicity.
// Each case usage is one performance with its own local view of the
// acted-on qubit: a caseQubit item carrying only that case's beforeGate
// and afterGate phases. The cases are alternatives, not steps of one
// run, so no case's timeline touches another's. Adding or swapping a
// gate means: one gate definition plus one case usage.

package GateOperations {
    private import ScalarValues::*;

    attribute pi : Real = 3.141592653589793;

    abstract action def SingleQubitGateApplication :> QuantumComputing::quantumOperationDefinitions::QuantumGate {
        doc /* Common pattern for gates of the universal set acting on one
               qubit: fixes the acted-on multiplicity to one. Case usages
               carry their phases on a local caseQubit item.
               Source: QSysML gate-level mapping. */
        ref item redefines actsOn[1];
    }

    action def HadamardGate :> SingleQubitGateApplication {
        doc /* Single-qubit gate; the Hadamard operator interchanges the
               computational (z) and x basis views of the qubit. Exact
               action on the basis states: the member-1 state of zBasis
               maps to the member-1 state of xBasis (|0> to |+>), and
               the member-2 state of zBasis to the member-2 state of
               xBasis (|1> to |->). Equivalently, H maps a state's
               z-description to the x-description carrying the same
               probabilities and relative phase. General action on the
               probabilities in one basis:
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
               states this is a global phase only, so the description is
               unchanged; on a superposition it is the visible phase
               effect: H-T-H on |0> yields measurement probabilities of
               about (0.854, 0.146), versus (1, 0) without the T.
               Source: Qiskit Textbook, ch01. */
    }

    action def CNOTGate :> QuantumComputing::quantumOperationDefinitions::QuantumGate {
        doc /* Two-qubit gate; the controlled-NOT operator applies NOT to
               the target qubit conditioned on the state of the control
               qubit.
               Source: Qiskit Textbook, ch02. */
        ref item redefines actsOn[2];
    }

    abstract action def GateSeries :> SingleQubitGateApplication {
        doc /* An ordered series of gates composing one gate: the
               composition mechanism of the composite gates. All member
               gates act on the series' qubit, in the succession order
               stated by the specializing gate.
               Source: QSysML gate-level mapping. */
        action gate[1..*] : QuantumComputing::quantumOperationDefinitions::QuantumGate;
        bind gate.actsOn = actsOn;
    }

    action def ZGate :> GateSeries {
        doc /* Pauli Z gate realized from the universal gate set:
               Z = T T T T, exact, since T^4 = diag(1, exp(i pi)) =
               diag(1, -1). The body shows the realization; the gate
               remains one operation with one unitary operator.
               Source: Qiskit Textbook, ch01/ch02. */
        action t1 : TGate subsets gate;
        action t2 : TGate subsets gate;
        action t3 : TGate subsets gate;
        action t4 : TGate subsets gate;
        first t1 then t2;
        first t2 then t3;
        first t3 then t4;
    }

    action def XGate :> GateSeries {
        doc /* Pauli X gate realized from the universal gate set:
               X = H T T T T H, exact, since Z = T^4 and X = H Z H.
               The body shows the realization; the gate remains one
               operation with one unitary operator.
               Source: Qiskit Textbook, ch01/ch02. */
        action h1 : HadamardGate subsets gate;
        action t1 : TGate subsets gate;
        action t2 : TGate subsets gate;
        action t3 : TGate subsets gate;
        action t4 : TGate subsets gate;
        action h2 : HadamardGate subsets gate;
        first h1 then t1;
        first t1 then t2;
        first t2 then t3;
        first t3 then t4;
        first t4 then h2;
    }

    action def YGate :> GateSeries {
        doc /* Pauli Y gate realized from the universal gate set:
               Y is realized as Z then X, since X Z = i Y, exact up to
               the global phase i, which this model leaves in the
               native model as unobservable. The body shows the
               realization; the gate remains one operation with one
               unitary operator.
               Source: Qiskit Textbook, ch01/ch02. */
        action z : ZGate subsets gate;
        action x : XGate subsets gate;
        first z then x;
    }

    attribute zBasis : Quantum::Basis {
        doc /* The computational (z) basis of a single qubit; members
               labelled |0> and |1> by convention.
               Source: Qiskit Textbook, ch01. */
        attribute :>> dimension = 2;
        ref state zeroMember subsets memberState;
        ref state oneMember subsets memberState;
    }

    attribute xBasis : Quantum::Basis {
        doc /* The x basis of a single qubit; members labelled |+> and
               |-> by convention.
               Source: Qiskit Textbook, ch01. */
        attribute :>> dimension = 2;
        ref state plusMember subsets memberState;
        ref state minusMember subsets memberState;
    }

    action universalGateSet : QuantumComputing::quantumOperationDefinitions::UniversalGateSet {
        doc /* The universal gate set {H, T, CNOT}. S is omitted as
               redundant (S = T^2); the Pauli gates are generated
               (Z = T^4, X = H T^4 H, Y = X Z up to global phase).
               Source: /qp consult, 22 Oct 2026. */
        ref action hadamardMember : HadamardGate subsets memberGate;
        ref action tMember : TGate subsets memberGate;
        ref action cnotMember : CNOTGate subsets memberGate;
    }

    part def QuantumComputer {
        doc /* The quantum computer at the logical level: the performer of
               quantum operations on its logical qubits. The mapping to the
               physical qubit hardware is out of scope at this stage.
               Source: Quantum Ontology (BS ISO/IEC 4879), quantum computer. */
        item logicalQubit : QuantumComputing::quantumOperationDefinitions::LogicalQubit;

        // general operations: what the computer performs on its qubit
        action applyHadamard : HadamardGate {
            ref item :>> actsOn = logicalQubit;
        }

        action applyT : TGate {
            ref item :>> actsOn = logicalQubit;
        }

        // case usages: one performance each, with a local view of the
        // acted-on qubit carrying only that case's before/after phases
        action applyHadamardToZero : HadamardGate {
            doc /* H on the |0> state: certainty of member 1 in z becomes
                   certainty of member 1 in x; same description, different
                   basis.
                   Source: Qiskit Textbook, ch01. */
            item caseQubit : QuantumComputing::quantumOperationDefinitions::LogicalQubit {
                timeslice beforeGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (1.0, 0.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    state :>> quantumState {
                        attribute :>> basis = xBasis;
                        attribute :>> probability = (1.0, 0.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
            }
            ref item :>> actsOn = caseQubit;
        }

        action applyHadamardToOne : HadamardGate {
            doc /* H on the |1> state: certainty of member 2 in z becomes
                   certainty of member 2 in x.
                   Source: Qiskit Textbook, ch01. */
            item caseQubit : QuantumComputing::quantumOperationDefinitions::LogicalQubit {
                timeslice beforeGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.0, 1.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    state :>> quantumState {
                        attribute :>> basis = xBasis;
                        attribute :>> probability = (0.0, 1.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
            }
            ref item :>> actsOn = caseQubit;
        }

        // T on basis states: global phase only, description unchanged
        action applyTToZero : TGate {
            doc /* T on the |0> state: the state is unchanged, since T
                   adds only a global phase.
                   Source: Qiskit Textbook, ch01. */
            item caseQubit : QuantumComputing::quantumOperationDefinitions::LogicalQubit {
                timeslice beforeGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (1.0, 0.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (1.0, 0.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
            }
            ref item :>> actsOn = caseQubit;
        }

        action applyTToOne : TGate {
            doc /* T on the |1> state: the state is unchanged, since
                   exp(i pi/4)|1> equals |1> up to a global phase.
                   Source: Qiskit Textbook, ch01. */
            item caseQubit : QuantumComputing::quantumOperationDefinitions::LogicalQubit {
                timeslice beforeGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.0, 1.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.0, 1.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
            }
            ref item :>> actsOn = caseQubit;
        }

        // the visible T case: probabilities unchanged, phase + pi/4
        action applyTToPlus : TGate {
            doc /* T on the |+> state: both probabilities unchanged, the
                   relative phase advanced by pi/4.
                   Source: Qiskit Textbook, ch01. */
            item caseQubit : QuantumComputing::quantumOperationDefinitions::LogicalQubit {
                timeslice beforeGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.5, 0.5);
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.5, 0.5);
                        attribute :>> relativePhase = pi / 4;
                    }
                }
            }
            ref item :>> actsOn = caseQubit;
        }

        // X on |0>, traced through the realization: the T gates walk
        // the relative phase from 0 to pi in four quarter steps, and
        // the final Hadamard converts the minus state into |1>
        action applyXToZero : XGate {
            doc /* X on the |0> state, traced through the realization
                   X = H T^4 H: |0> -> (0.5, 0.5, 0) -> four T steps to
                   (0.5, 0.5, pi) = |-> -> H -> |1>.
                   Source: Qiskit Textbook, ch01/ch02. */
            item caseQubit : QuantumComputing::quantumOperationDefinitions::LogicalQubit {
                timeslice beforeGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (1.0, 0.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterHadamard {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.5, 0.5);
                        attribute :>> relativePhase = 0.0;
                    }
                }
                timeslice afterT1 {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.5, 0.5);
                        attribute :>> relativePhase = pi / 4;
                    }
                }
                timeslice afterT2 {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.5, 0.5);
                        attribute :>> relativePhase = pi / 2;
                    }
                }
                timeslice afterT3 {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.5, 0.5);
                        attribute :>> relativePhase = 3 * pi / 4;
                    }
                }
                timeslice afterT4 {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.5, 0.5);
                        attribute :>> relativePhase = pi;
                    }
                }
                timeslice afterGate {
                    state :>> quantumState {
                        attribute :>> basis = zBasis;
                        attribute :>> probability = (0.0, 1.0);
                        attribute :>> relativePhase = 0.0;
                    }
                }
            }
            ref item :>> actsOn = caseQubit;
        }
    }
}
