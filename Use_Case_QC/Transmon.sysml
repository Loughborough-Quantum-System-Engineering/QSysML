// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019) — see SuperconductiveQubit.sysml
// Fixed-frequency transmon: single Josephson junction shunted by a capacitor.

package Transmon {
    private import ISQ::*;
    private import SI::*;

    part def Transmon :> SuperconductiveQubit::SuperconductiveQubit {
        part junction : SuperconductiveQubit::JosephsonJunction;
        // single junction in parallel with the shunt capacitor
        connect (junction.a, shuntCapacitor.a, nodeA);   // island node
        connect (junction.b, shuntCapacitor.b, nodeB);   // ground node
    }
}
