
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
#include "dxl_HAL.h"

static predictiveControl pControl;


void predictive_control_init() {
    pControl.i0 					= 0.00353; 	//kg.m**2. Measured moment of inertia when empty (gear box)
    pControl.vAlim 					= 12; 		// V
    pControl.r 						= 4.07; 	// Ohm. Datasheet says 5.86 ohm but is not reliable
    pControl.ke 					= 1.399; 	// V.s/rad (voltage/rotational speed).
    /*
     * The datasheet of the supposed motor from maxon says 694/200 rpm/V (the 200 come from the gear box ratio) = 0.3634 rad/(s*V) => ke = 2.75 V*s/rad
     * Btw the ke (in V*s/rad) == kt (in N.m/A) is valid in the datasheet since they give torqueConstant = 13.8*200 mN.m/A (the 200 come from the gear box ratio) = 2.76 N.m/A
     * After manually counting the teeth of the gears, the actual gear box ratio is 172.08...
     */
    pControl.kvis 					= -0.0811; 	// in N.m.s/rad
    pControl.linearTransition 		= 0.195; 	// in rad/s.
    pControl.kstat 					= 0.1212; 	//N.m. Minimum torque needed to start moving the motor
    pControl.kcoul 					= 0.103; 	/* in N.m value of the friction torque when speed = linearTransition.
                                                                                                                                                                                                                                                                                                               The coulombContribution value makes sure this is true.*/
    pControl.coulombContribution 	= (pControl.kvis*pControl.linearTransition - exp(-1)*pControl.kstat + pControl.kcoul)/(1 - exp(-1)); //N.m

    pControl.voltsToCommand 		= 3000/pControl.vAlim; 		// Command/V
    pControl.stepsToRads 			= 2*PI/4096.0; 				// rad/step
    pControl.torqueToVoltage 		= pControl.r / pControl.ke; // in Ohm.rad/(V.s) = V/(N.m)

    pControl.estimatedSpeed 		= 1;
    pControl.previousCommand 		= 0;
}

/**
 * This function must be called if the parameters of the model have been changed
 */
void predictive_control_update() {
    pControl.coulombContribution 	= (pControl.kvis*pControl.linearTransition - exp(-1)*pControl.kstat + pControl.kcoul)/(1 - exp(-1)); //N.m
    pControl.voltsToCommand 		= 3000/pControl.vAlim; 		// Command/V
    pControl.stepsToRads 			= 2*PI/4096.0; 				// rad/step
    pControl.torqueToVoltage 		= pControl.r / pControl.ke; // in Ohm.rad/(V.s) = V/(N.m)
}

predictiveControl * get_predictive_control() {
    return &pControl;
}

uint16 traj_constant_speed(uint32 pDistance, uint16 pTotalTime, uint16 pTime) {
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
    int32 a3     = 20480;
    int32 a4     = -30720;
    int32 a5     = 12288;

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
    int32 a3     = 20480;
    int32 a4     = -30720;
    int32 a5     = 12288;

    return time_2*a3*3 + time_3*a4*4 + time_4*a5*5;
}

void eval_powers_of_t(float * pTimePowers, uint16 pTime, uint8 pPolySize, uint16 pPrescaler) {
    if (pPolySize >= 5) {
        pTimePowers[0] = pTime/(float)pPrescaler; // t
        pTimePowers[1] = pTimePowers[0]*pTimePowers[0]; // t**2
        pTimePowers[2] = pTimePowers[1]*pTimePowers[0]; // t**3
        pTimePowers[3] = pTimePowers[2]*pTimePowers[0]; // t**4
    } else if (pPolySize == 4) {
        pTimePowers[0] = pTime/(float)pPrescaler; // t
        pTimePowers[1] = pTimePowers[0]*pTimePowers[0]; // t**2
        pTimePowers[2] = pTimePowers[1]*pTimePowers[0]; // t**3
        pTimePowers[3] = 0.0;
    } else if (pPolySize == 3) {
        pTimePowers[0] = pTime/(float)pPrescaler; // t
        pTimePowers[1] = pTimePowers[0]*pTimePowers[0]; // t**2
        pTimePowers[2] = 0.0;
        pTimePowers[3] = 0.0;
    } else if (pPolySize == 2) {
        pTimePowers[0] = pTime/(float)pPrescaler; // t
        pTimePowers[1] = 0.0;
        pTimePowers[2] = 0.0;
        pTimePowers[3] = 0.0;
    } else {
        pTimePowers[0] = 0.0;
        pTimePowers[1] = 0.0;
        pTimePowers[2] = 0.0;
        pTimePowers[3] = 0.0;
    }
}

