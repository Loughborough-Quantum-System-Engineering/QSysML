view General : DS_Views::SymbolicViews::gv;
package QSysML {
    public import ScalarValues::**;
    public import SysML::**;
    public import ISQ::**;
    public import SI::**;
    public import VectorValues::**;
    viewpoint def BlackBoxPerspective;
    viewpoint def WhiteBoxPerspective;
    viewpoint def CatBoxPerspective;
    viewpoint def PhysicalPerspective;
    viewpoint def LogicalPerspective;
    viewpoint def MappingPerspective;
    package BlackBox {
        view def PhysicalBlackView :> DS_Views::SymbolicViews::gv {
            viewpoint Physical : PhysicalPerspective;
            viewpoint BlackBox : BlackBoxPerspective;
        }
        view def LogicalBlackView :> DS_Views::SymbolicViews::gv {
            viewpoint Logical : LogicalPerspective;
            viewpoint BlackBox : BlackBoxPerspective;
        }
        view def MappingBlackView :> DS_Views::SymbolicViews::gv {
            viewpoint Mapping : MappingPerspective;
            viewpoint BlackBox : BlackBoxPerspective;
        }
    }
    package WhitekBox {
        view def PhysicalWhiteView :> DS_Views::SymbolicViews::gv {
            viewpoint Physical : PhysicalPerspective;
            viewpoint WhiteBox : WhiteBoxPerspective;
        }
        view def LogicalWhiteView :> DS_Views::SymbolicViews::gv {
            viewpoint Logical : LogicalPerspective;
            viewpoint WhiteBox : WhiteBoxPerspective;
        }
        view def MappingWhiteView :> DS_Views::SymbolicViews::gv {
            viewpoint Mapping : MappingPerspective;
            viewpoint WhiteBox : WhiteBoxPerspective;
        }
    }
    package CatBox {
        view def PhysicalCatView :> DS_Views::SymbolicViews::gv {
            viewpoint Physical : PhysicalPerspective;
            viewpoint CatBox : CatBoxPerspective;
        }
        view def LogicalCatView :> DS_Views::SymbolicViews::gv {
            viewpoint Logical : LogicalPerspective;
            viewpoint CatBox : CatBoxPerspective;
        }
        view def MappingCatView :> DS_Views::SymbolicViews::gv {
            viewpoint Mapping : MappingPerspective;
            viewpoint CatBox : CatBoxPerspective;
        }
    }
    package QuantumCore;
    doc /* Quantum terms that have been reused and shared among different applications
     */
    package ClassicalCore;
    doc /* Classical terms that have been reused and shared interfacing quantum applications
     */
    package QComms {
        part def QKDSystem {
            doc /* A QKD system is the complete system that enables two parties to generate a shared secret key using quantum states to enable secure communication */
        }
        part def receiver {
            doc /* A receiver is the whole physical side or subsystem that accepts the incoming signal. */
        }
        part def decoder :> receiver {
            doc /* A decoder is the part that interprets or extracts the encoded state from the received signal. */
        }
        part def singlePhotonDetector :> decoder {
            doc /* In QKD, the incoming optical pulse is very weak, often at the single-photon level. The SPD converts that optical event into an electrical signal that the electronics can record. */
        }
        part def sender;
        part def Source :> sender {
            doc /* this is the source of weak coherent pulse or sigle photon emitter */
        }
        part def singlePhotonGenerator :> Source {
            doc /* This could be Quantum dot single-photon source, NV-centre source, Heralded single-photon source, Spontaneous parametric down-conversion source */
            attribute wavelength;
            attribute repetitionRate;
            attribute emissionProbability;
            attribute singlePhotonPurity;
            attribute photonNumberPerPulse = 1;
        }
        part def encoder :> sender {
            doc /* A qubit is a two-level quantum state, and the “encoding” tells you which physical degree of freedom carries those two basis states.  */
        }
        part def transmitter :> sender {
            doc /* Transmitter usually means the physical hardware block. what hardware performs the sending */
        }
        part def BeamSplitter {
            doc
            /* Splitting one optical pulse into two paths, Recombining paths to create interference (creating phase difference),
             * separating measurement bases probabilistically, Setting intensity ratios in decoy-state QKD or modulator designs to control how much power */
        }
        part def Eve;
        item def preperationBasis;
        item def measurementBasis;
        item def Qubits {
            doc /* There are many kinds of qubits such as electrons, photons, quantum dots, Josephson junctions etc. P */
        }
        enum def carrierType {
            Photons;
            Electrons;
            quantumDots;
            Ions;
        }
        attribute def encodingMethod;
        enum def encodingMethod {
            Polarisation;
            TimeBin;
            phase;
            orbital_angular_momentum;
            frequency;
            path_spatial_mode;
        }
        enum def polarisationStates {
            Horizontal = 0;
            Vertical = 90;
            Diagonal = 45;
            AntiDiagonal = -45;
        }
        attribute def prepration_Basis;
        enum def prepration_Basis {
            Random;
            Superposition;
        }
        attribute def QuantumState;
        attribute def BipartiteQuantumState :> QuantumState;
        enum def QuantumState {
            pureState;
            mixedState;
        }
        enum def BellStateKind {
            phiPlus;
            phiMinus;
            psiPlus;
            psiMinus;
        }
        item def Bits;
        connection def channel {
            end transmitter;
            end receiver;
        }
        use case def QuantumOperations {
            action EntanglementGeneration;
            action EntanglementSwapping;
            action EntanglementPurification;
        }
    }
}
