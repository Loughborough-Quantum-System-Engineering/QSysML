package QunantumCoreUtility {
    private import QuantumCoreOntology::**;
    private import RealFunctions::sqrt;
    attribute def PureState :> QuantumState {
        doc /* Pure state, represented by a complex vector (3.2.7 Note 1, 3.2.11 Note 1). The state is known exactly and is one single state vector. */
    }
    attribute def MixedState :> QuantumState {
        doc /* Non-pure, or mixed, represented by a density operator in the complex Hilbert spac (3.2.7 Note 1). */
    }
    attribute def PolarisationSpace :> HilbertSpace;
    attribute <h> HorizontalState : PureState;
    attribute <v> VerticalState : PureState;
    attribute <d> DiagonalState : PureState;
    attribute <a> AntiDiagonalState : PureState;
    attribute plusBasis : Basis {
        attribute :>> basisStates = (h, v);
        attribute :>> spannedSpace : PolarisationSpace;
    }
    attribute crossBasis : Basis {
        attribute :>> basisStates = (d, a);
        attribute :>> spannedSpace : PolarisationSpace;
    }
    attribute def MeasurementBasis :> Basis {
        doc /* Basis in which a measurement is performed, eigenbasis of a non-degenerate observable. */
    }
    attribute def Observable :> QuantumOperator {
        doc /* Its eigenvalues, which are real (ISO/IEC 4879:2024, 3.2.14 Note 1), are the possible measurement outcomes. A measurement asks the question that an observable represents*/
    }
    attribute def LogicalOperator :> QuantumOperator {
        doc
        /* quantum operator (3.2.11) defined relative to logical qubit or
         * logical qudit basis states
         * Note 1: For example, standard logical operators for a single qubit (3.3.3) are the logical X (bit-flip) and logical Z (phase-flip) quantum gates (3.4.2).*/
        attribute logicalBasis : Basis [1];
    }
    attribute def UnitaryOperator :> QuantumOperator;
    calc def ApplyUnitaryToPureState :> ApplyQuantumOperator {
        in attribute :>> op : UnitaryOperator;
        in attribute :>> inputState : PureState;
        return :>> outputState : PureState;
    }
    action def QuantumGate {
        inout item target : QuantumSystem [1..*];
        in attribute gateOperator : QuantumOperator [1];
    }
    part def PhysicalTransformer {
        doc /* Physical element that realises a quantum gate on a quantum system. */
    }
    allocation def GateRealisation {
        doc /* The physical transformer is responsible for realising the quantum gate (SysML 7.15.1). */
        end action gate : QuantumGate;
        end part transformer : PhysicalTransformer;
    }
}