float traj_eval_poly(volatile float * pPoly, float * pTimePowers) {

    return pPoly[0]
        + pTimePowers[0]*pPoly[1]
        + pTimePowers[1]*pPoly[2]
        + pTimePowers[2]*pPoly[3]
        + pTimePowers[3]*pPoly[4];
}

float traj_eval_poly_derivate(volatile float * pPoly, float * pTimePowers) {
    return pPoly[1]
        + pTimePowers[0]*2*pPoly[2]
        + pTimePowers[1]*3*pPoly[3]
        + pTimePowers[2]*4*pPoly[4];
}

/*
 * a modulo b with a handling of the negative values that matches our needs
 */
uint32 traj_magic_modulo(int32 a, uint32 b) {
    if (a > 0) {
        return a%b;
    } else {
        uint32 div = a/b;
        a = a + (abs(div)+1)*b;
        return a%b;
    }
}


/**
 * The formula used here is u(t) = voltsToCommand*[ke * speedInRads + torqueToVoltage*(outputTorque + accelTorque - frictionTorque)]
 *
 * Where :
 * -> voltsToCommand*ke*speedInRads is the command needed to maintain the current speed if there was no friction
 * -> voltsToCommand*torqueToVoltage*torque is the command that will make the motor create 'torque' (expressed in N.m)
 * -> frictionTorque is the torque created by the static friction, the coulomb friction and the viscous friction
 * -> outputTorque is the actual torque that could be measured outside the motor
 * -> accelTorque  = I * a(t) is the torque needed to create an acceleration of a(t) during dt, provided that 'outputTorque' is
 * either null or absorbed by the environment (which is typically the case when it's used as a weight compensation)
 * 		-> I = I0 + pIAdded (I0 is the moment of inertia of the gearbox)
 * 		-> a(t) = (pVGoal - v)/dt
 */
void predictive_control_tick(motor * pMot, int32 pVGoal, uint32 pDt, float pOutputTorque, float pIAdded) {
    int32 v = pControl.estimatedSpeed;//pMot->speed;
    int8 signV = sign(v);
    float speedInRads = v*pControl.stepsToRads; // rad/s
    float goalSpeedInRads = pVGoal*pControl.stepsToRads; // rad/s


    float beta = exp(-abs( speedInRads /pControl.linearTransition)); // range [0, 1]
    float accelTorque = ((goalSpeedInRads - speedInRads) * (pControl.i0 + pIAdded) * 10000.0)/((float)pDt); // in N.m. dt is in 1/10 of a ms
    float frictionTorque = signV * (beta * pControl.kstat + (1 - beta) * pControl.coulombContribution);

    int16 u = pControl.voltsToCommand *
        (pControl.ke * speedInRads + pControl.torqueToVoltage * (accelTorque - frictionTorque));
    int16 uTorque = pControl.voltsToCommand *
            (pControl.torqueToVoltage * (pOutputTorque));

    int32 totalU = u + uTorque;
    if (totalU > MAX_COMMAND) {
    	int16 diff = totalU - MAX_COMMAND;
        u = u - diff/2;
        uTorque = uTorque - diff/2;
    }
    if (totalU < -MAX_COMMAND) {
        	int16 diff = totalU + MAX_COMMAND;
            u = u - diff/2;
            uTorque = uTorque - diff/2;
        }
    pMot->predictiveCommand = u;
    pMot->predictiveCommandTorque = uTorque;
    pControl.estimatedSpeed = pVGoal; /* Would be better if we could get the real-life speed from time to time to update this value.
                                       * This is no easy task since getting the speed from a derivate of the position comes with the
                                       * tradeoff delay VS accuracy.
                                       */
    // Updating the output torque estimations
    dxl_regs.ram.ouputTorque = accelTorque + pOutputTorque;
    dxl_regs.ram.electricalTorque = accelTorque - frictionTorque + pOutputTorque;
}

