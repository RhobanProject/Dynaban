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
    long currentCommand;
    long previousCommand;
    long currentAngle;
    long previousAngle;
    long targetAngle;
    motorState state;
} motor;

void motor_init(encoder * pEnc);

void motor_update(encoder * pEnc);

void motor_setCommand(long pCommand);

/**
   /!\ pAngle must actually be 10x angle in degrees (1800 = 180°)
 */
void motor_setTargetAngle(long pAngle);
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
