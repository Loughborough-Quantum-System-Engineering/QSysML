package QuantumCoreOntology {
    doc
    /* Q-SysML quantum core: Application-independent ontology of ISO/IEC 4879:2024
     * clause 3.2 (quantum physics background) and clause 3.3 (quantum information).*/
    /* Modelling Decisions are added to the paper: attribute def for descriptions, properties and mathematical
     * entities (SysML 7.7.1, KerML 7.4.2), item def for quantum systems (SysML 7.10.1), action def for
     * processes (SysML 7.17.1), allocation def for realisation by a carrier system (SysML 7.15.1).
     * All definitions are abstract, so instances also belong to a concrete specialising definition or usage (SysML 7.6.2). */
    abstract part def QuantumSystem {
        doc
        /* Quantum system (3.2.6). System whose properties are determined by the laws of quantum physics and cannot be completely
         * described by just the laws of classical physics. */
        /* The multiplicity [1] therefore means exactly one quantum state per snapshot of the system. */
        attribute quantumState : QuantumState [1];
    }
    abstract attribute def QuantumState {
        doc
        /* description of the state of a quantum system (3.2.6) defining the probability distribution of possible outcomes of any measurement upon it.
         * A quantum state can be mathematically represented by a vector or, 
         * more generally, a density operator (3.2.2) in the complex Hilbert space (3.2.1). */
        /* A description has no identity or lifetime of its own and is fully determined by its content, a data type whose values do not exist in time or space */
        attribute stateSpace : HilbertSpace [1];
    }
    abstract attribute def Operator {
        doc
        /* operator: mathematical entity that transforms the elements of an input space to the elements of an output space
         * Note 1 to entry: In quantum physics (3.2.3), simple operators can be mathematically represented by a matrix that 
         * acts via matrix multiplication on vectors in a Hilbert space (3.2.1). */
        /* The operator stays an attribute def, and the gate (action def) takes it as an input. */
        attribute inputSpace [1];
        attribute outputSpace [1];
    }
    abstract attribute def QuantumOperator :> Operator {
        doc /* Quantum operator (3.2.11). Operator acting on quantum states in Hilbert space. */
        attribute :>> inputSpace : HilbertSpace;
    }
    abstract calc def ApplyQuantumOperator {
        in attribute op : QuantumOperator [1];
        in attribute inputState : QuantumState [1];
        return outputState [1];
    }
    abstract attribute def QuantumSuperposition {
        doc
        /* Quantum superposition (3.2.8). Complex linear combination of two or more different quantum states. 
         * Note 1 (3.2.9): Any quantum state can be written as a linear combination, or quantum superposition, of basis states */
        attribute componentStates : QuantumState [2..*] ordered;
        attribute amplitudes : ScalarValues::Complex [2..*] ordered nonunique;
        assert constraint oneAmplitudePerComponent {
            SequenceFunctions::size(amplitudes) == SequenceFunctions::size(componentStates)
        }
    }
    abstract attribute def QuantumEntanglement;
    /* Theroetical Terms defined from the ISO */
    abstract attribute def HilbertSpace {
        doc
        /* Hilbert space: vector space equipped with an inner product operation which allows distances, angles and vector norms to be defined, 
         * the space of quantum states (3.2.7) of a quantum system (3.2.6) is described by a complex Hilbert space, referred to as the state space.
         * Note 2 to entry: All possible quantum states can be represented as operators (3.2.2) on the quantum system’s Hilbert space. */
    }
    abstract attribute def WaveFunction {
        doc
        /* A quantum (3.2.4) wave-function is the mathematical representation of a quantum state in a particular
         * basis of the Hilbert space. Wave-functions are often defined over continuous parameters, such as position,
         * momentum and phase. (3.2.7 Note 2) */
        attribute representedState : QuantumState [1];
        attribute basis : Basis [1];
    }
    abstract attribute def Basis {
        doc
        /* Basis. Set of basis states spanning a Hilbert space, often complete and orthonormal (3.2.9 Note 2). 
         * Basis states are Members of a set of quantum states which span the Hilbert space (3.2.9) of a quantum system */
        attribute basisStates : QuantumState [1..*];
        attribute spannedSpace : HilbertSpace [1];
    }
}
