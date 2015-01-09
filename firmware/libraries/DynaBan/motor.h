#ifndef _MOTOR_MANAGER_H_
#define _MOTOR_MANAGER_H_
#include <wirish/wirish.h>
#include "magnetic_encoder.h"
#include "circular_buffer.h"

#define SHUT_DOWN_PIN PA12

const bool HAS_CURRENT_SENSING = true;
const int CURRENT_ADC_PIN = 33;// PB1
const long PRESCALE = 1 << 10;
const long AVERAGE_FACTOR_FOR_CURRENT = 256;
// 90% of 3000 (PWM period) :
const long MAX_COMMAND = 2700;
const long MAX_ANGLE = 4096;
const int PWM_1_PIN = 27; // PA8 --> Negative rotation
const int PWM_2_PIN = 26; // PA9 --> Positive rotation

const int NB_TICKS_BEFORE_UPDATING_SPEED = BUFF_SIZE;
const int NB_TICKS_BEFORE_UPDATING_ACCELERATION = 32 * NB_TICKS_BEFORE_UPDATING_SPEED;
const int MAX_SPEED = 1023;

const int C_NB_RAW_MEASURES = 60;
extern long currentRawMeasures[C_NB_RAW_MEASURES];
extern long currentTimming[C_NB_RAW_MEASURES];
extern int currentMeasureIndex;
extern bool currentDetailedDebugOn;

//Debug timer
extern HardwareTimer timer3;

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
    buffer angleBuffer;
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
    long targetCurrent;
} motor;

void motor_init(encoder * pEnc);

void motor_update(encoder * pEnc);

void motor_read_current();

void motor_set_command(long pCommand);

void motor_set_target_angle(long pAngle);

void motor_set_target_current(int pCurrent);

void motor_secure_pwm_write(uint8 pPin, uint16 pCommand);
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
