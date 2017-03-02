#ifndef _MOTOR_H_
#define _MOTOR_H_

#include <wirish/wirish.h>
#include "circular_buffer.h"
#include "dxl.h"
#include "magnetic_encoder.h"

#define SHUT_DOWN_PIN PA12
#define HAS_CURRENT_SENSING true
#define CURRENT_ADC_PIN 33  // PB1
#define AVERAGE_FACTOR_FOR_CURRENT 256
#define OVER_FLOW 3000
#define MAX_COMMAND 2950  // 98.3% of 3000 (PWM period)
#define MAX_ANGLE 4095
#define PWM_1_PIN 26  // PA9 --> Positive rotation
#define PWM_2_PIN 27  // PA8 --> Negative rotation

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
#define NB_TICKS_BEFORE_UPDATING_ACCELERATION 8
#define C_NB_RAW_MEASURES 0
#define NB_POSITIONS_SAVED 1024  // 2048 over flows by 392 bytes

static const int32 PRESCALE = 1 << 10;
extern int32 currentRawMeasures[C_NB_RAW_MEASURES];
extern int32 currentTimming[C_NB_RAW_MEASURES];
extern int currentMeasureIndex;
extern bool currentDetailedDebugOn;

extern int16 positionArray[NB_POSITIONS_SAVED];
extern uint16 timeArray[NB_POSITIONS_SAVED];
extern uint16 positionIndex;
extern bool positionTrackerOn;
extern bool predictiveCommandOn;
extern float addedInertia;

// Debug timer
extern HardwareTimer timer3;

enum motorState {
  COMPLIANT = 0,
  BRAKE = 1,
  MOVING = 2,
};

struct filter {
  float n0q, n1q, n2q, d1q, d2q;
  float xn_1, xn_2;
};

struct motor {
  int16 command;
  int16 predictiveCommand;
  int16 predictiveCommandTorque;
  int16 previousCommand;
  int16 angle;
  int16 previousAngle;
  buffer angleBuffer;
  buffer speedBuffer;
  int16 targetAngle;
  int32 speed;
  int32 averageSpeed;
  int32 previousSpeed;
  int8 signOfSpeed;
  int32 targetSpeed;
  bool speedUpdated;
  int32 acceleration;
  int32 targetAcceleration;
  bool accelerationUpdated;
  motorState state;
  int32 current;
  int32 averageCurrent;
  int32 targetCurrent;
  int16 posAngleLimit;
  int16 negAngleLimit;
  unsigned char testChar;
  int16 offset;
  boolean multiTurnOn;
  int16 multiTurnAngle;
  float electricalTorque;
  float outputTorque;
  float targetTorque;
  bool temperatureIsCritic;
  filter filt_speed;
  int16 feed_state[3];
};

void motor_init(encoder* pEnc);

void motor_restart_traj_timer();

void motor_update(encoder* pEnc);

void motor_read_current();

void motor_update_sign_of_speed();

void motor_set_command(int16 pCommand);

void motor_set_target_angle(int16 pAngle);

void motor_set_target_angle_multi_turn_mode(int16 pAngle);

void motor_set_target_current(int pCurrent);

/**
 * Returns pAngle if it's a valid target angle, otherwise it will return the
 * closest valid angle
 */
int16 motor_check_limit_angles(int16 pAngle);

/**
 * Returns true is pAngle is valid, false otherwise
 */
bool motor_is_valid_angle(int16 pAngle);

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

motor* motor_get_motor();

void motor_print_motor();

/**
 * Puts the motor in compliant mode.
 */
void motor_temperature_is_critic();

/**
 * Restarts the motor.
 */
void motor_temperature_is_okay();

void print_detailed_trajectory();

#endif /* _MOTOR_H_ */
