#include <wirish/wirish.h>
#include <libmaple/adc.h>
#include <libmaple/timer.h>
#include <DynaBan/magnetic_encoder.h>
#include <DynaBan/motor.h>
#include <DynaBan/control.h>
#include <DynaBan/dxl.h>

#define POWER_SUPPLY_ADC_PIN PA2
#define TEMPERATURE_ADC_PIN PA1


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
 * Scheduling of the hardware tasks
 */
void hardware_tick();

void set_ready_to_update_hardware();

/**
 * This function returns the inverted kinematics of the gear box in inches. 
 * Just kidding, it returns the temperature in degrees celcius. 
 */
unsigned char read_temperature();

/**
   From a signed convention to the dynamiel's unsigned convention
 */
unsigned short terrible_sign_convention(long pInput, long pIamZeroISwear);

/**
 * Generic debug print. Will show info on the current state of the motor and its control.
 */
void print_debug();

/**
 * Prints detailed current info in a csv format.
 */
void print_current_debug();

/**
 * Reads bursts of X values of the current as fast as possible and prints them.
 * This function will block the rest of the program.
 */
void print_detailed_current_debug();

void set_ready_to_update_hardware() {
    readyToUpdateHardware = true;
}


typedef struct _hardware__ {
    encoder * enc;
    motor * mot;
    unsigned char voltage;
    unsigned char temperature;
} hardware;

typedef enum _controlModeEnum_ {
    POSITION_CONTROL       = 0,
    TORQUE_CONTROL         = 1,
} controlModeEnum;


const bool     DXL_COM_ON = true;
const int      OVER_FLOW = 3000;

long           counter               = 0;
int            posCounter            = 0;
unsigned char  hardwareCounter       = 0;
unsigned int   slowHardwareCounter   = 0;
long           debugCounter          = 0;
bool           readyToUpdateHardware = false;
bool           controlMode           = POSITION_CONTROL;
hardware       hardwareStruct;


void setup() {
    disableDebugPorts();

    afio_remap(AFIO_REMAP_USART1);
    gpio_set_mode(GPIOB, 6, GPIO_AF_OUTPUT_PP);
    gpio_set_mode(GPIOB, 7, GPIO_INPUT_FLOATING);

    Serial1.begin(57600);

    /*Setting the timer's prescale to get a 24KHz PWM. 
      PWM1 and PWM2 share the same timer, channel 1 and 2.*/
    HardwareTimer timer1(1);
    timer1.setPrescaleFactor(1);
    timer1.setOverflow(OVER_FLOW);

    pinMode(BOARD_LED_PIN, OUTPUT);

    // Initialization of USART
    digitalWrite(BOARD_TX_ENABLE, LOW);
    pinMode(BOARD_TX_ENABLE, OUTPUT);
    digitalWrite(BOARD_TX_ENABLE, LOW);

    digitalWrite(BOARD_RX_ENABLE, LOW);
    pinMode(BOARD_RX_ENABLE, OUTPUT);
    digitalWrite(BOARD_RX_ENABLE, HIGH);

    // ADC pin init
    pinMode(CURRENT_ADC_PIN, INPUT_ANALOG);
    pinMode(POWER_SUPPLY_ADC_PIN, INPUT_ANALOG);
    pinMode(TEMPERATURE_ADC_PIN, INPUT_ANALOG);

    //Encoder init
    encoder_init_sharing_pins_mode(7, 8);
    encoder_add_encoder_sharing_pins_mode(6);

    //Motor init
    motor_init(encoder_get_encoder(0));
    control_init();

    //Dxl
    dxl_init();

    hardwareStruct.enc = encoder_get_encoder(0);
    hardwareStruct.mot = motor_getMotor();

    // This function will block the rest of the program and print detailed current debug
    //printDetailedCurrentDebug();

    HardwareTimer timer2(2);
    // The hardware will be read at ~~48Khz
    timer2.setPeriod(21);
    timer2.setChannel1Mode(TIMER_OUTPUT_COMPARE);
    
    //Interrupt 1 count after each update
    timer2.setCompare(TIMER_CH1, 1);
    timer2.attachCompare1Interrupt(set_ready_to_update_hardware);

    //Dxl struct init
    init_dxl_ram();

    // Heartbit
    for (int i = 0; i < 4; i++) {
        toggleLED();
        delay(250);
    }

}

