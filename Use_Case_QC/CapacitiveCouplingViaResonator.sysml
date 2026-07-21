// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019), Fig. 3(b)
// Capacitive coupling via a coupler: two qubits couple to a shared linear
// resonator (bus) through coupling capacitors, mediating their interaction.

package CapacitiveCouplingViaResonator {
    public import SuperconductiveQubit::*;
    public import ISQ::*;
    public import SI::*;

    part def CapacitiveCouplingViaResonator {
        attribute coupling1 : FrequencyValue;               // g_r1 [MHz]
        attribute coupling2 : FrequencyValue;               // g_r2 [MHz]
        part qubit1 : SuperconductiveQubit;
        part qubit2 : SuperconductiveQubit;
        part busResonator : Resonator;
        part couplingCapacitor1 : Capacitor;                // C_g1
        part couplingCapacitor2 : Capacitor;                // C_g2
        connect qubit1.nodeA to couplingCapacitor1.a;
        connect couplingCapacitor1.b to busResonator.a;
        connect qubit2.nodeA to couplingCapacitor2.a;
        connect couplingCapacitor2.b to busResonator.a;
    }
}
