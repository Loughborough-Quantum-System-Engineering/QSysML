// reference
// @article{monroe2013scaling,
//   title={Scaling the ion trap quantum processor},
//   author={Monroe, Christopher and Kim, Jungsang},
//   journal={Science},
//   volume={339},
//   number={6124},
//   pages={1164--1169},
//   year={2013},
//   publisher={American Association for the Advancement of Science}
// }
//
// Provenance notation used in line comments:
//   [p.N LC]  = journal page N, left  column   (para k = k-th paragraph)
//   [p.N RC]  = journal page N, right column
//   [Fig.2E]  = Fig. 2E photon emission from a communication qubit, p.1166
//   [Fig.2F]  = Fig. 2F beamsplitter and coincidence detection, p.1166
//   [Fig.3C]  = Fig. 3C MEMS beam steering, p.1167
//   [Fig.4A]  = Fig. 4A ELUs and optical crossconnect switch, p.1168

package LaserTrappedIonInterface {

    doc
    /*
     * Laser-driven control and readout interface for a trapped ion quantum
     * processor, with a photonic interconnect linking separate registers.
     *
     * Qubits are stored in two stable electronic levels of each ion. Laser
     * radiation performs initialization, gate operations through
     * qubit-state-dependent optical dipole forces mediated by the collective
     * motion of the ion crystal, and state detection by fluorescence.
     *
     * Individual addressing within an array is achieved by steering the
     * control beam, using electro-optic or acousto-optic deflectors for
     * small arrays and micromirror-based systems for larger ones. To scale
     * beyond a single chain, separate registers, termed elementary logic
     * units, are entangled through propagating photons emitted by designated
     * communication qubits and interfered on a beamsplitter, with
     * entanglement heralded by coincidence detection.
     *
     * Source: Monroe and Kim 2013, p.1165 through p.1168, with Figs. 2, 3
     * and 4.
     */

    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import AtomicCommon::*;
    public import ISQ::*;
    public import SI::*;

    // =====================================================================
    // Action definitions
    // =====================================================================







    action def TrapAndCoolIons {
        doc
        /*
         * Confine the ions and cool them into a linear crystal. When ions are
         * laser-cooled to very low temperatures they form a stable array,
         * with the Coulomb repulsion balancing the external confinement
         * force.
         *
         * Source: p.1164, right column.
         */
        in item rfDrive : microwaveSignal;
        in item coolingBeam : opticalSignal;
        in item ionisationBeam : opticalSignal;
    }

    action def PerformGateOperation {
        doc
        /*
         * Perform a gate by applying qubit-state-dependent optical dipole
         * forces. The motion of the trapped ions is coupled through the
         * Coulomb interaction, much like an array of pendulums connected by
         * springs, so the collective motion acts as an intermediary that
         * entangles the internal states of separated ions.
         *
         * Source: p.1165, right column.
         */
        in item focusedBeam : opticalSignal;
        out item memoryState : opticalSignal;
        attribute gateSpeed;                        // 10 to 100 kHz [p.1165 RC]
    }











    // =====================================================================
    // End-to-end behaviour
    // =====================================================================
    action def LaserTrappedIonControlAndReadout {

        doc
        /*
         * Sequence of the laser-driven control and readout cycle, together
         * with the photonic interconnect that entangles separate registers.
         *
         * Ions are loaded, trapped and cooled; the addressing beam is steered
         * and projected onto a chosen ion to perform a gate; state detection
         * illuminates the ion and images its fluorescence. In parallel, a
         * designated communication qubit is excited, its photon collected,
         * wavelength-converted, routed through the crossconnect switch,
         * interfered on a beamsplitter, and the coincidence detection heralds
         * entanglement between registers.
         *
         * This definition states ordering and the action-to-action item
         * chain. The physical routing of those items through ports is
         * modelled in the parts.
         *
         * Source: p.1164 right column through p.1168 right column.
         */

        out attribute measuredQubitState;
        out attribute entanglementHerald;

        // ---- trapping and preparation ----
        action generateRfTrapDrive : GenerateTrapDrive;          // [p.1164 RC]
        action generatePhotoionisationBeam : GenerateLaserBeam; // [p.1164 RC]
        action generateCoolingBeam : GenerateLaserBeam;          // [p.1165 LC]
        action trapAndCoolIons : TrapAndCoolIons;                  // [p.1164 RC]

        // ---- gate chain ----
        action generateAddressingBeam : GenerateLaserBeam;    // [p.1165 RC]
        action steerBeam : SteerBeam;                              // [p.1167 LC]
        action projectBeam : FocusBeam;                          // [Fig.3C]
        action performGateOperation : PerformGateOperation;        // [p.1165 RC]

        // ---- photonic interconnect ----
        action exciteCommunicationQubit : ExciteCommunicationQubit;// [p.1166 RC]
        action collectPhoton : CollectLight;                      // [p.1167 RC]
        action generatePumpBeam : GenerateLaserBeam;                // [Fig.4C]
        action convertWavelength : ConvertWavelength;              // [p.1168 RC]
        action routePhoton : RouteSignal;                          // [p.1168 LC]
        action interferePhotons : SplitBeam;                // [p.1166 RC]
        action heraldEntanglement : HeraldEntanglement;            // [p.1166 RC]

        // ---- readout ----
        action generateReadoutExcitation : GenerateLaserBeam; // [p.1165 LC]
        action imageFluorescence : CollectLight;              // [p.1165 LC]
        action detectQubitState : AnalyseMeasurement;                // [p.1165 LC]

        // ---- control nodes ----
        fork initiate;
        join joinTrap;
        join joinConvert;
        join joinHerald;

        // ---- ordering ----
        first start then initiate;
        first initiate then generateRfTrapDrive;                   // [p.1164 RC]
        first initiate then generatePhotoionisationBeam;
        first initiate then generateCoolingBeam;
        first generateRfTrapDrive then joinTrap;
        first generatePhotoionisationBeam then joinTrap;
        first generateCoolingBeam then joinTrap;
        first joinTrap then trapAndCoolIons;

        first trapAndCoolIons then generateAddressingBeam;         // [p.1165 RC]
        first generateAddressingBeam then steerBeam;               // [p.1167 LC]
        first steerBeam then projectBeam;
        first projectBeam then performGateOperation;

        // photonic interconnect runs alongside the local gate    [p.1166 RC]
        first trapAndCoolIons then exciteCommunicationQubit;
        first exciteCommunicationQubit then collectPhoton;
        first initiate then generatePumpBeam;
        first collectPhoton then joinConvert;
        first generatePumpBeam then joinConvert;
        first joinConvert then convertWavelength;                  // [p.1168 RC]
        first convertWavelength then routePhoton;                  // [p.1168 LC]
        first routePhoton then interferePhotons;                   // [p.1166 RC]
        first interferePhotons then joinHerald;
        first joinHerald then heraldEntanglement;

        // readout                                                 [p.1165 LC]
        first performGateOperation then generateReadoutExcitation;
        first generateReadoutExcitation then imageFluorescence;
        first imageFluorescence then detectQubitState;
        first detectQubitState then done;

        // ---- item chain ----
        flow from generateRfTrapDrive.rfDrive to trapAndCoolIons.rfDrive;
        flow from generateCoolingBeam.beam to trapAndCoolIons.coolingBeam;
        flow from generatePhotoionisationBeam.beam to trapAndCoolIons.ionisationBeam;

        flow from generateAddressingBeam.beam to steerBeam.beam;
        flow from steerBeam.steeredBeam to projectBeam.incomingBeam;
        flow from projectBeam.focusedBeam to performGateOperation.focusedBeam;

        flow from generateAddressingBeam.beam to exciteCommunicationQubit.excitationPulse;
        flow from exciteCommunicationQubit.communicationPhoton to collectPhoton.emittedLight;
        flow from collectPhoton.collectedLight to convertWavelength.inputPhoton;
        flow from generatePumpBeam.beam to convertWavelength.pumpBeam;
        flow from convertWavelength.outputPhoton to routePhoton.input;
        flow from routePhoton.output to interferePhotons.input;
        flow from interferePhotons.outputA to heraldEntanglement.photonA;
        flow from interferePhotons.outputB to heraldEntanglement.photonB;

        flow from performGateOperation.memoryState to imageFluorescence.emittedLight;
        flow from generateReadoutExcitation.beam to imageFluorescence.emittedLight;
        flow from imageFluorescence.collectedLight to detectQubitState.measurement;

        bind measuredQubitState = detectQubitState.qubitState;
        bind entanglementHerald = heraldEntanglement.herald;
    }

    action laserOperation : LaserTrappedIonControlAndReadout;

    // =====================================================================
    // Structure
    // =====================================================================
    part laserControlSystem : classicalControlSystem {

        doc
        /*
         * Laser and rf instrumentation outside the vacuum system: the
         * addressing beam and its steering and projection optics, the
         * cooling and photoionization beams, and the trap drive.
         *
         * Source: p.1164 right column; p.1167 left column; Fig. 3C.
         */

        part addressingLaser {
            port beamOut : opticalPort {
                in item item1;
            }
            perform laserOperation.generateAddressingBeam;         // [p.1165 RC]
            flow from generateAddressingBeam.beam to beamOut.item1;
        }
        part beamSteeringOptics {
            doc
            /*
             * Beam steering stage. Electro-optic and acousto-optic
             * deflectors suit small arrays; micromirror systems steer
             * multiple beams independently over larger arrays.
             *
             * Source: p.1167, left column; Fig. 3C.
             */
            variation part deflector {
                doc
                /*
                 * The three deflector technologies are alternatives, not a
                 * chain: electro-optic and acousto-optic deflectors suit
                 * small arrays, while micromirror-based systems suit larger
                 * ones and can steer multiple beams independently over the
                 * same array.
                 *
                 * Source: p.1167, left column; Fig. 3C.
                 */
                variant part memsMirror;
                variant part electroOpticDeflector;
                variant part acoustoOpticDeflector;
            }
            port beamIn : ~opticalPort {
                out item item1;
            }
            port beamOut : opticalPort {
                in item item1;
            }
            perform laserOperation.steerBeam;
            flow from beamIn.item1 to steerBeam.beam;
            flow from steerBeam.steeredBeam to beamOut.item1;
        }
        part projectionOptics {
            port beamIn : ~opticalPort {
                out item item1;
            }
            port beamOut : opticalPort {
                in item item1;
            }
            perform laserOperation.projectBeam;                    // [Fig.3C]
            flow from beamIn.item1 to projectBeam.incomingBeam;
            flow from projectBeam.focusedBeam to beamOut.item1;
        }
        part dopplerCoolingLaser {
            port beamOut : opticalPort {
                in item item1;
            }
            perform laserOperation.generateCoolingBeam;            // [p.1165 LC]
            flow from generateCoolingBeam.beam to beamOut.item1;
        }
        part photoionisationLaser {
            port beamOut : opticalPort {
                in item item1;
            }
            perform laserOperation.generatePhotoionisationBeam;    // [p.1164 RC]
            flow from generatePhotoionisationBeam.beam to beamOut.item1;
        }
        part rfDriveSource {
            port rfOut : microwavePort {
                in item item1;
            }
            perform laserOperation.generateRfTrapDrive;            // [p.1164 RC]
            flow from generateRfTrapDrive.rfDrive to rfOut.item1;
        }
        port addressingBeamOut : opticalPort;
        port coolingBeamOut : opticalPort;
        port photoionisationBeamOut : opticalPort;
        port rfTrapDriveOut : microwavePort;
        flow from addressingLaser.beamOut to beamSteeringOptics.beamIn;
        flow from beamSteeringOptics.beamOut to projectionOptics.beamIn;
        flow from projectionOptics.beamOut to addressingBeamOut;
        flow from dopplerCoolingLaser.beamOut to coolingBeamOut;
        flow from photoionisationLaser.beamOut to photoionisationBeamOut;
        flow from rfDriveSource.rfOut to rfTrapDriveOut;
    }

    part vacuumChamberEnv {

        doc
        /*
         * Vacuum chamber housing the electrodes that trap the ion crystal.
         * Elastic collisions with background gas occur roughly once per hour
         * per ion at typical ultrahigh vacuum pressures, and cryogenic
         * chambers can virtually eliminate these events by further reducing
         * the background pressure.
         *
         * Source: p.1164, right column.
         */

        attribute pressure : PressureUnit;

        port addressingBeamIn : ~opticalPort;
        port coolingBeamIn : ~opticalPort;
        port photoionisationBeamIn : ~opticalPort;
        port rfTrapDriveIn : ~microwavePort;
        port readoutExcitationIn : ~opticalPort;
        port fluorescenceOut : opticalPort;
        port communicationPhotonOut : opticalPort;

        part viewport {
            port beamIn : ~opticalPort;
            port beamOut : opticalPort;
        }
        part vacuumPump;

        part elementaryLogicUnit {
            doc
            /*
             * A single ion chain, or several chains connected through the
             * charge-coupled device architecture, serving as a processor node
             * of a distributed quantum multicomputer. Two-qubit gates between
             * ions belonging to different units are realized through the
             * photonic gate.
             *
             * Source: p.1168, left column; Fig. 4A.
             */
            part qpu : QPU {
                doc
                /*
                 * The trapped ion crystal, holding both memory qubits and the
                 * designated communication qubits. Modelled as a black box so
                 * that only the classical interface is in scope.
                 *
                 * Source: p.1166 right column; p.1168 left column.
                 */
                attribute redefines technology = qubitTechnology::trappedIon;
                port addressingBeamIn : ~opticalPort {
                    out item item1;
                }
                port coolingBeamIn : ~opticalPort {
                    out item item1;
                }
                port photoionisationBeamIn : ~opticalPort {
                    out item item1;
                }
                port rfTrapIn : ~microwavePort {
                    out item item1;
                }
                port readoutExcitationIn : ~opticalPort;
                port fluorescenceOut : opticalPort {
                    in item item1;
                }
                port communicationPhotonOut : opticalPort {
                    in item item1;
                }
                perform laserOperation.trapAndCoolIons;
                perform laserOperation.performGateOperation;
                perform laserOperation.exciteCommunicationQubit;
                flow from rfTrapIn.item1 to trapAndCoolIons.rfDrive;
                flow from coolingBeamIn.item1 to trapAndCoolIons.coolingBeam;
                flow from photoionisationBeamIn.item1 to trapAndCoolIons.ionisationBeam;
                flow from addressingBeamIn.item1 to performGateOperation.focusedBeam;
                flow from addressingBeamIn.item1 to exciteCommunicationQubit.excitationPulse;
                flow from performGateOperation.memoryState to fluorescenceOut.item1;
                flow from exciteCommunicationQubit.communicationPhoton to communicationPhotonOut.item1;
            }
            part opticalInterfaceCavity {
                doc
                /*
                 * Optical interface collecting the emitted photon into a
                 * single mode. Optical cavities are among the components used
                 * to improve the collection of emitted photons into a
                 * single-mode fibre.
                 *
                 * Source: p.1168, right column; Fig. 4B.
                 */
                port photonIn : ~opticalPort {
                    out item item1;
                }
                port photonOut : opticalPort {
                    in item item1;
                }
                perform laserOperation.collectPhoton;
                flow from photonIn.item1 to collectPhoton.emittedLight;
                flow from collectPhoton.collectedLight to photonOut.item1;
            }
            port addressingBeamIn : ~opticalPort;
            port coolingBeamIn : ~opticalPort;
            port photoionisationBeamIn : ~opticalPort;
            port rfTrapIn : ~microwavePort;
            port readoutExcitationIn : ~opticalPort;
            port fluorescenceOut : opticalPort;
            port communicationPhotonOut : opticalPort;
            flow from addressingBeamIn to qpu.addressingBeamIn;
            flow from coolingBeamIn to qpu.coolingBeamIn;
            flow from photoionisationBeamIn to qpu.photoionisationBeamIn;
            flow from rfTrapIn to qpu.rfTrapIn;
            flow from readoutExcitationIn to qpu.readoutExcitationIn;
            flow from qpu.fluorescenceOut to fluorescenceOut;
            flow from qpu.communicationPhotonOut to opticalInterfaceCavity.photonIn;
            flow from opticalInterfaceCavity.photonOut to communicationPhotonOut;
        }
        flow from addressingBeamIn to viewport.beamIn;
        flow from viewport.beamOut to elementaryLogicUnit.addressingBeamIn;
        flow from coolingBeamIn to elementaryLogicUnit.coolingBeamIn;
        flow from photoionisationBeamIn to elementaryLogicUnit.photoionisationBeamIn;
        flow from rfTrapDriveIn to elementaryLogicUnit.rfTrapIn;
        flow from readoutExcitationIn to elementaryLogicUnit.readoutExcitationIn;
        flow from elementaryLogicUnit.fluorescenceOut to fluorescenceOut;
        flow from elementaryLogicUnit.communicationPhotonOut to communicationPhotonOut;
    }

    part photonicInterconnect : interconnectSystem {

        doc
        /*
         * Reconfigurable photonic network linking elementary logic units.
         * Photons from designated communication qubits are converted to
         * telecommunication wavelengths, routed through an optical
         * crossconnect switch, interfered on a beamsplitter, and detected in
         * coincidence to herald entanglement between the registers.
         *
         * Source: p.1166 right column; p.1168 left and right columns;
         * Figs. 4A and 4C.
         */

        part opticalFiber {
            port photonIn : ~opticalPort;
            port photonOut : opticalPort;
        }
        part pumpLaser {
            port beamOut : opticalPort {
                in item item1;
            }
            perform laserOperation.generatePumpBeam;               // [Fig.4C]
            flow from generatePumpBeam.beam to beamOut.item1;
        }
        part nonlinearWavelengthConverter {
            doc
            /*
             * Quantum frequency converter translating the emitted photon to
             * the telecommunication band for long-distance transmission.
             *
             * Source: p.1168, right column; Fig. 4C.
             */
            port photonIn : ~opticalPort {
                out item item1;
            }
            port pumpIn : ~opticalPort {
                out item item1;
            }
            port telecomPhotonOut : opticalPort {
                in item item1;
            }
            perform laserOperation.convertWavelength;
            flow from photonIn.item1 to convertWavelength.inputPhoton;
            flow from pumpIn.item1 to convertWavelength.pumpBeam;
            flow from convertWavelength.outputPhoton to telecomPhotonOut.item1;
        }
        part opticalCrossconnectSwitch {
            doc
            /*
             * Switch supporting the reconfigurable photonic network, allowing
             * entanglement between any pair of registers.
             *
             * Source: p.1168, left column; Fig. 4A.
             */
            port photonIn : ~opticalPort {
                out item item1;
            }
            port photonOut : opticalPort {
                in item item1;
            }
            perform laserOperation.routePhoton;
            flow from photonIn.item1 to routePhoton.input;
            flow from routePhoton.output to photonOut.item1;
        }
        part beamSplitter {
            doc
            /*
             * 50:50 beamsplitter on which the photons from two communication
             * qubits are mode-matched.
             *
             * Source: p.1166, right column; Fig. 2F.
             */
            port photonIn : ~opticalPort {
                out item item1;
            }
            port photonOutA : opticalPort {
                in item item1;
            }
            port photonOutB : opticalPort {
                in item item1;
            }
            perform laserOperation.interferePhotons;
            flow from photonIn.item1 to interferePhotons.input;
            flow from interferePhotons.outputA to photonOutA.item1;
            flow from interferePhotons.outputB to photonOutB.item1;
        }
        part coincidenceDetector {
            doc
            /*
             * Output detectors whose joint coincidence detection heralds the
             * entanglement of the two memories.
             *
             * Source: p.1166, right column; Fig. 2F.
             */
            port photonInA : ~opticalPort {
                out item item1;
            }
            port photonInB : ~opticalPort {
                out item item1;
            }
            port heraldOut : digitalPort {
                in item item1;
            }
            perform laserOperation.heraldEntanglement;
            flow from photonInA.item1 to heraldEntanglement.photonA;
            flow from photonInB.item1 to heraldEntanglement.photonB;
            flow from heraldEntanglement.herald to heraldOut.item1;
        }
        port communicationPhotonIn : ~opticalPort;
        port heraldOut : digitalPort;
        flow from communicationPhotonIn to opticalFiber.photonIn;
        flow from opticalFiber.photonOut to nonlinearWavelengthConverter.photonIn;
        flow from pumpLaser.beamOut to nonlinearWavelengthConverter.pumpIn;
        flow from nonlinearWavelengthConverter.telecomPhotonOut to opticalCrossconnectSwitch.photonIn;
        flow from opticalCrossconnectSwitch.photonOut to beamSplitter.photonIn;
        flow from beamSplitter.photonOutA to coincidenceDetector.photonInA;
        flow from beamSplitter.photonOutB to coincidenceDetector.photonInB;
        flow from coincidenceDetector.heraldOut to heraldOut;
    }

    part laserReadoutSystem : classicalReadoutSystem {

        doc
        /*
         * State detection instrumentation: the resonant excitation laser and
         * the imaging path onto a photon-counting detector.
         *
         * Source: p.1165, left column; Fig. 1C.
         */

        part readoutExcitationLaser {
            port beamOut : opticalPort {
                in item item1;
            }
            perform laserOperation.generateReadoutExcitation;      // [p.1165 LC]
            flow from generateReadoutExcitation.beam to beamOut.item1;
        }
        part imagingOptics {
            port photonIn : ~opticalPort {
                out item item1;
            }
            port photonOut : opticalPort {
                in item item1;
            }
            perform laserOperation.imageFluorescence;              // [p.1165 LC]
            flow from photonIn.item1 to imageFluorescence.emittedLight;
            flow from imageFluorescence.collectedLight to photonOut.item1;
        }
        part photonCountingImager {
            port photonIn : ~opticalPort {
                out item item1;
            }
            perform laserOperation.detectQubitState;               // [p.1165 LC]
            flow from photonIn.item1 to detectQubitState.measurement;
        }
        port readoutExcitationOut : opticalPort;
        port fluorescenceIn : ~opticalPort;
        flow from readoutExcitationLaser.beamOut to readoutExcitationOut;
        flow from fluorescenceIn to imagingOptics.photonIn;
        flow from imagingOptics.photonOut to photonCountingImager.photonIn;
    }

    flow from laserControlSystem.addressingBeamOut to vacuumChamberEnv.addressingBeamIn;
    flow from laserControlSystem.coolingBeamOut to vacuumChamberEnv.coolingBeamIn;
    flow from laserControlSystem.photoionisationBeamOut to vacuumChamberEnv.photoionisationBeamIn;
    flow from laserControlSystem.rfTrapDriveOut to vacuumChamberEnv.rfTrapDriveIn;
    flow from laserReadoutSystem.readoutExcitationOut to vacuumChamberEnv.readoutExcitationIn;
    flow from vacuumChamberEnv.fluorescenceOut to laserReadoutSystem.fluorescenceIn;
    flow from vacuumChamberEnv.communicationPhotonOut to photonicInterconnect.communicationPhotonIn;
}
