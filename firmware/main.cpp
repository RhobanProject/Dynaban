#include <wirish/wirish.h>
#include <libmaple/adc.h>
#include <libmaple/timer.h>
#include "magnetic_encoder.h"
#include "motor.h"
#include "control.h"
#include "dxl.h"
#include "dxl_HAL.h"
#include "trajectory_manager.h"

#define POWER_SUPPLY_ADC_PIN  PA2
#define TEMPERATURE_ADC_PIN   PA1
#define MAX_TEMPERATURE       70
#define OVER_FLOW             3000

/**
 * Schedules the hardware tasks
 */
void hardware_tick();

void set_ready_to_update_hardware();

/**
 * Returns the temperature in degrees celcius.
 */
unsigned char read_temperature();


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

/**
 * Prints the trajectory of the motor
 */
void print_detailed_trajectory();

/*
 * Prints the trajectory of the motor (halts the rest of the program)
 **/
void print_detailed_trajectory_halt();

/*
 * Prints the benchmark array
 **/
void print_time_stamp();

/*
 * Saves the current value of the benchmark timer in a array
 **/
void add_benchmark_time();

static const bool     DXL_COM_ON = false; // /!\

long           counter               = 0;
int            posCounter            = 0;
unsigned char  hardwareCounter       = 0;
unsigned int   slowHardwareCounter   = 0;
bool           readyToUpdateHardware = false;
bool           firstTime             = true;
bool           firstTimePrint        = true;
bool           firstTimeNewSpeed     = true;


unsigned char  controlMode           = OFF;
hardware       hardwareStruct;

// Benchmarking
const int TIME_STAMP_SIZE = 1000;
static long arrayOfTimeStamps[TIME_STAMP_SIZE];
HardwareTimer timer4(4);
uint16 timeIndex = 0;

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
    encoder_read_angles_sharing_pins_mode();

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
    // The hardware will be read at 48Khz
    //timer2.setPeriod(21);
    timer2.setPrescaleFactor(1);
    timer2.setOverflow(1500);
    timer2.setChannel1Mode(TIMER_OUTPUT_COMPARE);

    //Interrupt 1 count after each update
    timer2.setCompare(TIMER_CH1, 1);
    timer2.attachCompare1Interrupt(set_ready_to_update_hardware);

    //Dxl struct init
    init_dxl_ram();

        //traj
    predictive_control_init();

    // Heartbit
    for (int i = 0; i < 4; i++) {
        toggleLED();
        delay(250);
    }
    controlMode = OFF;

        // // motor_set_command(330);
    // motor_set_command(500);
    // delay(1000);
    // motor_set_command(100);
    // hardware_tick();
    // // long angle = 3000;
    // long angle = hardwareStruct.mot->angle;
    // while(angle > 100) {
    //     delayMicroseconds(21);
    //     hardware_tick();
    //     angle = hardwareStruct.mot->angle;
    // }
    // counter = 48000;
    // return;

    // motor_set_command(95);
    // while(true);


    //Temp :
    timer4.setPrescaleFactor(72);
    timer4.setOverflow(65535);
    timer4.pause();
    timer4.refresh();
    timer4.resume();

    hardwareStruct.mot->targetAngle = 0;
    controlMode = POSITION_CONTROL_P;

    // hardwareStruct.mot->targetSpeed = 500;
    // controlMode = SPEED_CONTROL;

    // int t = 0;

    // while (t < 500) {
    //     delay(1);
    //     hardware_tick();
    //     t++;
    // }
    // print_debug();
    // while (t < 3000) {
    //     delay(1);
    //     hardware_tick();
    //     t++;
    // }

}

void loop() {

    if (DXL_COM_ON) {
        if (dxl_tick()) {
            read_dxl_ram();
        }
    }

    if (readyToUpdateHardware) {
        counter++;
        readyToUpdateHardware = false;
        hardware_tick();
        if (DXL_COM_ON) {
            update_dxl_ram();
        }
    }

    // if (counter % 4800 == 0) {
    //     print_debug();
    // }

    if (counter > 48000 && firstTime) {
        firstTime = false;
            //Taking care of the V(0) problem (static annoying stuff)
        // controlMode = OFF;

            // motor_set_command(80);
        // while (hardwareStruct.mot->angle > 5 && hardwareStruct.mot->angle < 4091) {
        //     hardware_tick();
        //     delay(1);
        // }

        timer3.pause();
        timer3.refresh();
        timer3.resume();

        // hardwareStruct.mot->targetAngle = (hardwareStruct.mot->angle + 2048)%4096;
        // controlMode = POSITION_CONTROL;
        controlMode = POSITION_CONTROL; // No asserv
        positionTrackerOn = true;
            //motor_set_command(2700); // max speed
    }

    // if (counter > 68000 && firstTimeNewSpeed == true) {
    //     firstTimeNewSpeed = false;
    //     motor_set_command(2700); // max speed
    // }

    if (firstTime == false && positionTrackerOn == false && firstTimePrint == true) {
        controlMode = OFF;
        hardwareStruct.mot->targetAngle = 0;
        motor_compliant();
        firstTimePrint = false;
        // print_detailed_trajectory();
        timer3.pause();
        // hardwareStruct.mot->targetAngle = 0;
        // controlMode = POSITION_CONTROL_P;
    }

    if (timeIndex >= (TIME_STAMP_SIZE-3)) {
        print_time_stamp();
        motor_compliant();
        while(true);
    }
}

