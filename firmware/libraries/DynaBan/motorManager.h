#ifndef _MOTOR_MANAGER_H_
#define _MOTOR_MANAGER_H_
#include <wirish/wirish.h>
#include "magneticEncoder.h"


const bool HAS_CURRENT_SENSING = true;
const int CURRENT_ADC_PIN = 33;// PB1
const int AVERAGE_FACTOR_FOR_CURRENT = 16;
const int SUPER_AVERAGE_FACTOR_FOR_CURRENT = 16;
// 90% of 3000 (PWM period) :
const long MAX_COMMAND = 2700;
const long MAX_ANGLE = 3600;
const int PWM_1_PIN = 27; // PA8 --> Negative rotation
const int PWM_2_PIN = 26; // PA9 --> Positive rotation
const int SHUT_DOWN_PIN = 23; // PA12
const int NB_TICKS_BEFORE_UPDATING_SPEED = 8;
const int NB_TICKS_BEFORE_UPDATING_ACCELERATION = 8 * NB_TICKS_BEFORE_UPDATING_SPEED;
const int MAX_SPEED = 1023;

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
    long speed;
    long previousSpeed;
    long targetSpeed;
    bool speedUpdated;
    long acceleration;
    long targetAcceleration;
    bool accelerationUpdated;
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
