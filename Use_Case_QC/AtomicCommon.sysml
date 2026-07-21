// Definitions shared across the atomic platforms (trapped ion + neutral atom).
package AtomicCommon {
    public import QuantumComputing::physicalLayerDefinitions::*;

    // ── Environment ──────────────────────────────────────────────────
    part def vacuumChamber :> qubitEnvironment;

    // ── Magnetic-field control (gradient-based multiqubit gates) ─────
    item def magneticField :> signal;
    port def magneticFieldPort { out item payload : magneticField; }
}
