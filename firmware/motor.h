#ifndef _MOTOR_H_
#define _MOTOR_H_

#include <wirish/wirish.h>
#include "magnetic_encoder.h"
#include "circular_buffer.h"

#define SHUT_DOWN_PIN PA12
#define HAS_CURRENT_SENSING true
#define CURRENT_ADC_PIN 33 // PB1
#define AVERAGE_FACTOR_FOR_CURRENT 256
#define MAX_COMMAND 2950 // 98.3% of 3000 (PWM period)
#define MAX_ANGLE 4096
#define PWM_1_PIN 27 // PA8 --> Negative rotation
#define PWM_2_PIN 26 // PA9 --> Positive rotation

/*
  Dxl datasheet says (seems pretty accurate) max speed is :
  58rpm at 11.1V
  63rpm at 12V
  78rpm at 14.8V

  We'll follow the same unit convention than dynamixel :
  1 unit of speed = 0.114rpm
  max range speed = 1023 => 117.07 rpm (2048 => -117.07)
  526 speed unit ~= 60 rpm = 1 rps
  => NB_TICK_BEFORE_UPDATING_SPEED * 4096/(NB_TICKS_PER_SECOND) = 526
  => NB_TICK_BEFORE_UPDATING_SPEED = 526 * NB_TICKS_PER_SECOND / 4096
                                   = 128.418 ~= 128
 */
#define NB_TICKS_BEFORE_UPDATING_SPEED 25
#define NB_TICKS_BEFORE_UPDATING_ACCELERATION 8
#define C_NB_RAW_MEASURES 60
#define NB_POSITIONS_SAVED 1024 // 2048 over flows by 392 bytes

static const uint16 SPEED_COEF = 1000/NB_TICKS_BEFORE_UPDATING_SPEED;
static const uint16 MAX_SPEED = 8096/SPEED_COEF + 5;
static const long PRESCALE = 1 << 10;
extern long currentRawMeasures[C_NB_RAW_MEASURES];
extern long currentTimming[C_NB_RAW_MEASURES];
extern int currentMeasureIndex;
extern bool currentDetailedDebugOn;

extern int16 positionArray[NB_POSITIONS_SAVED];
extern int16 timeArray[NB_POSITIONS_SAVED];
extern uint16 positionIndex;
extern bool positionTrackerOn;
extern float addedInertia;

//Debug timer
extern HardwareTimer timer3;

enum motorState {
    COMPLIANT       = 0,
    BRAKE           = 1,
    MOVING          = 2,
};

struct motor {
    long command;
    long predictiveCommand;
    long previousCommand;
    long angle;
    long previousAngle;
    buffer angleBuffer;
    buffer speedBuffer;
    long targetAngle;
    long speed;
    long averageSpeed;
    long previousSpeed;
    int8 signOfSpeed;
    long targetSpeed;
    bool speedUpdated;
    long acceleration;
    long targetAcceleration;
    bool accelerationUpdated;
    motorState state;
    long current;
    long averageCurrent;
    long targetCurrent;
};

void motor_init(encoder * pEnc);

void motor_update(encoder * pEnc);

void motor_read_current();

void motor_update_sign_of_speed();

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

/**
 * Puts the motor in compliant mode. You'll need to shut the motor down to get out of this mode.
 */
void motor_temperatureIsCritic();

#endif /* _MOTOR_H_ */
