// reference
// @article{guo2026atomflow,
//   title={AtomFlow: An End-to-End FPGA-Based Control Architecture for Neutral Atom Quantum Computers},
//   author={Guo, Xiaorang and Winklmann, Jonas and Chea, Vengkeat and Schulz, Martin},
//   journal={arXiv preprint arXiv:2607.11490},
//   year={2026}
// }
//
// Provenance notation used in line comments:
//   [p.N LC]  = page N, left  column   (para k = k-th paragraph of that column)
//   [p.N RC]  = page N, right column
//   [Fig.1]   = Fig. 1 abstract control schematic of NAQCs, p.1
//   [Fig.5]   = Fig. 5 system architecture of AtomFlow, p.4
//   [Fig.6]   = Fig. 6 FPGA-based atom rearrangement engine, p.5

package NeutralAtomInterface {

    doc
    /*
     * FPGA-based classical control interface for a neutral atom quantum
     * computer.
     *
     * Neutral atom quantum computing is valued for long coherence times and
     * naturally identical atomic qubits, but its execution rate is dominated
     * by lengthy classical processing: fluorescence imaging, cooling and atom
     * rearrangement. Atoms are loaded probabilistically into a
     * two-dimensional array of optical traps with roughly 50% occupancy, so
     * an initialization procedure is required, consisting of atom detection
     * by fluorescence imaging followed by rearrangement of the present atoms
     * into a smaller defect-free array.
     *
     * AtomFlow consolidates fluorescence-image analysis and atom
     * rearrangement onto a single device. By co-locating the two stages on
     * the same board and emitting rearrangement moves in a streaming fashion
     * as soon as they are computed, it eliminates the round-trip latency of
     * conventional host-mediated pipelines.
     *
     * The architecture operates in two distinct modes, initialization and
     * readout, which share the same image processing hardware and differ only
     * in what happens to the reconstructed emissions afterwards. That shared
     * front end is why the camera and image processing module serve both the
     * control and the readout path.
     *
     * Source: Guo et al. 2026, abstract and p.1 through p.6, with Figs. 1, 5
     * and 6.
     */

    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import AtomicCommon::*;
    public import ISQ::*;
    public import SI::*;

    // =====================================================================
    // Operating modes
    // =====================================================================
    enum def operatingMode {
        doc
        /*
         * AtomFlow operates in two distinct modes, both orchestrated by the
         * processing system. In initialization mode the reconstructed
         * emissions are binarized and passed to the rearrangement engine; in
         * readout mode they are returned directly for qubit state
         * evaluation, enabling mid-circuit measurement.
         *
         * Source: p.4, right column, paragraphs 1 and 2.
         */
        initialization;
        readout;
    }

    // =====================================================================
    // Action definitions
    // =====================================================================

    action def CalibrateSystem {
        doc
        /*
         * Perform the initial system calibration: detecting atom positions
         * and grid orientation, calculating the inverse kernel, and
         * determining the binarization threshold. Because this calibration is
         * performed offline and remains valid across multiple experimental
         * runs, it only requires re-execution when the physical optical setup
         * changes.
         *
         * Source: p.4, right column, paragraph 3.
         */
        out item calibration : digitalData;
    }

    action def ReconstructOccupancy {
        doc
        /*
         * Perform per-site atom occupancy reconstruction from the raw
         * fluorescence image, using point-spread function calibration data
         * provided by the processing system.
         *
         * This module is shared by both operating modes, which is what allows
         * the same hardware to serve initial atom detection and final
         * quantum-state readout.
         *
         * Source: p.4, right column, paragraph 1; p.2, left column,
         * paragraph 2.
         */
        in item rawImage : digitalData;
        in item calibration : digitalData;
        out item reconstructedEmissions : digitalData;
    }

    action def BinariseOccupancy {
        doc
        /*
         * Binarize the reconstructed emission values against a pre-set
         * threshold to produce an exact atom occupancy map. Performed only in
         * initialization mode.
         *
         * Source: p.4, right column, paragraph 2.
         */
        in item reconstructedEmissions : digitalData;
        out item occupancyMap : digitalData;
        attribute binarizationThreshold;
    }

    action def ClassifyAtoms {
        doc
        /*
         * First state of the rearrangement finite state machine. The
         * classifier sweeps the lattice by site and builds three per-index
         * lists. A site inside the target region that should be occupied
         * after rearrangement is appended to the target sites. An occupied
         * site is tested against a neighbourhood mask: if no other atoms are
         * so close as to prohibit reliable separation it is appended to the
         * usable atoms, otherwise to the unusable atoms.
         *
         * Source: p.5, right column.
         */
        in item occupancyMap : digitalData;
        out item classifiedSites : digitalData;
        attribute neighbourhoodMaskSize;            // 5 by 5 sites [p.5 RC]
    }

    action def ClearCorridor {
        doc
        /*
         * Second state of the rearrangement finite state machine. Before
         * atoms can be relocated between indices, a transit corridor, the
         * sorting channel, must be opened near the lattice boundary.
         *
         * Source: p.5, right column; p.6, left column.
         */
        in item classifiedSites : digitalData;
        out item clearedLattice : digitalData;
    }

    action def SortChannel {
        doc
        /*
         * Third state and main rearrangement phase. For each index, atoms are
         * consumed from the unusable and usable lists to fill the relevant
         * target sites. Intermediate discard, scatter, park and fill
         * operations may take place: surplus usable atoms are discarded,
         * atoms not needed immediately are parked outside the computation
         * zone for later use, and the remaining usable atoms are matched to
         * outstanding target sites.
         *
         * Source: p.6, left column.
         */
        in item clearedLattice : digitalData;
        out item sortedLattice : digitalData;
    }

    action def ResolveDeficiency {
        doc
        /*
         * Fourth state, invoked only when some target sites remain unfilled
         * after channel sorting. The missing atoms are routed from parking
         * spots using corridor-routed moves that traverse the cleared
         * boundary corridor. If the target sites are fully drained at the end
         * of channel sorting this stage is skipped entirely, saving one
         * traversal of the state machine.
         *
         * Source: p.6, left column.
         */
        in item sortedLattice : digitalData;
        out item resolvedLattice : digitalData;
    }

    action def EncodeMove {
        doc
        /*
         * Pack each parallel move for transmission. Each move is packed into
         * a packet of up to four steps, where each step carries up to sixteen
         * column and sixteen row selections as signed integers together with
         * their per-axis counts. The number of active steps determines the
         * move type.
         *
         * Source: p.6, right column.
         */
        in item resolvedLattice : digitalData;
        out item moveStream : digitalData;
        attribute packetSize;                       // 320 byte [p.6 RC]
        attribute maxSteps;                         // 4        [p.6 RC]
    }

    action def ManipulateQubitState {
        doc
        /*
         * Apply gates to the target atoms. Qubit states are encoded in
         * quantum states of individual atoms and manipulated by laser-driven
         * operations, with the Rydberg interaction providing entanglement.
         *
         * Source: p.1, right column; p.2, left column, paragraph 1.
         */
        in item gatePulse : microwaveSignal;
        in item rydbergBeam : opticalSignal;
        in item coolingBeam : opticalSignal;
        in item imagingBeam : opticalSignal;
        out item fluorescence : opticalSignal;
    }

    action def IssueGateInstruction :> ProcessData {
        doc
        /* Compile and issue the executable gate instructions, acting on the
         * conditional feedback from mid-circuit measurement. Kept local
         * because the library IssueCommand is a free-running source, whereas
         * this stage is driven by the feedback it receives.
         *
         * Source: p.2, left column, paragraph 1; Fig. 1, orange and green
         * paths.
         */
        in item feedback : digitalData;
        out item command : digitalData;
    }

    // =====================================================================
    // End-to-end behaviour
    // =====================================================================
    action def NeutralAtomControlAndReadout {

        doc
        /*
         * Sequence of the AtomFlow control cycle, covering the three control
         * flows drawn in Fig. 1: atom array initialization, circuit
         * execution, and mid-circuit measurement with feedback.
         *
         * The cycle begins with imaging. The reconstructed occupancy is then
         * routed by operating mode: in initialization mode it is binarized
         * and passed through the four-state rearrangement pipeline, whose
         * moves are streamed to the waveform generator and executed by the
         * deflectors; in readout mode it goes straight to state evaluation
         * and, for a mid-circuit measurement, back to the control processor
         * as conditional feedback.
         *
         * The mode branch is modelled with a decide node because the two
         * paths share the imaging front end and diverge only afterwards,
         * which is precisely the consolidation the architecture is built on.
         *
         * Reported performance on a 16 by 16 array: an end-to-end latency of
         * 25.3 ms, a first-move latency of 4 ms, and an average move
         * generation time of 1.01 ms.
         *
         * This definition states ordering and the action-to-action item
         * chain. The physical routing of those items through ports is
         * modelled in the parts.
         *
         * Source: abstract and p.1 through p.6, with Figs. 1, 5 and 6.
         */

        out item measuredQubitState : digitalData;
        attribute mode : operatingMode;
        attribute endToEndLatency = 25.3E-3 [s];    // 25.3 ms  [abstract]
        attribute firstMoveLatency = 4.0E-3 [s];    // 4 ms     [abstract]
        attribute averageMoveGeneration = 1.01E-3 [s]; // 1.01 ms [p.2 RC para 1]

        // ---- calibration and light generation ----
        action calibrateSystem : CalibrateSystem;                  // [p.4 RC para 3]
        action generateTrappingLight : GenerateLaserBeam;      // [p.2 LC para 2]
        action generateImagingBeam : GenerateLaserBeam;          // [p.2 LC para 2]
        action generateCoolingBeam : GenerateLaserBeam;          // [abstract]
        action generateRydbergBeam : GenerateLaserBeam;          // [p.1 RC]

        // ---- shared imaging front end ----
        action captureFluorescenceImage : DetectPhotons;// [p.2 LC para 2]
        action reconstructOccupancy : ReconstructOccupancy;        // [p.4 RC para 1]

        // ---- initialization path ----
        action binariseOccupancy : BinariseOccupancy;              // [p.4 RC para 2]
        action classifyAtoms : ClassifyAtoms;                      // [p.5 RC]
        action clearCorridor : ClearCorridor;                      // [p.6 LC]
        action sortChannel : SortChannel;                          // [p.6 LC]
        action resolveDeficiency : ResolveDeficiency;              // [p.6 LC]
        action encodeMove : EncodeMove;                            // [p.6 RC]
        action bufferMoveStream : BufferStream;                // [p.6 RC]
        action generateRfTones : SynthesiseWaveform;                  // [p.2 RC para 2]
        action deflectTweezers : DeflectBeam;                  // [p.3 LC para 1]
        action rearrangeAtoms : RearrangeAtoms;                    // [p.3 LC para 1]

        // ---- circuit execution ----
        action issueGateInstruction : IssueGateInstruction;        // [p.2 LC para 1]
        action generateMicrowaveGate : SynthesiseWaveform;      // [p.2 LC para 1]
        action manipulateQubitState : ManipulateQubitState;        // [p.1 RC]

        // ---- readout path ----
        action evaluateQubitState : EvaluateMeasurement;            // [p.4 RC para 2]
        action applyConditionalFeedback : ApplyFeedback;// [p.2 LC para 1]
        action analyseResult : AnalyseMeasurement;                      // [p.4 RC para 3]

        // ---- control nodes ----
        fork initiate;
        join joinReconstruct;
        join joinDeflect;
        join joinGate;
        decide selectMode;
        merge rejoin;

        // ---- ordering ----
        first start then calibrateSystem;                          // [p.4 RC para 3]
        first calibrateSystem then initiate;
        first initiate then generateTrappingLight;                 // [p.2 LC para 2]
        first initiate then generateImagingBeam;
        first initiate then generateCoolingBeam;
        first initiate then generateRydbergBeam;

        // shared imaging front end                                [p.4 RC para 1]
        first initiate then captureFluorescenceImage;
        first captureFluorescenceImage then joinReconstruct;
        first calibrateSystem then joinReconstruct;
        first joinReconstruct then reconstructOccupancy;

        // the two modes diverge here                              [p.4 RC para 2]
        first reconstructOccupancy then selectMode;
        if mode == operatingMode::initialization then binariseOccupancy;
        if mode == operatingMode::readout then evaluateQubitState;

        // initialization path: four-state rearrangement pipeline  [p.5 RC; p.6 LC]
        first binariseOccupancy then classifyAtoms;
        first classifyAtoms then clearCorridor;
        first clearCorridor then sortChannel;
        first sortChannel then resolveDeficiency;
        first resolveDeficiency then encodeMove;                   // [p.6 RC]
        first encodeMove then bufferMoveStream;
        first bufferMoveStream then generateRfTones;               // [p.2 RC para 2]
        first generateRfTones then joinDeflect;
        first generateTrappingLight then joinDeflect;
        first joinDeflect then deflectTweezers;                    // [p.3 LC para 1]
        first deflectTweezers then rearrangeAtoms;
        first rearrangeAtoms then rejoin;

        // readout path                                            [p.4 RC para 2]
        first evaluateQubitState then applyConditionalFeedback;    // [p.2 LC para 1]
        first evaluateQubitState then analyseResult;               // [p.4 RC para 3]
        first applyConditionalFeedback then rejoin;

        // circuit execution                                       [p.2 LC para 1]
        first rejoin then issueGateInstruction;
        first issueGateInstruction then generateMicrowaveGate;
        first generateMicrowaveGate then joinGate;
        first generateRydbergBeam then joinGate;
        first generateCoolingBeam then joinGate;
        first generateImagingBeam then joinGate;
        first joinGate then manipulateQubitState;
        first manipulateQubitState then captureFluorescenceImage;
        first analyseResult then done;

        // ---- item chain ----
        flow from calibrateSystem.calibration to reconstructOccupancy.calibration;
        flow from manipulateQubitState.fluorescence to captureFluorescenceImage.light;
        flow from captureFluorescenceImage.count to reconstructOccupancy.rawImage;

        flow from reconstructOccupancy.reconstructedEmissions to binariseOccupancy.reconstructedEmissions;
        flow from binariseOccupancy.occupancyMap to classifyAtoms.occupancyMap;
        flow from classifyAtoms.classifiedSites to clearCorridor.classifiedSites;
        flow from clearCorridor.clearedLattice to sortChannel.clearedLattice;
        flow from sortChannel.sortedLattice to resolveDeficiency.sortedLattice;
        flow from resolveDeficiency.resolvedLattice to encodeMove.resolvedLattice;
        flow from encodeMove.moveStream to bufferMoveStream.streamIn;
        flow from bufferMoveStream.streamOut to generateRfTones.command;
        flow from generateRfTones.waveform to deflectTweezers.drive;
        flow from generateTrappingLight.beam to deflectTweezers.light;
        flow from deflectTweezers.deflectedLight to rearrangeAtoms.movableTweezers;

        flow from reconstructOccupancy.reconstructedEmissions to evaluateQubitState.measurement;
        flow from evaluateQubitState.result to applyConditionalFeedback.measurement;
        flow from evaluateQubitState.result to analyseResult.measurement;
        flow from applyConditionalFeedback.feedback to issueGateInstruction.feedback;

        flow from issueGateInstruction.command to generateMicrowaveGate.command;
        flow from generateMicrowaveGate.waveform to manipulateQubitState.gatePulse;
        flow from generateRydbergBeam.beam to manipulateQubitState.rydbergBeam;
        flow from generateCoolingBeam.beam to manipulateQubitState.coolingBeam;
        flow from generateImagingBeam.beam to manipulateQubitState.imagingBeam;

        bind measuredQubitState = analyseResult.qubitState;
    }

    action atomFlowOperation : NeutralAtomControlAndReadout;

    // =====================================================================
    // Structure
    // =====================================================================
    part neutralAtomControlSystem : classicalControlSystem {

        doc
        /*
         * Control side, consolidating the real-time backend, the control
         * processor, the waveform generation and the laser system. The
         * architecture co-locates image analysis and rearrangement on one
         * device so that moves stream out as soon as they are computed.
         *
         * Source: abstract; p.4, right column; Fig. 5.
         */

        part realTimeControlBackend {
            doc
            /*
             * The real-time control backend, following a feed-forward
             * dataflow structure. Its image processing module and
             * rearrangement engine sit on the same device, which is what
             * removes the host round trip.
             *
             * Source: p.4, right column, paragraph 1; Fig. 5.
             */
            part armProcessor {
                doc
                /*
                 * Processing system side. Performs the offline calibration,
                 * manages parameter and register configuration, and executes
                 * the final result analysis.
                 *
                 * Source: p.4, right column, paragraph 3.
                 */
                port configOut : digitalPort {
                    in item item1;
                }
                perform atomFlowOperation.calibrateSystem;
                flow from calibrateSystem.calibration to configOut.item1;
            }
            part imageProcessingModule {
                doc
                /*
                 * Performs per-site atom occupancy reconstruction from the
                 * raw image using point-spread function calibration data.
                 * Shared by both operating modes.
                 *
                 * Source: p.4, right column, paragraph 1.
                 */
                port imageIn : ~digitalPort {
                    out item item1;
                }
                port configIn : ~digitalPort {
                    out item item1;
                }
                port occupancyOut : digitalPort {
                    in item item1;
                }
                port emissionsOut : digitalPort {
                    in item item1;
                }
                perform atomFlowOperation.reconstructOccupancy;
                flow from imageIn.item1 to reconstructOccupancy.rawImage;
                flow from configIn.item1 to reconstructOccupancy.calibration;
                flow from reconstructOccupancy.reconstructedEmissions to occupancyOut.item1;
                flow from reconstructOccupancy.reconstructedEmissions to emissionsOut.item1;
            }
            part controlInterfaceModule {
                doc
                /*
                 * Binarizes the reconstructed emission values against the
                 * pre-set threshold to produce the exact atom occupancy map,
                 * in initialization mode.
                 *
                 * Source: p.4, right column, paragraph 2.
                 */
                port emissionsIn : ~digitalPort {
                    out item item1;
                }
                port occupancyOut : digitalPort {
                    in item item1;
                }
                perform atomFlowOperation.binariseOccupancy;
                flow from emissionsIn.item1 to binariseOccupancy.reconstructedEmissions;
                flow from binariseOccupancy.occupancyMap to occupancyOut.item1;
            }
            part atomRearrangementEngine {
                doc
                /*
                 * Hardware-accelerated load, compute and stream pipeline
                 * fusing memory transfer, on-chip processing and result
                 * delivery into a single accelerator. The rearrangement core
                 * is driven by a four-state finite state machine whose states
                 * execute sequentially and share a single physical datapath
                 * by time-multiplexing.
                 *
                 * Source: p.5, right column; Fig. 6.
                 */
                attribute clockFrequency = 100.0E6 [Hz];   // 100 MHz [p.5 RC]
                part dataLoader;
                part stateArrayBram;
                part targetGeometryBram;
                part rearrangementCore {
                    part neighborhoodScanner {
                        port sitesIn : ~digitalPort {
                            out item item1;
                        }
                        port classifiedOut : digitalPort {
                            in item item1;
                        }
                        perform atomFlowOperation.classifyAtoms;   // [p.5 RC]
                        flow from sitesIn.item1 to classifyAtoms.occupancyMap;
                        flow from classifyAtoms.classifiedSites to classifiedOut.item1;
                    }
                    part corridorClearer {
                        port classifiedIn : ~digitalPort {
                            out item item1;
                        }
                        port clearedOut : digitalPort {
                            in item item1;
                        }
                        perform atomFlowOperation.clearCorridor;   // [p.6 LC]
                        flow from classifiedIn.item1 to clearCorridor.classifiedSites;
                        flow from clearCorridor.clearedLattice to clearedOut.item1;
                    }
                    part channelComparator {
                        port clearedIn : ~digitalPort {
                            out item item1;
                        }
                        port sortedOut : digitalPort {
                            in item item1;
                        }
                        perform atomFlowOperation.sortChannel;     // [p.6 LC]
                        flow from clearedIn.item1 to sortChannel.clearedLattice;
                        flow from sortChannel.sortedLattice to sortedOut.item1;
                    }
                    part deficiencyResolver {
                        port sortedIn : ~digitalPort {
                            out item item1;
                        }
                        port resolvedOut : digitalPort {
                            in item item1;
                        }
                        perform atomFlowOperation.resolveDeficiency; // [p.6 LC]
                        flow from sortedIn.item1 to resolveDeficiency.sortedLattice;
                        flow from resolveDeficiency.resolvedLattice to resolvedOut.item1;
                    }
                    port sitesIn : ~digitalPort;
                    port movesOut : digitalPort;
                    flow from sitesIn to neighborhoodScanner.sitesIn;
                    flow from neighborhoodScanner.classifiedOut to corridorClearer.classifiedIn;
                    flow from corridorClearer.clearedOut to channelComparator.clearedIn;
                    flow from channelComparator.sortedOut to deficiencyResolver.sortedIn;
                    flow from deficiencyResolver.resolvedOut to movesOut;
                }
                part moveEncoder {
                    doc
                    /*
                     * Packs each parallel move into a packet as soon as it is
                     * finalized, rather than accumulating an off-chip move
                     * list.
                     *
                     * Source: p.6, right column.
                     */
                    port latticeIn : ~digitalPort {
                        out item item1;
                    }
                    port packetOut : digitalPort {
                        in item item1;
                    }
                    perform atomFlowOperation.encodeMove;
                    flow from latticeIn.item1 to encodeMove.resolvedLattice;
                    flow from encodeMove.moveStream to packetOut.item1;
                }
                port occupancyIn : ~digitalPort;
                port movesOut : digitalPort;
                flow from occupancyIn to rearrangementCore.sitesIn;
                flow from rearrangementCore.movesOut to moveEncoder.latticeIn;
                flow from moveEncoder.packetOut to movesOut;
            }
            part axiStreamFifo {
                doc
                /*
                 * Decouples the producer-side timing of the rearrangement
                 * core from the consumer-side waveform hardware, so that the
                 * generator can act on the earliest moves while later ones
                 * are still being resolved.
                 *
                 * Source: p.6, right column.
                 */
                port movesIn : ~digitalPort {
                    out item item1;
                }
                port movesOut : digitalPort {
                    in item item1;
                }
                perform atomFlowOperation.bufferMoveStream;
                flow from movesIn.item1 to bufferMoveStream.streamIn;
                flow from bufferMoveStream.streamOut to movesOut.item1;
            }
            port imageIn : ~digitalPort;
            port movesOut : digitalPort;
            port emissionsOut : digitalPort;
            flow from armProcessor.configOut to imageProcessingModule.configIn;
            flow from imageIn to imageProcessingModule.imageIn;
            flow from imageProcessingModule.occupancyOut to controlInterfaceModule.emissionsIn;
            flow from controlInterfaceModule.occupancyOut to atomRearrangementEngine.occupancyIn;
            flow from atomRearrangementEngine.movesOut to axiStreamFifo.movesIn;
            flow from axiStreamFifo.movesOut to movesOut;
            flow from imageProcessingModule.emissionsOut to emissionsOut;
        }
        part controlProcessor {
            doc
            /*
             * Quantum control processor. Applies qubit gates on target atoms
             * and controls the timing of the waveform generators producing
             * the microwave pulses, acting on conditional feedback from
             * mid-circuit measurement.
             *
             * Source: p.2, left column, paragraph 1; Fig. 1, orange and green
             * paths.
             */
            port measResultIn : ~digitalPort {
                out item item1;
            }
            port gateInstrOut : digitalPort {
                in item item1;
            }
            perform atomFlowOperation.issueGateInstruction;
            flow from measResultIn.item1 to issueGateInstruction.feedback;
            flow from issueGateInstruction.command to gateInstrOut.item1;
        }
        part signalGenerator {
            doc
            /*
             * Waveform generation. Produces both the RF tones that drive the
             * deflectors and the microwave pulses that implement qubit gates.
             *
             * Source: p.2, left column, paragraph 1; p.2, right column,
             * paragraph 2.
             */
            port moveDataIn : ~digitalPort {
                out item item1;
            }
            port gateInstrIn : ~digitalPort {
                out item item1;
            }
            port rfToneOut : microwavePort {
                in item item1;
            }
            port microwaveGateOut : microwavePort {
                in item item1;
            }
            perform atomFlowOperation.generateRfTones;
            perform atomFlowOperation.generateMicrowaveGate;
            flow from moveDataIn.item1 to generateRfTones.command;
            flow from gateInstrIn.item1 to generateMicrowaveGate.command;
            flow from generateRfTones.waveform to rfToneOut.item1;
            flow from generateMicrowaveGate.waveform to microwaveGateOut.item1;
        }
        part acoustoOpticDeflector {
            doc
            /*
             * A pair of deflectors oriented perpendicular to each other, each
             * fed a number of RF tones, generating the two-dimensional grid
             * of movable traps used to rearrange atoms in parallel.
             *
             * Source: p.2, right column, paragraph 2.
             */
            port rfIn : ~microwavePort {
                out item item1;
            }
            port trapLightIn : ~opticalPort {
                out item item1;
            }
            port tweezerOut : opticalPort {
                in item item1;
            }
            perform atomFlowOperation.deflectTweezers;
            flow from rfIn.item1 to deflectTweezers.drive;
            flow from trapLightIn.item1 to deflectTweezers.light;
            flow from deflectTweezers.deflectedLight to tweezerOut.item1;
        }
        part laserSystem {
            doc
            /*
             * Laser sources for trapping, Rydberg gate driving, cooling and
             * fluorescence imaging.
             *
             * Source: p.1, right column; p.2, left column, paragraph 2.
             */
            part trappingLaser {
                port beamOut : opticalPort {
                    in item item1;
                }
                perform atomFlowOperation.generateTrappingLight;
                flow from generateTrappingLight.beam to beamOut.item1;
            }
            part rydbergGateLaser {
                port beamOut : opticalPort {
                    in item item1;
                }
                perform atomFlowOperation.generateRydbergBeam;
                flow from generateRydbergBeam.beam to beamOut.item1;
            }
            part coolingLaser {
                port beamOut : opticalPort {
                    in item item1;
                }
                perform atomFlowOperation.generateCoolingBeam;
                flow from generateCoolingBeam.beam to beamOut.item1;
            }
            part imagingLaser {
                port beamOut : opticalPort {
                    in item item1;
                }
                perform atomFlowOperation.generateImagingBeam;
                flow from generateImagingBeam.beam to beamOut.item1;
            }
            port trapOut : opticalPort;
            port rydbergOut : opticalPort;
            port coolingOut : opticalPort;
            port imagingOut : opticalPort;
            flow from trappingLaser.beamOut to trapOut;
            flow from rydbergGateLaser.beamOut to rydbergOut;
            flow from coolingLaser.beamOut to coolingOut;
            flow from imagingLaser.beamOut to imagingOut;
        }
        port fluorescenceImageIn : ~digitalPort;
        port tweezerOut : opticalPort;
        port microwaveGateOut : microwavePort;
        port rydbergBeamOut : opticalPort;
        port coolingBeamOut : opticalPort;
        port imagingBeamOut : opticalPort;
        port emissionsOut : digitalPort;
        port measResultIn : ~digitalPort;
        flow from fluorescenceImageIn to realTimeControlBackend.imageIn;
        flow from realTimeControlBackend.movesOut to signalGenerator.moveDataIn;
        flow from controlProcessor.gateInstrOut to signalGenerator.gateInstrIn;
        flow from signalGenerator.rfToneOut to acoustoOpticDeflector.rfIn;
        flow from laserSystem.trapOut to acoustoOpticDeflector.trapLightIn;
        flow from acoustoOpticDeflector.tweezerOut to tweezerOut;
        flow from signalGenerator.microwaveGateOut to microwaveGateOut;
        flow from laserSystem.rydbergOut to rydbergBeamOut;
        flow from laserSystem.coolingOut to coolingBeamOut;
        flow from laserSystem.imagingOut to imagingBeamOut;
        flow from realTimeControlBackend.emissionsOut to emissionsOut;
        flow from measResultIn to controlProcessor.measResultIn;
    }

    part vacuumChamberEnv {

        doc
        /*
         * Vacuum chamber holding the two-dimensional array of optical traps
         * and the camera that collects the fluorescence. Atoms are loaded
         * probabilistically into the traps, which is what makes the
         * rearrangement stage necessary.
         *
         * Source: p.1, right column; p.2, left column, paragraph 2.
         */

        attribute pressure : PressureUnit;

        port tweezerIn : ~opticalPort;
        port microwaveGateIn : ~microwavePort;
        port rydbergIn : ~opticalPort;
        port coolingIn : ~opticalPort;
        port imagingIn : ~opticalPort;
        port imageOut : digitalPort;

        part viewport;
        part vacuumPump;

        part qpu : QPU {
            doc
            /*
             * The atom array. Modelled as a black box so that only the
             * classical interface is in scope; the physical rearrangement of
             * atoms by the movable tweezers is performed here.
             *
             * Source: p.1, right column; p.3, left column, paragraph 1.
             */
            attribute redefines technology = qubitTechnology::neutralAtom;
            port tweezerIn : ~opticalPort {
                out item item1;
            }
            port microwaveGateIn : ~microwavePort {
                out item item1;
            }
            port rydbergIn : ~opticalPort {
                out item item1;
            }
            port coolingIn : ~opticalPort {
                out item item1;
            }
            port imagingIn : ~opticalPort {
                out item item1;
            }
            port fluorescenceOut : opticalPort {
                in item item1;
            }
            perform atomFlowOperation.rearrangeAtoms;
            perform atomFlowOperation.manipulateQubitState;
            flow from tweezerIn.item1 to rearrangeAtoms.movableTweezers;
            flow from microwaveGateIn.item1 to manipulateQubitState.gatePulse;
            flow from rydbergIn.item1 to manipulateQubitState.rydbergBeam;
            flow from coolingIn.item1 to manipulateQubitState.coolingBeam;
            flow from imagingIn.item1 to manipulateQubitState.imagingBeam;
            flow from manipulateQubitState.fluorescence to fluorescenceOut.item1;
        }
        part camera {
            doc
            /*
             * Highly sensitive camera collecting the scattered photons. Sited
             * with the chamber because it serves both operating modes, the
             * initial atom detection and the final state readout.
             *
             * Source: p.2, left column, paragraph 2.
             */
            port fluorescenceIn : ~opticalPort {
                out item item1;
            }
            port imageOut : digitalPort {
                in item item1;
            }
            perform atomFlowOperation.captureFluorescenceImage;
            flow from fluorescenceIn.item1 to captureFluorescenceImage.light;
            flow from captureFluorescenceImage.count to imageOut.item1;
        }
        flow from tweezerIn to qpu.tweezerIn;
        flow from microwaveGateIn to qpu.microwaveGateIn;
        flow from rydbergIn to qpu.rydbergIn;
        flow from coolingIn to qpu.coolingIn;
        flow from imagingIn to qpu.imagingIn;
        flow from qpu.fluorescenceOut to camera.fluorescenceIn;
        flow from camera.imageOut to imageOut;
    }

    part neutralAtomReadoutSystem : classicalReadoutSystem {

        doc
        /*
         * Readout side. In readout mode the reconstructed emissions are
         * evaluated to give the qubit state, and for a mid-circuit
         * measurement the outcome is fed back to the control processor for
         * conditional operations.
         *
         * Source: p.4, right column, paragraph 2; p.2, left column,
         * paragraph 1.
         */

        part stateReadoutEvaluation {
            port emissionsIn : ~digitalPort {
                out item item1;
            }
            port resultOut : digitalPort {
                in item item1;
            }
            perform atomFlowOperation.evaluateQubitState;          // [p.4 RC para 2]
            flow from emissionsIn.item1 to evaluateQubitState.measurement;
            flow from evaluateQubitState.measurement to resultOut.item1;
        }
        part conditionalFeedback {
            port resultIn : ~digitalPort {
                out item item1;
            }
            port feedbackOut : digitalPort {
                in item item1;
            }
            perform atomFlowOperation.applyConditionalFeedback;    // [p.2 LC para 1]
            flow from resultIn.item1 to applyConditionalFeedback.measurement;
            flow from applyConditionalFeedback.feedback to feedbackOut.item1;
        }
        part resultAnalyser {
            doc
            /*
             * Fetches the atom-array data from memory and executes the final
             * result analysis.
             *
             * Source: p.4, right column, paragraph 3.
             */
            port resultIn : ~digitalPort {
                out item item1;
            }
            perform atomFlowOperation.analyseResult;
            flow from resultIn.item1 to analyseResult.measurement;
        }
        port emissionsIn : ~digitalPort;
        port feedbackOut : digitalPort;
        flow from emissionsIn to stateReadoutEvaluation.emissionsIn;
        flow from stateReadoutEvaluation.resultOut to conditionalFeedback.resultIn;
        flow from stateReadoutEvaluation.resultOut to resultAnalyser.resultIn;
        flow from conditionalFeedback.feedbackOut to feedbackOut;
    }

    flow from neutralAtomControlSystem.tweezerOut to vacuumChamberEnv.tweezerIn;
    flow from neutralAtomControlSystem.microwaveGateOut to vacuumChamberEnv.microwaveGateIn;
    flow from neutralAtomControlSystem.rydbergBeamOut to vacuumChamberEnv.rydbergIn;
    flow from neutralAtomControlSystem.coolingBeamOut to vacuumChamberEnv.coolingIn;
    flow from neutralAtomControlSystem.imagingBeamOut to vacuumChamberEnv.imagingIn;
    flow from vacuumChamberEnv.imageOut to neutralAtomControlSystem.fluorescenceImageIn;
    flow from neutralAtomControlSystem.emissionsOut to neutralAtomReadoutSystem.emissionsIn;
    flow from neutralAtomReadoutSystem.feedbackOut to neutralAtomControlSystem.measResultIn;
}
