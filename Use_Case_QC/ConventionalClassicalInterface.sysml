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
//   [Fig.2]   = Fig. 2 schematic / legend, p.4

package ConventionalClassicalInterface {
    doc 
    /* Conventional microwave control and readout interface for a
     * superconducting transmon qubit housed in a dilution refrigerator.
     *
     * The architecture is built around two distinct microwave tones with
     * similar properties. One tone controls the qubit state, the other probes
     * it in a dispersive readout architecture. Both pass through thermally
     * anchored attenuator stages inside the refrigerator so that thermal
     * noise is suppressed before the signal reaches the qubit sample.
     *
     * Source: Brennan et al. 2025, section "CONVENTIONAL QUBIT CONTROL",
     * p.4 left column paragraph 1 through p.5 left column paragraph 2, and
     * the Fig. 2 schematic on p.4.
     *
     * Units: prefixed unit symbols such as kW and microwatt are not
     * recognised, so quantities are expressed in SI base units with a scaled
     * literal. The value as printed in the reference is restated in the
     * documentation of the owning element.
     */
    private import ISQ::*;
    private import SI::*;
    action def ConventionalControlAndReadout {
        doc 
        /* Sequence of the conventional control and readout cycle as drawn in
         * Fig. 2 on p.4.
         *
         * A typical experimental setup involves two distinct microwave tones
         * with similar properties. The drive chain shapes a baseband envelope,
         * mixes it onto a carrier near the qubit transition frequency, and
         * delivers it to the qubit through the attenuator stages. The readout
         * chain then probes the qubit dispersively through the on-chip
         * resonator and carries the response back out through the isolation
         * and amplification stages to be digitised and deciphered. A static
         * bias line is established and held throughout.
         *
         * Envelope generation and carrier generation are concurrent on both
         * chains, which is why each mixer is preceded by a join.
         *
         * Ordering is stated with first/then and the control nodes; the
         * payload carried between successive actions is stated separately
         * with flow, following the pattern of the language specification.
         *
         * Source: p.4 left column paragraph 1 through p.5 left column
         * paragraph 2, and Fig. 2.
         */
        out item measuredQubitState : QuantumComputing::physicalLayerDefinitions::digitalData;
        action generateEnvelope : CommonInstruments::GenerateEnvelope;
        action applyPulseProtocol : SuperconductingCommon::ApplyPulseProtocol;
        action convertDriveToAnalog : CommonInstruments::ConvertDigitalToAnalog;
        action generateDriveCarrier : CommonInstruments::GenerateCarrier;
        action upconvertDrive : CommonInstruments::Upconvert;
        action filterDrive : CommonInstruments::FilterSignal;
        action attenuateDrive50K : CommonInstruments::AttenuateSignal;
        action attenuateDrive4K : CommonInstruments::AttenuateSignal;
        action attenuateDrive800mK : CommonInstruments::AttenuateSignal;
        action manipulateQubitState : SuperconductingCommon::ManipulateQubitState;
        action provideQubitBias : CommonInstruments::SupplyBias;
        action filterBias : CommonInstruments::FilterSignal;
        action synchroniseClock : SuperconductingCommon::SynchroniseClock;
        action generateProbeEnvelope : CommonInstruments::GenerateEnvelope;
        action generateProbeCarrier : CommonInstruments::GenerateCarrier;
        action upconvertProbe : CommonInstruments::Upconvert;
        action disperseInteract : SuperconductingCommon::DispersiveInteraction;
        action suppressBackactionCirculator : SuperconductingCommon::SuppressBackaction;
        action suppressBackactionIsolator : SuperconductingCommon::SuppressBackaction;
        action amplifyQuantumLimited : SuperconductingCommon::AmplifyQuantumLimited;
        action amplifyCryogenic : CommonInstruments::Amplify;
        action amplifyRoomTemperature : CommonInstruments::Amplify;
        action downconvertProbe : CommonInstruments::Downconvert;
        action filterProbe : CommonInstruments::FilterSignal;
        action digitiseProbe : CommonInstruments::ConvertAnalogToDigital;
        action decipherQubitState : CommonInstruments::AnalyseMeasurement;
        fork initiate;
        join joinDrive;
        join joinProbe;
        first start then synchroniseClock;
        first synchroniseClock then initiate;
        first initiate then provideQubitBias;
        first provideQubitBias then filterBias;
        first initiate then generateEnvelope;
        first generateEnvelope then applyPulseProtocol;
        first applyPulseProtocol then convertDriveToAnalog;
        first initiate then generateDriveCarrier;
        first convertDriveToAnalog then joinDrive;
        first generateDriveCarrier then joinDrive;
        first joinDrive then upconvertDrive;
        first upconvertDrive then filterDrive;
        first filterDrive then attenuateDrive50K;
        first attenuateDrive50K then attenuateDrive4K;
        first attenuateDrive4K then attenuateDrive800mK;
        first attenuateDrive800mK then manipulateQubitState;
        first manipulateQubitState then generateProbeEnvelope;
        first initiate then generateProbeCarrier;
        first generateProbeEnvelope then joinProbe;
        first generateProbeCarrier then joinProbe;
        first joinProbe then upconvertProbe;
        first upconvertProbe then disperseInteract;
        first disperseInteract then suppressBackactionCirculator;
        first suppressBackactionCirculator then amplifyQuantumLimited;
        first amplifyQuantumLimited then suppressBackactionIsolator;
        first suppressBackactionIsolator then amplifyCryogenic;
        first amplifyCryogenic then amplifyRoomTemperature;
        first amplifyRoomTemperature then downconvertProbe;
        first downconvertProbe then filterProbe;
        first filterProbe then digitiseProbe;
        first digitiseProbe then decipherQubitState;
        first decipherQubitState then done;
        flow from generateEnvelope.envelope to applyPulseProtocol.envelope;
        flow from applyPulseProtocol.shapedEnvelope to convertDriveToAnalog.digitalInput;
        flow from convertDriveToAnalog.analogOutput to upconvertDrive.baseband;
        flow from generateDriveCarrier.carrier to upconvertDrive.carrier;
        flow from upconvertDrive.waveform to filterDrive.unfiltered;
        flow from filterDrive.filtered to attenuateDrive50K.unattenuated;
        flow from attenuateDrive50K.attenuated to attenuateDrive4K.unattenuated;
        flow from attenuateDrive4K.attenuated to attenuateDrive800mK.unattenuated;
        flow from attenuateDrive800mK.attenuated to manipulateQubitState.controlWaveform;
        flow from provideQubitBias.bias to filterBias.unfiltered;
        flow from filterBias.filtered to manipulateQubitState.biasSupply;
        flow from generateProbeEnvelope.envelope to upconvertProbe.baseband;
        flow from generateProbeCarrier.carrier to upconvertProbe.carrier;
        flow from upconvertProbe.waveform to disperseInteract.probeTone;
        // the resonator is capacitively coupled to the qubit [Fig.2]
        flow from manipulateQubitState.qubitResponse to disperseInteract.qubitCoupling;
        flow from disperseInteract.stateDependentResponse to suppressBackactionCirculator.incoming;
        flow from suppressBackactionCirculator.forwarded to amplifyQuantumLimited.weakSignal;
        flow from amplifyQuantumLimited.amplifiedSignal to suppressBackactionIsolator.incoming;
        flow from suppressBackactionIsolator.forwarded to amplifyCryogenic.weakSignal;
        flow from amplifyCryogenic.amplifiedSignal to amplifyRoomTemperature.weakSignal;
        flow from amplifyRoomTemperature.amplifiedSignal to downconvertProbe.waveform;
        flow from generateProbeCarrier.carrier to downconvertProbe.referenceCarrier;
        flow from downconvertProbe.baseband to filterProbe.unfiltered;
        flow from filterProbe.filtered to digitiseProbe.analogInput;
        flow from digitiseProbe.digitalOutput to decipherQubitState.measurement;
        binding bind measuredQubitState = decipherQubitState.qubitState;
    }
    action conventionalOperation : ConventionalControlAndReadout;
    part conventionalControlSystem : QuantumComputing::physicalLayerDefinitions::classicalControlSystem {
        doc 
        /* Room-temperature control electronics generating the qubit drive
         * tone and the static qubit bias. Drawn at the top left of Fig. 2.
         *
         * Source: Fig. 2, p.4; p.4 right column paragraph 1.
         */
        part controlAWGFPGA : CommonInstruments::awgFPGA {
            doc 
            /* Arbitrary waveform generator supplying the low-frequency
             * signals that define the shape and duration of the control
             * pulse, and applying the advanced pulse protocols. In modern
             * hybrid implementations an entire rack of generic microwave
             * hardware is combined onto a single board with FPGA fabric.
             *
             * Source: p.4 right column paragraph 1; p.5 left column
             * paragraph 2.
             */
            port envelopeOut : QuantumComputing::physicalLayerDefinitions::digitalPort {
                in item item1;
            }
            perform conventionalOperation.generateEnvelope;
            perform conventionalOperation.applyPulseProtocol;
            perform conventionalOperation.synchroniseClock;
            succession flow from generateEnvelope.envelope to applyPulseProtocol.envelope;
            succession flow from applyPulseProtocol.shapedEnvelope to envelopeOut.item1;
        }
        part dac : CommonInstruments::digitalToAnalogConverter {
            port digitalIn : ~QuantumComputing::physicalLayerDefinitions::digitalPort {
                out item item1;
            }
            port analogOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.convertDriveToAnalog;
            flow from digitalIn.item1 to convertDriveToAnalog.digitalInput;
            succession flow from convertDriveToAnalog.analogOutput to analogOut.item1;
        }
        part controlLocalOscillator : CommonInstruments::localOscillator {
            port carrierOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.generateDriveCarrier;
            succession flow from generateDriveCarrier.carrier to carrierOut.item1;
        }
        part controlIqMixer : CommonInstruments::iqMixer {
            doc 
            /* Mixes the baseband envelope with the high-frequency carrier to
             * produce the control waveform, implementing the heterodyne
             * scheme.
             *
             * Source: p.4 right column paragraph 1; IQ mixer in the Fig. 2
             * legend.
             */
            port ifIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port loIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port rfOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.upconvertDrive;
            flow from ifIn.item1 to upconvertDrive.baseband;
            flow from loIn.item1 to upconvertDrive.carrier;
            succession flow from upconvertDrive.waveform to rfOut.item1;
        }
        part controlFilter {
            port filterIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port filterOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.filterDrive;
            flow from filterIn.item1 to filterDrive.unfiltered;
            succession flow from filterDrive.filtered to filterOut.item1;
        }
        part qubitBias : CommonInstruments::powerSource {
            port biasOut : QuantumComputing::physicalLayerDefinitions::dcBiasPort {
                in item item1;
            }
            perform conventionalOperation.provideQubitBias;
            succession flow from provideQubitBias.bias to biasOut.item1;
        }
        port driveOut : QuantumComputing::physicalLayerDefinitions::microwavePort;
        port qubitBiasOut : QuantumComputing::physicalLayerDefinitions::dcBiasPort;
        flow from controlAWGFPGA.envelopeOut to dac.digitalIn;
        flow from dac.analogOut to controlIqMixer.ifIn;
        flow from controlLocalOscillator.carrierOut to controlIqMixer.loIn;
        flow from controlIqMixer.rfOut to controlFilter.filterIn;
        flow from controlFilter.filterOut to driveOut.payload;
        flow from qubitBias.biasOut to qubitBiasOut.payload;
    }
    part dilutionRefrigeratorEnv : SuperconductingCommon::dilutionRefrigerator {
        doc 
        /* Dilution refrigerator housing the quantum processing unit. Fig. 2
         * marks six temperature stages, from 300 K down to 10 mK, with the
         * qubit sample and its readout components inside a mu-metal shield at
         * the base stage.
         *
         * Limited cooling power is the major constraint on integrating
         * technology within a cryogenic system, and these limits restrict not
         * only the size of the quantum processor but also the classical
         * interfaces that can be placed within a cryostat.
         *
         * Source: Fig. 2, p.4; p.4 left column paragraph 1.
         */
        port driveIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort;
        port biasIn : ~QuantumComputing::physicalLayerDefinitions::dcBiasPort;
        port probeIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort;
        port readoutOut : QuantumComputing::physicalLayerDefinitions::microwavePort;
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part driveAttenuator : CommonInstruments::attenuator {
                doc 
                /* Thermally anchored attenuator stage on the drive line at
                 * the 50 K plate.
                 *
                 * Source: p.4 left column paragraph 1; Fig. 2.
                 */
                port attIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port attOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.attenuateDrive50K;
                flow from attIn.item1 to attenuateDrive50K.unattenuated;
                succession flow from attenuateDrive50K.attenuated to attOut.item1;
            }
        }
        part thirdLayer {
            doc 
            /* 4 K stage. At 4 K, high powered cooling systems can provide up
             * to 1 kW of cooling power, expressed below in watts.
             *
             * Source: p.4 left column paragraph 1.
             */
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            attribute coolingPower = 1000.0 [W];
            part driveAttenuator : CommonInstruments::attenuator {
                doc 
                /* Thermally anchored attenuator stage on the drive line at
                 * the 4 K plate.
                 *
                 * Source: p.4 left column paragraph 1; Fig. 2.
                 */
                port attIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port attOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.attenuateDrive4K;
                flow from attIn.item1 to attenuateDrive4K.unattenuated;
                succession flow from attenuateDrive4K.attenuated to attOut.item1;
            }
            part biasFilter {
                doc 
                /* Filter on the qubit bias line inside the refrigerator.
                 *
                 * Source: Fig. 2, p.4.
                 */
                port filterIn : ~QuantumComputing::physicalLayerDefinitions::dcBiasPort {
                    out item item1;
                }
                port filterOut : QuantumComputing::physicalLayerDefinitions::dcBiasPort {
                    in item item1;
                }
                perform conventionalOperation.filterBias;
                flow from filterIn.item1 to filterBias.unfiltered;
                succession flow from filterBias.filtered to filterOut.item1;
            }
            part lowNoiseAmplifier {
                doc 
                /* Cryogenic amplification stage of the measurement chain,
                 * realised by high-electron mobility transistor amplifiers.
                 *
                 * Source: p.5 left column paragraph 1; low-noise amplifier in
                 * the Fig. 2 legend.
                 */
                port ampIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port ampOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.amplifyCryogenic;
                flow from ampIn.item1 to amplifyCryogenic.weakSignal;
                succession flow from amplifyCryogenic.amplifiedSignal to ampOut.item1;
            }
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part driveAttenuator : CommonInstruments::attenuator {
                doc 
                /* Thermally anchored attenuator stage on the drive line at
                 * the 800 mK plate.
                 *
                 * Source: p.4 left column paragraph 1; Fig. 2.
                 */
                port attIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port attOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.attenuateDrive800mK;
                flow from attIn.item1 to attenuateDrive800mK.unattenuated;
                flow from attenuateDrive800mK.attenuated to attOut.item1;
            }
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            doc 
            /* Base stage holding the qubit sample and its readout chain
             * inside a mu-metal shield. The reference states that at 20 mK
             * there is only up to 30 microwatt of cooling power; that figure
             * is recorded below in watts, and is quoted by the reference at
             * 20 mK rather than at the 10 mK stage drawn in Fig. 2.
             *
             * Source: p.4 left column paragraph 1; Fig. 2.
             */
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];
            attribute coolingPower = 3.0E-5 [W];
            part qpu : QuantumComputing::physicalLayerDefinitions::QPU {
                doc 
                /* Quantum processing unit holding the superconducting
                 * transmon qubit. Modelled as a black box at this level, so
                 * that only the classical interface is in scope.
                 *
                 * Source: QPU in the Fig. 2 legend; Fig. 2 caption, p.4.
                 */
                attribute :>> technology = QuantumComputing::physicalLayerDefinitions::qubitTechnology::superconducting;
                port driveIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port biasIn : ~QuantumComputing::physicalLayerDefinitions::dcBiasPort {
                    out item item1;
                }
                port cavityOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.manipulateQubitState;
                flow from biasIn.item1 to manipulateQubitState.biasSupply;
                flow from driveIn.item1 to manipulateQubitState.controlWaveform;
                flow from manipulateQubitState.qubitResponse to cavityOut.item1;
            }
            part cavity {
                doc 
                /* On-chip resonator, capacitively coupled to the qubit. The
                 * probe tone interacts with this resonator so that the
                 * outgoing tone carries the qubit state.
                 *
                 * Source: p.4 right column paragraph 2; Cavity in Fig. 2.
                 */
                port qubitIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port probeIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port probeOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.disperseInteract;
                flow from probeIn.item1 to disperseInteract.probeTone;
                flow from qubitIn.item1 to disperseInteract.qubitCoupling;
                flow from disperseInteract.stateDependentResponse to probeOut.item1;
            }
            part circulator {
                doc 
                /* Routes the readout signal towards the parametric amplifier
                 * and onwards out of the refrigerator, while suppressing
                 * backaction signals travelling towards the qubit.
                 *
                 * Source: p.5 left column paragraph 1; circulator in the
                 * Fig. 2 legend.
                 */
                port cavityIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port jpaOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                port jpaIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port isolatorOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.suppressBackactionCirculator;
                flow from cavityIn.item1 to suppressBackactionCirculator.incoming;
                flow from jpaIn.item1 to suppressBackactionCirculator.incoming;
                flow from suppressBackactionCirculator.forwarded to jpaOut.item1;
                flow from suppressBackactionCirculator.forwarded to isolatorOut.item1;
            }
            part josephsonParametricAmplifier {
                doc 
                /* Quantum-limited Josephson parametric amplifier providing
                 * the first amplification stage of the measurement chain.
                 *
                 * Source: p.5 left column paragraph 1; JPA in the Fig. 2
                 * legend.
                 */
                port signalIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port signalOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.amplifyQuantumLimited;
                flow from signalIn.item1 to amplifyQuantumLimited.weakSignal;
                flow from amplifyQuantumLimited.amplifiedSignal to signalOut.item1;
            }
            part isolator {
                doc 
                /* Isolator in the measurement chain, suppressing backaction
                 * signals to the qubit. The reference names isolators
                 * alongside circulators in the text, although no isolator
                 * symbol is drawn in Fig. 2, so the placement after the
                 * parametric amplifier follows the conventional measurement
                 * chain rather than the figure.
                 *
                 * Source: p.5 left column paragraph 1.
                 */
                port signalIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                    out item item1;
                }
                port signalOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                    in item item1;
                }
                perform conventionalOperation.suppressBackactionIsolator;
                flow from signalIn.item1 to suppressBackactionIsolator.incoming;
                flow from suppressBackactionIsolator.forwarded to signalOut.item1;
            }
            flow from qpu.cavityOut to cavity.qubitIn;
            flow from cavity.probeOut to circulator.cavityIn;
            flow from circulator.jpaOut to josephsonParametricAmplifier.signalIn;
            flow from josephsonParametricAmplifier.signalOut to circulator.jpaIn;
            flow from circulator.isolatorOut to isolator.signalIn;
        }
        flow from driveIn.payload to secondLayer.driveAttenuator.attIn;
        flow from secondLayer.driveAttenuator.attOut to thirdLayer.driveAttenuator.attIn;
        flow from thirdLayer.driveAttenuator.attOut to fourthLayer.driveAttenuator.attIn;
        flow from fourthLayer.driveAttenuator.attOut to sixthLayer.qpu.driveIn;
        flow from biasIn.payload to thirdLayer.biasFilter.filterIn;
        flow from thirdLayer.biasFilter.filterOut to sixthLayer.qpu.biasIn;
        flow from probeIn.payload to sixthLayer.cavity.probeIn;
        flow from sixthLayer.isolator.signalOut to thirdLayer.lowNoiseAmplifier.ampIn;
        flow from thirdLayer.lowNoiseAmplifier.ampOut to readoutOut.payload;
    }
    part conventionalReadoutSystem : QuantumComputing::physicalLayerDefinitions::classicalReadoutSystem {
        doc 
        /* Room-temperature readout electronics. Generates the probe tone by
         * upconversion, then downconverts the returning signal with the same
         * reference carrier, digitises it and deciphers the qubit state.
         * Drawn at the top right of Fig. 2.
         *
         * Source: p.4 right column paragraph 2; p.5 left column paragraph 1;
         * Fig. 2, p.4.
         */
        part readoutAWGFPGA : CommonInstruments::awgFPGA {
            port envelopeOut : QuantumComputing::physicalLayerDefinitions::digitalPort {
                in item item1;
            }
            perform conventionalOperation.generateProbeEnvelope;
            flow from generateProbeEnvelope.envelope to envelopeOut.item1;
        }
        part readoutLocalOscillator : CommonInstruments::localOscillator {
            doc 
            /* Supplies the reference high-frequency carrier. The same
             * reference carrier is used both to generate the readout tone by
             * upconversion and to downconvert the returning signal, which is
             * why this one oscillator feeds both mixers.
             *
             * Source: p.5 left column paragraph 1.
             */
            port carrierOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.generateProbeCarrier;
            flow from generateProbeCarrier.carrier to carrierOut.item1;
        }
        part readoutIqMixer1 : CommonInstruments::iqMixer {
            doc 
            /* Upconversion mixer. A reference high-frequency carrier is mixed
             * with a probe pulse from a digital to analog converter or
             * arbitrary waveform generator to generate the readout tone, by a
             * process called upconversion.
             *
             * Source: p.5 left column paragraph 1.
             */
            port ifIn : ~QuantumComputing::physicalLayerDefinitions::digitalPort {
                out item item1;
            }
            port loIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port rfOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.upconvertProbe;
            flow from ifIn.item1 to upconvertProbe.baseband;
            flow from loIn.item1 to upconvertProbe.carrier;
            flow from upconvertProbe.waveform to rfOut.item1;
        }
        part lowNoiseAmplifier {
            doc 
            /* Room-temperature amplification stage. The returning tone is
             * amplified at several stages along the measurement chain.
             *
             * Source: p.4 right column paragraph 2; Fig. 2.
             */
            port ampIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port ampOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.amplifyRoomTemperature;
            flow from ampIn.item1 to amplifyRoomTemperature.weakSignal;
            flow from amplifyRoomTemperature.amplifiedSignal to ampOut.item1;
        }
        part readoutIqMixer2 : CommonInstruments::iqMixer {
            doc 
            /* Downconversion mixer. The transmitted signal is downconverted
             * using the same reference carrier wave that generated the
             * readout tone.
             *
             * Source: p.5 left column paragraph 1.
             */
            port rfIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port loIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port ifOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.downconvertProbe;
            flow from rfIn.item1 to downconvertProbe.waveform;
            flow from loIn.item1 to downconvertProbe.referenceCarrier;
            flow from downconvertProbe.baseband to ifOut.item1;
        }
        part readoutFilter {
            port filterIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port filterOut : QuantumComputing::physicalLayerDefinitions::microwavePort {
                in item item1;
            }
            perform conventionalOperation.filterProbe;
            flow from filterIn.item1 to filterProbe.unfiltered;
            flow from filterProbe.filtered to filterOut.item1;
        }
        part adc : CommonInstruments::analogToDigitalConverter {
            port analogIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort {
                out item item1;
            }
            port digitalOut : QuantumComputing::physicalLayerDefinitions::digitalPort {
                in item item1;
            }
            perform conventionalOperation.digitiseProbe;
            flow from analogIn.item1 to digitiseProbe.analogInput;
            flow from digitiseProbe.digitalOutput to digitalOut.item1;
        }
        part computerFpga {
            doc 
            /* Records the digitised signal and deciphers the qubit state. In
             * modern implementations this is done in real time on FPGA
             * fabric, which enables fast feedback control of multiple qubits.
             *
             * Source: p.4 right column paragraph 2; p.5 left column
             * paragraph 2.
             */
            port resultIn : ~QuantumComputing::physicalLayerDefinitions::digitalPort {
                out item item1;
            }
            perform conventionalOperation.decipherQubitState;
            flow from resultIn.item1 to decipherQubitState.measurement;
        }
        port probeOut : QuantumComputing::physicalLayerDefinitions::microwavePort;
        port readoutIn : ~QuantumComputing::physicalLayerDefinitions::microwavePort;
        flow from readoutAWGFPGA.envelopeOut to readoutIqMixer1.ifIn;
        flow from readoutLocalOscillator.carrierOut to readoutIqMixer1.loIn;
        flow from readoutIqMixer1.rfOut to probeOut.payload;
        flow from readoutIn.payload to lowNoiseAmplifier.ampIn;
        flow from lowNoiseAmplifier.ampOut to readoutIqMixer2.rfIn;
        flow from readoutLocalOscillator.carrierOut to readoutIqMixer2.loIn;
        flow from readoutIqMixer2.ifOut to readoutFilter.filterIn;
        flow from readoutFilter.filterOut to adc.analogIn;
        flow from adc.digitalOut to computerFpga.resultIn;
    }
    flow from conventionalControlSystem.driveOut to dilutionRefrigeratorEnv.driveIn;
    flow from conventionalControlSystem.qubitBiasOut to dilutionRefrigeratorEnv.biasIn;
    flow from conventionalReadoutSystem.probeOut to dilutionRefrigeratorEnv.probeIn;
    flow from dilutionRefrigeratorEnv.readoutOut to conventionalReadoutSystem.readoutIn;
}
