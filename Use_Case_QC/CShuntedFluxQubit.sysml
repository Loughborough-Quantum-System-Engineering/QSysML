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
        connect smallJunction.a to nodeA;
        connect smallJunction.b to nodeB;
        connect firstLargeJunction.a to nodeA;
        connect firstLargeJunction.b to secondLargeJunction.a;
        connect secondLargeJunction.b to nodeB;
    }
}
