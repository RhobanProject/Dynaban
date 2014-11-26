#ifndef _ASSERV_H_
#define _ASSERV_H_
#include <wirish/wirish.h>
#include "motorManager.h"
#include "magneticEncoder.h"

const int INITIAL_P_COEF = 40;
const int INITIAL_I_COEF = 0;
const int I_PRESCALE = 1;
const int MAX_DELTA_SUM = 1000;
//Would be good to wait a few reads before calculating the derivate :
const int INITIAL_D_COEF = 0;

const int INITIAL_TORQUE_P_COEF = 45;

typedef struct _asserv_ {
    long deltaAngle;
    int32 sumOfDeltas;
    int deltaAverageCurrent;
    int pCoef;
    int iCoef;
    int dCoef;
    int torquePCoef;
} asserv;

void asserv_init();
void asserv_tickP(motor * pMot);
void asserv_tickPID(motor * pMot);
void asserv_tickPIDOnTorque(motor * pMot);
void asserv_printAsserv();

#endif /* _ASSERV_H_ */
