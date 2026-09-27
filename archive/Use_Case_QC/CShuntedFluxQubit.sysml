// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019) — see SuperconductiveQubit.sysml
// Capacitively shunted flux qubit: small junction (C-shunted) across the
// nodes, with two larger junctions in series completing the loop.

package CShuntedFluxQubit {
    public import SuperconductiveQubit::*;
    public import ISQ::*;
    public import SI::*;

    part def CShuntedFluxQubit :> SuperconductiveQubit {
        part smallJunction : JosephsonJunction;
        part firstLargeJunction : JosephsonJunction;
        part secondLargeJunction : JosephsonJunction;
        attribute externalFlux;                             // Phi_ext / Phi_0
        attribute junctionAreaRatio;                        // gamma
        attribute persistentCurrent : ElectricCurrentValue; // [nA]
        attribute sweetSpotFrequency : FrequencyValue;      // [GHz]
        connect (smallJunction.a, shuntCapacitor.a, firstLargeJunction.a, nodeA);
        connect (smallJunction.b, shuntCapacitor.b, secondLargeJunction.b, nodeB);
        connect firstLargeJunction.b to secondLargeJunction.a;   // internal loop node
    }
}
