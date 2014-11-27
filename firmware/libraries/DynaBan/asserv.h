#ifndef _ASSERV_H_
#define _ASSERV_H_
#include <wirish/wirish.h>
#include "motorManager.h"
#include "magneticEncoder.h"

const int INITIAL_P_COEF = 32;
const int INITIAL_I_COEF = 0;
const int I_PRESCALE = 1;
const int MAX_DELTA_SUM = 1000;
const int INITIAL_D_COEF = 0;

const int INITIAL_SPEED_P_COEF = 45;
const int INITIAL_ACCELERATION_P_COEF = 45;
const int INITIAL_TORQUE_P_COEF = 45;

typedef struct _asserv_ {
    int deltaAngle;
    int deltaSpeed;
    int deltaAcceleration;
    int deltaAverageCurrent;
    int32 sumOfDeltas;
    int pCoef;
    int iCoef;
    int dCoef;
    int speedPCoef;
    int accelerationPCoef;
    int torquePCoef;
} asserv;

void asserv_init();
void asserv_tickPOnPosition(motor * pMot);
void asserv_tickPIDOnPosition(motor * pMot);
void asserv_tickPIDOnSpeed(motor * pMot);
void asserv_tickPIDOnAcceleration(motor * pMot);
void asserv_tickPIDOnTorque(motor * pMot);
void asserv_printAsserv();

#endif /* _ASSERV_H_ */
