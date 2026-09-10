package E91_Protocol {
    doc
    /* this scheme is based on Bohms's version and Bell state to test Eve, entanglement-based QKD.
     * https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.67.661 */
    public import QSysML::**;
    view Logical_E91 : LogicalBlackView;
    part Logical_E91 : QKDSystem {
        item AliceBasis : measurementBasis;
        item BobBasis : measurementBasis;
        item 'EPR : Qubits' {
            item QubitA : Qubits;
            item QubitB : Qubits;
            attribute singletState : BipartiteQuantumState;
        }
        part EPR_Source : sender {
            perform action generateEPR;
            perform action emitEPR;
            perform generateSecretKey.generateEPR;
            perform generateSecretKey.emitEPR;
            port E {
                out item EPR;
            }
        }
        part Users : receiver {
            part Alice {
                port CC;
                port A {
                    in item QubitA;
                }
            }
            part Bob {
                port CC;
                port B {
                    in item QubitB;
                }
            }
            perform action receiveOneParticle;
            perform action chooseRanodemMeasurementSetting;
            perform action announceMeasurementSettings;
            perform action splitData;
            perform action generateRawKey { in attribute sameOrientation; }
            perform action performBellTest { in attribute diffOrientation; }
            perform action perfromPrivacyAmplification;
            perform action calcaulateBellCoeffecient;
            perform action detectEveInterception;
            attribute ViolationValue;
            perform action FlibBits;
            perform action performErrorCorrection;
            connect Alice.CC to Bob.CC;
            perform generateSecretKey.receiveOneParticle;
            perform generateSecretKey.chooseRanodemMeasurementSetting;
            perform generateSecretKey.announceMeasurementSettings;
            perform generateSecretKey.splitData;
            perform generateSecretKey.generateRawKey;
            perform generateSecretKey.performBellTest;
            perform generateSecretKey.calcaulateViolationValue;
            perform generateSecretKey.detectEveInterception;
            perform generateSecretKey.FlibBits;
            perform generateSecretKey.performErrorCorrection;
            perform generateSecretKey.perfromPrivacyAmplification;
        }
        perform action generateSecretKey {
            perform EPR_Source::generateEPR;
            perform EPR_Source::emitEPR;
            perform Users::receiveOneParticle;
            perform Users::chooseRanodemMeasurementSetting;
            perform Users::announceMeasurementSettings;
            perform Users::splitData;
            perform Users::generateRawKey;
            perform Users::performBellTest;
            perform Users::detectEveInterception;
            perform action calcaulateViolationValue ::> Users::calcaulateBellCoeffecient;
            perform Users::perfromPrivacyAmplification;
            perform Users::FlibBits;
            perform Users::performErrorCorrection;
            first start then generateEPR;
            first generateEPR then emitEPR;
            first emitEPR then receiveOneParticle;
            first receiveOneParticle then chooseRanodemMeasurementSetting;
            first chooseRanodemMeasurementSetting then announceMeasurementSettings;
            first announceMeasurementSettings then splitData;
            decide Decition {
                out attribute attribute1;
                out attribute attribute2;
            }
            first splitData then Decition;
            succession flow Decition.attribute1 to generateRawKey.sameOrientation;
            succession flow Decition.attribute2 to performBellTest.diffOrientation;
            first performBellTest then calcaulateViolationValue;
            first calcaulateViolationValue then detectEveInterception;
            first generateRawKey then FlibBits;
            first FlibBits then performErrorCorrection;
            first performErrorCorrection then perfromPrivacyAmplification;
            first perfromPrivacyAmplification then done;
            first detectEveInterception then done;
        }
        flow EPR_Source.E.EPR to Users.Alice.A.QubitA;
        flow EPR_Source.E.EPR to Users.Bob.B.QubitB;
    }
}
