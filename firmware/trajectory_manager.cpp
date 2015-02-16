
/*************************************************************************
*  File Name	: 'trajectory_manager.cpp'
*  Author	: Remi FABRE
*  Contact      : remi.fabre@labri.fr
*  Created	: vendredi, février  6 2015
*  Licence	: http://creativecommons.org/licenses/by-nc-sa/3.0/
*
*  Notes:
*************************************************************************/

#include "trajectory_manager.h"
#include <math.h>

#define kDelta 9.0
// #define kDelta 4.820
//#define ke     9.27
#define ke     0.6426
#define g      9.80665
#define m      0.270
#define L      0.12

static predictiveControl pControl;

uint16 traj_constant_speed(uint16 pDistance, uint16 pTotalTime, uint16 pTime) {
    return ((float)pDistance/(float)pTotalTime) * pTime;
}

uint16 traj_min_jerk(uint16 pTime) {
    if (pTime > 10000) {
        return 0;
    }
    float time   = ((float)pTime)/10000.0;
    float time_3 = time*time*time;
    float time_4 = time_3*time;
    float time_5 = time_4*time;
    int16 a3     = 20480;
    int16 a4     = -30720;
    int16 a5     = 12288;

    return time_3*a3 + time_4*a4 + time_5*a5;
}

uint16 traj_min_jerk_on_speed(uint16 pTime) {
    if (pTime > 10000) {
        return 0;
    }
    float time   = ((float)pTime)/10000.0;
    float time_2 = time*time;
    float time_3 = time_2*time;
    float time_4 = time_3*time;
    int16 a3     = 20480;
    int16 a4     = -30720;
    int16 a5     = 12288;

    return time_2*a3*3 + time_3*a4*4 + time_4*a5*5;
}

void predictive_control_init() {
    pControl.estimatedSpeed = 0;
    pControl.previousCommand = 0;
}

/**
 * The formula used here is u(t) = ke*v(t)  + (vGoal - v(t))*kDelta
 * Where kDelta = (I*r)/(dt*ke) ~= 4.820
 * and ke ~=0.6426
 */
void predictive_control_tick(motor * pMot, int16 pVGoal) {
    int16 v = pControl.estimatedSpeed;

     // int16 u = kDelta * (float)(pVGoal - v) + ke * (float)v;
    int16 u = kDelta * (float)(pVGoal - v + acceleration_from_weight_calib(pMot->angle)) + ke * (float)v;

    // int16 u = kDelta * ((float)(pVGoal - v) + acceleration_from_weight(pMot->angle, L)) + ke * (float)v;
    if (u > MAX_COMMAND) {
        u = MAX_COMMAND;
    }
    if (u < -MAX_COMMAND) {
        u = -MAX_COMMAND;
    }
    pMot->predictiveCommand = u;
    pControl.estimatedSpeed = pVGoal; // This is crazy and will never work. Actually it does work quite well.
}

float acceleration_from_weight(uint16 angle, float l) {
    float angleRad = (angle * (float)PI) / 2048.0;

    return (g * cos(angleRad) * 2048)/(l * (float)PI); // *2048/PI to get a in step.s-2 instead of rad.s-2
}

float acceleration_from_weight_calib(uint16 angle) {
    float angleRad = (angle * (float)PI) / 2048.0;
    return (cos(angleRad) * (float)68.47); // Found by measure
}
