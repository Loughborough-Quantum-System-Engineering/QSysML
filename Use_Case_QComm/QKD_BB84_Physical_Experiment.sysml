package QKD_BB84_Physical_Experiment {
    doc
    /* a stable transmitter–receiver arrangement for polarization-encoded BB84 over a fiber channel.
     * The paper states that the setup is divided into transmitter (Alice), channel, and receiver (Bob), and that the transmitter
     * is responsible for the preparation side of the experiment. It also explains that a typical transmitter consists of a laser diode,
     * intensity modulator, and polarization-encoding modulator. The channel is named as one of the three main parts, and 
     * the paper explains that it introduces environmental disturbances that require compensation at the receiver. It is also tested
     * as a fiber spool up to 75 km. But the channel itself is not decomposed further.
     */
    public import QSysML::**;
    public import QSysML::BlackBox::**;
    view BlackView : PhysicalBlackView {
        part BB84_Physical_Black : QKDSystem {
            part Alice : sender {
                action sendQubits;
                port QC {
                    out item Polarisedphotons : Qubits;
                    in item item1;
                }
                port CC {
                    in item photons : Bits;
                }
            }
            part Bob : receiver {
                action detectQubits;
                port QC {
                    in item Polarisedphotons : Qubits;
                    out item item1;
                }
                port CC {
                    out item photons : Bits;
                }
            }
            item Polarisedphotons : Qubits {
                attribute Stability : ScalarValues::Real, duration;
                attribute SKR : ScalarValues::Real;
                attribute QBER : ScalarValues::Real;
                attribute SNR : ScalarValues::Real;
                exhibit state idle;
                exhibit state polarised;
                exhibit state attenuated;
                exhibit state transmitted;
                exhibit state analysed;
                exhibit state detected;
            }
            connection QChannel : channel connect BlackView::BB84_Physical_Black::Alice.QC to BlackView::BB84_Physical_Black::Bob.QC {
                flow BlackView::BB84_Physical_Black::Alice.QC.Polarisedphotons to BlackView::BB84_Physical_Black::Bob.QC.Polarisedphotons;
                attribute attenuation : Real;
                attribute distance : Real;
                exhibit state idle;
                exhibit state occupied;
            }
            connection CChannel : channel connect BlackView::BB84_Physical_Black::Bob.CC to BlackView::BB84_Physical_Black::Alice.CC {
                flow BlackView::BB84_Physical_Black::Bob.CC.photons to BlackView::BB84_Physical_Black::Bob.CC.photons;
                attribute delay : Real;
                exhibit state idle;
                exhibit state occupied;
            }
        }
    }
    view WhiteView : PhysicalWhiteView {
        part BB84_Physical_White :>> BlackView::BB84_Physical_Black : QKDSystem {
            action generateKey {
                action generatePulse;
                action modulateIntensity;
                action splitLight;
                action adjustPhase;
                action preparePolarisationState;
                action attenuateSingle_PhotonLevel;
                action splitGeneratedPhotons {
                    fork BS;
                }
                action checkGeneratedQubit;
                action compensateChannelDisturbances;
                action detectPhotons;
                action recordDetectionEvents;
                action analyzePolarisationStates;
                action setMeasurementProbabilities;
                action routeOutputs_to_detectors;
                first start then generatePulse;
                first generatePulse then splitLight;
                first splitLight then modulateIntensity;
                first modulateIntensity then adjustPhase;
                first adjustPhase then preparePolarisationState;
                first preparePolarisationState then attenuateSingle_PhotonLevel;
                first attenuateSingle_PhotonLevel then splitGeneratedPhotons;
                first splitGeneratedPhotons then splitGeneratedPhotons::BS;
                first splitGeneratedPhotons::BS then checkGeneratedQubit;
                first splitGeneratedPhotons::BS then compensateChannelDisturbances;
                first compensateChannelDisturbances then setMeasurementProbabilities;
                first setMeasurementProbabilities then analyzePolarisationStates;
                first analyzePolarisationStates then routeOutputs_to_detectors;
                first routeOutputs_to_detectors then detectPhotons;
                first detectPhotons then recordDetectionEvents;
                first recordDetectionEvents then done;
            }
            perform generateKey;
            part LaserDiode :> Alice : Source::weakCoherentSource {
                doc /* The paper explicitly states that the LD generates phase-randomized pulses at 50 MHz with 200 ps pulse width. */
                attribute frequency : Real, Hz;
                attribute pulseWidth : Real, s;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.generatePulse;
            }
            part Sagnac_Intensity_Modulator :> Alice : encoder {
                doc
                /* The Sagnac effect, also known as Sagnac interference, is a phenomenon observed in rotating systems 
                 * where two beams of light traveling in opposite directions along a closed path experience a phase shift
                 * due to the rotation of the system. This effect was first observed by French physicist Georges Sagnac in 1913.
                 * This part is a Sagnac IM :an intensity modulator for decoy-state modulation, using common-path interference. */
                part BS1 : BeamSplitter;
                part PhaseModulator1;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.modulateIntensity;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.splitLight;
                attribute signal_to_decoyIntensityRatio {
                    doc /* first what is the intensity of the pulse should be, then decide which polarization qubit state it should carry. */
                }
            }
            part Sagnac_Polarisation :> Alice : encoder::polarisationEncoding {
                doc
                /* Sagnac POL :A polarization encoding modulator is a device that manipulates the polarization state of light 
                 * to encode information or enhance the interaction between light and matter. The paper says it is the polarization modulator,
                 * explains its main internal constituents, explains the 45° aligned polarizing input and orthogonal linear polarizers, and 
                 * shows the output state equation and how it produces the four BB84 polarization states.*/
                part PolarizationModule;
                part PhaseModulator2;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.adjustPhase;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.preparePolarisationState;
            }
            part variableOpticalAttenuator :> Alice : transmitter {
                doc /* VOA: Subsequently, the pulses are attenuated to a single photon level with the help of a controllable device that reduces optical signal power*/
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.attenuateSingle_PhotonLevel;
            }
            part BS2 :> Alice : BeamSplitter, transmitter {
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.splitGeneratedPhotons;
            }
            part SPD1 :> Alice : singlePhotonDetector {
                doc /* SinglePhoton Detector: The paper doesn't explicity describe this but it could be to evaluate the transmitted signal as a monitor*/
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.checkGeneratedQubit;
            }
            part polarizationController :> Bob [1..1] {
                doc /* The PC is used for actively compensating the disturbances induced from the channel before the pulse enters the analysis module. */
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.compensateChannelDisturbances;
                attribute Loss : Real, dB;
            }
            part polarizationAnalysisModule :> Bob : decoder {
                doc
                /* PAM: The paper emphasizes that this module is designed so that the measurement bases are inherently aligned,
                 * which improves stability and simplifies control. */
                part BS2 : BeamSplitter {
                    doc /* contribute to the basis measurement probabilities, tailored to 90:10 that means Pz=0.9 and Px =0.1 */
                }
                part PBSs : BeamSplitter [2..1] {
                    doc
                    /* a BS feeding two PBS branches, with one vertical aligned branch and the other marked at 45° (Polarised beam splitters),
                     * each with 2 outputs routed to 4 SPDs */
                }
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.analyzePolarisationStates;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.setMeasurementProbabilities;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.routeOutputs_to_detectors;
            }
            part SPD :> Bob : singlePhotonDetector [4..1] {
                doc
                /* the outputs of the PBSs are detected by four InGaAs single-photon detectors, and it gives their physical characteristics:
                 * 10% efficiency, ~400 Hz dark count, 1 ns gate width. */
                attribute frequency : Real, Hz;
                attribute gateWidth : Real, s;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.detectPhotons;
            }
            part timeConcerter :> Bob {
                doc
                /* the detections are recorded by the time-to-digital converter (quTAG100). TDC needs a timing resolution
                 * much smaller than that (the quTAG100 typically has a resolution around 10–25 ps).*/
                attribute timeResolution : Real, s;
                perform QKD_BB84_Physical_Experiment::WhiteView::BB84_Physical_White::generateKey.recordDetectionEvents;
            }
        }
    }
    view CatView : PhysicalCatView {
        part BB84_Physical_Cat :>> BlackView::BB84_Physical_Black : QKDSystem {
            part weakCoherentSource :> Alice : Source {
                perform action generatePulse;
                first Actions::Action::start then generatePulse;
            }
            part polariser :> Alice : encoder {
                perform action polarsiePhotons;
            }
            part emitter :> Alice : transmitter {
                perform action emitPolarisedPhotons;
            }
            part polariser :> Bob : decoder {
                action analysePolarisedPhotons {
                    perform action compensatePolarisationDisturbance;
                    perform action selectMeasurementBasis;
                    first start then compensatePolarisationDisturbance;
                    first compensatePolarisationDisturbance then selectMeasurementBasis;
                }
                first analysePolarisedPhotons::compensatePolarisationDisturbance then analysePolarisedPhotons::selectMeasurementBasis;
            }
            part Detector :> Bob : singlePhotonDetector {
                perform action Click;
                perform action recordDetectionTime;
                first start then Click;
                first Click then recordDetectionTime;
                first recordDetectionTime then Actions::Action::done;
                first Actions::Action::start then Click;
            }
        }
    }
}
