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
//   [Fig.5]   = Fig. 5 schematic / legend, p.8
//   [Eq.1]    = Equation 1, p.7 left column

package SingleFluxQuantumInterface {

    doc
    /*
     * Single flux quantum (SFQ) control and readout interface for a
     * superconducting qubit in a dilution refrigerator.
     *
     * SFQ is a digital approach that uses Josephson junctions and the
     * quantization of magnetic flux to encode and process quantum
     * information. An individual SFQ pulse produces a broadband excitation
     * and so cannot coherently manipulate a qubit on its own; control
     * instead relies on driving the qubit with a train of SFQ pulses whose
     * pulse-to-pulse separation is matched to the qubit period. Readout is
     * fully digital: the qubit state is mapped onto photon occupation in a
     * cavity, detected by a Josephson photomultiplier, and converted to an
     * SFQ logic signal by a Josephson transmission line.
     *
     * Source: Brennan et al. 2025, section "Single flux quantum",
     * p.7 left column paragraph 1 through p.8 left column paragraph 2, and
     * the Fig. 5 schematic on p.8.
     *
     * Units: prefixed unit symbols are not recognised, so quantities are
     * expressed in SI base units with a scaled literal, and the value as
     * printed in the reference is restated in the documentation of the
     * owning element.
     */

    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import SuperconductingCommon::*;
    public import ISQ::*;
    public import SI::*;

    // =====================================================================
    // Local signal vocabulary
    // =====================================================================
    item def circulatingCurrent :> signal {
        doc
        /*
         * Persistent current in which a Josephson photomultiplier stores the
         * outcome of a photon detection. Declared locally because it is
         * specific to the SFQ readout chain and has no counterpart in the
         * shared instrument library.
         *
         * Source: p.7, right column, paragraph 2.
         */
    }
    port def circulatingCurrentPort {
        out item payload : circulatingCurrent;
    }

    // =====================================================================
    // Action definitions
    // =====================================================================









    action def ManipulateQubitState {
        doc
        /*
         * Drive the qubit with the SFQ pulse train. The train is coupled
         * capacitively to a transmon qubit and each SFQ pulse induces an
         * incremental rotation of the qubit state vector about the Bloch
         * sphere, so that coherent and accurate qubit control is achieved.
         *
         * Source: p.7, left column, paragraph 3.
         */
        in item pulseTrain : sfqPulse;
        out item qubitResponse : microwaveSignal;
        attribute incrementalRotation;
        attribute predictedGateFidelity;            // > 99.99 %   [p.7 LC para 3]
        attribute realisedGateFidelity;             // approx 95 % [p.7 LC para 3]
    }









    // =====================================================================
    // End-to-end behaviour
    // =====================================================================
    action def SfqControlAndReadout {

        doc
        /*
         * Sequence of the SFQ control and readout cycle as drawn in Fig. 5
         * on p.8.
         *
         * A microwave trigger tone is generated at room temperature, carried
         * down through the attenuator stages, and used to trigger the
         * control SFQ chip, which emits the pulse train that drives the
         * qubit. Readout is fully digital: the qubit state becomes photon
         * occupation in the cavity, the photomultiplier converts that to a
         * circulating current, the transmission line converts the current to
         * a fluxon arrival-time deviation, and the readout SFQ chip converts
         * that to a logic signal which is amplified and digitised. Two bias
         * lines, one per SFQ chip, are established and held.
         *
         * This definition states ordering and the action-to-action item
         * chain. The physical routing of those items through ports is
         * modelled in the parts.
         *
         * Source: p.7 left column paragraph 1 through p.8 left column
         * paragraph 2, and Fig. 5.
         */

        out attribute measuredQubitState;

        // ---- trigger (control) chain ----
        action generateEnvelope : GenerateEnvelope;                // [Fig.5]
        action convertTriggerToAnalog : ConvertDigitalToAnalog;    // [Fig.5]
        action generateTriggerCarrier : GenerateCarrier;           // [Fig.5]
        action upconvertTrigger : Upconvert;                       // [p.7 LC para 3]
        action filterTrigger : FilterSignal;                       // [Fig.5]
        action attenuateTrigger50K : AttenuateSignal;        // [Fig.5]
        action attenuateTrigger4K : AttenuateSignal;         // [Fig.5]
        action attenuateTrigger800mK : AttenuateSignal;      // [Fig.5]
        action generateSfqPulseTrain : GenerateSfqPulseTrain;      // [p.7 LC para 3]
        action manipulateQubitState : ManipulateQubitState;        // [p.7 LC para 3]

        // ---- bias chains, one per SFQ chip ----
        action provideDcSfqBias : SupplyBias;                     // [Fig.5]
        action filterDcSfqBias : FilterSignal;                     // [Fig.5]
        action provideSfqDcBias : SupplyBias;                     // [Fig.5]
        action filterSfqDcBias : FilterSignal;                     // [Fig.5]

        // ---- digital readout chain ----
        action mapStateToPhoton : MapStateToPhotonOccupation;      // [p.7 RC para 2]
        action detectPhoton : DetectPhotonToCurrent;                        // [p.7 RC para 2]
        action modulateFluxonArrival : ModulateFluxonArrival;      // [p.7 RC para 2]
        action convertToSfqLogic : ConvertToSfqLogic;              // [p.7 RC para 2]
        action amplifyCryogenic : Amplify;                         // [Fig.5]
        action amplifyRoomTemperature : Amplify;                   // [Fig.5]
        action generateReadoutCarrier : GenerateCarrier;           // [Fig.5]
        action downconvertReadout : Downconvert;                   // [Fig.5]
        action filterReadout : FilterSignal;                       // [Fig.5]
        action digitiseReadout : ConvertAnalogToDigital;           // [Fig.5]
        action decipherQubitState : AnalyseMeasurement;                   // [Fig.5]

        // ---- control nodes ----
        fork initiate;
        join joinTrigger;
        join joinPulseTrain;
        join joinSfqLogic;

        // ---- ordering ----
        first start then initiate;

        first initiate then provideDcSfqBias;                      // [Fig.5]
        first provideDcSfqBias then filterDcSfqBias;
        first initiate then provideSfqDcBias;
        first provideSfqDcBias then filterSfqDcBias;

        first initiate then generateEnvelope;                      // [Fig.5]
        first generateEnvelope then convertTriggerToAnalog;
        first initiate then generateTriggerCarrier;
        first convertTriggerToAnalog then joinTrigger;
        first generateTriggerCarrier then joinTrigger;
        first joinTrigger then upconvertTrigger;
        first upconvertTrigger then filterTrigger;

        first filterTrigger then attenuateTrigger50K;              // [Fig.5]
        first attenuateTrigger50K then attenuateTrigger4K;
        first attenuateTrigger4K then attenuateTrigger800mK;

        // the converter needs both the trigger tone and its bias
        first attenuateTrigger800mK then joinPulseTrain;           // [p.7 LC para 3]
        first filterDcSfqBias then joinPulseTrain;
        first joinPulseTrain then generateSfqPulseTrain;
        first generateSfqPulseTrain then manipulateQubitState;

        // digital readout follows the drive                       // [p.7 RC para 2]
        first manipulateQubitState then mapStateToPhoton;
        first mapStateToPhoton then detectPhoton;
        first detectPhoton then modulateFluxonArrival;
        first modulateFluxonArrival then joinSfqLogic;
        first filterSfqDcBias then joinSfqLogic;
        first joinSfqLogic then convertToSfqLogic;
        first convertToSfqLogic then amplifyCryogenic;             // [Fig.5]
        first amplifyCryogenic then amplifyRoomTemperature;
        first initiate then generateReadoutCarrier;
        first amplifyRoomTemperature then downconvertReadout;
        first downconvertReadout then filterReadout;
        first filterReadout then digitiseReadout;
        first digitiseReadout then decipherQubitState;
        first decipherQubitState then done;

        // ---- item chain ----
        flow from generateEnvelope.envelope to convertTriggerToAnalog.digitalInput;
        flow from convertTriggerToAnalog.analogOutput to upconvertTrigger.baseband;
        flow from generateTriggerCarrier.carrier to upconvertTrigger.carrier;
        flow from upconvertTrigger.waveform to filterTrigger.unfiltered;
        flow from filterTrigger.filtered to attenuateTrigger50K.unattenuated;
        flow from attenuateTrigger50K.attenuated to attenuateTrigger4K.unattenuated;
        flow from attenuateTrigger4K.attenuated to attenuateTrigger800mK.unattenuated;
        flow from attenuateTrigger800mK.attenuated to generateSfqPulseTrain.triggerTone;

        flow from provideDcSfqBias.bias to filterDcSfqBias.unfiltered;
        flow from filterDcSfqBias.filtered to generateSfqPulseTrain.biasSupply;
        flow from provideSfqDcBias.bias to filterSfqDcBias.unfiltered;
        flow from filterSfqDcBias.filtered to convertToSfqLogic.biasSupply;

        flow from generateSfqPulseTrain.pulseTrain to manipulateQubitState.pulseTrain;
        flow from manipulateQubitState.qubitResponse to mapStateToPhoton.qubitCoupling;
        flow from mapStateToPhoton.photonOccupation to detectPhoton.photonOccupation;
        flow from detectPhoton.storedResult to modulateFluxonArrival.storedResult;
        flow from modulateFluxonArrival.fluxon to convertToSfqLogic.fluxon;
        flow from convertToSfqLogic.logicSignal to amplifyCryogenic.weakSignal;
        flow from amplifyCryogenic.amplifiedSignal to amplifyRoomTemperature.weakSignal;
        flow from amplifyRoomTemperature.amplifiedSignal to downconvertReadout.waveform;
        flow from generateReadoutCarrier.carrier to downconvertReadout.referenceCarrier;
        flow from downconvertReadout.baseband to filterReadout.unfiltered;
        flow from filterReadout.filtered to digitiseReadout.analogInput;
        flow from digitiseReadout.digitalOutput to decipherQubitState.measurement;

        bind measuredQubitState = decipherQubitState.qubitState;
    }

    action sfqOperation : SfqControlAndReadout;

    // =====================================================================
    // Structure
    // =====================================================================
    part sfqControlSystem : classicalControlSystem {

        doc
        /*
         * Room-temperature electronics generating the microwave tone that
         * triggers the DC-SFQ converter, together with the dc-SFQ bias
         * source. Drawn at the top left of Fig. 5.
         *
         * Source: Fig. 5, p.8; p.7 left column paragraph 3.
         */

        part controlAWGFPGA : awgFPGA {
            port envelopeOut : digitalPort {
                in item item1;
            }
            perform sfqOperation.generateEnvelope;                 // [Fig.5]
            flow from generateEnvelope.envelope to envelopeOut.item1;
        }
        part dac : digitalToAnalogConverter {
            port digitalIn : ~digitalPort {
                out item item1;
            }
            port analogOut : microwavePort {
                in item item1;
            }
            perform sfqOperation.convertTriggerToAnalog;           // [Fig.5]
            flow from digitalIn.item1 to convertTriggerToAnalog.digitalInput;
            flow from convertTriggerToAnalog.analogOutput to analogOut.item1;
        }
        part controlLocalOscillator : localOscillator {
            port carrierOut : microwavePort {
                in item item1;
            }
            perform sfqOperation.generateTriggerCarrier;           // [Fig.5]
            flow from generateTriggerCarrier.carrier to carrierOut.item1;
        }
        part controlIqMixer : iqMixer {
            doc
            /*
             * Produces the external microwave tone that triggers the DC-SFQ
             * converter.
             *
             * Source: p.7 left column paragraph 3; IQ mixer in the Fig. 5
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
            perform sfqOperation.upconvertTrigger;
            flow from ifIn.item1 to upconvertTrigger.baseband;
            flow from loIn.item1 to upconvertTrigger.carrier;
            flow from upconvertTrigger.waveform to rfOut.item1;
        }
        part controlFilter {
            port filterIn : ~microwavePort {
                out item item1;
            }
            port filterOut : microwavePort {
                in item item1;
            }
            perform sfqOperation.filterTrigger;                    // [Fig.5]
            flow from filterIn.item1 to filterTrigger.unfiltered;
            flow from filterTrigger.filtered to filterOut.item1;
        }
        part dcSfqBias : powerSource {
            doc
            /*
             * dc-SFQ bias source for the control SFQ chip.
             *
             * Source: Fig. 5, p.8.
             */
            port biasOut : dcBiasPort {
                in item item1;
            }
            perform sfqOperation.provideDcSfqBias;
            flow from provideDcSfqBias.bias to biasOut.item1;
        }
        port triggerToneOut : microwavePort;
        port dcSfqBiasOut : dcBiasPort;
        flow from controlAWGFPGA.envelopeOut to dac.digitalIn;
        flow from dac.analogOut to controlIqMixer.ifIn;
        flow from controlLocalOscillator.carrierOut to controlIqMixer.loIn;
        flow from controlIqMixer.rfOut to controlFilter.filterIn;
        flow from controlFilter.filterOut to triggerToneOut;
        flow from dcSfqBias.biasOut to dcSfqBiasOut;
    }

    part dilutionRefrigeratorEnv : dilutionRefrigerator {

        doc
        /*
         * Dilution refrigerator housing the SFQ chips and the qubit. Fig. 5
         * marks six temperature stages, from 300 K down to 10 mK, with the
         * SFQ control chip, qubit, cavity, photomultiplier, transmission
         * line and readout SFQ chip inside a mu-metal shield at the base
         * stage.
         *
         * Integrating SFQ devices into commercially available dilution
         * refrigerators is a significant issue. The low-noise requirements
         * and the sensitivity of the devices to magnetic fields and trapped
         * flux mean that manageable but not insignificant modifications are
         * required to adapt the system from conventional qubit control
         * architecture. Quasiparticle poisoning was an issue in early
         * implementations and has been improved by installing the SFQ device
         * at the 3 K cryostat stage or by using a flipchip module
         * architecture.
         *
         * Source: p.7 right column paragraph 4; p.8 left column paragraph 1;
         * Fig. 5, p.8.
         */

        port triggerToneIn : ~microwavePort;
        port dcSfqBiasIn : ~dcBiasPort;
        port sfqDcBiasIn : ~dcBiasPort;
        port readoutOut : microwavePort;

        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
            part triggerAttenuator : attenuator {
                doc
                /*
                 * Attenuator stage on the trigger line at the 50 K plate.
                 *
                 * Source: Fig. 5, p.8.
                 */
                port attIn : ~microwavePort {
                    out item item1;
                }
                port attOut : microwavePort {
                    in item item1;
                }
                perform sfqOperation.attenuateTrigger50K;
                flow from attIn.item1 to attenuateTrigger50K.unattenuated;
                flow from attenuateTrigger50K.attenuated to attOut.item1;
            }
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part triggerAttenuator : attenuator {
                doc
                /*
                 * Attenuator stage on the trigger line at the 4 K plate.
                 *
                 * Source: Fig. 5, p.8.
                 */
                port attIn : ~microwavePort {
                    out item item1;
                }
                port attOut : microwavePort {
                    in item item1;
                }
                perform sfqOperation.attenuateTrigger4K;
                flow from attIn.item1 to attenuateTrigger4K.unattenuated;
                flow from attenuateTrigger4K.attenuated to attOut.item1;
            }
            part dcSfqBiasFilter {
                doc
                /*
                 * Filter on the dc-SFQ bias line at the 4 K plate.
                 *
                 * Source: Fig. 5, p.8.
                 */
                port filterIn : ~dcBiasPort {
                    out item item1;
                }
                port filterOut : dcBiasPort {
                    in item item1;
                }
                perform sfqOperation.filterDcSfqBias;
                flow from filterIn.item1 to filterDcSfqBias.unfiltered;
                flow from filterDcSfqBias.filtered to filterOut.item1;
            }
            part sfqDcBiasFilter {
                doc
                /*
                 * Filter on the SFQ-dc bias line at the 4 K plate.
                 *
                 * Source: Fig. 5, p.8.
                 */
                port filterIn : ~dcBiasPort {
                    out item item1;
                }
                port filterOut : dcBiasPort {
                    in item item1;
                }
                perform sfqOperation.filterSfqDcBias;
                flow from filterIn.item1 to filterSfqDcBias.unfiltered;
                flow from filterSfqDcBias.filtered to filterOut.item1;
            }
            part lowNoiseAmplifier {
                doc
                /*
                 * Cryogenic amplification stage on the readout line.
                 *
                 * Source: low-noise amplifier in the Fig. 5 legend, p.8.
                 */
                port ampIn : ~microwavePort {
                    out item item1;
                }
                port ampOut : microwavePort {
                    in item item1;
                }
                perform sfqOperation.amplifyCryogenic;
                flow from ampIn.item1 to amplifyCryogenic.weakSignal;
                flow from amplifyCryogenic.amplifiedSignal to ampOut.item1;
            }
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
            part triggerAttenuator : attenuator {
                doc
                /*
                 * Attenuator stage on the trigger line at the 800 mK plate.
                 *
                 * Source: Fig. 5, p.8.
                 */
                port attIn : ~microwavePort {
                    out item item1;
                }
                port attOut : microwavePort {
                    in item item1;
                }
                perform sfqOperation.attenuateTrigger800mK;
                flow from attIn.item1 to attenuateTrigger800mK.unattenuated;
                flow from attenuateTrigger800mK.attenuated to attOut.item1;
            }
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];

            part controlSfqChip {
                doc
                /*
                 * DC-SFQ converter and control logic chip. An external
                 * microwave tone triggers the converter, which generates the
                 * pulse train that is coupled capacitively to the qubit.
                 *
                 * Source: p.7 left column paragraph 3; SFQ in the Fig. 5
                 * legend.
                 */
                port triggerToneIn : ~microwavePort {
                    out item item1;
                }
                port biasIn : ~dcBiasPort {
                    out item item1;
                }
                port pulseTrainOut : sfqPort {
                    in item item1;
                }
                perform sfqOperation.generateSfqPulseTrain;
                flow from triggerToneIn.item1 to generateSfqPulseTrain.triggerTone;
                flow from biasIn.item1 to generateSfqPulseTrain.biasSupply;
                flow from generateSfqPulseTrain.pulseTrain to pulseTrainOut.item1;
            }
            part qpu : QPU {
                doc
                /*
                 * Quantum processing unit holding the transmon qubit, driven
                 * by the capacitively coupled SFQ pulse train. Modelled as a
                 * black box so that only the classical interface is in scope.
                 *
                 * Source: QPU in the Fig. 5 legend; p.7 left column
                 * paragraph 3.
                 */
                attribute redefines technology = qubitTechnology::superconducting;
                port pulseTrainIn : ~sfqPort {
                    out item item1;
                }
                port cavityOut : microwavePort {
                    in item item1;
                }
                perform sfqOperation.manipulateQubitState;
                flow from pulseTrainIn.item1 to manipulateQubitState.pulseTrain;
                flow from manipulateQubitState.qubitResponse to cavityOut.item1;
            }
            part cavity {
                doc
                /*
                 * Microwave cavity onto whose photon occupation the qubit
                 * state is mapped.
                 *
                 * Source: p.7 right column paragraph 2; Cavity in Fig. 5.
                 */
                port qubitIn : ~microwavePort {
                    out item item1;
                }
                port photonOut : microwavePort {
                    in item item1;
                }
                perform sfqOperation.mapStateToPhoton;
                flow from qubitIn.item1 to mapStateToPhoton.qubitCoupling;
                flow from mapStateToPhoton.photonOccupation to photonOut.item1;
            }
            part josephsonPhotomultiplier {
                doc
                /*
                 * Josephson photomultiplier. Detects the cavity photon,
                 * effectively measuring the qubit state, and stores the
                 * result in a circulating current.
                 *
                 * Source: p.7 right column paragraph 2; JPM in the Fig. 5
                 * legend.
                 */
                port photonIn : ~microwavePort {
                    out item item1;
                }
                port circulatingCurrentOut : circulatingCurrentPort {
                    in item item1;
                }
                perform sfqOperation.detectPhoton;
                flow from photonIn.item1 to detectPhoton.photonOccupation;
                flow from detectPhoton.storedResult to circulatingCurrentOut.item1;
            }
            part josephsonTransmissionLine {
                doc
                /*
                 * Underdamped Josephson transmission line coupled to the
                 * photomultiplier. Delays or accelerates the fluxons
                 * travelling along it according to the circulating current.
                 *
                 * Source: p.7 right column paragraph 2; JTL in the Fig. 5
                 * legend.
                 */
                port circulatingCurrentIn : ~circulatingCurrentPort {
                    out item item1;
                }
                port fluxonOut : sfqPort {
                    in item item1;
                }
                perform sfqOperation.modulateFluxonArrival;
                flow from circulatingCurrentIn.item1 to modulateFluxonArrival.storedResult;
                flow from modulateFluxonArrival.fluxon to fluxonOut.item1;
            }
            part readoutSfqChip {
                doc
                /*
                 * Readout SFQ logic chip. Converts the deviation in fluxon
                 * arrival time into an SFQ logic signal, delivering digital
                 * qubit readout.
                 *
                 * Source: p.7 right column paragraph 2; SFQ in the Fig. 5
                 * legend.
                 */
                port fluxonIn : ~sfqPort {
                    out item item1;
                }
                port biasIn : ~dcBiasPort {
                    out item item1;
                }
                port readoutOut : microwavePort {
                    in item item1;
                }
                perform sfqOperation.convertToSfqLogic;
                flow from fluxonIn.item1 to convertToSfqLogic.fluxon;
                flow from biasIn.item1 to convertToSfqLogic.biasSupply;
                flow from convertToSfqLogic.logicSignal to readoutOut.item1;
            }
            flow from controlSfqChip.pulseTrainOut to qpu.pulseTrainIn;
            flow from qpu.cavityOut to cavity.qubitIn;
            flow from cavity.photonOut to josephsonPhotomultiplier.photonIn;
            flow from josephsonPhotomultiplier.circulatingCurrentOut to josephsonTransmissionLine.circulatingCurrentIn;
            flow from josephsonTransmissionLine.fluxonOut to readoutSfqChip.fluxonIn;
        }

        // trigger line passes through the attenuator stages [Fig.5]
        flow from triggerToneIn to secondLayer.triggerAttenuator.attIn;
        flow from secondLayer.triggerAttenuator.attOut to thirdLayer.triggerAttenuator.attIn;
        flow from thirdLayer.triggerAttenuator.attOut to fourthLayer.triggerAttenuator.attIn;
        flow from fourthLayer.triggerAttenuator.attOut to sixthLayer.controlSfqChip.triggerToneIn;
        flow from dcSfqBiasIn to thirdLayer.dcSfqBiasFilter.filterIn;
        flow from thirdLayer.dcSfqBiasFilter.filterOut to sixthLayer.controlSfqChip.biasIn;
        flow from sfqDcBiasIn to thirdLayer.sfqDcBiasFilter.filterIn;
        flow from thirdLayer.sfqDcBiasFilter.filterOut to sixthLayer.readoutSfqChip.biasIn;
        flow from sixthLayer.readoutSfqChip.readoutOut to thirdLayer.lowNoiseAmplifier.ampIn;
        flow from thirdLayer.lowNoiseAmplifier.ampOut to readoutOut;
    }

    part sfqReadoutSystem : classicalReadoutSystem {

        doc
        /*
         * Room-temperature readout electronics, together with the SFQ-dc
         * bias source for the readout chip. Drawn at the top right of
         * Fig. 5.
         *
         * Source: Fig. 5, p.8.
         */

        part lowNoiseAmplifier {
            port ampIn : ~microwavePort {
                out item item1;
            }
            port ampOut : microwavePort {
                in item item1;
            }
            perform sfqOperation.amplifyRoomTemperature;           // [Fig.5]
            flow from ampIn.item1 to amplifyRoomTemperature.weakSignal;
            flow from amplifyRoomTemperature.amplifiedSignal to ampOut.item1;
        }
        part readoutLocalOscillator : localOscillator {
            port carrierOut : microwavePort {
                in item item1;
            }
            perform sfqOperation.generateReadoutCarrier;           // [Fig.5]
            flow from generateReadoutCarrier.carrier to carrierOut.item1;
        }
        part readoutIqMixer : iqMixer {
            port rfIn : ~microwavePort {
                out item item1;
            }
            port loIn : ~microwavePort {
                out item item1;
            }
            port ifOut : microwavePort {
                in item item1;
            }
            perform sfqOperation.downconvertReadout;               // [Fig.5]
            flow from rfIn.item1 to downconvertReadout.waveform;
            flow from loIn.item1 to downconvertReadout.referenceCarrier;
            flow from downconvertReadout.baseband to ifOut.item1;
        }
        part readoutFilter {
            port filterIn : ~microwavePort {
                out item item1;
            }
            port filterOut : microwavePort {
                in item item1;
            }
            perform sfqOperation.filterReadout;                    // [Fig.5]
            flow from filterIn.item1 to filterReadout.unfiltered;
            flow from filterReadout.filtered to filterOut.item1;
        }
        part adc : analogToDigitalConverter {
            port analogIn : ~microwavePort {
                out item item1;
            }
            port digitalOut : digitalPort {
                in item item1;
            }
            perform sfqOperation.digitiseReadout;                  // [Fig.5]
            flow from analogIn.item1 to digitiseReadout.analogInput;
            flow from digitiseReadout.digitalOutput to digitalOut.item1;
        }
        part computerFpga {
            port resultIn : ~digitalPort {
                out item item1;
            }
            perform sfqOperation.decipherQubitState;               // [Fig.5]
            flow from resultIn.item1 to decipherQubitState.measurement;
        }
        part sfqDcBias : powerSource {
            doc
            /*
             * SFQ-dc bias source for the readout SFQ chip.
             *
             * Source: Fig. 5, p.8.
             */
            port biasOut : dcBiasPort {
                in item item1;
            }
            perform sfqOperation.provideSfqDcBias;
            flow from provideSfqDcBias.bias to biasOut.item1;
        }
        port readoutIn : ~microwavePort;
        port sfqDcBiasOut : dcBiasPort;
        flow from readoutIn to lowNoiseAmplifier.ampIn;
        flow from lowNoiseAmplifier.ampOut to readoutIqMixer.rfIn;
        flow from readoutLocalOscillator.carrierOut to readoutIqMixer.loIn;
        flow from readoutIqMixer.ifOut to readoutFilter.filterIn;
        flow from readoutFilter.filterOut to adc.analogIn;
        flow from adc.digitalOut to computerFpga.resultIn;
        flow from sfqDcBias.biasOut to sfqDcBiasOut;
    }

    flow from sfqControlSystem.triggerToneOut to dilutionRefrigeratorEnv.triggerToneIn;
    flow from sfqControlSystem.dcSfqBiasOut to dilutionRefrigeratorEnv.dcSfqBiasIn;
    flow from sfqReadoutSystem.sfqDcBiasOut to dilutionRefrigeratorEnv.sfqDcBiasIn;
    flow from dilutionRefrigeratorEnv.readoutOut to sfqReadoutSystem.readoutIn;
}
