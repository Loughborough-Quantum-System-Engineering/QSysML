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
//   [Fig.7]   = Fig. 7 schematic / legend, p.10

package OpticalInterface {

    doc
    /*
     * Electro-optical control and readout interface for a superconducting
     * qubit in a dilution refrigerator.
     *
     * The primary issue addressed by electro-optical techniques is heat
     * dissipation from coaxial cabling within the cryostat. The methods
     * split into two areas: encoding electrical signals onto the optical
     * domain, carried out by an electro-optical modulator exploiting the
     * Pockels effect in dielectric crystals, and recovery of the electrical
     * signal, carried out most simply by a photodiode.
     *
     * Full readout of superconducting qubits has been shown using
     * radio-over-fibre down to mK temperatures in an optical heterodyne
     * detection scheme, with simultaneous upconversion and downconversion
     * between microwave and optical frequencies, removing the requirement
     * for any active or passive cryogenic microwave equipment.
     *
     * Source: Brennan et al. 2025, section "Optical control and readout",
     * p.8 left column paragraph 3 through p.9 right column paragraph 1, and
     * the Fig. 7 schematic on p.10.
     */

    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import SuperconductingCommon::*;
    public import ISQ::*;
    public import SI::*;

    // =====================================================================
    // Action definitions
    // =====================================================================

    action def GenerateEnvelope {
        doc
        /*
         * Produce the low-frequency baseband envelope of the qubit drive
         * pulse.
         *
         * Source: AWG/FPGA in Fig. 7, p.10.
         */
        out item envelope : digitalData;
    }

    action def ConvertDigitalToAnalog {
        doc
        /*
         * Convert the digital waveform description into an analog signal.
         *
         * Source: DAC in Fig. 7, p.10.
         */
        in item digitalInput : digitalData;
        out item analogOutput : microwaveSignal;
    }

    action def GenerateCarrier {
        doc
        /*
         * Produce the high-frequency microwave carrier tone.
         *
         * Source: local oscillator in the Fig. 7 legend, p.10.
         */
        out item carrier : microwaveSignal;
    }

    action def Upconvert {
        doc
        /*
         * Mix the baseband signal with the microwave carrier.
         *
         * Source: IQ mixer in the Fig. 7 legend, p.10.
         */
        in item baseband : microwaveSignal;
        in item carrier : microwaveSignal;
        out item waveform : microwaveSignal;
    }

    action def Downconvert {
        doc
        /*
         * Mix the recovered readout signal back down to baseband. The
         * reference describes simultaneous upconversion and downconversion
         * between microwave and optical frequencies in an optical heterodyne
         * detection scheme.
         *
         * Source: p.9, right column, paragraph 1; IQ mixer in the Fig. 7
         * legend.
         */
        in item waveform : microwaveSignal;
        in item referenceCarrier : microwaveSignal;
        out item baseband : microwaveSignal;
    }

    action def FilterSignal {
        doc
        /*
         * Band-limit a signal. Typed against the general signal item so that
         * one definition serves the microwave lines and the photodiode bias
         * line.
         *
         * Source: filter in the Fig. 7 legend, p.10.
         */
        in item unfiltered : signal;
        out item filtered : signal;
    }

    action def GenerateOpticalCarrier {
        doc
        /*
         * Produce the coherent optical carrier onto which the electrical
         * signal is encoded. The laser power required to transmit
         * information effectively is set by the extinction ratio of the
         * modulator.
         *
         * Source: p.8 right column paragraph 1; p.9 left column paragraph 1;
         * laser source in the Fig. 7 legend.
         */
        out item opticalCarrier : opticalSignal;
    }

    action def EncodeOntoOptical {
        doc
        /*
         * Encode an electrical signal onto the optical domain. Encoding is
         * generally carried out by an electro-optical modulator, which takes
         * advantage of the Pockels effect in dielectric crystals. This
         * controls the optical path length of light propagating through the
         * electro-optic crystal and, in combination with optical waveguides,
         * allows the phase, intensity and polarization of coherent light to
         * be controlled.
         *
         * Which performance metric matters depends on where the modulator
         * sits. At room temperature a high extinction ratio is crucial,
         * because it minimises the laser power required; lithium niobate
         * intensity modulators have been tested with extinction ratios
         * upward of 20 dB. At cryogenic temperatures insertion losses, power
         * consumption and modulation efficiency must be considered instead,
         * because the first two determine the heat dissipated in the
         * cryogenic stage. Power consumption is strongly related to
         * electrode resistance, which can be greatly reduced by employing
         * superconducting electrodes.
         *
         * Source: p.8 left column paragraph 3; p.8 right column paragraph 1;
         * p.9 left column paragraphs 1 and 2.
         */
        in item electricalInput : microwaveSignal;
        in item opticalCarrier : opticalSignal;
        out item modulatedLight : opticalSignal;
        attribute extinctionRatio;                  // upward of 20 dB [p.9 LC para 1]
        attribute insertionLoss;                    // [p.9 LC para 2]
        attribute powerConsumption;                 // [p.9 LC para 2]
        attribute modulationEfficiency;             // [p.9 LC para 2]
    }

    action def ProvidePhotodiodeBias {
        doc
        /*
         * Supply the photodiode bias.
         *
         * Source: PD bias in Fig. 7; power source in the Fig. 7 legend, p.10.
         */
        out item bias : dcBias;
    }

    action def RecoverElectricalSignal {
        doc
        /*
         * Recover the electrical signal from intensity modulated light,
         * carried out most simply and directly by a photodiode. Photodiodes
         * can detect 1550 nm light at mK temperatures with a bandwidth of
         * tens of GHz, which is suitable for current superconducting qubit
         * measurements, and have been demonstrated to provide shot-noise
         * limited performance in an electro-optical control scheme.
         *
         * One drawback of commercially available photodiodes is the ubiquity
         * of 50 ohm output lines; a photodiode with higher output impedance
         * could achieve increased conversion gain and so decrease the
         * required laser power.
         *
         * Source: p.9, left column, paragraph 3.
         */
        in item modulatedLight : opticalSignal;
        in item bias : dcBias;
        out item electricalOutput : microwaveSignal;
        attribute detectionWavelength = 1.55E-6 [m];   // 1550 nm [p.9 LC para 3]
        attribute outputImpedance;                     // 50 ohm  [p.9 LC para 3]
        attribute bandwidth;                           // tens of GHz [p.9 LC para 3]
    }

    action def ManipulateQubitState {
        doc
        /*
         * Drive the qubit with the electrical signal recovered at the base
         * stage.
         *
         * Source: QPU in the Fig. 7 legend, p.10.
         */
        in item driveSignal : microwaveSignal;
        out item qubitResponse : microwaveSignal;
    }

    action def Amplify {
        doc
        /*
         * Boost the qubit readout signal before it is encoded onto the
         * optical domain. Fig. 7 places this amplifier at the base stage,
         * immediately ahead of the cryogenic modulator.
         *
         * Source: low-noise amplifier in the Fig. 7 legend, p.10.
         */
        in item weakSignal : microwaveSignal;
        out item amplifiedSignal : microwaveSignal;
    }

    action def ConvertAnalogToDigital {
        doc
        /*
         * Digitise the downconverted readout signal.
         *
         * Source: ADC in Fig. 7, p.10.
         */
        in item analogInput : microwaveSignal;
        out item digitalOutput : digitalData;
    }

    action def PostProcess {
        doc
        /*
         * Recover the qubit state from the digitised record.
         *
         * Source: Computer/FPGA in Fig. 7, p.10.
         */
        in item digitisedResponse : digitalData;
        out attribute qubitState;
    }

    // =====================================================================
    // End-to-end behaviour
    // =====================================================================
    action def OpticalControlAndReadout {

        doc
        /*
         * Sequence of the optical control and readout cycle as drawn in
         * Fig. 7 on p.10.
         *
         * On the drive side the microwave waveform is built at room
         * temperature, encoded onto a laser carrier by an electro-optical
         * modulator, carried into the refrigerator over fibre, and recovered
         * by a photodiode at the base stage. On the readout side the
         * response is amplified at the base stage, encoded onto a second
         * optical carrier by a cryogenic modulator, carried back out over
         * fibre, and recovered by a room-temperature photodiode before being
         * downconverted and digitised.
         *
         * Both optical carriers are generated at room temperature; the
         * readout carrier is sent down into the refrigerator to feed the
         * cryogenic modulator.
         *
         * This definition states ordering and the action-to-action item
         * chain. The physical routing of those items through ports is
         * modelled in the parts.
         *
         * Source: p.8 left column paragraph 3 through p.9 right column
         * paragraph 1, and Fig. 7.
         */

        out attribute measuredQubitState;

        // ---- drive chain ----
        action generateEnvelope : GenerateEnvelope;                // [Fig.7]
        action convertDriveToAnalog : ConvertDigitalToAnalog;      // [Fig.7]
        action generateDriveCarrier : GenerateCarrier;             // [Fig.7]
        action upconvertDrive : Upconvert;                         // [Fig.7]
        action filterDrive : FilterSignal;                         // [Fig.7]
        action generateDriveOpticalCarrier : GenerateOpticalCarrier; // [Fig.7]
        action encodeDriveOntoOptical : EncodeOntoOptical;         // [p.8 LC para 3]
        action provideDriveBias : ProvidePhotodiodeBias;           // [Fig.7]
        action filterDriveBias : FilterSignal;                     // [Fig.7]
        action recoverDriveSignal : RecoverElectricalSignal;       // [p.9 LC para 3]
        action manipulateQubitState : ManipulateQubitState;        // [Fig.7]

        // ---- readout chain ----
        action amplifyCryogenic : Amplify;                         // [Fig.7]
        action generateReadoutOpticalCarrier : GenerateOpticalCarrier; // [Fig.7]
        action encodeReadoutOntoOptical : EncodeOntoOptical;       // [p.9 RC para 1]
        action recoverReadoutSignal : RecoverElectricalSignal;     // [p.9 LC para 3]
        action filterReadout : FilterSignal;                       // [Fig.7]
        action generateReadoutCarrier : GenerateCarrier;           // [Fig.7]
        action downconvertReadout : Downconvert;                   // [p.9 RC para 1]
        action digitiseReadout : ConvertAnalogToDigital;           // [Fig.7]
        action decipherQubitState : PostProcess;                   // [Fig.7]

        // ---- control nodes ----
        fork initiate;
        join joinDriveMixer;
        join joinDriveModulator;
        join joinDrivePhotodiode;
        join joinReadoutModulator;
        join joinReadoutMixer;

        // ---- ordering ----
        first start then initiate;

        first initiate then provideDriveBias;                      // [Fig.7]
        first provideDriveBias then filterDriveBias;

        first initiate then generateEnvelope;                      // [Fig.7]
        first generateEnvelope then convertDriveToAnalog;
        first initiate then generateDriveCarrier;
        first convertDriveToAnalog then joinDriveMixer;
        first generateDriveCarrier then joinDriveMixer;
        first joinDriveMixer then upconvertDrive;
        first upconvertDrive then filterDrive;

        // the modulator needs the electrical signal and the optical carrier
        first initiate then generateDriveOpticalCarrier;           // [p.8 LC para 3]
        first filterDrive then joinDriveModulator;
        first generateDriveOpticalCarrier then joinDriveModulator;
        first joinDriveModulator then encodeDriveOntoOptical;

        // the photodiode needs the modulated light and its bias
        first encodeDriveOntoOptical then joinDrivePhotodiode;     // [p.9 LC para 3]
        first filterDriveBias then joinDrivePhotodiode;
        first joinDrivePhotodiode then recoverDriveSignal;
        first recoverDriveSignal then manipulateQubitState;

        // readout: amplify at the base stage, then encode onto optical
        first manipulateQubitState then amplifyCryogenic;          // [Fig.7]
        first initiate then generateReadoutOpticalCarrier;
        first amplifyCryogenic then joinReadoutModulator;
        first generateReadoutOpticalCarrier then joinReadoutModulator;
        first joinReadoutModulator then encodeReadoutOntoOptical;  // [p.9 RC para 1]
        first encodeReadoutOntoOptical then recoverReadoutSignal;
        first recoverReadoutSignal then filterReadout;
        first initiate then generateReadoutCarrier;
        first filterReadout then joinReadoutMixer;
        first generateReadoutCarrier then joinReadoutMixer;
        first joinReadoutMixer then downconvertReadout;
        first downconvertReadout then digitiseReadout;
        first digitiseReadout then decipherQubitState;
        first decipherQubitState then done;

        // ---- item chain ----
        flow from generateEnvelope.envelope to convertDriveToAnalog.digitalInput;
        flow from convertDriveToAnalog.analogOutput to upconvertDrive.baseband;
        flow from generateDriveCarrier.carrier to upconvertDrive.carrier;
        flow from upconvertDrive.waveform to filterDrive.unfiltered;
        flow from filterDrive.filtered to encodeDriveOntoOptical.electricalInput;
        flow from generateDriveOpticalCarrier.opticalCarrier to encodeDriveOntoOptical.opticalCarrier;
        flow from encodeDriveOntoOptical.modulatedLight to recoverDriveSignal.modulatedLight;
        flow from provideDriveBias.bias to filterDriveBias.unfiltered;
        flow from filterDriveBias.filtered to recoverDriveSignal.bias;
        flow from recoverDriveSignal.electricalOutput to manipulateQubitState.driveSignal;

        flow from manipulateQubitState.qubitResponse to amplifyCryogenic.weakSignal;
        flow from amplifyCryogenic.amplifiedSignal to encodeReadoutOntoOptical.electricalInput;
        flow from generateReadoutOpticalCarrier.opticalCarrier to encodeReadoutOntoOptical.opticalCarrier;
        flow from encodeReadoutOntoOptical.modulatedLight to recoverReadoutSignal.modulatedLight;
        flow from filterDriveBias.filtered to recoverReadoutSignal.bias;
        flow from recoverReadoutSignal.electricalOutput to filterReadout.unfiltered;
        flow from filterReadout.filtered to downconvertReadout.waveform;
        flow from generateReadoutCarrier.carrier to downconvertReadout.referenceCarrier;
        flow from downconvertReadout.baseband to digitiseReadout.analogInput;
        flow from digitiseReadout.digitalOutput to decipherQubitState.digitisedResponse;

        bind measuredQubitState = decipherQubitState.qubitState;
    }

    action opticalOperation : OpticalControlAndReadout;

    // =====================================================================
    // Structure
    // =====================================================================
    part opticalControlSystem : classicalControlSystem {

        doc
        /*
         * Room-temperature control electronics. The microwave drive waveform
         * is built conventionally and then encoded onto a laser carrier, so
         * that what enters the refrigerator is light rather than a coaxial
         * microwave signal.
         *
         * Source: Fig. 7, p.10; p.8 left column paragraph 3.
         */

        part controlAWGFPGA : awgFPGA {
            port envelopeOut : digitalPort {
                in item item1;
            }
            perform opticalOperation.generateEnvelope;             // [Fig.7]
            flow from generateEnvelope.envelope to envelopeOut.item1;
        }
        part dac : digitalToAnalogConverter {
            port digitalIn : ~digitalPort {
                out item item1;
            }
            port analogOut : microwavePort {
                in item item1;
            }
            perform opticalOperation.convertDriveToAnalog;         // [Fig.7]
            flow from digitalIn.item1 to convertDriveToAnalog.digitalInput;
            flow from convertDriveToAnalog.analogOutput to analogOut.item1;
        }
        part controlLocalOscillator : localOscillator {
            port carrierOut : microwavePort {
                in item item1;
            }
            perform opticalOperation.generateDriveCarrier;         // [Fig.7]
            flow from generateDriveCarrier.carrier to carrierOut.item1;
        }
        part controlIqMixer : iqMixer {
            port ifIn : ~microwavePort {
                out item item1;
            }
            port loIn : ~microwavePort {
                out item item1;
            }
            port rfOut : microwavePort {
                in item item1;
            }
            perform opticalOperation.upconvertDrive;               // [Fig.7]
            flow from ifIn.item1 to upconvertDrive.baseband;
            flow from loIn.item1 to upconvertDrive.carrier;
            flow from upconvertDrive.waveform to rfOut.item1;
        }
        part controlFilter {
            port filterIn : ~microwavePort {
                out item item1;
            }
            port filterOut : microwavePort {
                in item item1;
            }
            perform opticalOperation.filterDrive;                  // [Fig.7]
            flow from filterIn.item1 to filterDrive.unfiltered;
            flow from filterDrive.filtered to filterOut.item1;
        }
        part controlLaserSource {
            doc
            /*
             * Laser supplying the optical carrier for the drive modulator.
             *
             * Source: laser source in the Fig. 7 legend, p.10.
             */
            port carrierOut : opticalPort {
                in item item1;
            }
            perform opticalOperation.generateDriveOpticalCarrier;
            flow from generateDriveOpticalCarrier.opticalCarrier to carrierOut.item1;
        }
        part controlElectroOpticalModulator {
            doc
            /*
             * Electro-optical modulator encoding the microwave drive
             * waveform onto the laser carrier, exploiting the Pockels effect
             * in dielectric crystals. Sited at room temperature, where a
             * high extinction ratio is the metric that matters.
             *
             * Source: p.8 left column paragraph 3; p.8 right column
             * paragraph 1; EOM in the Fig. 7 legend.
             */
            port rfIn : ~microwavePort {
                out item item1;
            }
            port carrierIn : ~opticalPort {
                out item item1;
            }
            port modulatedOut : opticalPort {
                in item item1;
            }
            perform opticalOperation.encodeDriveOntoOptical;
            flow from rfIn.item1 to encodeDriveOntoOptical.electricalInput;
            flow from carrierIn.item1 to encodeDriveOntoOptical.opticalCarrier;
            flow from encodeDriveOntoOptical.modulatedLight to modulatedOut.item1;
        }
        part pdBias : powerSource {
            doc
            /*
             * Photodiode bias source, feeding the bias line that runs into
             * the refrigerator.
             *
             * Source: PD bias in Fig. 7, p.10.
             */
            port biasOut : dcBiasPort {
                in item item1;
            }
            perform opticalOperation.provideDriveBias;
            flow from provideDriveBias.bias to biasOut.item1;
        }
        port driveOpticalOut : opticalPort;
        port pdBiasOut : dcBiasPort;
        flow from controlAWGFPGA.envelopeOut to dac.digitalIn;
        flow from dac.analogOut to controlIqMixer.ifIn;
        flow from controlLocalOscillator.carrierOut to controlIqMixer.loIn;
        flow from controlIqMixer.rfOut to controlFilter.filterIn;
        flow from controlFilter.filterOut to controlElectroOpticalModulator.rfIn;
        flow from controlLaserSource.carrierOut to controlElectroOpticalModulator.carrierIn;
        flow from controlElectroOpticalModulator.modulatedOut to driveOpticalOut;
        flow from pdBias.biasOut to pdBiasOut;
    }

    part dilutionRefrigeratorEnv : dilutionRefrigerator {

        doc
        /*
         * Dilution refrigerator. Because the drive and readout lines are
         * optical fibre rather than coaxial cable, the intermediate stages
         * carry no attenuators; only the photodiode bias line has a filter,
         * at the 4 K plate. The base stage holds the drive photodiode, the
         * qubit, the amplifier and the cryogenic modulator.
         *
         * Operating the modulator at cryogenic temperatures makes insertion
         * loss and power consumption the dominant metrics, since both relate
         * to the heat dissipated in the cryogenic stage, and coupling the
         * optical fibre mode to the waveguide mode is complicated by the
         * thermal stresses of cooling to mK temperatures.
         *
         * Source: p.9 left column paragraph 2; Fig. 7, p.10.
         */

        port driveOpticalIn : ~opticalPort;
        port pdBiasIn : ~dcBiasPort;
        port readoutCarrierIn : ~opticalPort;
        port readoutOpticalOut : opticalPort;

        part firstLayer {
            attribute temp : ThermodynamicTemperatureUnit = 300 [K];
        }
        part secondLayer {
            attribute temp : ThermodynamicTemperatureUnit = 50 [K];
        }
        part thirdLayer {
            attribute temp : ThermodynamicTemperatureUnit = 4 [K];
            part biasFilter {
                doc
                /*
                 * Filter on the photodiode bias line at the 4 K plate.
                 *
                 * Source: Fig. 7, p.10.
                 */
                port filterIn : ~dcBiasPort {
                    out item item1;
                }
                port filterOut : dcBiasPort {
                    in item item1;
                }
                perform opticalOperation.filterDriveBias;
                flow from filterIn.item1 to filterDriveBias.unfiltered;
                flow from filterDriveBias.filtered to filterOut.item1;
            }
        }
        part fourthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.8 [K];
        }
        part fifthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.1 [K];
        }
        part sixthLayer {
            attribute temp : ThermodynamicTemperatureUnit = 0.01 [K];

            part controlPhotodiode {
                doc
                /*
                 * Photodiode recovering the electrical drive signal from the
                 * intensity modulated light at the base stage.
                 *
                 * Source: p.9 left column paragraph 3; photodiode in the
                 * Fig. 7 legend.
                 */
                port opticalIn : ~opticalPort {
                    out item item1;
                }
                port biasIn : ~dcBiasPort {
                    out item item1;
                }
                port rfOut : microwavePort {
                    in item item1;
                }
                perform opticalOperation.recoverDriveSignal;
                flow from opticalIn.item1 to recoverDriveSignal.modulatedLight;
                flow from biasIn.item1 to recoverDriveSignal.bias;
                flow from recoverDriveSignal.electricalOutput to rfOut.item1;
            }
            part qpu : QPU {
                doc
                /*
                 * Quantum processing unit. Modelled as a black box so that
                 * only the classical interface is in scope.
                 *
                 * Source: QPU in the Fig. 7 legend, p.10.
                 */
                attribute redefines technology = qubitTechnology::superconducting;
                port driveIn : ~microwavePort {
                    out item item1;
                }
                port readoutOut : microwavePort {
                    in item item1;
                }
                perform opticalOperation.manipulateQubitState;
                flow from driveIn.item1 to manipulateQubitState.driveSignal;
                flow from manipulateQubitState.qubitResponse to readoutOut.item1;
            }
            part lowNoiseAmplifier {
                doc
                /*
                 * Amplification stage at the base plate, ahead of the
                 * cryogenic modulator.
                 *
                 * Source: low-noise amplifier in the Fig. 7 legend, p.10.
                 */
                port ampIn : ~microwavePort {
                    out item item1;
                }
                port ampOut : microwavePort {
                    in item item1;
                }
                perform opticalOperation.amplifyCryogenic;
                flow from ampIn.item1 to amplifyCryogenic.weakSignal;
                flow from amplifyCryogenic.amplifiedSignal to ampOut.item1;
            }
            part readoutElectroOpticalModulator {
                doc
                /*
                 * Cryogenic electro-optical modulator encoding the amplified
                 * qubit response onto the readout optical carrier, so that
                 * the signal leaves the refrigerator over fibre. Operating at
                 * cryogenic temperature makes insertion loss and power
                 * consumption the dominant metrics; power consumption is
                 * strongly related to electrode resistance and can be greatly
                 * reduced with superconducting electrodes.
                 *
                 * Source: p.9 left column paragraph 2; p.9 right column
                 * paragraph 1; EOM in the Fig. 7 legend.
                 */
                port rfIn : ~microwavePort {
                    out item item1;
                }
                port carrierIn : ~opticalPort {
                    out item item1;
                }
                port modulatedOut : opticalPort {
                    in item item1;
                }
                perform opticalOperation.encodeReadoutOntoOptical;
                flow from rfIn.item1 to encodeReadoutOntoOptical.electricalInput;
                flow from carrierIn.item1 to encodeReadoutOntoOptical.opticalCarrier;
                flow from encodeReadoutOntoOptical.modulatedLight to modulatedOut.item1;
            }
            flow from controlPhotodiode.rfOut to qpu.driveIn;
            flow from qpu.readoutOut to lowNoiseAmplifier.ampIn;
            flow from lowNoiseAmplifier.ampOut to readoutElectroOpticalModulator.rfIn;
        }
        flow from driveOpticalIn to sixthLayer.controlPhotodiode.opticalIn;
        flow from pdBiasIn to thirdLayer.biasFilter.filterIn;
        flow from thirdLayer.biasFilter.filterOut to sixthLayer.controlPhotodiode.biasIn;
        flow from readoutCarrierIn to sixthLayer.readoutElectroOpticalModulator.carrierIn;
        flow from sixthLayer.readoutElectroOpticalModulator.modulatedOut to readoutOpticalOut;
    }

    part opticalReadoutSystem : classicalReadoutSystem {

        doc
        /*
         * Room-temperature readout electronics. Supplies the optical carrier
         * that feeds the cryogenic modulator, then recovers, downconverts
         * and digitises the returning optical signal.
         *
         * Source: Fig. 7, p.10; p.9 right column paragraph 1.
         */

        part readoutLaserSource {
            doc
            /*
             * Laser supplying the optical carrier for the cryogenic readout
             * modulator. The instrument sits at room temperature while its
             * carrier travels down into the refrigerator.
             *
             * Source: laser source in the Fig. 7 legend, p.10.
             */
            port carrierOut : opticalPort {
                in item item1;
            }
            perform opticalOperation.generateReadoutOpticalCarrier;
            flow from generateReadoutOpticalCarrier.opticalCarrier to carrierOut.item1;
        }
        part readoutPhotodiode {
            doc
            /*
             * Photodiode recovering the electrical readout signal from the
             * returning modulated light.
             *
             * Source: p.9 left column paragraph 3; photodiode in the Fig. 7
             * legend.
             */
            port opticalIn : ~opticalPort {
                out item item1;
            }
            port biasIn : ~dcBiasPort {
                out item item1;
            }
            port rfOut : microwavePort {
                in item item1;
            }
            perform opticalOperation.recoverReadoutSignal;
            flow from opticalIn.item1 to recoverReadoutSignal.modulatedLight;
            flow from biasIn.item1 to recoverReadoutSignal.bias;
            flow from recoverReadoutSignal.electricalOutput to rfOut.item1;
        }
        part readoutFilter {
            port filterIn : ~microwavePort {
                out item item1;
            }
            port filterOut : microwavePort {
                in item item1;
            }
            perform opticalOperation.filterReadout;                // [Fig.7]
            flow from filterIn.item1 to filterReadout.unfiltered;
            flow from filterReadout.filtered to filterOut.item1;
        }
        part readoutLocalOscillator : localOscillator {
            port carrierOut : microwavePort {
                in item item1;
            }
            perform opticalOperation.generateReadoutCarrier;       // [Fig.7]
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
            perform opticalOperation.downconvertReadout;           // [p.9 RC para 1]
            flow from rfIn.item1 to downconvertReadout.waveform;
            flow from loIn.item1 to downconvertReadout.referenceCarrier;
            flow from downconvertReadout.baseband to ifOut.item1;
        }
        part adc : analogToDigitalConverter {
            port analogIn : ~microwavePort {
                out item item1;
            }
            port digitalOut : digitalPort {
                in item item1;
            }
            perform opticalOperation.digitiseReadout;              // [Fig.7]
            flow from analogIn.item1 to digitiseReadout.analogInput;
            flow from digitiseReadout.digitalOutput to digitalOut.item1;
        }
        part computerFpga {
            port resultIn : ~digitalPort {
                out item item1;
            }
            perform opticalOperation.decipherQubitState;           // [Fig.7]
            flow from resultIn.item1 to decipherQubitState.digitisedResponse;
        }
        port readoutCarrierOut : opticalPort;
        port readoutOpticalIn : ~opticalPort;
        port readoutBiasIn : ~dcBiasPort;
        flow from readoutLaserSource.carrierOut to readoutCarrierOut;
        flow from readoutOpticalIn to readoutPhotodiode.opticalIn;
        flow from readoutBiasIn to readoutPhotodiode.biasIn;
        flow from readoutPhotodiode.rfOut to readoutFilter.filterIn;
        flow from readoutFilter.filterOut to readoutIqMixer.rfIn;
        flow from readoutLocalOscillator.carrierOut to readoutIqMixer.loIn;
        flow from readoutIqMixer.ifOut to adc.analogIn;
        flow from adc.digitalOut to computerFpga.resultIn;
    }

    flow from opticalControlSystem.driveOpticalOut to dilutionRefrigeratorEnv.driveOpticalIn;
    flow from opticalControlSystem.pdBiasOut to dilutionRefrigeratorEnv.pdBiasIn;
    // the shared photodiode bias also feeds the room-temperature photodiode [Fig.7]
    flow from opticalControlSystem.pdBiasOut to opticalReadoutSystem.readoutBiasIn;
    flow from opticalReadoutSystem.readoutCarrierOut to dilutionRefrigeratorEnv.readoutCarrierIn;
    flow from dilutionRefrigeratorEnv.readoutOpticalOut to opticalReadoutSystem.readoutOpticalIn;
}
