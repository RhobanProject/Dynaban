#include "motorManager.h"
#include "asserv.h"

static motor mot;
static int nbUpdates = 0;
static buffer previousAngleBuffer;

long currentRawMeasures[C_NB_RAW_MEASURES];
long currentTimming[C_NB_RAW_MEASURES];
int currentMeasureIndex = 0;
bool currentDetailedDebugOn = false;

//Debug timer, to be supressed : *************************************************************************************
HardwareTimer timer3(3);    

motor * motor_getMotor() {
    return &mot;
}

void motor_init(encoder * pEnc) {
    //Ensuring the shut down is active (inversed logic on this one)
    digitalWrite(SHUT_DOWN_PIN, LOW);
    pinMode(SHUT_DOWN_PIN, OUTPUT);
    digitalWrite(SHUT_DOWN_PIN, LOW);

    //Preparing the first PWM signal
    digitalWrite(PWM_1_PIN, LOW);
    pinMode(PWM_1_PIN, PWM);
    pwmWrite(PWM_1_PIN, 0x0000);

    //Preparing the second PWM signal
    digitalWrite(PWM_2_PIN, LOW);
    pinMode(PWM_2_PIN, PWM);
    pwmWrite(PWM_2_PIN, 0x0000);

    if (HAS_CURRENT_SENSING) {
        // ADC pin init
        pinMode(CURRENT_ADC_PIN, INPUT_ANALOG);
    }

    //Releasing the shutdown
    digitalWrite(SHUT_DOWN_PIN, HIGH);

    mot.command = pEnc->angle;
    mot.previousCommand = pEnc->angle;
    mot.angle = pEnc->angle;
    mot.previousAngle = pEnc->angle;
    //mot.angleBuffer = previousAngleBuffer;  
    buffer_init(&(mot.angleBuffer));
    mot.targetAngle = pEnc->angle;
    mot.speed = 0;
    mot.previousSpeed = 0;
    mot.targetSpeed = 0;
    mot.acceleration = 0;
    mot.targetAcceleration = 0;
    mot.state = MOVING;
    mot.current = 0;
    mot.averageCurrent = 0;
    mot.targetCurrent = 0;

    timer3.setPrescaleFactor(1);
    timer3.setOverflow(65535);
}

void motor_update(encoder * pEnc) {
    //buffer_printBuffer(&(mot.angleBuffer));
    buffer_add(&(mot.angleBuffer), mot.angle);
    mot.previousAngle = mot.angle;
    mot.angle = pEnc->angle;
        
    if (nbUpdates % NB_TICKS_BEFORE_UPDATING_SPEED == 0) {
        mot.speedUpdated = true;
        //Normal case 
        mot.speed = mot.angle - buffer_get(&(mot.angleBuffer));
        if (abs(mot.speed) > MAX_SPEED) {
            //Position went from near max to near 0 or vice-versa
            if (mot.angle > mot.previousAngle) {
                mot.speed = (buffer_get(&(mot.angleBuffer)) + MAX_ANGLE - mot.angle);
            } else if (mot.angle < mot.previousAngle) {
                mot.speed = (buffer_get(&(mot.angleBuffer)) - MAX_ANGLE + mot.angle);
            }
        }
                
    }

    if (nbUpdates == NB_TICKS_BEFORE_UPDATING_ACCELERATION) {
        mot.accelerationUpdated = true;
        nbUpdates = 0;
        mot.acceleration = mot.speed - mot.previousSpeed;
        mot.previousSpeed = mot.speed;
    }
    
    nbUpdates++;
}

void motor_readCurrent() {
    if (HAS_CURRENT_SENSING) {
        mot.current = analogRead(CURRENT_ADC_PIN) - 2048;

        if (abs(mot.current) > 500) {
            // Values that big are not taken into account
        } else {
            mot.averageCurrent = ((AVERAGE_FACTOR_FOR_CURRENT - 1) * mot.averageCurrent * PRESCALE + mot.current * PRESCALE) / (AVERAGE_FACTOR_FOR_CURRENT * PRESCALE);
        }
        
        /*digitalWrite(BOARD_TX_ENABLE, HIGH);
            Serial1.println("yop");
            Serial1.waitDataToBeSent();
            digitalWrite(BOARD_TX_ENABLE, LOW);*/
        
        if (currentDetailedDebugOn == true) {
            currentRawMeasures[currentMeasureIndex] = mot.current;
            currentTimming[currentMeasureIndex] = timer3.getCount();
            currentMeasureIndex++;
            if (currentMeasureIndex > (C_NB_RAW_MEASURES-1)) {
                currentDetailedDebugOn = false;
                currentMeasureIndex = 0;
            }
        }
    }
}

