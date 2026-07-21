// Superconducting-specific definitions shared across the superconducting
// interface models (conventional, SFQ, cryo-CMOS, optical, wireless).
package SuperconductingCommon {
    public import QuantumComputing::physicalLayerDefinitions::*;

    // ── Environment ──────────────────────────────────────────────────
    part def dilutionRefrigerator :> qubitEnvironment;

    // ── Superconducting quantum devices ──────────────────────────────
    part def josephsonParametricAmplifier :> amplifier;
    part def josephsonPhotomultiplier :> transducer;
    part def josephsonTransmissionLine :> transducer;
    part def sfqConverter :> transducer;          // dc-SFQ / SFQ logic chip
    part def cryoCMOSProcessor :> classicalProcessor;

    // ── SFQ signal + port ────────────────────────────────────────────
    item def sfqPulse :> signal;
    port def sfqPort { out item payload : sfqPulse; }
}
