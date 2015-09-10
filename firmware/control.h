#ifndef _CONTROL_H_
#define _CONTROL_H_
#include <wirish/wirish.h>
#include "motor.h"
#include "magnetic_encoder.h"

const int NB_TICKS_PER_SECOND = 1000;
const int INITIAL_P_COEF = 16;//32; //8;
const int INITIAL_I_COEF = 1;
const float I_PRESCALE = 50.0;
const int MAX_DELTA_SUM = 1024;
const int INITIAL_D_COEF = 0;

const float INITIAL_SPEED_P_COEF = 0.5;
const int INITIAL_ACCELERATION_P_COEF = 20;
const int INITIAL_TORQUE_P_COEF = 45;

struct control {
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
};

control * get_control_struct();

void control_init();

// Resets control specific temporary variables
void control_reset();

// PID position control
void control_tick_PID_on_position(motor * pMot);

// P-only position control cos lets be honest
void control_tick_P_on_position(motor * pMot);

// Open loop control using the predictive command (useful for calibration of the predictive command)
void control_tick_predictive_command_only(motor * pMot);

// PID + predictive control
void control_tick_PID_and_predictive_command(motor * pMot);

// P-only speed control
void control_tick_P_on_speed(motor * pMot);

// P-only acceleration control
void control_tick_P_on_acceleration(motor * pMot);

// Returns the signed difference between 2 angles
long control_angle_diff(long a, long b);

// Returns the other angle between 2 angles (the bigger one, aka the on that is bigger than MAX_ANGLE/2)
long control_other_angle_diff(long a, long b);

// P-only torque control
void control_tick_P_on_torque(motor * pMot);

// Prints debug info through Serial1
void control_print();

#endif /* _CONTROL_H_ */
