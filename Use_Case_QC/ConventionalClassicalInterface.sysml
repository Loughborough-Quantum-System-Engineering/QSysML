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
    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import SuperconductingCommon::*;
    public import ISQ::*;
    public import SI::*;
    enum def pulseProtocol {
        doc 
        /* Advanced protocols with complex pulse sequences, employed to reduce
         * the unwanted side effects of anharmonicity and environment noise in
         * real qubit devices, aiming to improve the fidelity of the control
         * operation. The reference names these two.
         *
         * Source: p.4, right column, paragraph 1.
         */
        derivativeRemovalByAdiabaticGate;
        dynamicalDecoupling;
    }
    action def GenerateEnvelope {
        doc 
        /* Produce the low-frequency baseband envelope of a microwave pulse.
         * Low-frequency signals from an arbitrary waveform generator define
         * the shape and duration of the pulse. By engineering the amplitude,
         * duration and shape of the pulse it is possible to reach any
         * arbitrary state on the Bloch sphere.
         *
         * Amplitude, duration and shape are characteristics that configure
         * this action rather than payloads transferred to another action, so
         * they are plain attributes; the envelope itself is the out parameter.
         *
         * Source: p.4, right column, paragraph 1.
         */
        out item envelope : digitalData;
        attribute pulseAmplitude;
        attribute pulseDuration : DurationValue;
        attribute pulseShape;
    }
    action def ApplyPulseProtocol {
        doc 
        /* Shape the pulse sequence according to an advanced control protocol
         * in order to suppress the side effects of anharmonicity and
         * environmental noise, improving control fidelity.
         *
         * Source: p.4, right column, paragraph 1.
         */
        in item envelope : digitalData;
        out item shapedEnvelope : digitalData;
        attribute protocol : pulseProtocol;
        attribute controlFidelity;
    }
    action def ConvertDigitalToAnalog {
        doc 
        /* Convert the digital waveform description into an analog signal. A
         * probe pulse is supplied from a digital to analog converter or from
         * an arbitrary waveform generator.
         *
         * Source: p.5, left column, paragraph 1; DAC shown in Fig. 2.
         */
        in item digitalInput : digitalData;
        out item analogOutput : microwaveSignal;
    }
    action def GenerateCarrier {
        doc 
        /* Produce the high-frequency carrier tone used by the heterodyne
         * scheme. The carrier sits near the qubit fundamental transition
         * frequency.
         *
         * Source: p.4, right column, paragraph 1; local oscillator in the
         * Fig. 2 legend.
         */
        out item carrier : microwaveSignal;
        attribute carrierFrequency : FrequencyValue;
    }
    action def Upconvert {
        doc 
        /* Mix a baseband signal with the high-frequency carrier to produce
         * the desired waveform at the qubit frequency. Control pulses are
         * generated using a heterodyne scheme in which the baseband signals
         * are mixed with a carrier near the qubit fundamental transition
         * frequency. On the readout side the same operation generates the
         * readout tone and is named upconversion; together with the matching
         * downconversion it constitutes the heterodyne or homodyne
         * measurement of the probe tone.
         *
         * Source: p.4, right column, paragraph 1; p.5, left column,
         * paragraph 1.
         */
        in item baseband : microwaveSignal;
        in item carrier : microwaveSignal;
        out item waveform : microwaveSignal;
    }
    action def FilterSignal {
        doc 
        /* Band-limit a signal. Filters appear both in the room-temperature
         * electronics and inside the refrigerator, and are among the
         * components combined onto a single board in modern FPGA-based
         * hardware. Typed against the general signal item so that the same
         * definition serves the microwave drive line and the qubit bias line.
         *
         * Source: Fig. 2 legend, p.4; p.5, left column, paragraph 2.
         */
        in item unfiltered : signal;
        out item filtered : signal;
    }
    action def AttenuateThermalNoise {
        doc 
        /* Suppress thermal noise carried on a microwave line. The two tones
         * pass through thermally anchored attenuator stages within the
         * dilution refrigerator so that thermal noise is suppressed before
         * the signal reaches the qubit sample. Fig. 2 places one such stage
         * at each of the 50 K, 4 K and 800 mK plates.
         *
         * Source: p.4, left column, paragraph 1; attenuator in the Fig. 2
         * legend.
         */
        in item unattenuated : microwaveSignal;
        out item attenuated : microwaveSignal;
    }
    action def ProvideQubitBias {
        doc 
        /* Supply the static qubit bias. Fig. 2 shows a dedicated power source
         * feeding a qubit bias line into the refrigerator.
         *
         * Source: Fig. 2 and its legend, p.4.
         */
        out item bias : dcBias;
    }
    action def ManipulateQubitState {
        doc 
        /* Drive the qubit to a target state. By engineering the amplitude,
         * duration and shape of the microwave pulse it is possible to achieve
         * any arbitrary state on the Bloch sphere, within a timescale of tens
         * of nanoseconds.
         *
         * The achieved state is recorded as an attribute rather than an out
         * parameter, because it is not transferred to a following action; the
         * readout chain observes it indirectly through the dispersive
         * interaction with the on-chip resonator.
         *
         * Source: p.4, right column, paragraph 1.
         */
        in item controlWaveform : microwaveSignal;
        in item biasSupply : dcBias;
        out item qubitResponse : microwaveSignal;
        attribute blochSphereState;
        attribute gateDuration : DurationValue;
    }
    action def DispersiveInteraction {
        doc 
        /* Let the probe tone interact with the on-chip resonator so that the
         * resonator response carries the qubit state. A microwave tone probes
         * the qubit state in a dispersive readout architecture, interacting
         * with the resonator on-chip before leaving the sample.
         *
         * Source: p.4, right column, paragraph 2.
         */
        in item probeTone : microwaveSignal;
        in item qubitCoupling : microwaveSignal;
        out item stateDependentResponse : microwaveSignal;
    }
    action def SuppressBackaction {
        doc 
        /* Prevent measurement-chain signals from propagating back to the
         * qubit. Inside the dilution refrigerator the measurement chain
         * includes circulators and isolators, which suppress backaction
         * signals to the qubit.
         *
         * Source: p.5, left column, paragraph 1.
         */
        in item incoming : microwaveSignal;
        out item forwarded : microwaveSignal;
    }
    action def AmplifyQuantumLimited {
        doc 
        /* First-stage amplification of the readout signal at the base plate,
         * performed by quantum-limited Josephson parametric amplifiers.
         *
         * Source: p.5, left column, paragraph 1; JPA in the Fig. 2 legend.
         */
        in item weakSignal : microwaveSignal;
        out item amplifiedSignal : microwaveSignal;
    }
    action def Amplify {
        doc 
        /* Boost the readout signal. The tone is amplified at several stages.
         * Inside the refrigerator this is done by high-electron mobility
         * transistor amplifiers, and a further low-noise amplifier stage sits
         * at room temperature.
         *
         * Source: p.4, right column, paragraph 2; p.5, left column,
         * paragraph 1; low-noise amplifier in the Fig. 2 legend.
         */
        in item weakSignal : microwaveSignal;
        out item amplifiedSignal : microwaveSignal;
    }
    action def Downconvert {
        doc 
        /* Mix the returning signal back down to baseband. The transmitted
         * signal is downconverted using the same reference carrier wave that
         * was used to generate the readout tone. Together with the preceding
         * upconversion this realises the heterodyne or homodyne measurement.
         *
         * Source: p.5, left column, paragraph 1.
         */
        in item waveform : microwaveSignal;
        in item referenceCarrier : microwaveSignal;
        out item baseband : microwaveSignal;
    }
    action def ConvertAnalogToDigital {
        doc 
        /* Digitise the downconverted readout signal. The signal is recorded
         * through an analog to digital converter. Commercial products for
         * quantum measurement offer analog signal capture at high bitrate,
         * up to 14 bit.
         *
         * Source: p.5, left column, paragraph 1; bitrate from p.5, left
         * column, paragraph 2.
         */
        in item analogInput : microwaveSignal;
        out item digitalOutput : digitalData;
        attribute resolution;
    }
    action def PostProcess {
        doc 
        /* Recover the qubit state from the digitised record. The signal is
         * converted from analog to digital and recorded for post-processing.
         * Modern FPGA-based hardware records analog signals and deciphers
         * qubit states in real time, which enables fast feedback control.
         *
         * Source: p.4, right column, paragraph 2; p.5, left column,
         * paragraph 2.
         */
        in item digitisedResponse : digitalData;
        out attribute qubitState;
    }
    action def SynchroniseClock {
        doc 
        /* Align the individual drive electronics to a common external clock.
         * This is a major limitation of the conventional architecture,
         * because the instruments are generic and individually commercially
         * sourced. Synchronisation causes a delay of approximately one
         * microsecond, which significantly affects gate operations.
         *
         * Source: p.5, left column, paragraph 1.
         */
        attribute clockDelay : DurationValue;
    }
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
        out attribute measuredQubitState;
        action generateEnvelope : GenerateEnvelope;
        action applyPulseProtocol : ApplyPulseProtocol;
        action convertDriveToAnalog : ConvertDigitalToAnalog;
        action generateDriveCarrier : GenerateCarrier;
        action upconvertDrive : Upconvert;
        action filterDrive : FilterSignal;
        action attenuateDrive50K : AttenuateThermalNoise;
        action attenuateDrive4K : AttenuateThermalNoise;
        action attenuateDrive800mK : AttenuateThermalNoise;
        action manipulateQubitState : ManipulateQubitState;
        action provideQubitBias : ProvideQubitBias;
        action filterBias : FilterSignal;
        action synchroniseClock : SynchroniseClock;
        action generateProbeEnvelope : GenerateEnvelope;
        action generateProbeCarrier : GenerateCarrier;
        action upconvertProbe : Upconvert;
        action disperseInteract : DispersiveInteraction;
        action suppressBackactionCirculator : SuppressBackaction;
        action suppressBackactionIsolator : SuppressBackaction;
        action amplifyQuantumLimited : AmplifyQuantumLimited;
        action amplifyCryogenic : Amplify;
        action amplifyRoomTemperature : Amplify;
        action downconvertProbe : Downconvert;
        action filterProbe : FilterSignal;
        action digitiseProbe : ConvertAnalogToDigital;
        action decipherQubitState : PostProcess;
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
        flow from digitiseProbe.digitalOutput to decipherQubitState.digitisedResponse;
        binding bind measuredQubitState = decipherQubitState.qubitState;
    }
    action conventionalOperation : ConventionalControlAndReadout;
    part conventionalControlSystem : classicalControlSystem {
        doc 
        /* Room-temperature control electronics generating the qubit drive
         * tone and the static qubit bias. Drawn at the top left of Fig. 2.
         *
         * Source: Fig. 2, p.4; p.4 right column paragraph 1.
         */
        part controlAWGFPGA : awgFPGA {
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
            port envelopeOut : digitalPort {
                in item item1;
            }
            perform conventionalOperation.generateEnvelope;
            perform conventionalOperation.applyPulseProtocol;
            perform conventionalOperation.synchroniseClock;
            succession flow from generateEnvelope.envelope to applyPulseProtocol.envelope;
            succession flow from applyPulseProtocol.shapedEnvelope to envelopeOut.item1;
        }
        part dac : digitalToAnalogConverter {
            port digitalIn : ~digitalPort {
                out item item1;
            }
            port analogOut : microwavePort {
                in item item1;
            }
            perform conventionalOperation.convertDriveToAnalog;
            flow from digitalIn.item1 to convertDriveToAnalog.digitalInput;
            succession flow from convertDriveToAnalog.analogOutput to analogOut.item1;
        }
        part controlLocalOscillator : localOscillator {
            port carrierOut : microwavePort {
                in item item1;
            }
            perform conventionalOperation.generateDriveCarrier;
            succession flow from generateDriveCarrier.carrier to carrierOut.item1;
        }
        part controlIqMixer : iqMixer {
            doc 
            /* Mixes the baseband envelope with the high-frequency carrier to
             * produce the control waveform, implementing the heterodyne
             * scheme.
             *
             * Source: p.4 right column paragraph 1; IQ mixer in the Fig. 2
             * legend.
             */
            port ifIn : ~microwavePort {
                out item item1;
            }
            port loIn : ~microwavePort {
                out item item1;
            }
            port rfOut : microwavePort {
                in item item1;
            }
            perform conventionalOperation.upconvertDrive;
            flow from ifIn.item1 to upconvertDrive.baseband;
            flow from loIn.item1 to upconvertDrive.carrier;
            succession flow from upconvertDrive.waveform to rfOut.item1;
        }
        part controlFilter {
            port filterIn : ~microwavePort {
                out item item1;
            }
            port filterOut : microwavePort {
                in item item1;
            }
            perform conventionalOperation.filterDrive;
            flow from filterIn.item1 to filterDrive.unfiltered;
            succession flow from filterDrive.filtered to filterOut.item1;
        }
        part qubitBias : powerSource {
            port biasOut : dcBiasPort {
                in item item1;
            }
            perform conventionalOperation.provideQubitBias;
            succession flow from provideQubitBias.bias to biasOut.item1;
        }
        port driveOut : microwavePort;
        port qubitBiasOut : dcBiasPort;
        flow from controlAWGFPGA.envelopeOut to dac.digitalIn;
        flow from dac.analogOut to controlIqMixer.ifIn;
        flow from controlLocalOscillator.carrierOut to controlIqMixer.loIn;
        flow from controlIqMixer.rfOut to controlFilter.filterIn;
        flow from controlFilter.filterOut to driveOut;
        flow from qubitBias.biasOut to qubitBiasOut;
    }
    part dilutionRefrigeratorEnv : dilutionRefrigerator {
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
        port driveIn : ~microwavePort;
        port biasIn : ~dcBiasPort;
        port probeIn : ~microwavePort;
        port readoutOut : microwavePort;
        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part driveAttenuator : attenuator {
                doc 
                /* Thermally anchored attenuator stage on the drive line at
                 * the 50 K plate.
                 *
                 * Source: p.4 left column paragraph 1; Fig. 2.
                 */
                port attIn : ~microwavePort {
                    out item item1;
                }
                port attOut : microwavePort {
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
            part driveAttenuator : attenuator {
                doc 
                /* Thermally anchored attenuator stage on the drive line at
                 * the 4 K plate.
                 *
                 * Source: p.4 left column paragraph 1; Fig. 2.
                 */
                port attIn : ~microwavePort {
                    out item item1;
                }
                port attOut : microwavePort {
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
                port filterIn : ~dcBiasPort {
                    out item item1;
                }
                port filterOut : dcBiasPort {
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
                port ampIn : ~microwavePort {
                    out item item1;
                }
                port ampOut : microwavePort {
                    in item item1;
                }
                perform conventionalOperation.amplifyCryogenic;
                flow from ampIn.item1 to amplifyCryogenic.weakSignal;
                succession flow from amplifyCryogenic.amplifiedSignal to ampOut.item1;
            }
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part driveAttenuator : attenuator {
                doc 
                /* Thermally anchored attenuator stage on the drive line at
                 * the 800 mK plate.
                 *
                 * Source: p.4 left column paragraph 1; Fig. 2.
                 */
                port attIn : ~microwavePort {
                    out item item1;
                }
                port attOut : microwavePort {
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
            part qpu : QPU {
                doc 
                /* Quantum processing unit holding the superconducting
                 * transmon qubit. Modelled as a black box at this level, so
                 * that only the classical interface is in scope.
                 *
                 * Source: QPU in the Fig. 2 legend; Fig. 2 caption, p.4.
                 */
                attribute :>> technology = qubitTechnology::superconducting;
                port driveIn : ~microwavePort {
                    out item item1;
                }
                port biasIn : ~dcBiasPort {
                    out item item1;
                }
                port cavityOut : microwavePort {
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
                port qubitIn : ~microwavePort {
                    out item item1;
                }
                port probeIn : ~microwavePort {
                    out item item1;
                }
                port probeOut : microwavePort {
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
                port cavityIn : ~microwavePort {
                    out item item1;
                }
                port jpaOut : microwavePort {
                    in item item1;
                }
                port jpaIn : ~microwavePort {
                    out item item1;
                }
                port isolatorOut : microwavePort {
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
                port signalIn : ~microwavePort {
                    out item item1;
                }
                port signalOut : microwavePort {
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
                port signalIn : ~microwavePort {
                    out item item1;
                }
                port signalOut : microwavePort {
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
        flow from driveIn to secondLayer.driveAttenuator.attIn;
        flow from secondLayer.driveAttenuator.attOut to thirdLayer.driveAttenuator.attIn;
        flow from thirdLayer.driveAttenuator.attOut to fourthLayer.driveAttenuator.attIn;
        flow from fourthLayer.driveAttenuator.attOut to sixthLayer.qpu.driveIn;
        flow from biasIn to thirdLayer.biasFilter.filterIn;
        flow from thirdLayer.biasFilter.filterOut to sixthLayer.qpu.biasIn;
        flow from probeIn to sixthLayer.cavity.probeIn;
        flow from sixthLayer.isolator.signalOut to thirdLayer.lowNoiseAmplifier.ampIn;
        flow from thirdLayer.lowNoiseAmplifier.ampOut to readoutOut;
    }
    part conventionalReadoutSystem : classicalReadoutSystem {
        doc 
        /* Room-temperature readout electronics. Generates the probe tone by
         * upconversion, then downconverts the returning signal with the same
         * reference carrier, digitises it and deciphers the qubit state.
         * Drawn at the top right of Fig. 2.
         *
         * Source: p.4 right column paragraph 2; p.5 left column paragraph 1;
         * Fig. 2, p.4.
         */
        part readoutAWGFPGA : awgFPGA {
            port envelopeOut : digitalPort {
                in item item1;
            }
            perform conventionalOperation.generateProbeEnvelope;
            flow from generateProbeEnvelope.envelope to envelopeOut.item1;
        }
        part readoutLocalOscillator : localOscillator {
            doc 
            /* Supplies the reference high-frequency carrier. The same
             * reference carrier is used both to generate the readout tone by
             * upconversion and to downconvert the returning signal, which is
             * why this one oscillator feeds both mixers.
             *
             * Source: p.5 left column paragraph 1.
             */
            port carrierOut : microwavePort {
                in item item1;
            }
            perform conventionalOperation.generateProbeCarrier;
            flow from generateProbeCarrier.carrier to carrierOut.item1;
        }
        part readoutIqMixer1 : iqMixer {
            doc 
            /* Upconversion mixer. A reference high-frequency carrier is mixed
             * with a probe pulse from a digital to analog converter or
             * arbitrary waveform generator to generate the readout tone, by a
             * process called upconversion.
             *
             * Source: p.5 left column paragraph 1.
             */
            port ifIn : ~digitalPort {
                out item item1;
            }
            port loIn : ~microwavePort {
                out item item1;
            }
            port rfOut : microwavePort {
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
            port ampIn : ~microwavePort {
                out item item1;
            }
            port ampOut : microwavePort {
                in item item1;
            }
            perform conventionalOperation.amplifyRoomTemperature;
            flow from ampIn.item1 to amplifyRoomTemperature.weakSignal;
            flow from amplifyRoomTemperature.amplifiedSignal to ampOut.item1;
        }
        part readoutIqMixer2 : iqMixer {
            doc 
            /* Downconversion mixer. The transmitted signal is downconverted
             * using the same reference carrier wave that generated the
             * readout tone.
             *
             * Source: p.5 left column paragraph 1.
             */
            port rfIn : ~microwavePort {
                out item item1;
            }
            port loIn : ~microwavePort {
                out item item1;
            }
            port ifOut : microwavePort {
                in item item1;
            }
            perform conventionalOperation.downconvertProbe;
            flow from rfIn.item1 to downconvertProbe.waveform;
            flow from loIn.item1 to downconvertProbe.referenceCarrier;
            flow from downconvertProbe.baseband to ifOut.item1;
        }
        part readoutFilter {
            port filterIn : ~microwavePort {
                out item item1;
            }
            port filterOut : microwavePort {
                in item item1;
            }
            perform conventionalOperation.filterProbe;
            flow from filterIn.item1 to filterProbe.unfiltered;
            flow from filterProbe.filtered to filterOut.item1;
        }
        part adc : analogToDigitalConverter {
            port analogIn : ~microwavePort {
                out item item1;
            }
            port digitalOut : digitalPort {
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
            port resultIn : ~digitalPort {
                out item item1;
            }
            perform conventionalOperation.decipherQubitState;
            flow from resultIn.item1 to decipherQubitState.digitisedResponse;
        }
        port probeOut : microwavePort;
        port readoutIn : ~microwavePort;
        flow from readoutAWGFPGA.envelopeOut to readoutIqMixer1.ifIn;
        flow from readoutLocalOscillator.carrierOut to readoutIqMixer1.loIn;
        flow from readoutIqMixer1.rfOut to probeOut;
        flow from readoutIn to lowNoiseAmplifier.ampIn;
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
