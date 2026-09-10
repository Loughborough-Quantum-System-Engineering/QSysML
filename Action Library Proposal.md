---
tags:
  - phd
  - sysml-v2
  - agent
status: proposal
Date: 2026-07-30
Author: Claude
---

# Action Library Proposal

Proposed canonical names, tiers and unified parameters for the [[QSysML-v2]] action library. Derived from the 112 action defs currently spread across the 9 interface models; collapses to **~70 real concepts**. Mirrors the existing part-role tiering (see [[Modelling Workflow]]).

**Status: awaiting review.** Nothing has been applied yet.

## Naming rules used

- Verb-first, no platform prefix in the def name; the *purpose* goes in the usage name (`action generateCoolingBeam : GenerateLaserBeam`).
- One def per operation, not per instrument. Same operation on a different signal kind is the same def, typed against the `signal` root.
- Parameters named for their **role in the operation**, not the instrument (`unfiltered`/`filtered`, not `signalIn`/`signalOut`).

---

## Tier 1 — `QuantumComputing` (abstract roles, 8)

One abstract action per functional part role. Everything below specialises these.

| Action def | Parameters | Performed by (part role) |
|---|---|---|
| `GenerateSignal` | `out item signal : signal` | `signalSource` |
| `ConvertSignal` | `in item input : signal` · `out item output : signal` | `transducer` |
| `AmplifySignal` | `in item weakSignal : signal` · `out item amplifiedSignal : signal` | `amplifier` |
| `ConditionSignal` | `in item input : signal` · `out item output : signal` | `signalConditioner` |
| `TransmitSignal` | `in item input : signal` · `out item output : signal` | `transmissionMedium` |
| `ProcessData` | `in item input : digitalData` · `out item output : digitalData` | `classicalProcessor` |
| `OperateOnQubit` | abstract, no parameters | `QPU` |
| `RegulateEnvironment` | abstract, no parameters | `qubitEnvironment` |

---

## Tier 2 — `CommonInstruments` (technology-agnostic, 28)

### Sources

| Canonical | Parameters + attributes | Replaces |
|---|---|---|
| `GenerateEnvelope` | `out envelope : digitalData`; `pulseAmplitude`, `pulseDuration`, `pulseShape` | `GenerateEnvelope` ×3 |
| `GenerateCarrier` | `out carrier : microwaveSignal`; `carrierFrequency` | `GenerateCarrier` ×3 |
| `GenerateMicrowaveDrive` | `out drive : microwaveSignal`; `driveFrequency` | `GenerateTone`, `GenerateGlobalMicrowaveField`, `GenerateGateRfSignal`, `GenerateMicrowaveGate` |
| `GenerateLaserBeam` | `out beam : opticalSignal`; `wavelength` | `GenerateLaserBeam` ×2, `GenerateCoolingBeam` ×2, `GenerateImagingBeam`, `GenerateRydbergBeam`, `GenerateTrappingLight`, `GenerateAddressingBeam`, `GeneratePhotoionisationBeam`, `GeneratePumpBeam`, `GenerateReadoutExcitation`, `GenerateOpticalCarrier` **(11→1)** |
| `SupplyBias` | `out bias : dcBias`; `voltageStability` | `ProvideQubitBias`, `ProvideBias`, `ProvidePower`, `ProvidePhotodiodeBias`, `ApplyElectrodeVoltage` |
| `IssueCommand` | `out command : digitalData` | `IssueControlCommand`, `IssueControlSequence`, `IssueGateInstruction`, `PreloadDataSequence`, `GenerateControlSignal` |

### Transducers

| Canonical | Parameters + attributes | Replaces |
|---|---|---|
| `ConvertDigitalToAnalog` | `in digitalInput : digitalData` · `out analogOutput : microwaveSignal`; `precision`, `updateRate` | `ConvertDigitalToAnalog` ×3, `ConvertToAnalogDrive`, `GenerateElectrodeWaveform` |
| `ConvertAnalogToDigital` | `in analogInput : microwaveSignal` · `out digitalOutput : digitalData`; `resolution` | `ConvertAnalogToDigital` ×3 |
| `Upconvert` | `in baseband : signal` · `in carrier : microwaveSignal` · `out waveform : microwaveSignal` | `Upconvert` ×3 |
| `Downconvert` | `in waveform : microwaveSignal` · `in referenceCarrier : microwaveSignal` · `out baseband : microwaveSignal` | `Downconvert` ×3 |
| `RadiateBeam` | `in feed : microwaveSignal` · `out beam : signal` | `RadiateBeam`, `RadiateGlobalField`, `RadiateNearFieldRf` |
| `ReceiveBeam` | `in beam : signal` · `out feed : microwaveSignal` | `ReceiveBeam` |
| `EncodeOntoOptical` | `in electricalInput : microwaveSignal` · `in opticalCarrier : opticalSignal` · `out modulatedLight : opticalSignal`; `extinctionRatio`, `insertionLoss`, `powerConsumption`, `modulationEfficiency` | `EncodeOntoOptical` |
| `RecoverElectricalSignal` | `in modulatedLight : opticalSignal` · `in bias : dcBias` · `out electricalOutput : microwaveSignal`; `detectionWavelength`, `outputImpedance`, `bandwidth` | `RecoverElectricalSignal` |
| `ConvertWavelength` | `in inputPhoton : opticalSignal` · `in pumpBeam : opticalSignal` · `out outputPhoton : opticalSignal` | `ConvertWavelength` |
| `DeflectBeam` | `in drive : microwaveSignal` · `in light : opticalSignal` · `out deflectedLight : opticalSignal` | `DeflectTweezers` |
| `DetectPhotons` | `in light : opticalSignal` · `out count : digitalData`; `quantumEfficiency`, `darkCountRate`, `exposureTime` | `DetectPhotons`, `CountPhotons`, `CaptureFluorescenceImage` |