/**
 * Estimates the torque that's outputed by the motor (with and without accounting for friction), when the command is pCommand and the rotationnal speed
 * is pSpeed.
 * Same formula as predictive_control_tick but this function is used only to update the output torques. Torque units in in [N.m]
 *
 */
void predictive_update_output_torques(int32 pCommand, int32 pSpeed) {
    int8 signV = sign(pSpeed);
    float speedInRads = pSpeed*pControl.stepsToRads; // rad/s

    //	int16 u = pControl.voltsToCommand *(pControl.ke * speedInRads + pControl.torqueToVoltage * (accelTorque - frictionTorque + pOutputTorque));
    float electricalTorque = ((pCommand/pControl.voltsToCommand) - pControl.ke*speedInRads)/pControl.torqueToVoltage; // == -frictionTorque + outputTorque

    float beta = exp(-abs( speedInRads /pControl.linearTransition)); // range [0, 1]
    float frictionTorque = signV * (beta * pControl.kstat + (1 - beta) * pControl.coulombContribution);
    float outputTorque = electricalTorque + frictionTorque;

    // Updating the output torque estimations
    dxl_regs.ram.ouputTorque = outputTorque;
    dxl_regs.ram.electricalTorque = electricalTorque;

}

/**
 * The formula used here is u(t) = voltsToCommand*[ke * speedInRads + torqueToVoltage*(outputTorque - frictionTorque)]
 *
 * Where :
 * -> voltsToCommand*ke*speedInRads is the command needed to maintain the current speed if there was no friction
 * -> voltsToCommand*torqueToVoltage*torque is the command that will make the motor create 'torque' (expressed in N.m)
 * -> frictionTorque is the torque created by the static friction, the coulomb friction and the viscous friction
 * -> outputTorque is the actual torque that could be measured outside the motor
 */
void predictive_control_anti_gravity_tick(motor * pMot, int32 pVGoal, float pOutputTorque, float pIAdded) {
    int32 v = pMot->speed;//(pMot->averageSpeed);//pControl.estimatedSpeed;

    // Hack for anti-gravity/friction arm :
    /* The issue here is that our initial model states that the static friction depends on the sign of the current speed
     * which is true as long as the speed is not null.
     * When the speed is null, the static friction will oppose itself to the torque applied on the motor.
     **/
    int8 signV = pMot->signOfSpeed;
    if (signV == 1) {
        digitalWrite(BOARD_LED_PIN, HIGH);
    } else if (signV == -1) {
        digitalWrite(BOARD_LED_PIN, LOW);
    } else {
        // digitalWrite(BOARD_LED_PIN, LOW);
    }
    // Un-comment this to emulate an old windows PC loading a program (quite funny)
    // if (pMot->averageCurrent > 0) {
    //     signV = 1;
    //     digitalWrite(BOARD_LED_PIN, LOW);
    // } else if (pMot->averageCurrent < 0) {
    //     signV = -1;
    //     digitalWrite(BOARD_LED_PIN, LOW);
    // } else {
    //     signV = 0;
    //     digitalWrite(BOARD_LED_PIN, HIGH);
    // }

    float speedInRads = v*pControl.stepsToRads; // rad/s


    float beta = exp(-abs( speedInRads /pControl.linearTransition)); // range [0, 1]
    float frictionTorque = signV * (beta * pControl.kstat + (1 - beta) * pControl.coulombContribution);

    int16 u = pControl.voltsToCommand *
        (pControl.ke * speedInRads + pControl.torqueToVoltage * (- frictionTorque + pOutputTorque));

    if (u > MAX_COMMAND) {
        u = MAX_COMMAND;
    }
    if (u < -MAX_COMMAND) {
        u = -MAX_COMMAND;
    }
    pMot->predictiveCommand = u;
    pControl.estimatedSpeed = v;

    // Updating the output torque estimations
    dxl_regs.ram.ouputTorque = pOutputTorque;
    dxl_regs.ram.electricalTorque = frictionTorque + pOutputTorque;
}


int8 sign(int32 pInput) {
    if (pInput > 0) {
        return 1;
    } else if (pInput < 0) {
        return -1;
    } else {
        return 0;
    }
}
