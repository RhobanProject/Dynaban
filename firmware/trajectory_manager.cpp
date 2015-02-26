
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

#define kDelta_old 3.5//5.076//4.820 -> first calibration with an empty arm
#define ke_old     0.582//0.614//0.6426
#define g      9.80665
#define m      0.270
#define L      0.12

#define STATIC_FRICTION 80
#define I0     0 //0.00353 kg.m**2 is the measured moment of inertia when empty (gear box)
#define V_ALIM 12
#define r      6
#define STAT_TO_COUL_TRANS 1300 // To be checked

static const float unitFactor = (3000*2*PI) / ((float)(V_ALIM*4096)); // == 0.3834 at 12V

static float torqueToCommand   = 3.75;//3.56; // Should be r/ke (ke ~ 1.6) = 3.75. To be used with torques expressed in [N.m * 4096 / 2*PI]
static float kv                = 1.705;//1.462 // kv = ke + kvis
static float kstat             = STATIC_FRICTION / (torqueToCommand * unitFactor); // kstat * 1 * torqueToVolt * unitFactor should be equal to STATIC_FRICTION (min command to get the motor moving).
static float coulombMaxCommand = STATIC_FRICTION/4.567;
static float kcoul             = coulombMaxCommand / (torqueToCommand * unitFactor);

static predictiveControl pControl;

uint8 punchTicksRemaining = 0;


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
    pControl.estimatedSpeed = 1;
    pControl.previousCommand = 0;
}

/**
 * The formula used here is u(t) = unitFactor*[kv * v + torqueToCommand*(outputTorque + accelTorque + frictionTorque)]
 *
 * Where :
 * -> unitFactor*kv*v(t) is the command needed to mantain the current speed (kv = ke + kvis, where kvis is the viscous constant)
 * -> unitFactor*torqueToCommand*torque is the command that will make the motor create 'torque' (expressed in N.m*4096/2*PI) during dt
 * -> frictionTorque compensates the static and the coulomb friction
 * -> outputTorque is the actual torque that could be measured outside the motor
 * -> accelTorque  = I * a(t) is the torque needed to create an acceleration of a(t) during dt, provided that 'outputTorque' is
 * either null or absorbed by the environment (which is typically the case when it's used as a weight compensation)
 * -> I = I0 + pIAdded (I0 is the moment of inertia of the gearbox)
 * -> a(t) = (pVGoal - v)/dt
 */
void predictive_control_tick(motor * pMot, int16 pVGoal, uint16 pDt, float pOutputTorque, float pIAdded) {
    int16 v = pControl.estimatedSpeed;
    float beta = exp(-abs( v / ((float)STAT_TO_COUL_TRANS) ));
    float accelTorque = ((float)(pVGoal - v) * (I0 + pIAdded) * 10000)/((float)pDt); // dt is in 1/10 of a ms
    float frictionTorque = sign(v) * (beta * kstat + (1 - beta) * kcoul);

    int16 u = unitFactor *
        (kv * v + torqueToCommand * (accelTorque + frictionTorque + pOutputTorque));

    if (u > MAX_COMMAND) {
        u = MAX_COMMAND;
    }
    if (u < -MAX_COMMAND) {
        u = -MAX_COMMAND;
    }
    pMot->predictiveCommand = u;
    pControl.estimatedSpeed = pVGoal; /* Would be better if we could get the real-life speed from time to time to update this value.
                                       * This is no easy task since getting the speed from a derivate of the position comes with the
                                       * tradeoff delay VS accuracy.
                                       */
}

/**
 * The formula used here is u(t) = ke*v(t)  + (vGoal - v(t))*kDelta
 * Where kDelta = (I*r)/(dt*ke) ~= 4.820
 * and ke ~=0.6426
 */
void predictive_control_tick_simple(motor * pMot, int16 pVGoal) {
    int16 v = pControl.estimatedSpeed;
    int16 punchValue = 350;

    if (punchTicksRemaining > 0) {
            // We are in punch mode
        punchTicksRemaining--;
        pMot->predictiveCommand = sign(pVGoal) * punchValue;
        if (punchTicksRemaining == 0) {
            pControl.estimatedSpeed = 40;
        }
        return;
    }

    if (abs(v) < 40 && abs(v) < abs(pVGoal)) {
            // We assume that the actual speed is 0. The time the motor needs to start moving depends on the command.
            // The idea is to minimize that time. The motor needs ~6.1 ms to start moving when the command is at its maximum
        punchTicksRemaining = 1;
        pMot->predictiveCommand = (sign(pVGoal) * punchValue);
        pControl.estimatedSpeed = 0;
        return;

    }

        // Normal case
    float angleRad = (pMot->angle * (float)PI) / 2048.0;
    float weightCompensation = cos(angleRad) * 140.0;//235.0;
        // int16 u = kDelta * (float)(pVGoal - v) + ke * (float)v;
        // int16 u = kDelta * (float)(pVGoal - v + acceleration_from_weight_calib(pMot->angle)) + ke * (float)v;
    int16 u = kDelta_old * (float)(pVGoal - v)
        + ke_old * (float)v
        + static_friction(v);

        // + weightCompensation
        // + static_friction(v)
        // + viscous_friction(v);
        // int16 u = kDelta * (float)(acceleration_from_weight_calib(pMot->angle));

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
    float result = (cos(angleRad) * (float)68.47); // Found by measure
    // int add = 50;

    // if (result > 0) {
    //     if (result < add) {
    //         result = add;
    //     }
    // } else {
    //     result = result + add;
    // }

    return result;
}

int16 static_friction(int16 v) {
    uint16 limitConstant = 41;
    uint16 limitLinear = 400;
    float coef = 1.0/((float)(limitLinear - limitConstant));

    if (abs(v) < limitConstant) {
        return STATIC_FRICTION*sign(v);
    } else if (abs(v) < limitLinear) {
        return STATIC_FRICTION * (1 - coef * (v - limitConstant));
    }

    return 0;

}

float viscous_friction(int16 v) {
    uint16 linearLimit = 3000;
    float coef = 0.1;//0.168;
    return v * coef;
    // if (abs(v) < linearLimit) {
    //     return v * coef;
    // } else {
    //         //Apparently the viscous friction reduces when speed is high enough !
    //     return (3000 - v) * coef;
    // }

}

char sign(int16 pInput) {
    if (pInput > 0) {
        return 1;
    } else if (pInput < 0) {
        return -1;
    } else {
        return 0;
    }
}