### Amplifier

| Canonical | Parameters | Replaces |
|---|---|---|
| `Amplify` | `in weakSignal : microwaveSignal` · `out amplifiedSignal : microwaveSignal` | `Amplify` ×3, `AmplifyMicrowave` |

### Conditioners

| Canonical | Parameters + attributes | Replaces |
|---|---|---|
| `FilterSignal` | `in unfiltered : signal` · `out filtered : signal` | `FilterSignal` ×3, `FilterElectrodeVoltage` |
| `AttenuateSignal` | `in unattenuated : signal` · `out attenuated : signal` | `AttenuateThermalNoise` ×2 |
| `SteerBeam` | `in beam : opticalSignal` · `out steeredBeam : opticalSignal`; `steeringRange` | `SteerBeam`, `SteerLaserBeam` |
| `FocusBeam` | `in incomingBeam : signal` · `out focusedBeam : signal`; `beamDiameter` | `FocusBeam`, `ProjectBeam` |
| `CollectLight` | `in emittedLight : opticalSignal` · `out collectedLight : opticalSignal`; `collectionEfficiency`, `transmission` | `CollectPhoton`, `CollectFluorescence`, `ImageFluorescence`, `TransmitFluorescence` |
| `RouteSignal` | `in input : signal` · `out output : signal` | `RouteLightToZone`, `RoutePhoton`, `GuideToQubit` |
| `Resonate` | `in input : microwaveSignal` · `out output : microwaveSignal`; `qualityFactor` | `ResonateRfDrive` |
| `SplitBeam` | `in input : opticalSignal` · `out outputA : opticalSignal` · `out outputB : opticalSignal` | `InterferePhotons` |

### Processing

| Canonical | Parameters + attributes | Replaces |
|---|---|---|
| `AnalyseMeasurement` | `in measurement : digitalData` · `out attribute qubitState`; `readoutFidelity`, `detectionWindow` | `PostProcess` ×4, `DetectQubitState`, `DetermineQubitState`, `EvaluateQubitState`, `BinariseCount`, `AnalyseSignal`, `AnalyseResult` ×2 **(11→1)** |
| `ApplyFeedback` | `in measurement : digitalData` · `out feedback : digitalData`; `feedbackLatency` | `PerformFastFeedback`, `ApplyConditionalFeedback` |
| `BufferStream` | `in input : digitalData` · `out output : digitalData` | `BufferMoveStream` |

---

## Tier 3a — `SuperconductingCommon` (10)

| Canonical | Parameters + attributes | Replaces / source |
|---|---|---|
| `ManipulateQubitState` | `in controlWaveform : microwaveSignal` · `in biasSupply : dcBias` · `out qubitResponse : microwaveSignal`; `blochSphereState`, `gateDuration` | `ManipulateQubitState` (SC models) |
| `DispersiveInteraction` | `in probeTone : microwaveSignal` · `in qubitCoupling : microwaveSignal` · `out stateDependentResponse : microwaveSignal` | Conventional |
| `SuppressBackaction` | `in incoming : microwaveSignal` · `out forwarded : microwaveSignal` | Conventional |
| `AmplifyQuantumLimited` | `:> Amplify` | Conventional (JPA) |
| `ApplyPulseProtocol` | `in envelope : digitalData` · `out shapedEnvelope : digitalData`; `protocol`, `controlFidelity` | Conventional |
| `SynchroniseClock` | `clockDelay` | Conventional |
| `GenerateSfqPulseTrain` | `in triggerTone : microwaveSignal` · `in biasSupply : dcBias` · `out pulseTrain : sfqPulse`; `fluxQuantum`, `pulseArea`, `minimumPulseInterval`, `pulseAmplitude`, `pulseSeparation` | SFQ |
| `MapStateToPhotonOccupation` | `in qubitCoupling : microwaveSignal` · `out photonOccupation : microwaveSignal` | SFQ |
| `DetectPhotonToCurrent` | `in photonOccupation : microwaveSignal` · `out storedResult : circulatingCurrent` | SFQ (JPM) |
| `ModulateFluxonArrival` | `in storedResult : circulatingCurrent` · `out fluxon : sfqPulse`; `arrivalTimeDeviation` | SFQ (JTL) |
| `ConvertToSfqLogic` | `in fluxon : sfqPulse` · `in biasSupply : dcBias` · `out logicSignal : microwaveSignal`; `clockSpeed`, `bitSwitchEnergy` | SFQ |

