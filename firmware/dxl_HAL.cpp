#include "dxl.h"
#include "dxl_HAL.h"
#include <string.h>
#include "circular_buffer.h"
#include "trajectory_manager.h"

void dxl_print_debug();

unsigned int dxl_data_available() {
    return Serial1.available();
}

ui8 dxl_data_byte() {
    return Serial1.read();
}

void dxl_send(ui8 *buffer, int n) {
    digitalWrite(BOARD_RX_ENABLE, LOW);
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.write(buffer, n);
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
    digitalWrite(BOARD_RX_ENABLE, HIGH);
}

bool dxl_sending() {
    return false;
}

void init_dxl_ram() {
    dxl_regs.ram.torqueEnable = 0;
    dxl_regs.ram.led = 0;
    dxl_regs.ram.servoKd = INITIAL_D_COEF;
    dxl_regs.ram.servoKi = INITIAL_I_COEF;
    dxl_regs.ram.servoKp = INITIAL_P_COEF;
    dxl_regs.ram.torqueLimit = dxl_regs.eeprom.maxTorque;
    dxl_regs.ram.lock = 0;
    dxl_regs.ram.punch = 0;
    dxl_regs.ram.torqueMode = 0;
    dxl_regs.ram.goalCurrent = 0;
    dxl_regs.ram.goalAcceleration = 0;

    dxl_regs.ram.goalPosition = hardwareStruct.mot->targetAngle;
    dxl_regs.ram.movingSpeed = hardwareStruct.mot->targetSpeed;
    dxl_regs.ram.goalAcceleration = hardwareStruct.mot->targetAcceleration;
    dxl_regs.ram.goalCurrent = hardwareStruct.mot->targetCurrent;
    dxl_regs.ram.mode = POSITION_CONTROL;

    predictiveControl * predictiveControl = get_predictive_control();
    dxl_regs.ram.kcoul = predictiveControl->kcoul;
	dxl_regs.ram.i0 = predictiveControl->i0;
	dxl_regs.ram.r = predictiveControl->r;
	dxl_regs.ram.ke = predictiveControl->ke;
	dxl_regs.ram.kvis = predictiveControl->kvis;
	dxl_regs.ram.linearTransition = predictiveControl->linearTransition;
	dxl_regs.ram.kstat = predictiveControl->kstat;

	dxl_regs.ram.ouputTorque = 0.0;
	dxl_regs.ram.electricalTorque = 0.0;

	dxl_regs.ram.frozenRamOn = false;
	dxl_regs.ram.useValuesNow = false;
	dxl_regs.ram.torqueKp = get_control_struct()->torquePCoef;

    //The other registers are updated here :
    update_dxl_ram();
}

void update_dxl_ram() {
    dxl_regs.ram.presentPosition = hardwareStruct.mot->angle;

    //dxl unit : 1023 == 117.07rpm. Our speed x is in steps/s => x(in dxl unit) = x*(60/4096)*1023/117.07 = x * 0.12800. Awful unit.
    dxl_regs.ram.presentSpeed = terrible_sign_convention((int32_t)(hardwareStruct.mot->speed * 0.12800), 1024);

    dxl_regs.ram.presentLoad = terrible_sign_convention(hardwareStruct.mot->averageCurrent, 1024);

    dxl_regs.ram.presentVoltage = hardwareStruct.voltage;

    dxl_regs.ram.presentTemperature = hardwareStruct.temperature;

    //dxl_regs.ram.registeredInstruction = ; // To do?

    if (hardwareStruct.mot->speed != 0) {
        dxl_regs.ram.moving = 1;
    } else {
        dxl_regs.ram.moving = 0;
    }

    dxl_regs.ram.current = terrible_sign_convention(hardwareStruct.mot->averageCurrent, 2048);
}

