#include "asserv.h"
 
static asserv asservStruct;

void asserv_init() {
    asservStruct.deltaAngle = 0;
    asservStruct.deltaSpeed = 0;
    asservStruct.deltaAcceleration = 0;
    asservStruct.deltaAverageCurrent = 0;
    
    asservStruct.sumOfDeltas = 0;
    
    asservStruct.pCoef = INITIAL_P_COEF;
    asservStruct.iCoef = INITIAL_I_COEF;
    asservStruct.dCoef = INITIAL_D_COEF;
    asservStruct.speedPCoef = INITIAL_SPEED_P_COEF;
    asservStruct.accelerationPCoef = INITIAL_ACCELERATION_P_COEF;
    asservStruct.torquePCoef = INITIAL_TORQUE_P_COEF;
}

void asserv_tickPOnPosition(motor * pMot) {
    asservStruct.deltaAngle = pMot->targetAngle - pMot->angle;
    if (abs(asservStruct.deltaAngle) > (MAX_ANGLE/2)) {
        // There is a shorter way, engine bro
        asservStruct.deltaAngle = pMot->angle - pMot->targetAngle;
    }
    
    motor_setCommand(asservStruct.deltaAngle * asservStruct.pCoef);
}

void asserv_tickPIDOnPosition(motor * pMot) {
    asservStruct.deltaAngle = pMot->targetAngle - pMot->angle;

    if (abs(asservStruct.deltaAngle) > (MAX_ANGLE/2)) {
        // There is a shorter way, engine bro
        asservStruct.deltaAngle = pMot->angle - pMot->targetAngle;
    }

    asservStruct.sumOfDeltas = asservStruct.sumOfDeltas + asservStruct.deltaAngle;
    if (asservStruct.sumOfDeltas > MAX_DELTA_SUM) {
        asservStruct.sumOfDeltas = MAX_DELTA_SUM;
    } else if (asservStruct.sumOfDeltas < -MAX_DELTA_SUM) {
        asservStruct.sumOfDeltas = -MAX_DELTA_SUM;
    }
    
    motor_setCommand(asservStruct.deltaAngle * asservStruct.pCoef 
                     + (asservStruct.sumOfDeltas * asservStruct.iCoef) / I_PRESCALE
                     + pMot->speed * asservStruct.dCoef);
}

void asserv_tickPIDOnSpeed(motor * pMot) {
    if (pMot->speedUpdated == true) {
        pMot->speedUpdated = false;
        asservStruct.deltaSpeed = pMot->targetSpeed - pMot->speed;
    
        motor_setCommand(asservStruct.deltaSpeed * asservStruct.speedPCoef * NB_TICKS_BEFORE_UPDATING_SPEED);
    }
    
}

void asserv_tickPIDOnAcceleration(motor * pMot) {
    if (pMot->accelerationUpdated == true) {
        pMot->accelerationUpdated = false;
        asservStruct.deltaAcceleration = pMot->targetAcceleration - pMot->acceleration;
        
        motor_setCommand(asservStruct.deltaAcceleration * asservStruct.accelerationPCoef);
    }
    
}

void asserv_tickPIDOnTorque(motor * pMot) {
    asservStruct.deltaAverageCurrent = pMot->targetCurrent - pMot->averageCurrent;
    
    // /!\ the -1 conspiracy continues
    long command = - asservStruct.deltaAverageCurrent * asservStruct.torquePCoef;
    
    motor_setCommand(command);
}

#if BOARD_HAVE_SERIALUSB
void asserv_printAsserv() {
    SerialUSB.println("***Asserv :");
    SerialUSB.print("deltaAngle : ");
    SerialUSB.println(asservStruct.deltaAngle);
}
#else 
void asserv_printAsserv() {
    Serial1.println();
    Serial1.println("***Asserv :");
    Serial1.print("deltaAngle : ");
    Serial1.println(asservStruct.deltaAngle);
    Serial1.print("sumOfDeltas : ");
    Serial1.println(asservStruct.sumOfDeltas);
    Serial1.print("deltaAverageCurrent : ");
    Serial1.println(asservStruct.deltaAverageCurrent);
}
#endif
