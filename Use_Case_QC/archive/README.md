# Archive

Models parked while work focuses on a single superconducting transmon slice under the QSysMM framework.
Files are kept unchanged for reference and may return to active use later.
Folder structure mirrors the original location.

| Group | Files | Why parked |
|---|---|---|
| Other superconducting modalities | SplitTransmon, CShuntedFluxQubit, CShuntedFluxonium | Outside transmon focus |
| Couplings | CapacitiveCouplingViaResonator, DirectInductiveCoupling, InductiveCouplingViaTunableCoupler | DirectCapacitiveCoupling kept instead |
| Alternative interfaces | SingleFluxQuantumInterface, CryoCMOSInterface, OpticalInterface, WirelessInterface | Conventional microwave interface kept |
| Other platforms | LaserTrappedIonInterface, MicrowaveTrappedIonInterface, EQCTrappedIonInterface, NeutralAtomInterface, AtomicCommon | Non-superconducting platforms |
| Legacy | physicalBlackBox, logicalBlackBox, physicalLayerAction | QSAM-era black boxes, superseded |

Archived files import shared packages that remain in Use_Case_QC/ (QuantumComputing, CommonInstruments, SuperconductingCommon, SuperconductiveQubit).
If a tool loads only the active folders, archived files may show unresolved imports. That is expected.
