#include "motorManager.h"


// 90% of 3000 (PWM period) :
const long MAX_COMMAND = 2700;
const long MAX_ANGLE = 3600;
const int PWM_1_PIN = 27; // PA8 --> Negative rotation
const int PWM_2_PIN = 26; // PA9 --> Positive rotation
const int SHUT_DOWN_PIN = 23; // PA12
static motor mot;


void motor_securePwmWrite(uint8 pPin, uint16 pCommand);

motor * motor_getMotor() {
    return &mot;
}

void motor_init(encoder * pEnc) {
    //Ensuring the shut down is active (inversed logic on this one)
    digitalWrite(SHUT_DOWN_PIN, LOW);
    pinMode(SHUT_DOWN_PIN, OUTPUT);
    digitalWrite(SHUT_DOWN_PIN, LOW);

    //Procedure to safely prepare the first PWM signal
    digitalWrite(PWM_1_PIN, LOW);
    pinMode(PWM_1_PIN, PWM);
    pwmWrite(PWM_1_PIN, 0x0000);

    //Procedure to safely prepare the second PWM signal
    digitalWrite(PWM_2_PIN, LOW);
    pinMode(PWM_2_PIN, PWM);
    pwmWrite(PWM_2_PIN, 0x0000);

    //Releasing the shutdown
    digitalWrite(SHUT_DOWN_PIN, HIGH);

    mot.currentCommand = pEnc->angle;
    mot.previousCommand = pEnc->angle;
    mot.currentAngle = pEnc->angle;
    mot.previousAngle = pEnc->angle;
    mot.targetAngle = pEnc->angle;
    mot.state = MOVING;
}

void motor_update(encoder * pEnc) {
    mot.previousAngle = mot.currentAngle;
    mot.currentAngle = pEnc->angle; 
}

void motor_setCommand(long pCommand) {
    mot.previousCommand = mot.currentCommand;
    if (pCommand > MAX_COMMAND) {
        mot.currentCommand = MAX_COMMAND;
    } else if (pCommand < (-MAX_COMMAND)) {
        mot.currentCommand = -MAX_COMMAND;
    } else {
        mot.currentCommand = pCommand;
    }
    
    long command = mot.currentCommand;
    long previousCommand = mot.previousCommand;
    if (mot.state == COMPLIANT) {
        mot.state = MOVING;
        motor_restart();
    }
    
    if (command >= 0 && previousCommand >= 0) {
        //No need to change the spin direction
        motor_securePwmWrite(PWM_2_PIN, command);
    } else if (command <= 0 && previousCommand <= 0) {
        motor_securePwmWrite(PWM_1_PIN, -command);
    } else {
        // Change of spin direction procedure
        if (command > 0) {
            motor_securePwmWrite(PWM_1_PIN, 0);
            motor_securePwmWrite(PWM_2_PIN, 0);
            delay(1); // This is not necessary, to be reduced or deleted
            motor_securePwmWrite(PWM_2_PIN, command);
        } else {
            motor_securePwmWrite(PWM_2_PIN, 0);
            motor_securePwmWrite(PWM_1_PIN, 0);
            delay(1); // This is not necessary, to be reduced or deleted
            motor_securePwmWrite(PWM_1_PIN, -command);
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
    if (pAngle > MAX_ANGLE) {
        mot.targetAngle = MAX_ANGLE;
    } else if (pAngle < (-MAX_ANGLE)) {
        mot.targetAngle = -MAX_ANGLE;
    } else {
        mot.targetAngle = pAngle;
    }
}

/**
   Will make the engine brake
 */
void motor_brake() {
    mot.state = BRAKE;
    mot.previousCommand = mot.currentCommand;
    mot.currentCommand = 0;
    pwmWrite(PWM_2_PIN, 0);
    pwmWrite(PWM_1_PIN, 0);
}

/**
   Will release the motor. Call restartMotor() to get out of this mode
 */
void motor_compliant() {
    mot.state = COMPLIANT;
    mot.previousCommand = mot.currentCommand;
    mot.currentCommand = 0;
    digitalWrite(SHUT_DOWN_PIN, LOW);
    pwmWrite(PWM_2_PIN, 0);
    pwmWrite(PWM_1_PIN, 0);
}

void motor_restart() {
    digitalWrite(SHUT_DOWN_PIN, HIGH);
}

#if BOARD_HAVE_SERIALUSB
void motor_printMotor() {
    SerialUSB.println("*** Motor :");
    SerialUSB.print("currentCommand : ");
    SerialUSB.println(mot.currentCommand);
    SerialUSB.print("previousCommand : ");
    SerialUSB.println(mot.previousCommand);
    SerialUSB.print("currentAngle : ");
    SerialUSB.println(mot.currentAngle);
    SerialUSB.print("previousAngle : ");
    SerialUSB.println(mot.previousAngle);
    SerialUSB.print("targetAngle : ");
    SerialUSB.println(mot.targetAngle);
    SerialUSB.print("state : ");
    SerialUSB.println(mot.state);
}
#else 
void motor_printMotor() {
    Serial1.println("*** Motor :");
    Serial1.print("currentCommand : ");
    Serial1.println(mot.currentCommand);
    Serial1.print("previousCommand : ");
    Serial1.println(mot.previousCommand);
    Serial1.print("currentAngle : ");
    Serial1.println(mot.currentAngle);
    Serial1.print("previousAngle : ");
    Serial1.println(mot.previousAngle);
    Serial1.print("targetAngle : ");
    Serial1.println(mot.targetAngle);
    Serial1.print("state : ");
    Serial1.println(mot.state);
}
#endif
