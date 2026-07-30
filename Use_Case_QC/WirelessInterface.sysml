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
//   [Fig.8]   = Fig. 8 schematic / legend, p.11
//   [Tab.I]   = Table I, p.11

package WirelessInterface {

    doc
    /*
     * Wireless control and readout interface for a superconducting qubit in
     * a dilution refrigerator.
     *
     * Conventional wired connections for addressing and control of qubits
     * are replaced directly with wireless links. Fig. 8 shows a setup with a
     * separate control path, the downlink, and readout path, the uplink,
     * inside the system; a reflection mode with both sharing one path is
     * also possible. The links include transceivers and multiplexing units
     * at both room temperature outside the refrigerator and the mK stage
     * inside it, together with beam control components including filters and
     * collimators or lenses linking the two transceivers.
     *
     * The reference gives five advantages over wired solutions: the bulky
     * room-temperature electronics stay outside, so cryostats can be
     * smaller; thousands of channels can co-exist, so qubit upscaling is no
     * longer limited by refrigerator size; vacuum needs no transmission
     * medium and propagates signals 33% faster than coaxial cable, cutting
     * latency; there is no transmission loss in vacuum and the mK
     * transceivers are passive, so no extra heat is brought to the chamber;
     * and millimetre wave operation leaves room for higher frequencies and
     * relaxed cooling requirements.
     *
     * Source: Brennan et al. 2025, section "Wireless control and readout",
     * p.9 right column paragraph 2 through p.11 left column, and the Fig. 8
     * schematic on p.11.
     */

    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import SuperconductingCommon::*;
    public import ISQ::*;
    public import SI::*;

    // =====================================================================
    // Action definitions
    // =====================================================================

    action def GenerateTone {
        doc
        /*
         * Generate the microwave or terahertz tone that addresses the qubit.
         * All bulky and energy-hungry but mature control and digital
         * electronics remain at room temperature, which is what allows the
         * cryostat to be made smaller.
         *
         * Wireless links can accommodate thousands or more channels, with
         * microwave tones spaced a few MHz apart subject to the qubit
         * technology, so qubit upscaling is no longer limited by the size of
         * the refrigerator.
         *
         * Source: p.9 right column paragraph 2; p.9 right column advantages
         * 1 and 2; GHz/THz source in Fig. 8.
         */
        out item tone : microwaveSignal;
        attribute channelSpacing;                   // a few MHz [p.9 RC adv 2]
        attribute carrierFrequency : FrequencyValue;
    }

    action def RadiateBeam {
        doc
        /*
         * Convert a guided signal into a free-space beam. New cryogenic
         * compatible microwave free space components are required for this,
         * for example antennas and lenses.
         *
         * The transceivers on the mK stage do not contain additional active
         * devices but passives, such as antennas and matching circuits.
         * Since those passives can be realised by superconductors with
         * negligible ohmic loss at that stage, no extra power is required
         * apart from what the qubits themselves need.
         *
         * Source: p.10 right column paragraph 2; p.10 left column
         * advantage 4; antenna in the Fig. 8 legend.
         */
        in item feed : microwaveSignal;
        out item beam : microwaveSignal;
    }

    action def ReceiveBeam {
        doc
        /*
         * Convert a free-space beam back into a guided signal.
         *
         * Source: antenna in the Fig. 8 legend, p.11.
         */
        in item beam : microwaveSignal;
        out item feed : microwaveSignal;
    }

    action def FocusBeam {
        doc
        /*
         * Collimate or focus the free-space beam so that it stays aligned
         * across the gap between temperature stages. Fig. 8 places a lens
         * pair at each of the 50 K, 4 K, 800 mK and 100 mK stages, one for
         * the downlink and one for the uplink.
         *
         * Wireless links do not need a transmission medium; the vacuum
         * inside the refrigerator makes signals propagate 33% faster than
         * they do in coaxial cables, so latency between the room-temperature
         * electronics and the qubits is reduced by at least 33%, which is
         * crucial for high fidelity in multi-qubit technologies.
         *
         * Source: p.10 left column advantage 3; lens in the Fig. 8 legend.
         */
        in item incomingBeam : microwaveSignal;
        out item focusedBeam : microwaveSignal;
    }

    action def GuideToQubit {
        doc
        /*
         * Carry the signal between the cryogenic antenna and the qubit over
         * a short guided section at the base stage.
         *
         * Source: waveguide in the Fig. 8 legend, p.11.
         */
        in item feed : microwaveSignal;
        out item guided : microwaveSignal;
    }

    action def ManipulateQubitState {
        doc
        /*
         * Drive the qubit with the received signal. In future developments
         * the qubits' receiving antennae and multiplexing circuits could be
         * replaced with direct sensing using gate resonators.
         *
         * Source: p.10 left column advantage 4; QPU in the Fig. 8 legend.
         */
        in item driveSignal : microwaveSignal;
        out item qubitResponse : microwaveSignal;
    }

    action def AnalyseSignal {
        doc
        /*
         * Recover the qubit state from the returning uplink signal at room
         * temperature.
         *
         * Source: signal analyser in Fig. 8, p.11.
         */
        in item receivedSignal : microwaveSignal;
        out attribute qubitState;
    }

    // =====================================================================
    // End-to-end behaviour
    // =====================================================================
    action def WirelessControlAndReadout {

        doc
        /*
         * Sequence of the wireless control and readout cycle as drawn in
         * Fig. 8 on p.11.
         *
         * The downlink runs from the room-temperature source, out of the
         * room-temperature antenna, through the lens at each temperature
         * stage, into the cryogenic antenna and along a short waveguide to
         * the qubit. The uplink is the mirror image, ending at the signal
         * analyser.
         *
         * Unlike the wired architectures there are no attenuator, filter or
         * amplifier stages in the chain: the beam crosses the stages through
         * vacuum, and the mK transceivers are passive.
         *
         * This definition states ordering and the action-to-action item
         * chain. The physical routing of those items through ports is
         * modelled in the parts.
         *
         * Source: p.9 right column paragraph 2 through p.11 left column, and
         * Fig. 8.
         */

        out attribute measuredQubitState;

        // ---- downlink (control) ----
        action generateTone : GenerateTone;                        // [Fig.8]
        action radiateDownlink : RadiateBeam;                      // [Fig.8]
        action focusDownlink50K : FocusBeam;                       // [Fig.8]
        action focusDownlink4K : FocusBeam;                        // [Fig.8]
        action focusDownlink800mK : FocusBeam;                     // [Fig.8]
        action focusDownlink100mK : FocusBeam;                     // [Fig.8]
        action receiveDownlink : ReceiveBeam;                      // [Fig.8]
        action guideDownlinkToQubit : GuideToQubit;                // [Fig.8]
        action manipulateQubitState : ManipulateQubitState;        // [Fig.8]

        // ---- uplink (readout) ----
        action guideUplinkFromQubit : GuideToQubit;                // [Fig.8]
        action radiateUplink : RadiateBeam;                        // [Fig.8]
        action focusUplink100mK : FocusBeam;                       // [Fig.8]
        action focusUplink800mK : FocusBeam;                       // [Fig.8]
        action focusUplink4K : FocusBeam;                          // [Fig.8]
        action focusUplink50K : FocusBeam;                         // [Fig.8]
        action receiveUplink : ReceiveBeam;                        // [Fig.8]
        action analyseSignal : AnalyseSignal;                      // [Fig.8]

        // ---- ordering ----
        first start then generateTone;
        first generateTone then radiateDownlink;
        first radiateDownlink then focusDownlink50K;
        first focusDownlink50K then focusDownlink4K;
        first focusDownlink4K then focusDownlink800mK;
        first focusDownlink800mK then focusDownlink100mK;
        first focusDownlink100mK then receiveDownlink;
        first receiveDownlink then guideDownlinkToQubit;
        first guideDownlinkToQubit then manipulateQubitState;

        first manipulateQubitState then guideUplinkFromQubit;
        first guideUplinkFromQubit then radiateUplink;
        first radiateUplink then focusUplink100mK;
        first focusUplink100mK then focusUplink800mK;
        first focusUplink800mK then focusUplink4K;
        first focusUplink4K then focusUplink50K;
        first focusUplink50K then receiveUplink;
        first receiveUplink then analyseSignal;
        first analyseSignal then done;

        // ---- item chain ----
        flow from generateTone.tone to radiateDownlink.feed;
        flow from radiateDownlink.beam to focusDownlink50K.incomingBeam;
        flow from focusDownlink50K.focusedBeam to focusDownlink4K.incomingBeam;
        flow from focusDownlink4K.focusedBeam to focusDownlink800mK.incomingBeam;
        flow from focusDownlink800mK.focusedBeam to focusDownlink100mK.incomingBeam;
        flow from focusDownlink100mK.focusedBeam to receiveDownlink.beam;
        flow from receiveDownlink.feed to guideDownlinkToQubit.feed;
        flow from guideDownlinkToQubit.guided to manipulateQubitState.driveSignal;

        flow from manipulateQubitState.qubitResponse to guideUplinkFromQubit.feed;
        flow from guideUplinkFromQubit.guided to radiateUplink.feed;
        flow from radiateUplink.beam to focusUplink100mK.incomingBeam;
        flow from focusUplink100mK.focusedBeam to focusUplink800mK.incomingBeam;
        flow from focusUplink800mK.focusedBeam to focusUplink4K.incomingBeam;
        flow from focusUplink4K.focusedBeam to focusUplink50K.incomingBeam;
        flow from focusUplink50K.focusedBeam to receiveUplink.beam;
        flow from receiveUplink.feed to analyseSignal.receivedSignal;

        bind measuredQubitState = analyseSignal.qubitState;
    }

    action wirelessOperation : WirelessControlAndReadout;

    // =====================================================================
    // Structure
    // =====================================================================
    part wirelessControlSystem : classicalControlSystem {

        doc
        /*
         * Room-temperature control side: the tone source and the downlink
         * transmit antenna. All bulky and energy-hungry control and digital
         * electronics remain here, outside the refrigerator.
         *
         * Source: p.9 right column advantage 1; Fig. 8, p.11.
         */

        part ghzThzSource {
            doc
            /*
             * GHz or THz source generating the addressing tone.
             *
             * Source: GHz/THz source in Fig. 8, p.11.
             */
            port toneOut : microwavePort {
                in item item1;
            }
            perform wirelessOperation.generateTone;
            flow from generateTone.tone to toneOut.item1;
        }
        part roomTempTransmitAntenna {
            doc
            /*
             * Room-temperature downlink antenna.
             *
             * Source: antenna in the Fig. 8 legend, p.11.
             */
            port feedIn : ~microwavePort {
                out item item1;
            }
            port beamOut : microwavePort {
                in item item1;
            }
            perform wirelessOperation.radiateDownlink;
            flow from feedIn.item1 to radiateDownlink.feed;
            flow from radiateDownlink.beam to beamOut.item1;
        }
        port downlinkBeamOut : microwavePort;
        flow from ghzThzSource.toneOut to roomTempTransmitAntenna.feedIn;
        flow from roomTempTransmitAntenna.beamOut to downlinkBeamOut;
    }

    part dilutionRefrigeratorEnv : dilutionRefrigerator {

        doc
        /*
         * Dilution refrigerator. The beam crosses the temperature stages
         * through vacuum, so no attenuators, filters or amplifiers are
         * anchored to the plates; only the lens pairs that keep the downlink
         * and uplink beams collimated. The base stage holds the cryogenic
         * transceiver antennas, their waveguides and the qubit.
         *
         * Remaining challenges include unknown signal propagation and
         * scattering within the chambers, channel interference and
         * crosstalk, stray field associated noise on qubit performance, and
         * thermal control at the interfaces between ambient and the
         * refrigerator and between chambers inside it.
         *
         * Source: p.10 right column paragraph 2; Fig. 8, p.11.
         */

        port downlinkBeamIn : ~microwavePort;
        port uplinkBeamOut : microwavePort;

        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part downlinkLens {
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.focusDownlink50K;        // [Fig.8]
                flow from beamIn.item1 to focusDownlink50K.incomingBeam;
                flow from focusDownlink50K.focusedBeam to beamOut.item1;
            }
            part uplinkLens {
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.focusUplink50K;          // [Fig.8]
                flow from beamIn.item1 to focusUplink50K.incomingBeam;
                flow from focusUplink50K.focusedBeam to beamOut.item1;
            }
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part downlinkLens {
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.focusDownlink4K;         // [Fig.8]
                flow from beamIn.item1 to focusDownlink4K.incomingBeam;
                flow from focusDownlink4K.focusedBeam to beamOut.item1;
            }
            part uplinkLens {
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.focusUplink4K;           // [Fig.8]
                flow from beamIn.item1 to focusUplink4K.incomingBeam;
                flow from focusUplink4K.focusedBeam to beamOut.item1;
            }
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part downlinkLens {
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.focusDownlink800mK;      // [Fig.8]
                flow from beamIn.item1 to focusDownlink800mK.incomingBeam;
                flow from focusDownlink800mK.focusedBeam to beamOut.item1;
            }
            part uplinkLens {
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.focusUplink800mK;        // [Fig.8]
                flow from beamIn.item1 to focusUplink800mK.incomingBeam;
                flow from focusUplink800mK.focusedBeam to beamOut.item1;
            }
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
            part downlinkLens {
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.focusDownlink100mK;      // [Fig.8]
                flow from beamIn.item1 to focusDownlink100mK.incomingBeam;
                flow from focusDownlink100mK.focusedBeam to beamOut.item1;
            }
            part uplinkLens {
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.focusUplink100mK;        // [Fig.8]
                flow from beamIn.item1 to focusUplink100mK.incomingBeam;
                flow from focusUplink100mK.focusedBeam to beamOut.item1;
            }
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];

            part cryogenicReceiveAntenna {
                doc
                /*
                 * Cryogenic downlink antenna. Part of the passive mK
                 * transceiver, which contains no active devices.
                 *
                 * Source: p.10 left column advantage 4; antenna in the
                 * Fig. 8 legend.
                 */
                port beamIn : ~microwavePort {
                    out item item1;
                }
                port feedOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.receiveDownlink;
                flow from beamIn.item1 to receiveDownlink.beam;
                flow from receiveDownlink.feed to feedOut.item1;
            }
            part downlinkWaveguide {
                doc
                /*
                 * Short guided section carrying the received signal from the
                 * cryogenic antenna to the qubit.
                 *
                 * Source: waveguide in the Fig. 8 legend, p.11.
                 */
                port feedIn : ~microwavePort {
                    out item item1;
                }
                port guidedOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.guideDownlinkToQubit;
                flow from feedIn.item1 to guideDownlinkToQubit.feed;
                flow from guideDownlinkToQubit.guided to guidedOut.item1;
            }
            part qpu : QPU {
                doc
                /*
                 * Quantum processing unit. Modelled as a black box so that
                 * only the classical interface is in scope.
                 *
                 * Source: QPU in the Fig. 8 legend, p.11.
                 */
                attribute redefines technology = qubitTechnology::superconducting;
                port driveIn : ~microwavePort {
                    out item item1;
                }
                port readoutOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.manipulateQubitState;
                flow from driveIn.item1 to manipulateQubitState.driveSignal;
                flow from manipulateQubitState.qubitResponse to readoutOut.item1;
            }
            part uplinkWaveguide {
                doc
                /*
                 * Short guided section carrying the qubit response from the
                 * qubit to the cryogenic uplink antenna.
                 *
                 * Source: waveguide in the Fig. 8 legend, p.11.
                 */
                port feedIn : ~microwavePort {
                    out item item1;
                }
                port guidedOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.guideUplinkFromQubit;
                flow from feedIn.item1 to guideUplinkFromQubit.feed;
                flow from guideUplinkFromQubit.guided to guidedOut.item1;
            }
            part cryogenicTransmitAntenna {
                doc
                /*
                 * Cryogenic uplink antenna.
                 *
                 * Source: antenna in the Fig. 8 legend, p.11.
                 */
                port feedIn : ~microwavePort {
                    out item item1;
                }
                port beamOut : microwavePort {
                    in item item1;
                }
                perform wirelessOperation.radiateUplink;
                flow from feedIn.item1 to radiateUplink.feed;
                flow from radiateUplink.beam to beamOut.item1;
            }
            flow from cryogenicReceiveAntenna.feedOut to downlinkWaveguide.feedIn;
            flow from downlinkWaveguide.guidedOut to qpu.driveIn;
            flow from qpu.readoutOut to uplinkWaveguide.feedIn;
            flow from uplinkWaveguide.guidedOut to cryogenicTransmitAntenna.feedIn;
        }

        // downlink beam descends through the lens at each stage [Fig.8]
        flow from downlinkBeamIn to secondLayer.downlinkLens.beamIn;
        flow from secondLayer.downlinkLens.beamOut to thirdLayer.downlinkLens.beamIn;
        flow from thirdLayer.downlinkLens.beamOut to fourthLayer.downlinkLens.beamIn;
        flow from fourthLayer.downlinkLens.beamOut to fifthLayer.downlinkLens.beamIn;
        flow from fifthLayer.downlinkLens.beamOut to sixthLayer.cryogenicReceiveAntenna.beamIn;
        // uplink beam ascends through the mirrored lens chain [Fig.8]
        flow from sixthLayer.cryogenicTransmitAntenna.beamOut to fifthLayer.uplinkLens.beamIn;
        flow from fifthLayer.uplinkLens.beamOut to fourthLayer.uplinkLens.beamIn;
        flow from fourthLayer.uplinkLens.beamOut to thirdLayer.uplinkLens.beamIn;
        flow from thirdLayer.uplinkLens.beamOut to secondLayer.uplinkLens.beamIn;
        flow from secondLayer.uplinkLens.beamOut to uplinkBeamOut;
    }

    part wirelessReadoutSystem : classicalReadoutSystem {

        doc
        /*
         * Room-temperature readout side: the uplink receive antenna and the
         * signal analyser.
         *
         * Source: Fig. 8, p.11.
         */

        part roomTempReceiveAntenna {
            port beamIn : ~microwavePort {
                out item item1;
            }
            port feedOut : microwavePort {
                in item item1;
            }
            perform wirelessOperation.receiveUplink;               // [Fig.8]
            flow from beamIn.item1 to receiveUplink.beam;
            flow from receiveUplink.feed to feedOut.item1;
        }
        part signalAnalyser {
            port signalIn : ~microwavePort {
                out item item1;
            }
            perform wirelessOperation.analyseSignal;               // [Fig.8]
            flow from signalIn.item1 to analyseSignal.receivedSignal;
        }
        port uplinkBeamIn : ~microwavePort;
        flow from uplinkBeamIn to roomTempReceiveAntenna.beamIn;
        flow from roomTempReceiveAntenna.feedOut to signalAnalyser.signalIn;
    }

    flow from wirelessControlSystem.downlinkBeamOut to dilutionRefrigeratorEnv.downlinkBeamIn;
    flow from dilutionRefrigeratorEnv.uplinkBeamOut to wirelessReadoutSystem.uplinkBeamIn;
}
