// reference
// @article{lekitsch2017blueprint,
//   title={Blueprint for a microwave trapped ion quantum computer},
//   author={Lekitsch, Bjoern and Weidt, Sebastian and Fowler, Austin G and M{\o}lmer, Klaus and Devitt, Simon J and Wunderlich, Christof and Hensinger, Winfried K},
//   journal={Science Advances},
//   volume={3},
//   number={2},
//   pages={e1601540},
//   year={2017},
//   publisher={American Association for the Advancement of Science}
// }
//
// Provenance notation used in line comments:
//   [p.N LC]  = page N, left  column   (para k = k-th paragraph of that column)
//   [p.N RC]  = page N, right column
//   [Fig.1A]  = Fig. 1A X-junction with multiple zones, p.3
//   [Fig.2A]  = Fig. 2A gradient wires under the gate zone, p.4
//   [Fig.2B]  = Fig. 2B embedded silicon photodetector, p.4

package MicrowaveTrappedIonInterface {

    doc
    /*
     * Microwave-driven control and readout interface for a trapped ion
     * quantum computer module, based on long-wavelength radiation and static
     * magnetic field gradients rather than individually addressed laser
     * beams.
     *
     * Coupling between the internal states of trapped ions and their motion
     * is vanishingly small for free-running microwaves because of the
     * centimetre wavelength, and so is not useful on its own for multiqubit
     * gates. Adding a static magnetic field gradient exerts a force on the
     * magnetic moment associated with the qubit states, which makes
     * multiqubit gates possible. The correlation between the number of ions
     * and the number of required gate radiation fields then vanishes, so
     * that instead of thousands or millions of individually controllable
     * fields, only a handful of global microwave fields are needed,
     * independent of the number of ions.
     *
     * Each X-junction features up to three zones: a microwave gate zone, a
     * state readout zone, and a loading zone. Laser light is required only
     * for state preparation and detection, photoionization, and sympathetic
     * cooling, and those beams need be neither intense nor phase-stable.
     *
     * Source: Lekitsch et al. 2017, p.2 right column through p.5 right
     * column, with Figs. 1 and 2.
     *
     * Units: prefixed unit symbols are not recognised, so quantities are
     * expressed in SI base units with a scaled literal, and the value as
     * printed in the reference is restated in the documentation of the
     * owning element.
     */

    public import QuantumComputing::physicalLayerDefinitions::*;
    public import CommonInstruments::*;
    public import AtomicCommon::*;
    public import ISQ::*;
    public import SI::*;

    // =====================================================================
    // Action definitions
    // =====================================================================

    action def GenerateGlobalMicrowaveField {
        doc
        /*
         * Generate the microwave frequencies for the global radiation
         * fields. These are produced by commercial frequency generators.
         *
         * Only a fixed number of gate radiation fields are needed,
         * independent of the number of ions, which is what removes the need
         * for thousands or millions of individually controllable fields.
         *
         * Source: p.4, right column, paragraph 1; p.4, left column,
         * paragraph 2.
         */
        out item tone : microwaveSignal;
    }

    action def AmplifyMicrowave {
        doc
        /*
         * Supply the microwave signal with sufficient amplitude to drive the
         * emitters inside the system.
         *
         * Source: p.4, right column, paragraph 1.
         */
        in item weakSignal : microwaveSignal;
        out item amplifiedSignal : microwaveSignal;
    }

    action def RadiateGlobalField {
        doc
        /*
         * Radiate a global long-wavelength field into the vacuum chamber.
         * Only a handful of global microwave fields are required, originating
         * from emitters placed periodically within the vacuum chambers, to
         * implement the required quantum logic on arbitrarily many ions.
         *
         * Source: p.4, left column, paragraph 2.
         */
        in item feed : microwaveSignal;
        out item globalField : microwaveSignal;
    }

    action def GenerateRfTrapDrive {
        doc
        /*
         * Generate the radio-frequency drive that forms the trapping
         * pseudopotential. All resonators are attached to the same frequency
         * source.
         *
         * Source: p.5, right column, paragraph 1; Fig. 1C caption, p.3.
         */
        out item rfDrive : microwaveSignal;
        attribute driveFrequency = 25.0E6 [Hz];     // 25 MHz  [Fig.1C caption]
        attribute driveVoltage = 200.0 [V];         // 200 V   [Fig.1C caption]
    }

    action def ResonateRfDrive {
        doc
        /*
         * Raise the rf drive to the voltage required at the trap electrodes
         * using a compact helical resonator. Connecting 6 by 6 junctions into
         * one electrical submodule keeps the capacitance below 80 pF, and a
         * quality factor above 200 is achievable with a resonator around
         * 15 mm in diameter. The resonant circuits are tuned into resonance
         * with the frequency source using tuning capacitors.
         *
         * Source: p.5, right column, paragraph 1.
         */
        in item rfIn : microwaveSignal;
        out item rfOut : microwaveSignal;
        attribute qualityFactor;                    // > 200   [p.5 RC para 1]
        attribute submoduleCapacitance;             // < 80 pF [p.5 RC para 1]
    }

    action def IssueControlCommand {
        doc
        /*
         * Issue the digital commands that drive the in-vacuum converters and
         * the detection system. An additional wafer layer houses an
         * electronic control unit for this purpose.
         *
         * Source: p.5, right column, paragraph 1.
         */
        out item command : digitalData;
    }

    action def GenerateLaserBeam {
        doc
        /*
         * Produce one of the laser beams required by the architecture. Laser
         * light is needed only for state preparation and detection,
         * photoionization, and sympathetic cooling. The beams have much less
         * stringent requirements than those used for laser-driven gates: they
         * need not be intense or phase-stable, and the mode profile need only
         * overlap the ion enough to scatter sufficient photons. Sympathetic
         * cooling beams can even be delivered as sheets.
         *
         * Source: p.2, right column, paragraph 3.
         */
        out item beam : opticalSignal;
    }

    action def SteerLaserBeam {
        doc
        /*
         * Steer the global laser beams so that they address only the
         * intended zones. The beams are steered parallel to and between the
         * gate zone arms, which are separated by 2.5 mm, so that only ions in
         * the readout zones are illuminated. The required accuracy is readily
         * achieved with in-vacuum optics.
         *
         * State readout is performed many times during error-corrected
         * logical qubit operations, so keeping the illumination off the gate
         * zones is what preserves the state of the physical qubits that are
         * not being measured.
         *
         * Source: p.5, left column, paragraph 2.
         */
        in item beams : opticalSignal;
        out item steeredBeams : opticalSignal;
        attribute gateZoneArmSeparation = 2.5E-3 [m];   // 2.5 mm [p.5 LC para 2]
    }

    action def ConvertToAnalogDrive {
        doc
        /*
         * Convert the digital command stream into the analog currents and
         * voltages applied inside the vacuum system. The on-chip control
         * electronics is based on digital-to-analog converters that control
         * the currents applied to the very low inductance coils, with 16-bit
         * precision and an update rate above 1 MHz.
         *
         * Each electrical submodule features 1224 static voltage electrodes
         * and 108 individual local gradient current wires; the converters are
         * fabricated on separate silicon substrates attached to the ion trap
         * substrate using through-silicon via and wafer-stacking technology.
         *
         * Source: p.4, right column, paragraph 1; p.5, right column,
         * paragraph 1.
         */
        in item command : digitalData;
        out item coilCurrent : dcBias;
        out item electrodeVoltage : dcBias;
        attribute precision;                        // 16 bit   [p.4 RC para 1]
        attribute updateRate = 1.0E6 [Hz];          // > 1 MHz  [p.4 RC para 1]
        attribute staticVoltageElectrodeCount;      // 1224     [p.5 RC para 1]
        attribute gradientWireCount;                // 108      [p.5 RC para 1]
    }

    action def FilterElectrodeVoltage {
        doc
        /*
         * Filter the electrode voltage line inside the vacuum system.
         * Resistor-capacitor filters are combined with the converters and the
         * through-silicon via structures on the stacked wafer layers.
         *
         * Source: p.5, right column, paragraph 1.
         */
        in item unfiltered : dcBias;
        out item filtered : dcBias;
    }

    action def GenerateFieldGradient {
        doc
        /*
         * Generate the large static magnetic field gradient used for fast,
         * high-fidelity microwave gates, using current-carrying wires
         * embedded in the silicon substrate.
         *
         * During shuttling operations the gradient can be turned off,
         * removing the requirement to shuttle ions through large magnetic
         * fields. The gradient wires have an impedance on the order of
         * 10 microhenry, which allows ramp-up and ramp-down times on the
         * order of 5 microseconds.
         *
         * Source: p.4, left column, paragraph 1; p.4, right column,
         * paragraph 3; Fig. 2A.
         */
        in item current : dcBias;
        out item gradient : magneticField;
        attribute gradientStrength;                 // 150 T/m at the ion [p.4 LC para 1]
        attribute wireCurrent = 10.0 [A];           // ~10 A   [p.4 LC para 1]
        attribute ionHeight = 100.0E-6 [m];         // 100 um  [p.4 LC para 1]
        attribute wireInductance = 10.0E-6 [H];     // ~10 uH  [p.4 RC para 3]
        attribute rampTime = 5.0E-6 [s];            // ~5 us   [p.4 RC para 3]
    }

    action def AdjustLocalMagneticField {
        doc
        /*
         * Shift the qubit frequency in and out of resonance with the global
         * radiation fields, using local B-field coils placed underneath each
         * gate zone. The architecture already carries these local offset
         * coils to adjust the field in each gate zone and to compensate slow
         * variations of the global magnetic field, so they are also used for
         * the resonance shift rather than shuttling the ion along the
         * gradient.
         *
         * Source: p.4, left column, paragraphs 3 and 4; p.4, right column,
         * paragraph 1; Fig. 2A.
         */
        in item current : dcBias;
        out item offsetField : magneticField;
        attribute coilInductance = 25.0E-9 [H];     // ~25 nH  [p.4 RC para 1]
    }

    action def ApplyElectrodeVoltage {
        doc
        /*
         * Place the ion precisely within the static magnetic field gradient
         * during gate operations, using highly stable and precise voltages
         * applied to the appropriate electrodes in the gate zones. For
         * shuttling operations these voltages are overridden by the fast
         * control system through a summing amplification circuit.
         *
         * Source: p.4, right column, paragraph 2.
         */
        in item voltage : dcBias;
        out item electrodePotential : dcBias;
        attribute voltageStability = 50.0E-6 [V];   // better than 50 uV [p.4 RC para 2]
    }

    action def ShuttleIon {
        doc
        /*
         * Transport an ion between the loading, gate and readout zones of the
         * X-junction. High-fidelity shuttling through junctions requires a
         * highly optimized electrode geometry, combined with static voltage
         * electrodes designed for fast and efficient shuttling and
         * separation.
         *
         * Decoherence that would be caused by transferring ions through the
         * strong magnetic field gradients is avoided by globally turning off
         * the gradient fields during shuttling.
         *
         * Source: p.3, left column, paragraphs 1 and 2; p.2, right column,
         * paragraph 3; Fig. 1A.
         */
        in item electrodePotential : dcBias;
        attribute cycleTime = 235.0E-6 [s];         // ~235 us [p.3 LC para 1]
        attribute rfBarrier;                        // ~0.15 meV [p.3 LC para 1]
        attribute trapDepth;                        // ~80 meV   [p.3 LC para 1]
    }

    action def PerformQuantumGate {
        doc
        /*
         * Perform single- and multiqubit gates in the gate zone. The gate
         * zones perform all quantum operations, controlled by in-vacuum
         * electronics and powered by the global long-wavelength radiation
         * fields, with the ions individually addressed by the locally
         * adjustable magnetic fields and entangled using the static gradient
         * in conjunction with the global microwave and rf fields.
         *
         * Source: p.4, right column, paragraph 1; p.2, right column,
         * paragraph 3.
         */
        in item globalField : microwaveSignal;
        in item gradient : magneticField;
        in item offsetField : magneticField;
        in item electrodePotential : dcBias;
        in item trapDrive : microwaveSignal;
        out item fluorescence : opticalSignal;
    }

    action def LoadIon {
        doc
        /*
         * Load an ion into the trap, or replace a lost one. Backside loading
         * zones require a global ionization laser beam in combination with an
         * atomic flux originating from the back of the substrate, the flux
         * being generated by an atomic oven passing through slots fabricated
         * into the silicon substrate.
         *
         * When an ion is lost from a position within a module, a new ion is
         * trapped and all ions between the lost position and the loading zone
         * are shifted by one position, requiring only single-shuttling
         * sequences.
         *
         * Source: p.3, right column, paragraph 2; p.4, left column,
         * paragraph 1.
         */
        in item ionisationBeam : opticalSignal;
    }

    action def CoolIon {
        doc
        /*
         * Sympathetically cool the qubit ion using a second ion species, so
         * that the internal states of the qubit are not affected.
         *
         * Source: p.2, right column, paragraph 3.
         */
        in item coolingBeam : opticalSignal;
    }

    action def PrepareState {
        doc
        /*
         * Prepare the initial internal state of the ion using laser light.
         *
         * Source: p.2, right column, paragraph 3.
         */
        in item statePrepBeam : opticalSignal;
    }

    action def TransmitFluorescence {
        doc
        /*
         * Pass the light emitted by an ion in the readout zone through the
         * segmented electrodes to the detector below. The centre segmented
         * electrodes in the readout zone are made of indium tin oxide rather
         * than gold, which is ultraviolet transparent at about 80%
         * transmission and so lets the emitted light through.
         *
         * Source: p.4, right column, paragraph 4; Fig. 2B.
         */
        in item emittedLight : opticalSignal;
        out item transmittedLight : opticalSignal;
        attribute uvTransmission;                   // ~80 %   [p.4 RC para 4]
    }

    action def CountPhotons {
        doc
        /*
         * Count the transmitted photons on a photodetector fabricated onto
         * the silicon substrate and separated from the electrodes by a highly
         * UV-transparent dielectric layer. Via wall structures prevent
         * optical cross-talk from neighbouring readout zones. Commercial
         * silicon-based multi-pixel photon counters reach quantum
         * efficiencies around 30%, and when cooled to 77 K show a dark count
         * rate reduced to the order of 1 Hz.
         *
         * Source: p.4, right column, paragraph 4; Fig. 2B.
         */
        in item transmittedLight : opticalSignal;
        out item photonCount : digitalData;
        attribute quantumEfficiency;                // ~30 %   [p.4 RC para 4]
        attribute darkCountRate = 1.0 [Hz];         // ~1 Hz at 77 K [p.4 RC para 4]
    }

    action def DetermineQubitState {
        doc
        /*
         * Determine the qubit state from the photon count. The total photon
         * detection efficiency of the setup is on the order of 2%, taking an
         * 80% transmission through the ITO and dielectric layer and a
         * collection efficiency of about 10%. A state readout fidelity on the
         * order of 99.9% for a 25 microsecond detection window can be
         * expected.
         *
         * Source: p.4, right column, paragraph 5; p.5, left column,
         * paragraph 1.
         */
        in item photonCount : digitalData;
        out item result : digitalData;
        attribute detectionEfficiency;              // ~2 %    [p.5 LC para 1]
        attribute collectionEfficiency;             // ~10 %   [p.5 LC para 1]
        attribute readoutFidelity;                  // ~99.9 % [p.5 LC para 1]
        attribute detectionWindow = 25.0E-6 [s];    // 25 us   [p.5 LC para 1]
    }

    action def AnalyseResult {
        doc
        /*
         * Analyse the readout result outside the vacuum system.
         *
         * Source: p.5, right column, paragraph 1.
         */
        in item result : digitalData;
        out attribute qubitState;
    }

    action def RemoveHeat {
        doc
        /*
         * Remove the heat generated by the copper wires, rf dissipation in
         * the trap structure and the on-chip electronics. A liquid nitrogen
         * microchannel cooler is integrated into the back wafer of the
         * module; deep trenches are etched into the backside of the last
         * wafer, forming channels through which liquid nitrogen is passed.
         * The coolant is cooled from 77 K to 65 K to prevent boiling inside
         * the cooler. Cooling the silicon substrates below 100 K also raises
         * the thermal conductivity of silicon sharply and of copper by a
         * factor of ten, which prevents the wire structures from melting.
         *
         * Source: p.5, left column, paragraphs 3 and 4.
         */
        attribute heatOutputPerModule = 1.0E3 [W];  // ~1000 W [p.5 LC para 3]
        attribute powerDensity;                     // 0.12 W/mm2 [p.5 LC para 3]
    }

    // =====================================================================
    // End-to-end behaviour
    // =====================================================================
    action def MicrowaveTrappedIonControlAndReadout {

        doc
        /*
         * Sequence of the microwave trapped ion control and readout cycle.
         *
         * An ion is loaded and cooled, prepared, and shuttled to the gate
         * zone. There the global microwave field, the static gradient, the
         * local offset field and the electrode potentials combine to perform
         * the gate. The ion is then shuttled to the readout zone, where the
         * steered laser beams excite it, the emitted light passes through the
         * transparent electrodes to the embedded photon counter, and the
         * count is converted to a state.
         *
         * The gradient is turned off during shuttling, which is why the
         * gradient generation and the shuttling steps are ordered rather than
         * concurrent.
         *
         * This definition states ordering and the action-to-action item
         * chain. The physical routing of those items through ports is
         * modelled in the parts.
         *
         * Source: p.2 right column paragraph 3 through p.5 right column
         * paragraph 1, with Figs. 1 and 2.
         */

        out attribute measuredQubitState;

        // ---- room-temperature generation ----
        action generateGlobalMicrowaveField : GenerateGlobalMicrowaveField;  // [p.4 RC para 1]
        action amplifyMicrowave : AmplifyMicrowave;                // [p.4 RC para 1]
        action radiateGlobalField : RadiateGlobalField;            // [p.4 LC para 2]
        action generateRfTrapDrive : GenerateRfTrapDrive;          // [p.5 RC para 1]
        action resonateRfDrive : ResonateRfDrive;                  // [p.5 RC para 1]
        action issueControlCommand : IssueControlCommand;          // [p.5 RC para 1]
        action generateIonisationBeam : GenerateLaserBeam;         // [p.2 RC para 3]
        action generateCoolingBeam : GenerateLaserBeam;            // [p.2 RC para 3]
        action generateStatePrepBeam : GenerateLaserBeam;          // [p.2 RC para 3]
        action generateSympatheticBeam : GenerateLaserBeam;        // [p.2 RC para 3]
        action steerLaserBeam : SteerLaserBeam;                    // [p.5 LC para 2]
        action generateReadoutExcitation : GenerateLaserBeam;      // [p.5 LC para 2]

        // ---- in-vacuum electronics ----
        action convertToAnalogDrive : ConvertToAnalogDrive;        // [p.4 RC para 1]
        action filterElectrodeVoltage : FilterElectrodeVoltage;    // [p.5 RC para 1]
        action generateFieldGradient : GenerateFieldGradient;      // [p.4 LC para 1]
        action adjustLocalMagneticField : AdjustLocalMagneticField;// [p.4 LC para 4]
        action applyElectrodeVoltage : ApplyElectrodeVoltage;      // [p.4 RC para 2]
        action removeHeat : RemoveHeat;                            // [p.5 LC para 4]

        // ---- ion operations ----
        action loadIon : LoadIon;                                  // [p.3 RC para 2]
        action coolIon : CoolIon;                                  // [p.2 RC para 3]
        action prepareState : PrepareState;                        // [p.2 RC para 3]
        action shuttleToGateZone : ShuttleIon;                     // [p.3 LC para 1]
        action performQuantumGate : PerformQuantumGate;            // [p.4 RC para 1]
        action shuttleToReadoutZone : ShuttleIon;                  // [p.3 LC para 1]

        // ---- readout ----
        action transmitFluorescence : TransmitFluorescence;        // [p.4 RC para 4]
        action countPhotons : CountPhotons;                        // [p.4 RC para 4]
        action determineQubitState : DetermineQubitState;          // [p.5 LC para 1]
        action analyseResult : AnalyseResult;                      // [p.5 RC para 1]

        // ---- control nodes ----
        fork initiate;
        join joinGate;

        // ---- ordering ----
        first start then initiate;

        // trapping field and cooling loop are established and held
        first initiate then generateRfTrapDrive;                   // [p.5 RC para 1]
        first generateRfTrapDrive then resonateRfDrive;
        first initiate then removeHeat;                            // [p.5 LC para 4]

        // global microwave chain
        first initiate then generateGlobalMicrowaveField;          // [p.4 RC para 1]
        first generateGlobalMicrowaveField then amplifyMicrowave;
        first amplifyMicrowave then radiateGlobalField;

        // laser generation and steering
        first initiate then generateIonisationBeam;                // [p.2 RC para 3]
        first initiate then generateCoolingBeam;
        first initiate then generateStatePrepBeam;
        first initiate then generateSympatheticBeam;
        first initiate then generateReadoutExcitation;
        first generateIonisationBeam then steerLaserBeam;          // [p.5 LC para 2]

        // digital command chain into the in-vacuum converters
        first initiate then issueControlCommand;                   // [p.5 RC para 1]
        first issueControlCommand then convertToAnalogDrive;
        first convertToAnalogDrive then filterElectrodeVoltage;
        first filterElectrodeVoltage then applyElectrodeVoltage;   // [p.4 RC para 2]
        first convertToAnalogDrive then adjustLocalMagneticField;  // [p.4 LC para 4]

        // ion preparation
        first steerLaserBeam then loadIon;                         // [p.3 RC para 2]
        first loadIon then coolIon;                                // [p.2 RC para 3]
        first coolIon then prepareState;

        // shuttle with the gradient off, then raise it for the gate
        first prepareState then shuttleToGateZone;                 // [p.3 LC para 2]
        first applyElectrodeVoltage then shuttleToGateZone;
        first shuttleToGateZone then generateFieldGradient;        // [p.4 RC para 3]
        first generateFieldGradient then joinGate;
        first radiateGlobalField then joinGate;
        first adjustLocalMagneticField then joinGate;
        first resonateRfDrive then joinGate;
        first joinGate then performQuantumGate;                    // [p.4 RC para 1]

        // shuttle to the readout zone and detect
        first performQuantumGate then shuttleToReadoutZone;        // [p.3 LC para 1]
        first shuttleToReadoutZone then transmitFluorescence;      // [p.4 RC para 4]
        first transmitFluorescence then countPhotons;
        first countPhotons then determineQubitState;               // [p.5 LC para 1]
        first determineQubitState then analyseResult;
        first analyseResult then done;

        // ---- item chain ----
        flow from generateGlobalMicrowaveField.tone to amplifyMicrowave.weakSignal;
        flow from amplifyMicrowave.amplifiedSignal to radiateGlobalField.feed;
        flow from radiateGlobalField.globalField to performQuantumGate.globalField;
        flow from generateRfTrapDrive.rfDrive to resonateRfDrive.rfIn;
        flow from resonateRfDrive.rfOut to performQuantumGate.trapDrive;

        flow from issueControlCommand.command to convertToAnalogDrive.command;
        flow from convertToAnalogDrive.electrodeVoltage to filterElectrodeVoltage.unfiltered;
        flow from filterElectrodeVoltage.filtered to applyElectrodeVoltage.voltage;
        flow from convertToAnalogDrive.coilCurrent to generateFieldGradient.current;
        flow from convertToAnalogDrive.coilCurrent to adjustLocalMagneticField.current;
        flow from generateFieldGradient.gradient to performQuantumGate.gradient;
        flow from adjustLocalMagneticField.offsetField to performQuantumGate.offsetField;
        flow from applyElectrodeVoltage.electrodePotential to performQuantumGate.electrodePotential;
        flow from applyElectrodeVoltage.electrodePotential to shuttleToGateZone.electrodePotential;
        flow from applyElectrodeVoltage.electrodePotential to shuttleToReadoutZone.electrodePotential;

        flow from generateIonisationBeam.beam to steerLaserBeam.beams;
        flow from steerLaserBeam.steeredBeams to loadIon.ionisationBeam;
        flow from generateCoolingBeam.beam to coolIon.coolingBeam;
        flow from generateSympatheticBeam.beam to coolIon.coolingBeam;
        flow from generateStatePrepBeam.beam to prepareState.statePrepBeam;

        flow from performQuantumGate.fluorescence to transmitFluorescence.emittedLight;
        flow from generateReadoutExcitation.beam to steerLaserBeam.beams;
        flow from transmitFluorescence.transmittedLight to countPhotons.transmittedLight;
        flow from countPhotons.photonCount to determineQubitState.photonCount;
        flow from determineQubitState.result to analyseResult.result;

        bind measuredQubitState = analyseResult.qubitState;
    }

    action microwaveOperation : MicrowaveTrappedIonControlAndReadout;

    // =====================================================================
    // Structure
    // =====================================================================
    part microwaveControlSystem : classicalControlSystem {

        doc
        /*
         * Control instrumentation outside the vacuum system: the global
         * microwave chain, the rf trap drive and its resonator, the digital
         * control unit, and the laser system whose beams are steered into the
         * chamber.
         *
         * Source: p.4 right column paragraph 1; p.5 right column
         * paragraph 1; p.2 right column paragraph 3.
         */

        part globalFrequencyGenerator : microwaveSource {
            doc
            /*
             * Commercial frequency generator producing the global field
             * frequencies.
             *
             * Source: p.4, right column, paragraph 1.
             */
            port toneOut : microwavePort {
                in item item1;
            }
            perform microwaveOperation.generateGlobalMicrowaveField;
            flow from generateGlobalMicrowaveField.tone to toneOut.item1;
        }
        part microwaveAmplifier {
            port ampIn : ~microwavePort {
                out item item1;
            }
            port ampOut : microwavePort {
                in item item1;
            }
            perform microwaveOperation.amplifyMicrowave;           // [p.4 RC para 1]
            flow from ampIn.item1 to amplifyMicrowave.weakSignal;
            flow from amplifyMicrowave.amplifiedSignal to ampOut.item1;
        }
        part radiationEmitter {
            doc
            /*
             * Emitter placed periodically within the vacuum chamber,
             * radiating one of the handful of global long-wavelength fields.
             *
             * Source: p.4, left column, paragraph 2.
             */
            port feedIn : ~microwavePort {
                out item item1;
            }
            port globalFieldOut : microwavePort {
                in item item1;
            }
            perform microwaveOperation.radiateGlobalField;
            flow from feedIn.item1 to radiateGlobalField.feed;
            flow from radiateGlobalField.globalField to globalFieldOut.item1;
        }
        part rfFrequencySource {
            port rfOut : microwavePort {
                in item item1;
            }
            perform microwaveOperation.generateRfTrapDrive;        // [p.5 RC para 1]
            flow from generateRfTrapDrive.rfDrive to rfOut.item1;
        }
        part helicalResonator {
            doc
            /*
             * Compact helical resonator, around 15 mm in diameter, tuned into
             * resonance with the frequency source using a tuning capacitor.
             * All resonators are attached to the same frequency source.
             *
             * Source: p.5, right column, paragraph 1.
             */
            part variableCapacitor;
            port rfIn : ~microwavePort {
                out item item1;
            }
            port rfOut : microwavePort {
                in item item1;
            }
            perform microwaveOperation.resonateRfDrive;
            flow from rfIn.item1 to resonateRfDrive.rfIn;
            flow from resonateRfDrive.rfOut to rfOut.item1;
        }
        part digitalController {
            doc
            /*
             * Electronic control unit housed on an additional wafer layer,
             * controlling the in-vacuum converters and the detection system.
             *
             * Source: p.5, right column, paragraph 1.
             */
            port controlOut : digitalPort {
                in item item1;
            }
            perform microwaveOperation.issueControlCommand;
            flow from issueControlCommand.command to controlOut.item1;
        }
        part globalLaserSystem {
            doc
            /*
             * Laser system supplying the beams required for photoionization,
             * Doppler and sympathetic cooling, and state preparation. These
             * beams need be neither intense nor phase-stable.
             *
             * Source: p.2, right column, paragraph 3.
             */
            part photoionisationLaser {
                port beamOut : opticalPort {
                    in item item1;
                }
                perform microwaveOperation.generateIonisationBeam;
                flow from generateIonisationBeam.beam to beamOut.item1;
            }
            part dopplerCoolingLaser {
                port beamOut : opticalPort {
                    in item item1;
                }
                perform microwaveOperation.generateCoolingBeam;
                flow from generateCoolingBeam.beam to beamOut.item1;
            }
            part statePreparationLaser {
                port beamOut : opticalPort {
                    in item item1;
                }
                perform microwaveOperation.generateStatePrepBeam;
                flow from generateStatePrepBeam.beam to beamOut.item1;
            }
            part sympatheticCoolingLaser {
                port beamOut : opticalPort {
                    in item item1;
                }
                perform microwaveOperation.generateSympatheticBeam;
                flow from generateSympatheticBeam.beam to beamOut.item1;
            }
            part inVacuumBeamSteeringOptics {
                doc
                /*
                 * In-vacuum optics steering the global beams parallel to and
                 * between the gate zone arms, so that only ions in the
                 * readout zones are illuminated.
                 *
                 * Source: p.5, left column, paragraph 2.
                 */
                port photoionisationIn : ~opticalPort {
                    out item item1;
                }
                port coolingIn : ~opticalPort;
                port statePrepIn : ~opticalPort;
                port sympatheticIn : ~opticalPort;
                port sheetOut : opticalPort {
                    in item item1;
                }
                perform microwaveOperation.steerLaserBeam;
                flow from photoionisationIn.item1 to steerLaserBeam.beams;
                flow from steerLaserBeam.steeredBeams to sheetOut.item1;
            }
            port laserSheetOut : opticalPort;
            flow from photoionisationLaser.beamOut to inVacuumBeamSteeringOptics.photoionisationIn;
            flow from dopplerCoolingLaser.beamOut to inVacuumBeamSteeringOptics.coolingIn;
            flow from statePreparationLaser.beamOut to inVacuumBeamSteeringOptics.statePrepIn;
            flow from sympatheticCoolingLaser.beamOut to inVacuumBeamSteeringOptics.sympatheticIn;
            flow from inVacuumBeamSteeringOptics.sheetOut to laserSheetOut;
        }
        port globalMicrowaveOut : microwavePort;
        port rfTrapDriveOut : microwavePort;
        port laserSheetOut : opticalPort;
        port digitalControlOut : digitalPort;
        flow from globalFrequencyGenerator.toneOut to microwaveAmplifier.ampIn;
        flow from microwaveAmplifier.ampOut to radiationEmitter.feedIn;
        flow from radiationEmitter.globalFieldOut to globalMicrowaveOut;
        flow from rfFrequencySource.rfOut to helicalResonator.rfIn;
        flow from helicalResonator.rfOut to rfTrapDriveOut;
        flow from globalLaserSystem.laserSheetOut to laserSheetOut;
        flow from digitalController.controlOut to digitalControlOut;
    }

    part vacuumChamberEnv {

        doc
        /*
         * Ultrahigh vacuum chamber housing the quantum computer module. The
         * chambers are octagon shaped, about 4.5 by 4.5 m, with viewports on
         * the sides and top for optical access, and carry the feedthroughs
         * for currents, static voltages, rf and microwave signals, coolant
         * and digital control signals.
         *
         * Source: p.7, left column, paragraph 2.
         */

        attribute pressure : PressureUnit;

        port globalMicrowaveIn : ~microwavePort;
        port rfTrapDriveIn : ~microwavePort;
        port laserSheetIn : ~opticalPort;
        port digitalControlIn : ~digitalPort;
        port readoutExcitationIn : ~opticalPort;
        port photonCountOut : digitalPort;

        part viewport {
            port beamIn : ~opticalPort;
            port beamOut : opticalPort;
        }
        part readoutViewport {
            port beamIn : ~opticalPort;
            port beamOut : opticalPort;
        }
        part vacuumPump;
        part liquidNitrogenHeatShield;
        part electricalFeedthrough {
            port signalIn : ~digitalPort;
            port signalOut : digitalPort;
        }
        part steelFrame;

        part quantumComputerModule {
            doc
            /*
             * Scalable quantum computer module, 6 by 6 electrical submodules
             * on a 90 by 90 mm high-resistivity silicon wafer piece,
             * containing 1296 X-junctions. The module is controlled by
             * on-chip electronics and performs the required quantum
             * operations using magnetic field gradients, local magnetic
             * fields, and global laser and microwave fields.
             *
             * Source: p.5, right column, paragraph 2.
             */
            attribute temp : ThermodynamicTemperatureUnit = 72 [K];

            part qpu : QPU {
                doc
                /*
                 * The X-junction array holding the ions, with its gate,
                 * readout and loading zones. Modelled as a black box so that
                 * only the classical interface is in scope; the gate zones
                 * perform all quantum operations, controlled by the in-vacuum
                 * electronics and powered by the global radiation fields.
                 *
                 * Source: p.4 right column paragraph 1; p.2 right column
                 * paragraph 3; Fig. 1A.
                 */
                attribute redefines technology = qubitTechnology::trappedIon;
                port globalMicrowaveIn : ~microwavePort {
                    out item item1;
                }
                port rfTrapIn : ~microwavePort {
                    out item item1;
                }
                port gradientIn : ~magneticFieldPort {
                    out item item1;
                }
                port offsetFieldIn : ~magneticFieldPort {
                    out item item1;
                }
                port electrodeVoltageIn : ~dcBiasPort {
                    out item item1;
                }
                port laserSheetIn : ~opticalPort {
                    out item item1;
                }
                port readoutExcitationIn : ~opticalPort;
                port fluorescenceOut : opticalPort {
                    in item item1;
                }
                perform microwaveOperation.loadIon;
                perform microwaveOperation.coolIon;
                perform microwaveOperation.prepareState;
                perform microwaveOperation.shuttleToGateZone;
                perform microwaveOperation.performQuantumGate;
                perform microwaveOperation.shuttleToReadoutZone;
                flow from globalMicrowaveIn.item1 to performQuantumGate.globalField;
                flow from rfTrapIn.item1 to performQuantumGate.trapDrive;
                flow from gradientIn.item1 to performQuantumGate.gradient;
                flow from offsetFieldIn.item1 to performQuantumGate.offsetField;
                flow from electrodeVoltageIn.item1 to performQuantumGate.electrodePotential;
                flow from electrodeVoltageIn.item1 to shuttleToGateZone.electrodePotential;
                flow from electrodeVoltageIn.item1 to shuttleToReadoutZone.electrodePotential;
                flow from laserSheetIn.item1 to loadIon.ionisationBeam;
                flow from laserSheetIn.item1 to coolIon.coolingBeam;
                flow from laserSheetIn.item1 to prepareState.statePrepBeam;
                flow from performQuantumGate.fluorescence to fluorescenceOut.item1;
            }
            part gradientWire {
                doc
                /*
                 * Copper wire embedded in the silicon substrate, carrying
                 * about 10 A to generate the static magnetic field gradient
                 * at the ion position.
                 *
                 * Source: p.4, left column, paragraph 1; Fig. 2A.
                 */
                port currentIn : ~dcBiasPort {
                    out item item1;
                }
                port gradientOut : magneticFieldPort {
                    in item item1;
                }
                perform microwaveOperation.generateFieldGradient;
                flow from currentIn.item1 to generateFieldGradient.current;
                flow from generateFieldGradient.gradient to gradientOut.item1;
            }
            part localBFieldCoil {
                doc
                /*
                 * Very low inductance coil placed underneath each gate zone,
                 * used to shift the qubit in and out of resonance with the
                 * global radiation fields and to compensate slow variations
                 * of the global magnetic field.
                 *
                 * Source: p.4, left column, paragraph 4; p.4, right column,
                 * paragraph 1; Fig. 2A.
                 */
                port currentIn : ~dcBiasPort {
                    out item item1;
                }
                port offsetFieldOut : magneticFieldPort {
                    in item item1;
                }
                perform microwaveOperation.adjustLocalMagneticField;
                flow from currentIn.item1 to adjustLocalMagneticField.current;
                flow from adjustLocalMagneticField.offsetField to offsetFieldOut.item1;
            }
            part itoElectrode {
                doc
                /*
                 * Indium tin oxide centre segmented electrode in the readout
                 * zone, ultraviolet transparent so that light emitted by the
                 * ion passes through to the detector below.
                 *
                 * Source: p.4, right column, paragraph 4; Fig. 2B.
                 */
                port photonIn : ~opticalPort {
                    out item item1;
                }
                port photonOut : opticalPort {
                    in item item1;
                }
                perform microwaveOperation.transmitFluorescence;
                flow from photonIn.item1 to transmitFluorescence.emittedLight;
                flow from transmitFluorescence.transmittedLight to photonOut.item1;
            }
            part embeddedPhotonCounter {
                doc
                /*
                 * Silicon-based multi-pixel photon counter fabricated onto
                 * the substrate, cooled to 77 K to reduce the dark count
                 * rate. Via wall structures prevent optical cross-talk from
                 * neighbouring readout zones.
                 *
                 * Source: p.4, right column, paragraph 4; Fig. 2B.
                 */
                attribute temp : ThermodynamicTemperatureUnit = 77 [K];
                port photonIn : ~opticalPort {
                    out item item1;
                }
                port countOut : digitalPort {
                    in item item1;
                }
                perform microwaveOperation.countPhotons;
                flow from photonIn.item1 to countPhotons.transmittedLight;
                flow from countPhotons.photonCount to countOut.item1;
            }
            part electronicsLayer {
                doc
                /*
                 * Stacked wafer layers carrying the in-vacuum converters and
                 * their filters, attached to the ion trap substrate using
                 * through-silicon via and wafer-stacking technology.
                 *
                 * Source: p.5, right column, paragraph 1.
                 */
                part fpga : fieldProgrammableGateArrays {
                    port controlIn : ~digitalPort;
                    port dacDriveOut : digitalPort;
                }
                part inVacuumDac : digitalToAnalogConverter {
                    port digitalIn : ~digitalPort {
                        out item item1;
                    }
                    port coilCurrentOut : dcBiasPort {
                        in item item1;
                    }
                    port electrodeVoltageOut : dcBiasPort {
                        in item item1;
                    }
                    perform microwaveOperation.convertToAnalogDrive;
                    flow from digitalIn.item1 to convertToAnalogDrive.command;
                    flow from convertToAnalogDrive.coilCurrent to coilCurrentOut.item1;
                    flow from convertToAnalogDrive.electrodeVoltage to electrodeVoltageOut.item1;
                }
                part rcFilter {
                    port filterIn : ~dcBiasPort {
                        out item item1;
                    }
                    port filterOut : dcBiasPort {
                        in item item1;
                    }
                    perform microwaveOperation.filterElectrodeVoltage;
                    flow from filterIn.item1 to filterElectrodeVoltage.unfiltered;
                    flow from filterElectrodeVoltage.filtered to filterOut.item1;
                }
                part electrodeDriver {
                    doc
                    /*
                     * Summing amplification circuit applying the highly
                     * stable electrode potentials, and overriding them with
                     * the fast control system during shuttling operations.
                     *
                     * Source: p.4, right column, paragraph 2.
                     */
                    port voltageIn : ~dcBiasPort {
                        out item item1;
                    }
                    port potentialOut : dcBiasPort {
                        in item item1;
                    }
                    perform microwaveOperation.applyElectrodeVoltage;
                    flow from voltageIn.item1 to applyElectrodeVoltage.voltage;
                    flow from applyElectrodeVoltage.electrodePotential to potentialOut.item1;
                }
                part throughSiliconVia;
                port controlIn : ~digitalPort;
                port coilCurrentOut : dcBiasPort;
                port electrodeVoltageOut : dcBiasPort;
                flow from controlIn to fpga.controlIn;
                flow from fpga.dacDriveOut to inVacuumDac.digitalIn;
                flow from inVacuumDac.coilCurrentOut to coilCurrentOut;
                flow from inVacuumDac.electrodeVoltageOut to rcFilter.filterIn;
                flow from rcFilter.filterOut to electrodeDriver.voltageIn;
                flow from electrodeDriver.potentialOut to electrodeVoltageOut;
            }
            part controlUnit : physicalControlUnit {
                doc
                /*
                 * Determines the qubit state from the photon count.
                 *
                 * Source: p.4 right column paragraph 5; p.5 left column
                 * paragraph 1.
                 */
                port countIn : ~digitalPort {
                    out item item1;
                }
                port resultOut : digitalPort {
                    in item item1;
                }
                perform microwaveOperation.determineQubitState;
                flow from countIn.item1 to determineQubitState.photonCount;
                flow from determineQubitState.result to resultOut.item1;
            }
            part microchannelCooler {
                doc
                /*
                 * Liquid nitrogen microchannel cooler integrated into the
                 * back wafer, removing the heat generated by the copper
                 * wires, rf dissipation and on-chip electronics. The coolant
                 * is cooled from 77 K to 65 K to prevent boiling inside the
                 * cooler.
                 *
                 * Source: p.5, left column, paragraphs 3 and 4.
                 */
                attribute coolantTemp : ThermodynamicTemperatureUnit = 65 [K];
                part coolantTubing;
                perform microwaveOperation.removeHeat;
            }
            part supportStructure {
                part piezoActuator;
                part diffractionGrating;
            }
            port globalMicrowaveIn : ~microwavePort;
            port rfTrapIn : ~microwavePort;
            port laserSheetIn : ~opticalPort;
            port readoutExcitationIn : ~opticalPort;
            port digitalControlIn : ~digitalPort;
            port resultOut : digitalPort;
            flow from globalMicrowaveIn to qpu.globalMicrowaveIn;
            flow from rfTrapIn to qpu.rfTrapIn;
            flow from laserSheetIn to qpu.laserSheetIn;
            flow from readoutExcitationIn to qpu.readoutExcitationIn;
            flow from digitalControlIn to electronicsLayer.controlIn;
            flow from electronicsLayer.coilCurrentOut to gradientWire.currentIn;
            flow from electronicsLayer.coilCurrentOut to localBFieldCoil.currentIn;
            flow from electronicsLayer.electrodeVoltageOut to qpu.electrodeVoltageIn;
            flow from gradientWire.gradientOut to qpu.gradientIn;
            flow from localBFieldCoil.offsetFieldOut to qpu.offsetFieldIn;
            flow from qpu.fluorescenceOut to itoElectrode.photonIn;
            flow from itoElectrode.photonOut to embeddedPhotonCounter.photonIn;
            flow from embeddedPhotonCounter.countOut to controlUnit.countIn;
            flow from controlUnit.resultOut to resultOut;
        }
        flow from globalMicrowaveIn to quantumComputerModule.globalMicrowaveIn;
        flow from rfTrapDriveIn to quantumComputerModule.rfTrapIn;
        flow from laserSheetIn to viewport.beamIn;
        flow from viewport.beamOut to quantumComputerModule.laserSheetIn;
        flow from readoutExcitationIn to readoutViewport.beamIn;
        flow from readoutViewport.beamOut to quantumComputerModule.readoutExcitationIn;
        flow from digitalControlIn to electricalFeedthrough.signalIn;
        flow from electricalFeedthrough.signalOut to quantumComputerModule.digitalControlIn;
        flow from quantumComputerModule.resultOut to photonCountOut;
    }

    part microwaveReadoutSystem : classicalReadoutSystem {

        doc
        /*
         * Readout instrumentation outside the vacuum system: the excitation
         * laser that illuminates ions in the readout zone, and the analysis
         * of the returned result.
         *
         * Source: p.5, left column, paragraph 2; p.5, right column,
         * paragraph 1.
         */

        part readoutExcitationLaser {
            port beamOut : opticalPort {
                in item item1;
            }
            perform microwaveOperation.generateReadoutExcitation;  // [p.5 LC para 2]
            flow from generateReadoutExcitation.beam to beamOut.item1;
        }
        part detectionSystem {
            port countIn : ~digitalPort {
                out item item1;
            }
            port resultOut : digitalPort;
            perform microwaveOperation.analyseResult;              // [p.5 RC para 1]
            flow from countIn.item1 to analyseResult.result;
        }
        part readoutControlUnit {
            port resultIn : ~digitalPort;
        }
        port readoutExcitationOut : opticalPort;
        port photonCountIn : ~digitalPort;
        flow from readoutExcitationLaser.beamOut to readoutExcitationOut;
        flow from photonCountIn to detectionSystem.countIn;
        flow from detectionSystem.resultOut to readoutControlUnit.resultIn;
    }

    flow from microwaveControlSystem.globalMicrowaveOut to vacuumChamberEnv.globalMicrowaveIn;
    flow from microwaveControlSystem.rfTrapDriveOut to vacuumChamberEnv.rfTrapDriveIn;
    flow from microwaveControlSystem.laserSheetOut to vacuumChamberEnv.laserSheetIn;
    flow from microwaveControlSystem.digitalControlOut to vacuumChamberEnv.digitalControlIn;
    flow from microwaveReadoutSystem.readoutExcitationOut to vacuumChamberEnv.readoutExcitationIn;
    flow from vacuumChamberEnv.photonCountOut to microwaveReadoutSystem.photonCountIn;
}