void loop() {
    if (DXL_COM_ON) {
        if (dxl_tick()) {
            read_dxl_ram();
        }
    }

    if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
        if (DXL_COM_ON) {
            update_dxl_ram();
        }
    }
    /*
    if (counter % (100*200) == 0) {
        if (DXL_COM_ON == false) {
            //toggleLED();
            print_current_debug();
            //printDebug();
        }
    }

    if (counter % (100*2000*5) == 0) {
        counter = 0;
        //motor_setTargetAngle(1000 * posCounter);
        //printDebug();
        if (posCounter == 0) {
            motor_set_target_angle(0);
            //motor_set_target_current(20);
            //motor_securePwmWrite(PWM_2_PIN, 0);
            //motor_securePwmWrite(PWM_1_PIN, 500);
            posCounter = 1;
            digitalWrite(BOARD_LED_PIN, HIGH);
            //hardwareStruct.mot->targetSpeed = -20;
            //motor_setTargetAngle(1020);
        } else if (posCounter == 1) {
            motor_set_target_angle(1024);
            //motor_set_target_current(-20);
            //motor_securePwmWrite(PWM_1_PIN, 0);
            //motor_securePwmWrite(PWM_2_PIN, 500);
            posCounter = 2;
            digitalWrite(BOARD_LED_PIN, LOW);
            //hardwareStruct.mot->targetSpeed = -40;
            //motor_setTargetAngle(2040);
        } else if (posCounter == 2) {
            motor_set_target_angle(2048);
            posCounter = 3;
            //hardwareStruct.mot->targetSpeed = -60;
            //motor_setTargetAngle(3060);
        } else {
            motor_set_target_angle(3072);
            posCounter = 0;
            //hardwareStruct.mot->targetSpeed = -80;
            //motor_setTargetAngle(4095);
        }
    }
    */
    counter++;
}

void hardware_tick() {
    /* The current must be read as often as possible because it's so noisy that
     * it requires an averaging for it to be usable */
    motor_read_current();

    if (hardwareCounter > 47) {
        slowHardwareCounter++;
        hardwareCounter = 0;
        //These actions are performed at a rate of 1KHz
        
        //Updating the encoder
        encoder_read_angles_sharing_pins_mode();

        //Updating the motor
        motor_update(hardwareStruct.enc);

        //Updating asserv
        /*
        if (controlMode == POSITION_CONTROL) {
            asserv_tickPIDOnPosition(hardwareStruct.mot);
        } else if (controlMode == TORQUE_CONTROL) {
            asserv_tickPIDOnTorque(hardwareStruct.mot);
        } else {
            //asserv_tickPIDOnPosition(hardwareStruct.mot);
            }*/
        //control_tick_PID_on_torque(hardwareStruct.mot);
        control_tick_PID_on_position(hardwareStruct.mot);

        //asserv_tickPIDOnSpeed(hardwareStruct.mot);
        //asserv_tickPIDOnAcceleration(hardwareStruct.mot);
        //motor_compliant();
        //printDebug();
        //printCurrentDebug();
    }
    
    if (slowHardwareCounter > 999) {
        //These actions are performed at 1 Hz
        slowHardwareCounter = 0;
        
        //Updating power supply value (the value is 10 times bigger than the real value)
        hardwareStruct.voltage = (unsigned char)((analogRead(POWER_SUPPLY_ADC_PIN) * 33 *766)/409600);
    
        //Updating the temperature
        hardwareStruct.temperature = read_temperature();
    }

    hardwareCounter++;
}

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
    //Asserv struct à rajouter dans hardwareStruct
    //asservStruct->dCoef = dxl_regs.ram.servoKd;
    //asservStruct->iCoef = dxl_regs.ram.servoKi;
    //asservStruct->pCoef = dxl_regs.ram.servoKp;
    hardwareStruct.mot->targetAngle = dxl_regs.ram.goalPosition;
    /*if (hardwareStruct.mot->targetAngle != dxl_regs.ram.goalPosition) {
        hardwareStruct.mot->targetAngle = dxl_regs.ram.goalPosition;
        controlMode = POSITION_CONTROL;
        }*/

    //Moving speed actually means "goalSpeed"
    hardwareStruct.mot->targetSpeed = dxl_regs.ram.movingSpeed;
    //To do : //dxl_regs.ram.torqueLimit;
    //To do  : //dxl_regs.ram.lock;
    //To do : //dxl_regs.ram.punch;

    //To do : //dxl_regs.ram.torqueMode;
    hardwareStruct.mot->targetCurrent = dxl_regs.ram.goalTorque;
    /*
    if (hardwareStruct.mot->targetCurrent != dxl_regs.ram.goalTorque) {
        hardwareStruct.mot->targetCurrent = dxl_regs.ram.goalTorque;
        controlMode = TORQUE_CONTROL;
        } */

    hardwareStruct.mot->targetAcceleration = dxl_regs.ram.goalAcceleration;

    if (dxl_regs.ram.torqueEnable) {
        if (hardwareStruct.mot->state == COMPLIANT) {
            motor_restart();
        }
    } else {
        if(hardwareStruct.mot->state != COMPLIANT) {
            motor_compliant();
        }
    }
}

