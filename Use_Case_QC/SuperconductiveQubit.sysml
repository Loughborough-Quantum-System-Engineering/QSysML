// reference
// @article{krantz2019quantum,
//   title={A quantum engineer's guide to superconducting qubits},
//   author={Krantz, Philip and Kjaergaard, Morten and Yan, Fei and Orlando, Terry P and Gustavsson, Simon and Oliver, William D},
//   journal={Applied Physics Reviews},
//   volume={6},
//   number={2},
//   year={2019},
//   publisher={AIP Publishing}
// }

// Common definitions for superconducting-qubit circuits: circuit elements,
// the electrical terminal, and the abstract capacitively-shunted qubit base.
// Each modality (transmon, split transmon, flux qubit, fluxonium) lives in
// its own file and specialises SuperconductiveQubit.
//
// Units follow the reference: characteristic energies are reported as E/h in
// [GHz] (typed as frequencies), magnetic flux in units of the flux quantum
// Phi_0 (dimensionless), coherence times in [us], temperature in [mK].

package SuperconductiveQubit {
    public import ISQ::*;
    public import SI::*;

    // Electrical connection point (non-directional circuit node terminal).
    port def Terminal;

    // =====================================================================
    // Circuit elements
    // =====================================================================
    part def Capacitor {
        attribute capacitance : CapacitanceValue;       // [fF]
        attribute lossTangent;                          // dimensionless
        port a : Terminal;
        port b : Terminal;
    }

    part def LinearInductor {
        attribute inductance : InductanceValue;         // [nH]
        attribute geometricInductance : InductanceValue;
        attribute kineticInductance : InductanceValue;
        port a : Terminal;
        port b : Terminal;
    }

    part def JosephsonJunction {
        attribute criticalCurrent : ElectricCurrentValue;   // [nA]
        attribute josephsonEnergy : FrequencyValue;         // E_J/h [GHz]
        attribute josephsonInductance : InductanceValue;    // [nH]
        attribute junctionCapacitance : CapacitanceValue;   // [fF]
        attribute normalStateResistance;    // R_n [kOhm]
        attribute superconductingGap : FrequencyValue;      // Delta/h [GHz]
        attribute junctionArea : AreaValue;                 // [um^2]
        port a : Terminal;
        port b : Terminal;
    }

    // Two junctions in parallel forming a flux-threaded loop.
    part def Squid {
        part firstJunction : JosephsonJunction;
        part secondJunction : JosephsonJunction;
        attribute externalFlux;                             // Phi_ext / Phi_0
        attribute loopInductance : InductanceValue;         // [nH]
        attribute loopArea : AreaValue;                     // [um^2]
        attribute junctionAsymmetry;                        // gamma = E_J2/E_J1
        attribute effectiveJosephsonEnergy : FrequencyValue;// E_J'/h [GHz]
        port a : Terminal;
        port b : Terminal;
        connect (firstJunction.a, secondJunction.a, a);
        connect (firstJunction.b, secondJunction.b, b);
    }

    // N junctions in series -> superinductance (chain a -> ... -> b).
    part def JunctionArray {
        part junction : JosephsonJunction[1..*];
        attribute arraySize;                                // N
        attribute superinductance : InductanceValue;        // [nH]
        port a : Terminal;
        port b : Terminal;
    }

    // LC resonator (bus / readout), inductor and capacitor in parallel.
    part def Resonator {
        part inductor : LinearInductor;
        part capacitor : Capacitor;
        attribute resonantFrequency : FrequencyValue;       // omega_r/2pi [GHz]
        attribute qualityFactor;                            // dimensionless
        port a : Terminal;
        port b : Terminal;
        connect (inductor.a, capacitor.a, a);
        connect (inductor.b, capacitor.b, b);
    }

    // Magnetic (mutual-inductance) coupling between two inductive branches.
    // Not a galvanic tie: (a1,b1) couples to (a2,b2) through the field.
    part def MutualInductance {
        attribute mutualInductance : InductanceValue;       // M [nH]
        attribute couplingCoefficient;                      // k, dimensionless
        port a1 : Terminal;
        port b1 : Terminal;
        port a2 : Terminal;
        port b2 : Terminal;
    }

    // =====================================================================
    // Superconducting qubit (abstract base) — capacitively shunted
    // anharmonic oscillator across two circuit nodes (nodeA, nodeB).
    // =====================================================================
    abstract part def SuperconductiveQubit {
        // characteristic energies (reported as E/h)
        attribute chargingEnergy : FrequencyValue;          // E_C/h [GHz]
        attribute josephsonEnergy : FrequencyValue;         // E_J/h [GHz]
        attribute inductiveEnergy : FrequencyValue;         // E_L/h [GHz]
        attribute energyRatio;                              // E_J/E_C, dimensionless

        // spectral properties
        attribute transitionFrequency : FrequencyValue;     // f_01 [GHz]
        attribute secondTransitionFrequency : FrequencyValue;// f_12 [GHz]
        attribute anharmonicity : FrequencyValue;           // alpha [MHz]

        // charge sensitivity
        attribute chargeDispersion : FrequencyValue;        // [MHz]
        attribute offsetCharge;                             // n_g, in units of 2e

        // capacitances
        attribute totalCapacitance : CapacitanceValue;      // C_Sigma [fF]
        attribute shuntingCapacitance : CapacitanceValue;   // [fF]
        attribute gateCapacitance : CapacitanceValue;       // [fF]

        // coherence
        attribute relaxationTime : DurationValue;           // T1 [us]
        attribute dephasingTime : DurationValue;            // T2 [us]
        attribute echoTime : DurationValue;                 // T2E [us]
        attribute qualityFactor;                            // dimensionless

        // operating condition
        attribute operatingTemperature : ThermodynamicTemperatureValue;  // [mK]

        // circuit nodes (also serve as external coupling terminals)
        port nodeA : Terminal;
        port nodeB : Terminal;

        // capacitive shunt; each modality wires it into its node topology
        part shuntCapacitor : Capacitor;
    }
}
