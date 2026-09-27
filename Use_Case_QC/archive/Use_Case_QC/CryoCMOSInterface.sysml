// reference
// @article{brennan2025classical,
//  title={Classical interfaces for controlling cryogenic quantum computing technologies},
//  author={Brennan, Jack C and Barbosa, Jo{\~a}o and Li, Chong and Ahmad, Meraj and Imroze, Fiheon and Rose, Calum and Karar, Wridhdhisom and Stanley, Manoj and Heidari, Hadi and Ridler, Nick M and others},
//  journal={APL Quantum},
// volume={2},
//  number={4},
//  year={2025},
//  publisher={AIP Publishing}
// }
//
// Provenance notation used in line comments:
//   [p.N LC]  = page N, left  column   (para k = k-th paragraph of that column)
//   [p.N RC]  = page N, right column
//   [Fig.3]   = Fig. 3 block diagram / legend, p.6

package CryoCMOSInterface {

    doc
    /*
     * Cryogenic CMOS control and readout interface for a superconducting
     * qubit in a dilution refrigerator.
     *
     * In a conventional setup the control and readout electronics operate at
     * room temperature, several metres from the qubits, and the resulting
     * cable length gives a signal latency of hundreds of nanoseconds. That
     * latency is unsuitable for fast quantum feedback, where the outcome of a
     * single-shot measurement must immediately inform the next action on the
     * qubit. Relocating the electronics to cryogenic temperatures alleviates
     * both the latency and the cabling burden.
     *
     * The architecture drawn in Fig. 3 takes this further: a data sequence is
     * pre-loaded into the cryo-CMOS processor, so that only a power source
     * needs to be connected through the cryostat and no signals need to be
     * sent in from instruments outside the fridge during measurement.
     *
     * Source: Brennan et al. 2025, section "Cryo-CMOS technologies",
     * p.5 right column paragraph 2 through p.6 right column paragraph 2, and
     * the Fig. 3 block diagram on p.6.
     */

    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import SuperconductingCommon::*;
    public import ISQ::*;
    public import SI::*;

    // =====================================================================
    // Cryo-CMOS process technologies named by the reference
    // =====================================================================
    enum def cryoCmosTechnology {
        doc
        /*
         * Two major technologies are currently used in cryoelectronics QC
         * hardware. Bulk CMOS offers low complexity and cost-effectiveness
         * but poses performance challenges at cryogenic temperatures, such
         * as carrier freeze-out, increased leakage current, kink effect and
         * hot carrier degradation. Fully depleted silicon-on-insulator is
         * more sophisticated and offers reduced leakage currents, low power
         * consumption, and back biasing to counter threshold voltage shift.
         *
         * Source: p.5, right column, paragraph 4.
         */
        bulkCMOS;
        fullyDepletedSiliconOnInsulator;
    }

    // =====================================================================
    // Action definitions
    // =====================================================================



    action def GenerateControlSignal {
        doc
        /*
         * Generate the qubit control signal from the pre-loaded sequence,
         * using custom-made control circuitry designed to operate at
         * cryogenic temperatures. Placing the circuitry within the proximity
         * of the qubit stage removes the metres of cable that dominate
         * latency in the conventional architecture.
         *
         * Source: p.5, right column, paragraphs 2 and 3; p.6, right column,
         * paragraph 2.
         */
        in item command : digitalData;
        in item bias : dcBias;
        out item driveSignal : microwaveSignal;
    }

    action def ManipulateQubitState {
        doc
        /*
         * Drive the qubit with the locally generated control signal.
         *
         * Source: QPU in the Fig. 3 legend, p.6.
         */
        in item driveSignal : microwaveSignal;
        out item qubitResponse : microwaveSignal;
    }

    action def AcquireQubitState {
        doc
        /*
         * Read out the qubit at cryogenic temperature. Custom-made readout
         * circuitry operating close to the qubit avoids the round trip to
         * room-temperature instruments.
         *
         * Source: p.5, right column, paragraph 3.
         */
        in item qubitResponse : microwaveSignal;
        in item bias : dcBias;
        out item measurement : digitalData;
    }



    // =====================================================================
    // End-to-end behaviour
    // =====================================================================
    action def CryoCmosControlAndReadout {

        doc
        /*
         * Sequence of the cryo-CMOS control and readout cycle as drawn in
         * Fig. 3 on p.6.
         *
         * The data sequence is pre-loaded and the two power lines are
         * established; thereafter the cryo-CMOS processor generates the
         * drive locally, reads the qubit back, and closes a fast feedback
         * loop at cryogenic temperature. Only the measurement record leaves
         * the fridge, for post-processing.
         *
         * The feedback path is what distinguishes this architecture: the
         * loop from measurement back to the next control action stays inside
         * the cryostat rather than crossing to room-temperature instruments.
         *
         * This definition states ordering and the action-to-action item
         * chain. The physical routing of those items through ports is
         * modelled in the parts.
         *
         * Source: p.5 right column paragraph 2 through p.6 right column
         * paragraph 2, and Fig. 3.
         */

        out attribute measuredQubitState;

        action preloadDataSequence : IssueCommand;          // [p.6 LC para 2]
        action provideControlPower : SupplyBias;                 // [Fig.3]
        action provideReadoutPower : SupplyBias;                 // [Fig.3]
        action generateControlSignal : GenerateControlSignal;      // [p.5 RC para 3]
        action manipulateQubitState : ManipulateQubitState;        // [Fig.3]
        action acquireQubitState : AcquireQubitState;              // [p.5 RC para 3]
        action performFastFeedback : ApplyFeedback;          // [p.5 RC para 2]
        action postProcess : AnalyseMeasurement;                          // [Fig.3]

        fork initiate;
        join joinControl;
        join joinReadout;

        // ---- ordering ----
        first start then initiate;
        first initiate then preloadDataSequence;                   // [p.6 LC para 2]
        first initiate then provideControlPower;
        first initiate then provideReadoutPower;

        // the processor needs both the sequence and its power
        first preloadDataSequence then joinControl;
        first provideControlPower then joinControl;
        first joinControl then generateControlSignal;
        first generateControlSignal then manipulateQubitState;

        first manipulateQubitState then joinReadout;
        first provideReadoutPower then joinReadout;
        first joinReadout then acquireQubitState;                  // [p.5 RC para 3]
        first acquireQubitState then performFastFeedback;          // [p.5 RC para 2]
        first acquireQubitState then postProcess;                  // [Fig.3]
        first postProcess then done;

        // ---- item chain ----
        flow from preloadDataSequence.command to generateControlSignal.command;
        flow from provideControlPower.bias to generateControlSignal.bias;
        flow from generateControlSignal.driveSignal to manipulateQubitState.driveSignal;
        flow from manipulateQubitState.qubitResponse to acquireQubitState.qubitResponse;
        flow from provideReadoutPower.bias to acquireQubitState.bias;
        flow from acquireQubitState.measurement to performFastFeedback.measurement;
        flow from acquireQubitState.measurement to postProcess.measurement;
        // the feedback loop stays inside the cryostat [p.5 RC para 2]
        flow from performFastFeedback.feedback to generateControlSignal.command;

        bind measuredQubitState = postProcess.qubitState;
    }

    action cryoCmosOperation : CryoCmosControlAndReadout;

    // =====================================================================
    // Structure
    // =====================================================================
    part cryoCMOSControlSystem : classicalControlSystem {

        doc
        /*
         * Room-temperature control side. Under the pre-loaded scheme this
         * reduces to a data source and a power source, both drawn at the top
         * of Fig. 3.
         *
         * Source: p.6 left column paragraph 2; Fig. 3, p.6.
         */

        part controlPowerSource : powerSource {
            port powerOut : dcBiasPort {
                in item item1;
            }
            perform cryoCmosOperation.provideControlPower;         // [Fig.3]
            flow from provideControlPower.bias to powerOut.item1;
        }
        part preLoadedData {
            doc
            /*
             * The data sequence pre-loaded into the processor, drawn in
             * Fig. 3 as a dashed pre-loaded data sequence rather than a wired
             * connection.
             *
             * Source: p.6 left column paragraph 2; Fig. 3 legend.
             */
            port sequenceOut : digitalPort {
                in item item1;
            }
            perform cryoCmosOperation.preloadDataSequence;
            flow from preloadDataSequence.command to sequenceOut.item1;
        }
        port powerOut : dcBiasPort;
        port sequenceOut : digitalPort;
        flow from controlPowerSource.powerOut to powerOut;
        flow from preLoadedData.sequenceOut to sequenceOut;
    }

    part dilutionRefrigeratorEnv : dilutionRefrigerator {

        doc
        /*
         * Dilution refrigerator housing both the cryo-CMOS processor and the
         * qubit. Fig. 3 marks six temperature stages and shows the lines
         * passing straight through them, with no stage-anchored components,
         * because the control and readout electronics have been moved to the
         * base stage rather than being distributed up the cryostat.
         *
         * The cryo-CMOS circuits still encounter significant heat
         * dissipation, which can surpass the cooling capacity of the
         * cryostat and raise the qubit temperature, disrupting all aspects of
         * its operation. Connections to the quantum processor can be made
         * with superconducting materials below 4 K to minimise heat
         * conduction between stages and electrical losses.
         *
         * Source: p.6 left column paragraph 2; Fig. 3, p.6.
         */

        port controlPowerIn : ~dcBiasPort;
        port sequenceIn : ~digitalPort;
        port readoutPowerIn : ~dcBiasPort;
        port resultOut : digitalPort;

        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];

            part cryoCMOSProcessor {
                doc
                /*
                 * Custom-made readout and control circuitry designed to
                 * operate at cryogenic temperatures, sited within the
                 * proximity of the qubit stage. It generates the drive from
                 * the pre-loaded sequence, acquires the qubit state, and
                 * closes the fast feedback loop locally.
                 *
                 * Source: p.5 right column paragraph 3; p.6 right column
                 * paragraph 2; CryoCMOS processor in Fig. 3.
                 */
                attribute technology : cryoCmosTechnology;
                port controlPowerIn : ~dcBiasPort {
                    out item item1;
                }
                port readoutPowerIn : ~dcBiasPort {
                    out item item1;
                }
                port sequenceIn : ~digitalPort {
                    out item item1;
                }
                port driveOut : microwavePort {
                    in item item1;
                }
                port readoutIn : ~microwavePort {
                    out item item1;
                }
                port resultOut : digitalPort {
                    in item item1;
                }
                perform cryoCmosOperation.generateControlSignal;
                perform cryoCmosOperation.acquireQubitState;
                perform cryoCmosOperation.performFastFeedback;
                flow from sequenceIn.item1 to generateControlSignal.command;
                flow from controlPowerIn.item1 to generateControlSignal.bias;
                flow from generateControlSignal.driveSignal to driveOut.item1;
                flow from readoutIn.item1 to acquireQubitState.qubitResponse;
                flow from readoutPowerIn.item1 to acquireQubitState.bias;
                flow from acquireQubitState.measurement to resultOut.item1;
                // feedback is internal to the processor [p.5 RC para 2]
                flow from acquireQubitState.measurement to performFastFeedback.measurement;
                flow from performFastFeedback.feedback to generateControlSignal.command;
            }
            part qpu : QPU {
                doc
                /*
                 * Quantum processing unit, wired directly to the cryo-CMOS
                 * processor at the base stage. Modelled as a black box so
                 * that only the classical interface is in scope.
                 *
                 * Source: QPU in the Fig. 3 legend, p.6.
                 */
                attribute redefines technology = qubitTechnology::superconducting;
                port driveIn : ~microwavePort {
                    out item item1;
                }
                port readoutOut : microwavePort {
                    in item item1;
                }
                perform cryoCmosOperation.manipulateQubitState;
                flow from driveIn.item1 to manipulateQubitState.driveSignal;
                flow from manipulateQubitState.qubitResponse to readoutOut.item1;
            }
            flow from cryoCMOSProcessor.driveOut to qpu.driveIn;
            flow from qpu.readoutOut to cryoCMOSProcessor.readoutIn;
        }
        flow from controlPowerIn to sixthLayer.cryoCMOSProcessor.controlPowerIn;
        flow from sequenceIn to sixthLayer.cryoCMOSProcessor.sequenceIn;
        flow from readoutPowerIn to sixthLayer.cryoCMOSProcessor.readoutPowerIn;
        flow from sixthLayer.cryoCMOSProcessor.resultOut to resultOut;
    }

    part cryoCMOSReadoutSystem : classicalReadoutSystem {

        doc
        /*
         * Room-temperature readout side. Reduced to a power source and the
         * post-processing electronics, since acquisition itself happens
         * inside the cryostat.
         *
         * Source: Fig. 3, p.6.
         */

        part readoutPowerSource : powerSource {
            port powerOut : dcBiasPort {
                in item item1;
            }
            perform cryoCmosOperation.provideReadoutPower;         // [Fig.3]
            flow from provideReadoutPower.bias to powerOut.item1;
        }
        part postProcessingElectronics {
            port resultIn : ~digitalPort {
                out item item1;
            }
            perform cryoCmosOperation.postProcess;                 // [Fig.3]
            flow from resultIn.item1 to postProcess.measurement;
        }
        port powerOut : dcBiasPort;
        port resultIn : ~digitalPort;
        flow from readoutPowerSource.powerOut to powerOut;
        flow from resultIn to postProcessingElectronics.resultIn;
    }

    flow from cryoCMOSControlSystem.powerOut to dilutionRefrigeratorEnv.controlPowerIn;
    flow from cryoCMOSControlSystem.sequenceOut to dilutionRefrigeratorEnv.sequenceIn;
    flow from cryoCMOSReadoutSystem.powerOut to dilutionRefrigeratorEnv.readoutPowerIn;
    flow from dilutionRefrigeratorEnv.resultOut to cryoCMOSReadoutSystem.resultIn;
}
