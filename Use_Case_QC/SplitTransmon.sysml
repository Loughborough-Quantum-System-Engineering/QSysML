// reference: Krantz et al., Appl. Phys. Rev. 6, 021318 (2019) — see SuperconductiveQubit.sysml
// Tunable (split) transmon: SQUID in parallel with the shunt capacitor,
// frequency-tunable via external flux. AsymmetricTransmon reduces the
// tuning range (and flux-noise susceptibility) via an asymmetric SQUID.

package SplitTransmon {
    public import SuperconductiveQubit::*;
    public import ISQ::*;
    public import SI::*;

    part def SplitTransmon :> SuperconductiveQubit {
        part squid : Squid;
        attribute fluxTuningRange : FrequencyValue;         // [GHz]
        attribute sweetSpotFrequency : FrequencyValue;      // [GHz]
        attribute fluxSensitivity;                          // d f_01 / d Phi_ext
        connect squid.a to nodeA;
        connect squid.b to nodeB;
    }

    part def AsymmetricTransmon :> SplitTransmon {
        attribute reducedTuningRange : FrequencyValue;      // [GHz]
    }
}
