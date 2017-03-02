/*************************************************************************
*  File Name	: 'trajectory_manager.h'
*  Author	    : Remi FABRE
*  Contact      : remi.fabre@labri.fr
*  Created	    : vendredi, février  6 2015
*  Licence	    : http://creativecommons.org/licenses/by-nc-sa/3.0/
*
*  Notes:
*************************************************************************/

#include <math.h>
#include <wirish/wirish.h>
#include "motor.h"
#if !defined(TRAJECTORY_MANAGER_H)
#define TRAJECTORY_MANAGER_H

/**
 * To do : test the kalman filter approach to get an approximation of the
 * current speed (intermediate solution between full model and full sensor)
 */
struct predictiveControl {
  float i0;
  float vAlim;
  float r;
  float ke;

  float kvis;
  float kstat;
  float kcoul;
  float linearTransition;

  float coulombContribution;
  float voltsToCommand;
  float stepsToRads;
  float torqueToVoltage;

  int32 estimatedSpeed;
  int32 previousCommand;
};

uint16 traj_constant_speed(uint16 pDistance, uint16 pTotalTime, uint16 pTime);
uint16 traj_min_jerk(uint16 pTime);
uint16 traj_min_jerk_on_speed(uint16 pTime);
void eval_powers_of_t(float* pTimePowers, uint16 pTime, uint8 pPolySize,
                      uint16 pPrescaler);
float traj_eval_poly(volatile float* pPoly, float* pTimePowers);
float traj_eval_poly_derivate(volatile float* pPoly, float* pTimePowers);
/*
 * a modulo b with a handling of the negative values that matches our needs
 */
uint32 traj_magic_modulo(int32 a, uint32 b);
void predictive_control_init();
void predictive_control_update();
predictiveControl* get_predictive_control();
void predictive_control_tick(motor* pMot, int32 pVGoal, uint32 pDt,
                             float pOutputTorque, float pIAdded);
void predictive_update_output_torques(int32 pCommand, int32 pSpeed);
void predictive_control_anti_gravity_tick(motor* pMot, int32 pVGoal,
                                          float pOutputTorque, float pIAdded);
int8 sign(int32 pInput);

void traj_interpolate_next_state(uint16 t, uint16 t0, uint16 dtControl,
                                 int16 current_state[3],
                                 int32* goalPosition, int32* goalSpeed,
                                 float* goalTorque);

#endif
