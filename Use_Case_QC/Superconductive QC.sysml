package 'Superconductive QC' {
    public import ISQ::*;
    public import SI::*;
    part def qubit;
    part def inductor;
    part def josephsonJunction :> inductor {
        attribute intrinsicJosephsonEnergy;
        attribute criticalCurrent;
        attribute junctionCapacitance;
    }
    attribute def qubitType;
    part superconductiveCircuit : qubit {
        attribute chargeQubit : qubitType;
        attribute transitionFrequency;
        attribute anharmonicity;
        attribute energyRatio;
        attribute chargeDispersion;
        attribute effectiveOffsetCharge;
        attribute operationTemp : ThermodynamicTemperatureUnit;
        assert constraint {
            operationTemp <= 0.015 [K]
        }
        part capacitance {
            attribute chargingEnergy;
            attribute totalCapacitance;
            attribute shuntingCapacitance;
            attribute gateCapacitance;
        }
        part squid {
            attribute totalJosephsonEnergy;
            attribute externalMagneticFlux;
            attribute effectiveNonLinerInductance;
            part jj1 : josephsonJunction;
            part jj2 : josephsonJunction;
        }
    }
}
view superconductiveQCPhysical : DS_Views::SymbolicViews::gv;