void motor_setCommand(long pCommand) {
    mot.previousCommand = mot.command;
    if (pCommand > MAX_COMMAND) {
        mot.command = MAX_COMMAND;
    } else if (pCommand < (-MAX_COMMAND)) {
        mot.command = -MAX_COMMAND;
    } else {
        mot.command = pCommand;
    }
    
    long command = mot.command;
    long previousCommand = mot.previousCommand;
    if (mot.state == COMPLIANT) {
        mot.state = MOVING;
        motor_restart();
    }
    
    if (command >= 0 && previousCommand >= 0) {
        //No need to change the spin direction
        motor_securePwmWrite(PWM_2_PIN, command);
    } else if (command <= 0 && previousCommand <= 0) {
        motor_securePwmWrite(PWM_1_PIN, abs(command));
    } else {
        // Change of spin direction procedure
        if (command > 0) {
            motor_securePwmWrite(PWM_1_PIN, 0);
            motor_securePwmWrite(PWM_2_PIN, 0);
            motor_securePwmWrite(PWM_2_PIN, command);
        } else {
            motor_securePwmWrite(PWM_2_PIN, 0);
            motor_securePwmWrite(PWM_1_PIN, 0);
            motor_securePwmWrite(PWM_1_PIN, abs(command));
        }
    }
}

void motor_securePwmWrite(uint8 pPin, uint16 pCommand){
    if (pCommand > MAX_COMMAND) {
        pwmWrite(pPin, MAX_COMMAND);
    } else {
        pwmWrite(pPin, pCommand);
    }
}

void motor_setTargetAngle(long pAngle) {
    //Reseting asserv to avoid inertia
    asserv_init();
    if (pAngle > MAX_ANGLE) {
        mot.targetAngle = MAX_ANGLE;
    } else if (pAngle < (-MAX_ANGLE)) {
        mot.targetAngle = -MAX_ANGLE;
    } else {
        mot.targetAngle = pAngle;
    }
}

void motor_setTargetCurrent(int pCurrent) {
    //Reseting asserv to avoid inertia
    asserv_init();
    mot.targetCurrent = pCurrent;
}

/**
   Will make the engine brake
 */
void motor_brake() {
    mot.state = BRAKE;
    mot.previousCommand = mot.command;
    mot.command = 0;
    pwmWrite(PWM_2_PIN, 0);
    pwmWrite(PWM_1_PIN, 0);
}

/**
   Will release the motor. Call restartMotor() to get out of this mode
 */
void motor_compliant() {
    mot.state = COMPLIANT;
    mot.previousCommand = mot.command;
    mot.command = 0;
    digitalWrite(SHUT_DOWN_PIN, LOW);
    pwmWrite(PWM_2_PIN, 0);
    pwmWrite(PWM_1_PIN, 0);
}

void motor_restart() {
    mot.state = MOVING;
    digitalWrite(SHUT_DOWN_PIN, HIGH);
}

#if BOARD_HAVE_SERIALUSB
void motor_printMotor() {
    SerialUSB.println();
    SerialUSB.println("*** Motor :");
    SerialUSB.print("command : ");
    SerialUSB.println(mot.command);
    SerialUSB.print("previousCommand : ");
    SerialUSB.println(mot.previousCommand);
    SerialUSB.print("angle : ");
    SerialUSB.println(mot.angle);
    SerialUSB.print("previousAngle : ");
    SerialUSB.println(mot.previousAngle);
    SerialUSB.print("targetAngle : ");
    SerialUSB.println(mot.targetAngle);
    SerialUSB.print("state : ");
    SerialUSB.println(mot.state);
    SerialUSB.print("speed : ");
    SerialUSB.println(mot.speed);
    SerialUSB.print("target speed : ");
    SerialUSB.println(mot.targetSpeed);
    SerialUSB.print("acceleration : ");
    SerialUSB.println(mot.acceleration);
    SerialUSB.print("target acceleration : ");
    SerialUSB.println(mot.targetAcceleration);
    SerialUSB.print("current : ");
    SerialUSB.println(mot.current);
    SerialUSB.print("averageCurrent : ");
    SerialUSB.println(mot.averageCurrent);
}
#else 
void motor_printMotor() {
    Serial1.println();
    Serial1.println("*** Motor :");
    Serial1.print("command : ");
    Serial1.println(mot.command);
    Serial1.print("previousCommand : ");
    Serial1.println(mot.previousCommand);
    Serial1.print("angle : ");
    Serial1.println(mot.angle);
    Serial1.print("previousAngle : ");
    Serial1.println(mot.previousAngle);
    Serial1.print("targetAngle : ");
    Serial1.println(mot.targetAngle);
    Serial1.print("state : ");
    Serial1.println(mot.state);
    Serial1.print("speed : ");
    Serial1.println(mot.speed);
    Serial1.print("target speed : ");
    Serial1.println(mot.targetSpeed);
    Serial1.print("acceleration : ");
    Serial1.println(mot.acceleration);
    Serial1.print("target acceleration : ");
    Serial1.println(mot.targetAcceleration);
    Serial1.print("current : ");
    Serial1.println(mot.current);
    Serial1.print("averageCurrent : ");
    Serial1.println(mot.averageCurrent);
}
#endif
