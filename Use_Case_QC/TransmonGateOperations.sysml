// reference
// @article{krantz2019quantum,
//   title={A quantum engineer's guide to superconducting qubits},
//   author={Krantz, Philip and Kjaergaard, Morten and Yan, Fei and Orlando, Terry P and Gustavsson, Simon and Oliver, William D},
//   journal={Applied Physics Reviews},
//   volume={6},
//   number={2},
//   year={2019}
// }
// @article{mckay2017efficient,
//   title={Efficient Z gates for quantum computing},
//   author={McKay, David C and Wood, Christopher J and Sheldon, Sarah and Chow, Jerry M and Gambetta, Jay M},
//   journal={Physical Review A},
//   volume={96},
//   number={2},
//   pages={022330},
//   year={2017}
// }

// Control-level model: the native rotating-frame operations (drive
// pulses and frame changes) and the control-level realizations of the
// logical gates H and T on the fixed-frequency transmon (QSysMM Table 1
// anchor case, D-1). The realizations specialize the logical gate
// definitions — the specialization is the realization statement; the
// QSysMM contract layer (RWA, computational subspace, fidelity margins)
// attaches to these defs. All phases are rotating-frame values at the
// drive frequency. The noisy physical realization (CPTP) is deferred —
// see the note on QuantumGate in QuantumComputing.sysml. The qubit is
// the same LogicalQubit the logical layer acts on (federated model).

package TransmonGateOperations {
    private import ScalarValues::*;

    // ── the native control-level operations ──

    action def DrivePulse {
        doc /* A calibrated microwave drive pulse in the rotating frame:
               the rotation angle is the calibrated pulse area, the drive
               phase selects the equatorial rotation axis (0 = x, pi/2 =
               y), the duration is the pulse length. All phases at this
               level are rotating-frame values at the drive frequency.
               The pulse envelope mathematics stays in the native model.
               Source: Krantz et al. 2019, Sec. IV C, Eqs. 84-92. */
        ref item qubit : Quantum::Qubit;
        attribute rotationAngle : Real;
        attribute drivePhase : Real;
        attribute duration : Real;
    }

    action def FrameChange {
        doc /* A frame change (virtual Z): a classical update of the drive
               reference phase, equivalent to a Z rotation of the same
               angle. Zero duration, nominally unity fidelity; performed
               by the control electronics, not the qubit.
               Source: Krantz et al. 2019, Sec. IV D 2; McKay et al. 2017. */
        ref item qubit : Quantum::Qubit;
        attribute rotationAngle : Real;
    }

    // ── the control-level realizations of the logical gates ──

    action def HadamardControl :> GateOperation::HadamardGate {
        doc /* Control-level realization of the Hadamard gate on the
               fixed-frequency transmon: H = Z(pi/2) X(pi/2) Z(pi/2) —
               one physical drive pulse bracketed by two zero-time frame
               changes. Validity: RWA, computational subspace (D-9),
               calibration margins.
               Source: Krantz et al. 2019, Eq. 99; McKay et al. 2017. */
        action fc1 : FrameChange {
            attribute :>> rotationAngle = BasicSetup::pi / 2;
        }
        action dp : DrivePulse {
            attribute :>> rotationAngle = BasicSetup::pi / 2;
            attribute :>> drivePhase = 0.0;
        }
        action fc2 : FrameChange {
            attribute :>> rotationAngle = BasicSetup::pi / 2;
        }
        first fc1 then dp;
        first dp then fc2;
        bind fc1.qubit = actsOn;
        bind dp.qubit = actsOn;
        bind fc2.qubit = actsOn;
    }

    action def TControl :> GateOperation::TGate {
        doc /* Control-level realization of the T gate: T = R_z(pi/4), a
               pure frame change — no physical pulse.
               Source: Krantz et al. 2019, Sec. IV D 2. */
        action fc : FrameChange {
            attribute :>> rotationAngle = BasicSetup::pi / 4;
        }
        bind fc.qubit = actsOn;
    }

    // ── the performing structure (D-1 anchor) ──

    part def TransmonComputer {
        doc /* The fixed-frequency transmon (QSysMM Table 1 anchor case:
               5.2 GHz, 15 mK, T1 = 50 us, T2 = 30 us) with its control
               electronics, at the rotating-frame level. The qubit is the
               two-level computational subspace (D-9); its realization by
               the physical transmon circuit is the KI-8 link, deferred
               with the drive ports (KI-6).
               Source: QSysMM (arXiv:2607.10347v1), Table 1. */
        item transmonQubit : QuantumComputing::quantumOperationDefinitions::LogicalQubit;

        action applyH : HadamardControl {
            ref item :>> actsOn = transmonQubit;
        }

        action applyT : TControl {
            ref item :>> actsOn = transmonQubit;
        }
    }
}
