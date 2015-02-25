#ifndef _DXL_HAL_H_
#define _DXL_HAL_H_

#include <wirish/wirish.h>
#include "motor.h"
#include "control.h"
#include "dxl.h"

struct hardware {
    encoder * enc;
    motor * mot;
    unsigned char voltage;
    unsigned char temperature;
};

enum controlModeEnum {
    POSITION_CONTROL            = 0,
    SPEED_CONTROL               = 1,
    ACCELERATION_CONTROL        = 2,
    TORQUE_CONTROL              = 3,
    OFF                         = 4,
    POSITION_CONTROL_P          = 5,
    PREDICTIVE_COMMAND_ONLY     = 6,
    PID_AND_PREDICTIVE_COMMAND  = 7,
};

extern unsigned char  controlMode;
extern hardware       hardwareStruct;

void init_dxl_ram();

/**
 * Updates the dynamixel ram with the new state of the motor (such as current position)
 */
void update_dxl_ram();

/**
 * Reads the dynamixel ram and applies modifications (such as goad position)
 */
void read_dxl_ram();

/**
 * From a signed convention to the dynamiel's unsigned convention
 */
unsigned short terrible_sign_convention(long pInput, long pIamZeroISwear);

#endif /* _DXL_HAL_H_ */
