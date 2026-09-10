package QKD_Kit {
    public import QSysML::**;
    part def transmitterModule :> sender {
        part LaserDiode [2] : Source {
            attribute power : PowerUnit = 1;
            attribute class : LaserClasse;
            attribute wavelength : EmissivityAtASpecifiedWavelengthValue = 635;
            perform action generateLight;
        }
        part wavePlate1 {
            attribute angle : rotationAngles;
            perform action polariseLight;
        }
        port QC_A;
        port CC_A;
        perform action generatePolarisedLight : encodeLight;
    }
    part def receiverModule :> receiver {
        part wavePlate2 {
            attribute Angle : engravedAngles;
            perform action selectMeasurementBasis;
        }
        part beamSplitterCube : BeamSplitter {
            attribute direction : receiverDirections;
            perform action 'transmit/reflect IncidentLight';
        }
        part sensors [2] {
            attribute direction : receiverDirections;
            attribute distance : DisintegrationConstantValue;
            attribute incidentLightintensite : CallIntensityValue;
            assert constraint Distance : equalDistances;
            perform action measureIntensity;
            perform action sendSignals;
        }
        port QC_B;
        port CC_B;
        perform action detectLight : processDetection;
    }
    part def interceptModule :> Eve;
    action def encodeLight {
        action generateLight;
        action polariseLight {
            action selectPolarisingAngle;
        }
        action transmitLight;
        first start then generateLight;
        first generateLight then polariseLight;
        first polariseLight then transmitLight;
        first transmitLight then done;
    }
    action def processDetection {
        action receiveLight;
        action selectMeasurementBasis;
        action 'transmit/reflect IncidentLight';
        action monitorSensors;
        decide detectLight;
        action measureIntensity;
        action sendtrueSignal;
        action sendrandomSignal;
        first start then receiveLight;
        first receiveLight then selectMeasurementBasis;
        first selectMeasurementBasis then 'transmit/reflect IncidentLight';
        first 'transmit/reflect IncidentLight' then monitorSensors;
        first monitorSensors then measureIntensity;
        first measureIntensity then detectLight;
        first detectLight then sendtrueSignal;
        first detectLight then sendrandomSignal;
        first sendtrueSignal then done;
        first sendrandomSignal then done;
    }
    enum def laserMode {
        Pulse;
        Continuos;
    }
    enum def LEDColour {
        Off;
        Yellow;
        Blue;
        Green;
    }
    enum def detectedBit {
        none;
        Bit0;
        Bit1;
    }
    enum def LaserClasse {
        class_2;
    }
    enum def rotationAngles {
        H;
        V;
        D;
        A;
    }
    enum def engravedAngles {
        H;
        D;
    }
    enum def receiverDirections {
        aligned_with_LaserBeam;
        perpendicular_to_LaserBeam;
    }
    enum def switch {
        ON;
        OFF;
        longPress;
    }
    constraint def equalDistances;
    part Thorlab_QKD_Kit {
        part Alice : transmitterModule;
        part Bob : receiverModule;
        part Eve : interceptModule {
            part Transmitter : transmitterModule {
                perform action resendPolarisedLight : encodeLight;
            }
            part Receiver : receiverModule {
                perform action interceptConnection : processDetection;
            }
            port QC_E;
            port QC_E;
        }
        part Electronics {
            part powerSupply [4] {
                doc /* 2 for laser electronics and 2 for sensor electronics */
                attribute Voltage : SourceVoltageValue = 5 [V];
                exhibit state powerStatus : Boolean;
            }
            action def controlEmissions {
                action pressFireON;
                action 'hold button for 2 sec';
                action emitPulse;
                action 'hold button again';
                action emitContinuosWave;
                action pressFireOFF;
                first start then pressFireON;
                decide controlBeam;
                action needPulse;
                action needWave;
                first pressFireON then controlBeam;
                first needPulse then 'hold button for 2 sec';
                first needWave then 'hold button again';
                first 'hold button for 2 sec' then emitPulse;
                first 'hold button again' then emitContinuosWave;
                first pressFireOFF then done;
            }
            part laserElectronics [2] {
                doc /* It is a control unit to switch between pulse mode and continuos mode, Kit has 2 :one for Alice and oe for Eve */
                attribute time : TimeUnit = 2 [S];
                attribute fireSwitch : switch;
                attribute Mode : laserMode;
                perform action controlLaserDiode : controlEmissions {
                    first controlBeam then needPulse;
                    first controlBeam then needWave;
                    merge __unnamed1;
                    first emitContinuosWave then __unnamed1;
                    first emitPulse then __unnamed1;
                    first __unnamed1 then pressFireOFF;
                }
            }
            action def controlDetection {
                action adjustSensor;
                action lightLEDYellow;
                first start then __unnamed2;
                first adjustSensor then lightLEDYellow;
                decide detectAllignment;
                action needAdjustment;
                action lightLED1Blue;
                action lightLED2Blue;
                action repeatDetection;
                action confirmAdjustment;
                action setMeasuringMode;
                action lightLEDGreen;
                action readoutSensorInputs;
                first lightLEDYellow then detectAllignment;
                first detectAllignment then needAdjustment;
                first detectAllignment then lightLED1Blue;
                first lightLED1Blue then repeatDetection;
                first repeatDetection then lightLED2Blue;
                merge __unnamed2;
                first needAdjustment then __unnamed2;
                first __unnamed2 then adjustSensor;
                first lightLED2Blue then confirmAdjustment;
                first confirmAdjustment then setMeasuringMode;
                first setMeasuringMode then lightLEDGreen;
                first lightLEDGreen then readoutSensorInputs;
                first readoutSensorInputs then done;
            }
            state def sensorMode {
                state adjustMode;
                state measuringMode;
            }
            part sensorElectronics [2] {
                doc /* control/readout unit for the two optical sensors connected to each receiver side, this action is defined above. Kit has one for Eve and one for Bob */
                exhibit state controlMode : sensorMode;
                attribute lightIndicator : LEDColour;
                attribute inputsReadout : detectedBit;
                perform action controlSensors : controlDetection;
                port powerInput;
                port sensor1Input;
                port sensor2Input;
            }
        }
        part MechanicalSubsystem {
            part breadBoards;
            part holders;
            part screws;
            perform action mountComponents;
        }
    }
    view KitStructure : DS_Views::SymbolicViews::gv;
    view Interfaces : DS_Views::SymbolicViews::gv;
}
