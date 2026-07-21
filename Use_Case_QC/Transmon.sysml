// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019) — see SuperconductiveQubit.sysml
// Fixed-frequency transmon: single Josephson junction shunted by a capacitor.

package Transmon {
    public import SuperconductiveQubit::*;
    public import ISQ::*;
    public import SI::*;

    part def Transmon :> SuperconductiveQubit {
        part junction : JosephsonJunction;
        // single junction in parallel with the (inherited) shunt capacitor
        connect junction.a to shuntCapacitor.a;
        connect junction.b to shuntCapacitor.b;
    }
}
