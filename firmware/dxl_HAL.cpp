#include "dxl.h"
#include "dxl_HAL.h"
#include <string.h>

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
    dxl_regs.ram.goalTorque = 0;
    dxl_regs.ram.goalAcceleration = 0;

    dxl_regs.ram.goalPosition = 0;
    dxl_regs.ram.movingSpeed = 0;
    dxl_regs.ram.goalAcceleration = 0;
    dxl_regs.ram.goalTorque = 0;

    //The other registers are updated here :
    update_dxl_ram();
}

void update_dxl_ram() {
    dxl_regs.ram.presentPosition = hardwareStruct.mot->angle;

    dxl_regs.ram.presentSpeed = terrible_sign_convention(hardwareStruct.mot->speed, 1024);

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

    digitalWrite(BOARD_LED_PIN, (dxl_regs.ram.led!=0) ? HIGH : LOW);

    get_control_struct()->dCoef = dxl_regs.ram.servoKd;
    get_control_struct()->iCoef = dxl_regs.ram.servoKi;
    get_control_struct()->pCoef = dxl_regs.ram.servoKp;

    if (hardwareStruct.mot->targetAngle != dxl_regs.ram.goalPosition) {
        motor_set_target_angle(dxl_regs.ram.goalPosition);
        // hardwareStruct.mot->targetAngle = dxl_regs.ram.goalPosition;
        controlMode = POSITION_CONTROL;
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

    if (hardwareStruct.mot->targetCurrent != dxl_regs.ram.goalTorque) {
        hardwareStruct.mot->targetCurrent = dxl_regs.ram.goalTorque;
        controlMode = TORQUE_CONTROL;
    }

    if (hardwareStruct.mot->targetAcceleration != dxl_regs.ram.goalAcceleration) {
        hardwareStruct.mot->targetAcceleration = dxl_regs.ram.goalAcceleration;
        controlMode = ACCELERATION_CONTROL;
    }

    if (dxl_regs.ram.torqueMode) {
        controlMode = TORQUE_CONTROL;
    }

    if (dxl_regs.ram.torqueEnable) {
        if (hardwareStruct.mot->state == COMPLIANT) {
            motor_restart();
        }
    } else {
        if(hardwareStruct.mot->state != COMPLIANT) {
            motor_compliant();
        }
    }

    // if(hardwareStruct.mot->testChar != dxl_regs.ram.testChar) {
    //     hardwareStruct.mot->testChar = dxl_regs.ram.testChar;
    //     // motor_set_target_angle(((long)hardwareStruct.mot->testChar));
    //     // delay(100);
    //     // digitalWrite(BOARD_TX_ENABLE, HIGH);
    //     // Serial1.print("testChar = ");
    //     // Serial1.println(hardwareStruct.mot->testChar);
    //     // Serial1.waitDataToBeSent();
    //     // digitalWrite(BOARD_TX_ENABLE, LOW);
    //     // delay(100);
    // }


    // float f = 0.6f;
    // memcpy(data, &f, sizeof f);    // send data


    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.print("accel = ");
    Serial1.println(dxl_regs.ram.goalAcceleration);
    for (int i = 0; i < 17; i ++) {
        Serial1.print("poly1Size[");
        Serial1.print(i);
        Serial1.print("] = ");
        Serial1.println((*( (&dxl_regs.ram.poly1Size) + i)));
    }
    for (int i = 0; i < 5; i ++) {
        Serial1.print("a");
        Serial1.print(i);
        Serial1.print(" = ");
        Serial1.println(dxl_regs.ram.poly1[i]);
    }

    float g = 2.1;
    float f = 1.2345;

    // unsigned char *pc;
    // pc = (unsigned char*)&g;
    // pc[0] = dxl_regs.ram.testFloat[0];
    // pc[1] = dxl_regs.ram.testFloat[1];
    // pc[2] = dxl_regs.ram.testFloat[2];
    // pc[3] = dxl_regs.ram.testFloat[3];

    memcpy(&g, (const void *)(dxl_regs.ram.poly1), sizeof(float));    // receive data
    Serial1.print("g = ");
    Serial1.println(g);
    Serial1.print("f = ");
    Serial1.println(f);
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
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
unsigned short terrible_sign_convention(long pInput, long pIamZeroISwear) {
    if (pInput >= 0) {
        return (unsigned short) pInput;
    } else {
        return (unsigned short) (pIamZeroISwear - pInput);
    }
}
