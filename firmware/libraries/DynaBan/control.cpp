#include "control.h"
 
static control controlStruct;

void control_init() {
    controlStruct.deltaAngle = 0;
    controlStruct.deltaSpeed = 0;
    controlStruct.deltaAcceleration = 0;
    controlStruct.deltaAverageCurrent = 0;
    
    controlStruct.sumOfDeltas = 0;
    
    controlStruct.pCoef = INITIAL_P_COEF;
    controlStruct.iCoef = INITIAL_I_COEF;
    controlStruct.dCoef = INITIAL_D_COEF;
    controlStruct.speedPCoef = INITIAL_SPEED_P_COEF;
    controlStruct.accelerationPCoef = INITIAL_ACCELERATION_P_COEF;
    controlStruct.torquePCoef = INITIAL_TORQUE_P_COEF;
}

void control_tick_PID_on_position(motor * pMot) {
    controlStruct.deltaAngle = pMot->targetAngle - pMot->angle;

    if (abs(controlStruct.deltaAngle) > (MAX_ANGLE/2)) {
        // There is a shorter way, engine bro
        controlStruct.deltaAngle = pMot->angle - pMot->targetAngle;
    }

    controlStruct.sumOfDeltas = controlStruct.sumOfDeltas + controlStruct.deltaAngle;
    if (controlStruct.sumOfDeltas > MAX_DELTA_SUM) {
        controlStruct.sumOfDeltas = MAX_DELTA_SUM;
    } else if (controlStruct.sumOfDeltas < -MAX_DELTA_SUM) {
        controlStruct.sumOfDeltas = -MAX_DELTA_SUM;
    }
    
    motor_set_command(controlStruct.deltaAngle * controlStruct.pCoef 
                     + (controlStruct.sumOfDeltas * controlStruct.iCoef) / I_PRESCALE
                     + pMot->speed * controlStruct.dCoef);
}

void control_tick_P_on_position(motor * pMot) {
    controlStruct.deltaAngle = pMot->targetAngle - pMot->angle;
    if (abs(controlStruct.deltaAngle) > (MAX_ANGLE/2)) {
        // There is a shorter way, engine bro
        controlStruct.deltaAngle = pMot->angle - pMot->targetAngle;
    }

    motor_set_command(controlStruct.deltaAngle * controlStruct.pCoef);
}

void control_tick_PID_on_speed(motor * pMot) {
    if (pMot->speedUpdated == true) {
        pMot->speedUpdated = false;
        controlStruct.deltaSpeed = pMot->targetSpeed - pMot->speed;
    
        motor_set_command(controlStruct.deltaSpeed * controlStruct.speedPCoef * NB_TICKS_BEFORE_UPDATING_SPEED);
    }
    
}

void control_tick_PID_on_acceleration(motor * pMot) {
    if (pMot->accelerationUpdated == true) {
        pMot->accelerationUpdated = false;
        controlStruct.deltaAcceleration = pMot->targetAcceleration - pMot->acceleration;
        
        motor_set_command(controlStruct.deltaAcceleration * controlStruct.accelerationPCoef);
    }
    
}

void control_tick_PID_on_torque(motor * pMot) {
    controlStruct.deltaAverageCurrent = pMot->targetCurrent - pMot->averageCurrent;
    
    // /!\ the -1 conspiracy continues
    long command = - controlStruct.deltaAverageCurrent * controlStruct.torquePCoef;
    
    motor_set_command(command);
    
}

#if BOARD_HAVE_SERIALUSB
void control_print() {
    SerialUSB.println("***Control :");
    SerialUSB.print("deltaAngle : ");
    SerialUSB.println(controlStruct.deltaAngle);
}
#else 
void control_print() {
    Serial1.println();
    Serial1.println("***Control :");
    Serial1.print("deltaAngle : ");
    Serial1.println(controlStruct.deltaAngle);
    Serial1.print("sumOfDeltas : ");
    Serial1.println(controlStruct.sumOfDeltas);
    Serial1.print("deltaAverageCurrent : ");
    Serial1.println(controlStruct.deltaAverageCurrent);
}
#endif
