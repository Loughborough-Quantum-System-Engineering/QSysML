// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019), Fig. 3(d)
// Inductive coupling via a tunable coupler: an rf-SQUID coupler is coupled
// to each qubit by a mutual inductance (M_1C, M_2C); its flux bias tunes the
// net qubit-qubit coupling, enabling a high on/off ratio.

package InductiveCouplingViaTunableCoupler {
    public import SuperconductiveQubit::*;
    public import ISQ::*;
    public import SI::*;

    // Flux-tunable rf-SQUID coupler.
    part def TunableCoupler {
        part couplerJunction : JosephsonJunction;
        part couplerInductor : LinearInductor;
        attribute externalFlux;                             // Phi_eC / Phi_0
        attribute onOffRatio;                               // dimensionless
        port a : Terminal;
        port b : Terminal;
        connect couplerJunction.a to a;
        connect couplerJunction.b to b;
        connect couplerInductor.a to a;
        connect couplerInductor.b to b;
    }

    part def InductiveCouplingViaTunableCoupler {
        attribute couplingStrength : FrequencyValue;        // tunable g [MHz]
        part qubit1 : SuperconductiveQubit;
        part qubit2 : SuperconductiveQubit;
        part coupler : TunableCoupler;
        part mutualInductance1 : MutualInductance;          // M_1C
        part mutualInductance2 : MutualInductance;          // M_2C
        // qubit1 <-M_1C-> coupler <-M_2C-> qubit2
        connect mutualInductance1.a1 to qubit1.nodeA;
        connect mutualInductance1.b1 to qubit1.nodeB;
        connect mutualInductance1.a2 to coupler.a;
        connect mutualInductance1.b2 to coupler.b;
        connect mutualInductance2.a1 to coupler.a;
        connect mutualInductance2.b1 to coupler.b;
        connect mutualInductance2.a2 to qubit2.nodeA;
        connect mutualInductance2.b2 to qubit2.nodeB;
    }
}