void hardware_tick() {

    /* The current must be read as often as possible because it's so noisy that
     * it requires an averaging for it to be usable */
    motor_read_current();

    if (hardwareCounter > 47) { //47
            //These actions are performed at a rate of 1kHz
            //These actions costs 97-98us

        add_benchmark_time();
        //Updating the encoder (~90-92 us)
        encoder_read_angles_sharing_pins_mode();

        add_benchmark_time();
        //Updating the motor (~5-6 us with predictive control on)
        motor_update(hardwareStruct.enc);

        slowHardwareCounter++;
        hardwareCounter = 0;

        add_benchmark_time();
        //Updating control (3-4 us)
        if (controlMode == POSITION_CONTROL) {
            control_tick_PID_on_position(hardwareStruct.mot);
        } else if (controlMode == SPEED_CONTROL) {
            control_tick_P_on_speed(hardwareStruct.mot);
        } else if (controlMode == ACCELERATION_CONTROL) {
            control_tick_P_on_acceleration(hardwareStruct.mot);
        } else if (controlMode == TORQUE_CONTROL) {
            control_tick_P_on_torque(hardwareStruct.mot);
        } else if (controlMode == POSITION_CONTROL_P) {
            control_tick_P_on_position(hardwareStruct.mot);
        } else {
            // No control
        }
        add_benchmark_time();
    }

    if (slowHardwareCounter > 999) {
        //These actions are performed at 1 Hz
        slowHardwareCounter = 0;

        //Updating power supply value (the value is 10 times bigger than the real value)
        hardwareStruct.voltage = (unsigned char)((analogRead(POWER_SUPPLY_ADC_PIN) * 33 *766)/409600);

        //Updating the temperature
        hardwareStruct.temperature = read_temperature();
        if (hardwareStruct.temperature > MAX_TEMPERATURE) {
            motor_temperatureIsCritic();
        }
    }

    hardwareCounter++;
}


void set_ready_to_update_hardware() {
    readyToUpdateHardware = true;
}

/* The Thermistor value is R (~4.7 kOhm at ~ 20°). We approximated the Temperature(Resitance) law as follows :
   T°(R) = -32.25 * ln(R) + 297.37.
   The voltage arrives at the adc pin through a bridge with a 4.7kOhm resistor : vThermistor = 3.3V * (R)/(4700 + R)
   => R = 4700*vThermistor / (vThermistor - 3.3)
*/
unsigned char read_temperature() {
    unsigned int input = analogRead(TEMPERATURE_ADC_PIN);

    float vThermistor = (input*33) / (40960.0);
    float thermistor = 47000*(vThermistor) / (33 - 10*vThermistor);
    unsigned char temperature = (-3225*log(thermistor) + 29737) / 100;

    return temperature;
}

void print_debug() {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println();
    Serial1.print("-----------------------:");
    Serial1.println();
    Serial1.print("Mode = ");
    Serial1.println(controlMode);
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

        //Waiting for the measures to be made
        while(currentDetailedDebugOn != false) {
            //delayMicroseconds(1);
            motor_read_current();
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

void print_detailed_trajectory() {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("");
    for (int i = 0; i < NB_POSITIONS_SAVED; i++) {
        if (i > 100 && timeArray[i] == 0) {
            break;
        }
        Serial1.print(timeArray[i] - 250); // Taking into account the speed update delay
        Serial1.print(" ");
        Serial1.println(positionArray[i]);
    }

    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
}

void print_time_stamp() {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("");
    for (int i = 0; i < TIME_STAMP_SIZE; i++) {
        Serial1.println(arrayOfTimeStamps[i]);
    }

    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
}

void add_benchmark_time() {
    if (timeIndex < TIME_STAMP_SIZE) {
        arrayOfTimeStamps[timeIndex] = timer4.getCount();
        timeIndex++;
    }
}

void print_detailed_trajectory_halt() {
    delay(3000);
        //Updating the encoder
    encoder_read_angles_sharing_pins_mode();
        //Updating the motor
    motor_update(hardwareStruct.enc);

    long counter = 0;
    timer3.pause();
    timer3.refresh();
    timer3.resume();

    hardwareStruct.mot->targetAngle = 0;//(hardwareStruct.mot->angle + 2048)%4096;
    controlMode = POSITION_CONTROL;
    positionTrackerOn = true;

    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("Start");
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);

        //Waiting for the measures to be made
    while(positionTrackerOn == true) {
        if (readyToUpdateHardware) {
            counter++;
            readyToUpdateHardware = false;
            hardware_tick();
        }
        delayMicroseconds(10);

        // if (counter%50 == 0) {
        //     digitalWrite(BOARD_TX_ENABLE, HIGH);
        //     Serial1.println(counter);
        //     Serial1.waitDataToBeSent();
        //     digitalWrite(BOARD_TX_ENABLE, LOW);
        // }
    }

    toggleLED();
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("Finished");
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);

    timer3.pause();
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("");
    for (int i = 0; i < NB_POSITIONS_SAVED; i++) {
        Serial1.print(timeArray[i]);
        Serial1.print(" ");
        Serial1.println(positionArray[i]);
    }

    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
    while (true);

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