void read_dxl_ram() {
    get_control_struct()->dCoef = dxl_regs.ram.servoKd;
    get_control_struct()->iCoef = dxl_regs.ram.servoKi;
    get_control_struct()->pCoef = dxl_regs.ram.servoKp;
    get_control_struct()->torquePCoef = dxl_regs.ram.torqueKp;

    if ((hardwareStruct.mot->posAngleLimit == 4095) && (hardwareStruct.mot->negAngleLimit == 4095)) {
    	hardwareStruct.mot->multiTurnOn = true;
    } else {
    	/* Multiturn mode is off.
    	 * Beware though, if we were in multiturn mode before, we'll reset the circular buffer containing the past positions to avoid weirdness
    	 * (going from [-32768, +32767] to [0, 4096] would create errors in the speed calculations)
    	 */
    	if (hardwareStruct.mot->multiTurnOn) {
    		buffer_reset_values(&(hardwareStruct.mot->angleBuffer), hardwareStruct.mot->angle);
    	}
    	hardwareStruct.mot->multiTurnOn = false;
    }
    if ((dxl_regs.ram.mode == 0) && (hardwareStruct.mot->targetAngle != dxl_regs.ram.goalPosition)) {
    	if (hardwareStruct.mot->multiTurnOn == false) {
            // The angle might be out of bounds, this function handles it and updates mot->targetAngle accordingly
            motor_set_target_angle(dxl_regs.ram.goalPosition);
            dxl_regs.ram.goalPosition = hardwareStruct.mot->targetAngle;
            controlMode = POSITION_CONTROL;
    	} else {
    		// Multi turn mode, no limits on the target angle
    		motor_set_target_angle_multi_turn_mode(dxl_regs.ram.goalPosition);
			controlMode = POSITION_CONTROL;
    	}

    }

    //Moving speed actually means "goalSpeed"
    if (hardwareStruct.mot->targetSpeed != dxl_regs.ram.movingSpeed) {
        if (dxl_regs.ram.movingSpeed < 1024) {
            hardwareStruct.mot->targetSpeed = dxl_regs.ram.movingSpeed;
        } else {
            hardwareStruct.mot->targetSpeed = 1024 - dxl_regs.ram.movingSpeed;
        }

        controlMode = SPEED_CONTROL;
    }

    //To do : //dxl_regs.ram.torqueLimit;
    //To do  : //dxl_regs.ram.lock;
    //To do : //dxl_regs.ram.punch;

    if (hardwareStruct.mot->targetCurrent != dxl_regs.ram.goalCurrent) {
        hardwareStruct.mot->targetCurrent = dxl_regs.ram.goalCurrent;
        controlMode = CURRENT_CONTROL;
    }

    if (hardwareStruct.mot->targetAcceleration != dxl_regs.ram.goalAcceleration) {
        hardwareStruct.mot->targetAcceleration = dxl_regs.ram.goalAcceleration;
        controlMode = ACCELERATION_CONTROL;
    }

    if (dxl_regs.ram.torqueMode) {
        controlMode = TORQUE_CONTROL;
    } else {
    	if (controlMode == TORQUE_CONTROL) {
    		controlMode = POSITION_CONTROL;
    	}
    }

    hardwareStruct.mot->targetTorque = dxl_regs.ram.goalTorque;


    if (dxl_regs.ram.torqueEnable) {
        if (hardwareStruct.mot->state == COMPLIANT) {
            motor_restart();
        }
    } else {
        if(hardwareStruct.mot->state != COMPLIANT) {
            motor_compliant();
        }
    }

    if (dxl_regs.ram.mode == 0) {
            //Stable mode
        if (controlMode != POSITION_CONTROL && controlMode != TORQUE_CONTROL) {
                controlMode = POSITION_CONTROL;
                hardwareStruct.mot->targetAngle = hardwareStruct.mot->angle;
                dxl_regs.ram.goalPosition = hardwareStruct.mot->targetAngle;
        }

    } else if (dxl_regs.ram.mode == 1) {
        if (controlMode != PREDICTIVE_COMMAND_ONLY) {
            motor_restart_traj_timer();
        }
        controlMode = PREDICTIVE_COMMAND_ONLY;
    } else if (dxl_regs.ram.mode == 2) {
        if (controlMode != PID_ONLY) {
            motor_restart_traj_timer();
        }
        controlMode = PID_ONLY;
    } else if (dxl_regs.ram.mode == 3) {
        if (controlMode != PID_AND_PREDICTIVE_COMMAND) {
            motor_restart_traj_timer();
        }
        controlMode = PID_AND_PREDICTIVE_COMMAND;
    } else if (dxl_regs.ram.mode == 4) {
        controlMode = COMPLIANT_KIND_OF;
    } else if (dxl_regs.ram.mode == 5) {
            // No strings attached
    }

    if (dxl_regs.ram.debugOn == true) {
        dxl_print_debug();
    }

    predictiveControl * pControl = get_predictive_control();
    if (pControl->kstat != dxl_regs.ram.kstat
    		|| pControl->i0 != dxl_regs.ram.i0
			|| pControl->r != dxl_regs.ram.r
			|| pControl->ke != dxl_regs.ram.ke
			|| pControl->kvis != dxl_regs.ram.kvis
			|| pControl->linearTransition != dxl_regs.ram.linearTransition
			|| pControl->kcoul != dxl_regs.ram.kcoul
			|| pControl->vAlim != hardwareStruct.voltage/10.0) {
        pControl->kstat = dxl_regs.ram.kstat;
        pControl->i0 = dxl_regs.ram.i0;
        pControl->r = dxl_regs.ram.r;
        pControl->ke = dxl_regs.ram.ke;
        pControl->kvis = dxl_regs.ram.kvis;
        pControl->linearTransition = dxl_regs.ram.linearTransition;
        pControl->kcoul = dxl_regs.ram.kcoul;
        pControl->vAlim = hardwareStruct.voltage/10.0;

    	predictive_control_update();
    }

    if (dxl_regs.ram.led == 0) {
        digitalWrite(BOARD_LED_PIN, HIGH);
    } else {
        digitalWrite(BOARD_LED_PIN, LOW);
    }

    //  XXX The problem comes from here :
//    int nbTicksForSpeed = (int)(1000/(dxl_regs.ram.speedCalculationDelay));
//    if (hardwareStruct.mot->angleBuffer.size != nbTicksForSpeed) {
//    	// Dynamically changing the size of the buffer
//    	buffer_delete(&(hardwareStruct.mot->angleBuffer));
////    	buffer_delete(&(hardwareStruct.mot->commandBuffer));
//    	hardwareStruct.mot->angleBuffer = *buffer_creation(nbTicksForSpeed, hardwareStruct.mot->angle);
////    	hardwareStruct.mot->commandBuffer = *buffer_creation((int)(1000/(dxl_regs.ram.speedCalculationDelay)), 0);
//    }



}

