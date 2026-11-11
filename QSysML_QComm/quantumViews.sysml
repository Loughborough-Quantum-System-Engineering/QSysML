package quantumViews {
    private import Views::*;
    part def Stakeholder;
    viewpoint def BlackBoxPerspective {
        subject systemEngineering;
        stakeholder SystemsEngineers : Stakeholder;
        concern def SE {
            /* whether the whole system is well-defined, integrated, traceable, and verifiable, rather than the detailed physics of one component. */
        }
    }
    viewpoint def WhiteBoxPerspective {
        subject quantumPhysics;
        stakeholder QuantumPhysists : Stakeholder;
        concern def QP {
            /* Does the model of each elemental part truly represent the physics, and is that representation mathematically correct? */
        }
    }
    viewpoint def CatBoxPerspective {
        subject quantumSystemsEngineering;
        stakeholder quantumSystemEngineer : Stakeholder;
        concern def QSE {
            /* Can the behaviour of elemental quantum parts be traced to system-level functions and requirements, in terms both physicists and systems engineers understand? */
        }
    }
    viewpoint def PhysicalPerspective;
    viewpoint def LogicalPerspective;
    viewpoint def MappingPerspective;
    view def PhysicalBlackView :> DS_Views::SymbolicViews::gv {
        viewpoint Physical : PhysicalPerspective;
        viewpoint BlackBox : BlackBoxPerspective {
            subject;
        }
    }
    view def LogicalBlackView :> DS_Views::SymbolicViews::gv {
        viewpoint Logical : LogicalPerspective;
        viewpoint BlackBox : BlackBoxPerspective {
            subject;
        }
    }
    view def MappingBlackView :> DS_Views::SymbolicViews::gv {
        viewpoint Mapping : MappingPerspective;
        viewpoint BlackBox : BlackBoxPerspective {
            subject;
        }
    }
    view def PhysicalWhiteView :> DS_Views::SymbolicViews::gv {
        viewpoint Physical : PhysicalPerspective;
        viewpoint WhiteBox : WhiteBoxPerspective {
            subject;
        }
    }
    view def LogicalWhiteView :> DS_Views::SymbolicViews::gv {
        viewpoint Logical : LogicalPerspective;
        viewpoint WhiteBox : WhiteBoxPerspective {
            subject;
        }
    }
    view def MappingWhiteView :> DS_Views::SymbolicViews::gv {
        viewpoint Mapping : MappingPerspective;
        viewpoint WhiteBox : WhiteBoxPerspective {
            subject;
        }
    }
    view def PhysicalCatView :> DS_Views::SymbolicViews::gv {
        viewpoint Physical : PhysicalPerspective;
        viewpoint CatBox : CatBoxPerspective {
            subject;
        }
    }
    view def LogicalCatView :> DS_Views::SymbolicViews::gv {
        viewpoint Logical : LogicalPerspective;
        viewpoint CatBox : CatBoxPerspective {
            subject;
        }
    }
    view def MappingCatView :> DS_Views::SymbolicViews::gv {
        viewpoint Mapping : MappingPerspective;
        viewpoint CatBox : CatBoxPerspective {
            subject;
        }
    }
    view QuantumViews : DS_Views::SymbolicViews::gv {
        expose quantumViews::*;
    }
}
