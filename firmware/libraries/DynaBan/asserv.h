#ifndef _ASSERV_H_
#define _ASSERV_H_
#include <wirish/wirish.h>
#include "motorManager.h"
#include "magneticEncoder.h"

const int NB_TICKS_PER_SECOND = 1000;
const int INITIAL_P_COEF = 32;
const int INITIAL_I_COEF = 0;
const int I_PRESCALE = 1;
const int MAX_DELTA_SUM = 1000;
const int INITIAL_D_COEF = 0;

const int INITIAL_SPEED_P_COEF = 45;
const int INITIAL_ACCELERATION_P_COEF = 45;
const int INITIAL_TORQUE_P_COEF = 45;

/*
  Dxl datasheet says (seems pretty accurate) :
  58rpm (at 11.1V)
  63rpm (at 12V)
  78rpm (at 14.8V)
  
  We'll follow the same unit convention :
  1 unit of speed = 0.114rpm
  max range speed = 1023 => 117.07 rpm
  526 speed unit ~= 60 rpm = 1 rps
  => K * NB_TICK_BEFORE_UPDATING_SPEED * 4096/(NB_TICKS_PER_SECOND) = 526 
  => SPEED_GAIN = K = NB_TICKS_PER_SECOND * 526 / (NB_TICKS_BEFORE_UPDATING_SPEED * 4096)
Very poor precision tho, to be changed
 */
const int SPEED_GAIN = 1;//NB_TICKS_PER_SECOND * 526 / (NB_TICKS_BEFORE_UPDATING_SPEED * 4096); == 16,061


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
