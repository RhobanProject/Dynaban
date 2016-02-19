#ifndef _DXL_HAL_H_
#define _DXL_HAL_H_

#include <wirish/wirish.h>
#include "motor.h"
#include "control.h"
#include "dxl.h"

struct hardware {
    encoder * enc;
    motor * mot;
    uint8_t voltage;
    uint8_t temperature;
};

enum controlModeEnum {
    POSITION_CONTROL            = 0,
    SPEED_CONTROL               = 1,
    ACCELERATION_CONTROL        = 2,
    TORQUE_CONTROL              = 3,
    OFF                         = 4,
    POSITION_CONTROL_P          = 5,
    PREDICTIVE_COMMAND_ONLY     = 6,
    PID_ONLY                    = 7,
    PID_AND_PREDICTIVE_COMMAND  = 8,
    COMPLIANT_KIND_OF           = 9,
	CURRENT_CONTROL				= 10,

};

extern unsigned char  controlMode;
extern hardware       hardwareStruct;

void init_dxl_ram();
void init_dxl_eeprom();

/**
 * Updates the dynamixel ram with the new state of the motor (such as current position)
 */
void update_dxl_ram();

/**
 * Copies the trajPoly2 and torquePoly2 info into the trajPoly2 and torquePoly2
 */
void dxl_copy_buffer_trajs();

/**
 * Reads the dynamixel ram and applies modifications (such as goas position)
 */
void read_dxl_ram();

void read_dxl_eeprom();

/**
 * From a signed convention to the dynamiel's unsigned convention
 */
unsigned short terrible_sign_convention(int32 pInput, int32 pIamZeroISwear);


#endif /* _DXL_HAL_H_ */
