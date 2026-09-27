// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019), Fig. 3(c)
// Direct inductive coupling: two qubit loops share a mutual inductance M_12.

package DirectInductiveCoupling {
    public import SuperconductiveQubit::*;
    public import ISQ::*;
    public import SI::*;

    part def DirectInductiveCoupling {
        attribute couplingStrength : FrequencyValue;        // g [MHz]
        part qubit1 : SuperconductiveQubit;
        part qubit2 : SuperconductiveQubit;
        part coupling : MutualInductance;                   // M_12
        // magnetic coupling between the two qubit loops
        connect coupling.a1 to qubit1.nodeA;
        connect coupling.b1 to qubit1.nodeB;
        connect coupling.a2 to qubit2.nodeA;
        connect coupling.b2 to qubit2.nodeB;
    }
}
