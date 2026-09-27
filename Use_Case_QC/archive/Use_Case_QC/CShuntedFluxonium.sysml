// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019) — see SuperconductiveQubit.sysml
// Capacitively shunted fluxonium: small junction shunted by C and by a large
// junction array (superinductance), all across the two nodes.

package CShuntedFluxonium {
    public import SuperconductiveQubit::*;
    public import ISQ::*;
    public import SI::*;

    part def CShuntedFluxonium :> SuperconductiveQubit {
        part smallJunction : JosephsonJunction;
        part junctionArray : JunctionArray;
        attribute externalFlux;                             // Phi_ext / Phi_0
        attribute plasmonFrequency : FrequencyValue;        // [GHz]
        attribute fluxonFrequency : FrequencyValue;         // [GHz]
        connect (smallJunction.a, junctionArray.a, shuntCapacitor.a, nodeA);
        connect (smallJunction.b, junctionArray.b, shuntCapacitor.b, nodeB);
    }
}
