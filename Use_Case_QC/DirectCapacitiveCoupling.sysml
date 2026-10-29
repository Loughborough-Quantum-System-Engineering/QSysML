// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019), Fig. 3(a)
// Direct capacitive coupling: a coupling capacitor C_g placed between the
// voltage nodes of two qubits.

package DirectCapacitiveCoupling {
    private import ISQ::*;
    private import SI::*;

    part def DirectCapacitiveCoupling {
        attribute couplingStrength : FrequencyValue;        // g_12 [MHz]
        part qubit1 : SuperconductiveQubit::SuperconductiveQubit;
        part qubit2 : SuperconductiveQubit::SuperconductiveQubit;
        part couplingCapacitor : SuperconductiveQubit::Capacitor;                 // C_g
        connect couplingCapacitor.a to qubit1.nodeA;
        connect couplingCapacitor.b to qubit2.nodeA;
    }
}
