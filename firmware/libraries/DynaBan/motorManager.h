#ifndef _MOTOR_MANAGER_H_
#define _MOTOR_MANAGER_H_
#include <wirish/wirish.h>
#include "magneticEncoder.h"


typedef enum _motorState_ {
    COMPLIANT       = 0,
    BRAKE           = 1,
    MOVING          = 2,
} motorState;

typedef struct _motor_ {
    long command;
    long previousCommand;
    long angle;
    long previousAngle;
    long targetAngle;
    motorState state;
    long current;
    long averageCurrent;
    long superAverageCurrent;
    long targetCurrent;
} motor;


void motor_init(encoder * pEnc);

void motor_update(encoder * pEnc);

void motor_readCurrent();

void motor_setCommand(long pCommand);

/**
   /!\ pAngle must actually be 10x angle in degrees (1800 = 180°)
 */
void motor_setTargetAngle(long pAngle);

void motor_setTargetCurrent(int pCurrent);

/**
   Will make the engine brake
 */
void motor_brake();

/**
   Will release the motor. Call restartMotor() to get out of this mode
 */
void motor_compliant();

void motor_restart();

motor * motor_getMotor();

void motor_printMotor();

#endif /* _MOTOR_MANAGER_H_ */