/* Thermistor value is R (~4.7 kOhm at ~ 20°). We approximated the Temperature(Resitance) law as follows :
   T°(R) = -32.25 * ln(R) + 297.37.
   The voltage arrives at the adc pin through a bridge : vThermistor = 3.3V * (R)/(4700 + R)
   => R = 4700*vThermistor / (vThermistor - 3.3)
*/
unsigned char read_temperature() {
    unsigned int input = analogRead(TEMPERATURE_ADC_PIN);
    
    float vThermistor = (input*33) / (40960.0);
    float thermistor = 47000*(vThermistor) / (33 - 10*vThermistor);
    unsigned char temperature = (-3225*log(thermistor) + 29737) / 100;
    
    return temperature;
}

unsigned short terrible_sign_convention(long pInput, long pIamZeroISwear) {
    if (pInput > 0) {
        return (unsigned short) pInput;
    } else {
        return (unsigned short) (pIamZeroISwear - pInput);
    }
}

void print_debug() {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println();
    Serial1.print("-----------------------:");
    motor_printMotor();
    control_print();
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
}

void print_current_debug() {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.print(hardwareStruct.mot->current);
    Serial1.print(" ");
    Serial1.println(hardwareStruct.mot->averageCurrent);
    Serial1.print(" ");
    Serial1.println(hardwareStruct.mot->command);
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
}

void print_detailed_current_debug() {
    long detailedCounter = 0;
    timer3.pause();
    timer3.refresh();

    while(true) {
        detailedCounter++;
        delay(50);
        timer3.resume();
        currentDetailedDebugOn = true;
        //Waiting for the measures tu be made

        while(currentDetailedDebugOn != false) {
            //delayMicroseconds(1);
            motor_read_current();

            /*if (readyToUpdateHardware) {
                hardwareTick();
                readyToUpdateHardware = false;
                }*/
        }

        timer3.pause();
        digitalWrite(BOARD_TX_ENABLE, HIGH);
        Serial1.println("");
        for (int i = 0; i < C_NB_RAW_MEASURES; i++) {
            Serial1.print(currentRawMeasures[i]);
            Serial1.print(" ");
            Serial1.println(currentTimming[i]);
        }

        Serial1.waitDataToBeSent();
        digitalWrite(BOARD_TX_ENABLE, LOW);
        if (detailedCounter == 50) {
            motor_secure_pwm_write(PWM_1_PIN, 0);
            motor_secure_pwm_write(PWM_2_PIN, 500);
            digitalWrite(BOARD_LED_PIN, LOW);
        } else if (detailedCounter == 100) {
            detailedCounter = 0;
            motor_secure_pwm_write(PWM_2_PIN, 0);
            motor_secure_pwm_write(PWM_1_PIN, 500);
            digitalWrite(BOARD_LED_PIN, HIGH);
        }
    }
}


// Force init to be called *first*, i.e. before static object allocation.
// Otherwise, statically allocated objects that need libmaple may fail.
__attribute__((constructor)) void premain() {
    init();
}

int main(void) {
    setup();

    while (true) {
        loop();
    }

    return 0;
}