*(`circulatingCurrent` + `circulatingCurrentPort` move here from the SFQ model.)*

---

## Tier 3b — `AtomicCommon` (14)

| Canonical | Parameters + attributes | Replaces / source |
|---|---|---|
| `GenerateTrapDrive` | `out rfDrive : microwaveSignal`; `driveFrequency`, `driveVoltage` | `GenerateRfTrapDrive` ×2 |
| `LoadIon` | `in ionisationBeam : opticalSignal`; `loadingRate` | `LoadIon` ×2, part of `TrapAndCoolIons` |
| `CoolAtom` | `in coolingBeam : opticalSignal`; `coolingRate`, `steadyStatePhononNumber` | `CoolIon` ×2 |
| `PrepareState` | `in pumpingBeam : opticalSignal` · `in shelvingDrive : opticalSignal`; `preparationTime`, `postSelectionRate` | `PrepareState` ×2 |
| `TransportIon` | `in electrodePotential : dcBias`; `shuttlingTime`, `cycleTime` | `ShuttleIon`, `TransportIon` |
| `MergeWells` | `in electrodePotential : dcBias`; `mergeTime` | EQC |
| `SplitWells` | `in electrodePotential : dcBias`; `splitTime` | EQC |
| `PerformSingleQubitGate` | `in driveField : signal`; `gateTime` | EQC, `PerformQuantumGate`, `PerformGateOperation` |
| `PerformEntanglingGate` | `in driveField : signal`; `gateTime` | EQC |
| `ShelveQubit` | `in shelvingBeam : opticalSignal` · `out shelvedState : opticalSignal` | EQC |
| `ExciteCommunicationQubit` | `in excitationPulse : opticalSignal` · `out communicationPhoton : opticalSignal`; `excitationProbability` | Laser TI |
| `HeraldEntanglement` | `in photonA : opticalSignal` · `in photonB : opticalSignal` · `out herald : digitalData`; `connectionRate`, `detectorEfficiency` | Laser TI |
| `GenerateFieldGradient` | `in current : dcBias` · `out gradient : magneticField`; `gradientStrength`, `wireCurrent`, `ionHeight`, `wireInductance`, `rampTime` | Blueprint |
| `AdjustLocalMagneticField` | `in current : dcBias` · `out offsetField : magneticField`; `coilInductance` | Blueprint |
| `RearrangeAtoms` | `in movableTweezers : opticalSignal`; `transferTime`, `transportSpeed`, `moveExecutionTime` | AtomFlow |

---

## Tier 4 — model-local (10)

Genuinely single-model, stay where they are:

- **AtomFlow**: `CalibrateSystem`, `ReconstructOccupancy`, `BinariseOccupancy`, `ClassifyAtoms`, `ClearCorridor`, `SortChannel`, `ResolveDeficiency`, `EncodeMove`
- **Blueprint**: `RemoveHeat` *(or promote to `RegulateEnvironment` in Tier 1)*
- **Wireless**: none — all map to Tier 2

---

## Consequences to accept

1. **`GenerateLaserBeam` collapses 11 defs into 1.** Purpose moves to the usage name. Loses the per-beam `doc`, so the beam's role must be documented on the *usage* rather than the def.
2. **`AnalyseMeasurement` collapses 11 into 1.** Same trade-off.
3. **`AcquireQubitState` (cryo-CMOS) splits into two** — `ConvertAnalogToDigital` + `AnalyseMeasurement` — since it currently does both.
4. **`TrapAndCoolIons` (laser TI) splits into** `LoadIon` + `CoolAtom`.
5. **`ManipulateQubitState` sits in `SuperconductingCommon`**, not Tier 1, because the atomic models use the finer-grained single/entangling split. Cross-platform comparison then happens at the `OperateOnQubit` role, not at a shared concrete def.

## Open questions

- Should `RemoveHeat` be a Tier 1 `RegulateEnvironment` or stay model-local?
- `RadiateBeam` output typed `signal` so it covers both the free-space microwave beam (wireless) and the near-field magnetic field (EQC) — acceptable, or split into two defs?
- `GenerateMicrowaveDrive` vs `GenerateCarrier`: kept separate because one drives the qubit and one is a mixing reference. Confirm that distinction is worth two defs.

## Related Topics
- [[Modelling Workflow]] | [[7.17 Actions]] | [[7.6 Definition and Usage]] | [[SysML v2]]