void dxl_copy_buffer_trajs() {
    dxl_regs.ram.trajPoly1Size = dxl_regs.ram.trajPoly2Size;
    dxl_regs.ram.torquePoly1Size = dxl_regs.ram.torquePoly2Size;
    dxl_regs.ram.duration1 = dxl_regs.ram.duration2;
    for (int i = 0; i < DXL_POLY_SIZE; i++) {
        dxl_regs.ram.trajPoly1[i] = dxl_regs.ram.trajPoly2[i];
        dxl_regs.ram.torquePoly1[i] = dxl_regs.ram.torquePoly2[i];
    }
}

void init_dxl_eeprom() {
    read_dxl_eeprom();
}

void read_dxl_eeprom() {
    hardwareStruct.mot->posAngleLimit = dxl_regs.eeprom.cwLimit;
    hardwareStruct.mot->negAngleLimit = dxl_regs.eeprom.ccwLimit;
}

/* Dxl uses a convention with two zeros. Per example, if the second zero is 1024 then the values from 0 to 1023 are unchanged but 1025 means -1.
 */
unsigned short terrible_sign_convention(int32 pInput, int32 pIamZeroISwear) {
    if (pInput >= 0) {
        return (unsigned short) pInput;
    } else {
        return (unsigned short) (pIamZeroISwear - pInput);
    }
}


void dxl_print_debug() {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println();
    motor_print_motor();


    Serial1.print("trajPoly1Size = ");
    Serial1.println(dxl_regs.ram.trajPoly1Size);
    for (int i = 0; i < 5; i ++) {
        Serial1.print("trajPoly1[");
        Serial1.print(i);
        Serial1.print("] = ");
        Serial1.println(dxl_regs.ram.trajPoly1[i]);
    }
    Serial1.print("torquePoly1Size = ");
    Serial1.println(dxl_regs.ram.torquePoly1Size);
    for (int i = 0; i < 5; i ++) {
        Serial1.print("torquePoly1[");
        Serial1.print(i);
        Serial1.print("] = ");
        Serial1.println(dxl_regs.ram.torquePoly1[i]);
    }
    Serial1.print("duration1 = ");
    Serial1.println(dxl_regs.ram.duration1);

    Serial1.print("trajPoly2Size = ");
    Serial1.println(dxl_regs.ram.trajPoly2Size);
    for (int i = 0; i < 5; i ++) {
        Serial1.print("trajPoly2[");
        Serial1.print(i);
        Serial1.print("] = ");
        Serial1.println(dxl_regs.ram.trajPoly2[i]);
    }
    Serial1.print("torquePoly2Size = ");
    Serial1.println(dxl_regs.ram.torquePoly2Size);
    for (int i = 0; i < 5; i ++) {
        Serial1.print("torquePoly2[");
        Serial1.print(i);
        Serial1.print("] = ");
        Serial1.println(dxl_regs.ram.torquePoly2[i]);
        // Serial1.println((*( (&dxl_regs.ram.torquePoly2) + i)));
    }
    Serial1.print("duration2 = ");
    Serial1.println(dxl_regs.ram.duration2);

    Serial1.print("mode = ");
    Serial1.println(dxl_regs.ram.mode);

    Serial1.print("controlMode = ");
    Serial1.println(controlMode);

    Serial1.print("sizeOfRam = ");
    Serial1.println(sizeof(dxl_regs.ram));

    Serial1.print("sizeof struct dxl_ram ");
    Serial1.println(sizeof(struct dxl_ram));

    Serial1.print("present position in ram = ");
    Serial1.println(dxl_regs.ram.presentPosition);
    Serial1.print("present position in frozen ram = ");
    Serial1.println(dxl_regs.frozen_ram.presentPosition);

    Serial1.print("goal position in ram = ");
	Serial1.println(dxl_regs.ram.goalPosition);
	Serial1.print("goal position in frozen ram = ");
	Serial1.println(dxl_regs.frozen_ram.goalPosition);


    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
}

