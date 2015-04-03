#include <wirish/wirish.h>
#include <libmaple/adc.h>
#include <libmaple/timer.h>
#include "magnetic_encoder.h"
#include "dxl_HAL.h"
#include "motor.h"
#include "control.h"
#include "dxl.h"
#include "trajectory_manager.h"

#define POWER_SUPPLY_ADC_PIN  PA2
#define TEMPERATURE_ADC_PIN   PA1
#define MAX_TEMPERATURE       70
#define OVER_FLOW             3000

/**
 * To do :
 * Re-test the anti-gravity arm (the speed update had a bug in it)
 */

/**
 * Schedules the hardware tasks
 */
void hardware_tick();

void set_ready_to_update_hardware();

void set_ready_to_update_current();

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

int32 evaluate_trajectory_least_square(uint16 (*pidealTraj)(uint16));

/**
 * Returns the next moment of inertia I to be tested in order to minimize the score
 * Xn+1 = Xn - f(Xn) * (Xn - Xn-1)/(f(Xn) - f(Xn-1))
 */
float next_inertia(float pPreviousI, float pCurrentI, int32 pPreviousScore, int32 pCurrentScore);

float auto_calibrate_inertia(float pPreviousI, float pCurrentI, int32 pPreviousScore, int32 pCurrentScore);

/*
 * Saves the current value of the benchmark timer in a array
 **/
void add_benchmark_time();


const uint32    TOO_BIG              = 1<<30;
static bool     DXL_COM_ON = true; // /!\

long           counter               = 0;
int            posCounter            = 0;
unsigned char  hardwareCounter       = 0;
unsigned int   slowHardwareCounter   = 0;
bool           readyToUpdateHardware = false;
bool           readyToUpdateCurrent  = false;
bool           firstTime             = true;
bool           firstTimePrint        = true;
bool           firstTimeNewSpeed     = true;
int32          score                 = TOO_BIG;
int32          previousScore         = TOO_BIG;
int32          averageScore          = 0;
float          previousInertia       = 0.0;
uint8          repetitions           = 0;

unsigned char  controlMode           = OFF;
hardware       hardwareStruct;

// Benchmarking
const int TIME_STAMP_SIZE = 1000;
static long arrayOfTimeStamps[TIME_STAMP_SIZE];
HardwareTimer timer2(2);
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
    hardwareStruct.mot = motor_get_motor();

    // This function will block the rest of the program and print detailed current debug
    //printDetailedCurrentDebug();


    timer2.pause();
    // The hardware will be read at 1Khz
    timer2.setPrescaleFactor(72);
    timer2.setOverflow(1000);
    timer2.setChannel1Mode(TIMER_OUTPUT_COMPARE);
    //Interrupt 1 count after each update
    timer2.setCompare(TIMER_CH1, 1);
    timer2.attachCompare1Interrupt(set_ready_to_update_hardware);
    timer2.refresh();
    timer2.resume();

        /* The current will be read at 48Khz. It must be read as often as possible
         * because it's so noisy that it requires averaging for it to be usable */
    HardwareTimer timer4(4);
    timer4.pause();
    timer4.setPrescaleFactor(1);
    timer4.setOverflow(1500);
    timer4.setChannel2Mode(TIMER_OUTPUT_COMPARE);
    // //Interrupt 1 count after each update
    timer4.setCompare(TIMER_CH2, 1);
    timer4.attachCompare2Interrupt(set_ready_to_update_current);
    timer4.refresh();
    timer4.resume();

    //Dxl struct init
    init_dxl_ram();
    init_dxl_eeprom();

        //traj
    predictive_control_init();

    // Heartbit
    for (int i = 0; i < 4; i++) {
        toggleLED();
        delay(250);
    }
        // HIGH means off ...
    digitalWrite(BOARD_LED_PIN, HIGH);
    controlMode = OFF;

        //motor_set_command(80); //80 doesn't move, 85 moves
    //Temp :

    // hardwareStruct.mot->targetAngle = 0;
    // controlMode = POSITION_CONTROL;

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

    // motor_set_command(-MAX_COMMAND);
}

void loop() {
    if (DXL_COM_ON) {
        if (dxl_tick()) {
            read_dxl_eeprom();
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

    if (readyToUpdateCurrent) {
        readyToUpdateCurrent = false;
        motor_read_current();
    }

    // if (counter % 100*4 == 0) {
    //     print_debug();
    // }

    if (counter > 2000 && firstTime && false) {
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
        controlMode = PREDICTIVE_COMMAND_ONLY; // PID_AND_PREDICTIVE_COMMAND
        dxl_regs.ram.positionTrackerOn = true;
            //motor_set_command(2700); // max speed
    }

    // if (counter > 68000 && firstTimeNewSpeed == true) {
    //     firstTimeNewSpeed = false;
    //     motor_set_command(2700); // max speed
    // }

    if (firstTime == false && dxl_regs.ram.positionTrackerOn == false && firstTimePrint == true) {
        controlMode = OFF;
        hardwareStruct.mot->targetAngle = 0;
        motor_compliant();
        firstTimePrint = false;
        print_detailed_trajectory();
        timer3.pause();
        digitalWrite(BOARD_TX_ENABLE, HIGH);
        Serial1.println();
        Serial1.print("Score :");
        Serial1.print(evaluate_trajectory_least_square(traj_min_jerk));
        Serial1.waitDataToBeSent();
        digitalWrite(BOARD_TX_ENABLE, LOW);

        return;
            //Auto-calibration :
        hardwareStruct.mot->targetAngle = 0;
        controlMode = POSITION_CONTROL;
        int32 tempScore = evaluate_trajectory_least_square(traj_min_jerk);
        if (tempScore < 10000000) {
            averageScore = averageScore + tempScore;
            digitalWrite(BOARD_TX_ENABLE, HIGH);
            Serial1.println();
            Serial1.print("Score : ");
            Serial1.print(tempScore);
            // Serial1.print("Sum : ");
            // Serial1.println(averageScore);
            Serial1.waitDataToBeSent();
            digitalWrite(BOARD_TX_ENABLE, LOW);
        } else {
                // This score is way too high, the least-square must have over-flowed. We'll redo the move
            digitalWrite(BOARD_TX_ENABLE, HIGH);
            Serial1.println();
            Serial1.print("Score invalid");
            Serial1.waitDataToBeSent();
            digitalWrite(BOARD_TX_ENABLE, LOW);
            repetitions--;
        }


        if (repetitions == 2) {
            repetitions = 0;

            previousScore = score;
            score = averageScore/3;
            averageScore = 0;
            float temp = addedInertia;
            addedInertia = auto_calibrate_inertia(previousInertia, addedInertia, previousScore, score);
            previousInertia = temp;

            digitalWrite(BOARD_TX_ENABLE, HIGH);
            Serial1.println();
            Serial1.print("Previous least square : ");
            Serial1.println(previousScore);
            Serial1.print("Current least square  : ");
            Serial1.println(score);
            Serial1.print("With inertia : ");
            Serial1.println(previousInertia*1000);
            Serial1.print("Next inertia to be tested : ");
            Serial1.println(addedInertia*1000);
            Serial1.waitDataToBeSent();
            digitalWrite(BOARD_TX_ENABLE, LOW);
        } else {
            repetitions++;
        }

            // Shining new start
        firstTime = true;
        firstTimePrint = true;
        dxl_regs.ram.positionTrackerOn = false;
        counter = 0;
    }

    // if (timeIndex >= (TIME_STAMP_SIZE-3) && firstTime == false && positionTrackerOn == false && firstTimePrint == false) {
    //     print_time_stamp();
    //     motor_compliant();
    //     while(true);
    // }
}

void hardware_tick() {
        //These actions are performed at a rate of 1kh and cost ~98-102 us
    // add_benchmark_time();
        //Updating the encoder (~90-92 us)
    encoder_read_angles_sharing_pins_mode();
    // add_benchmark_time();
        //Updating the motor (~5-6 us with predictive control on)
    motor_update(hardwareStruct.enc);

    slowHardwareCounter++;

    // add_benchmark_time();
        //Updating control (3-4 us)
    if (controlMode == POSITION_CONTROL) {
        predictiveCommandOn = false;
        control_tick_PID_on_position(hardwareStruct.mot);
    } else if (controlMode == SPEED_CONTROL) {
        predictiveCommandOn = false;
        control_tick_P_on_speed(hardwareStruct.mot);
    } else if (controlMode == ACCELERATION_CONTROL) {
        predictiveCommandOn = false;
        control_tick_P_on_acceleration(hardwareStruct.mot);
    } else if (controlMode == TORQUE_CONTROL) {
        predictiveCommandOn = false;
        control_tick_P_on_torque(hardwareStruct.mot);
    } else if (controlMode == POSITION_CONTROL_P) {
        predictiveCommandOn = false;
        control_tick_P_on_position(hardwareStruct.mot);
    } else if (controlMode == PREDICTIVE_COMMAND_ONLY) {
        predictiveCommandOn = true;
        control_tick_predictive_command_only(hardwareStruct.mot);
    } else if (controlMode == PID_AND_PREDICTIVE_COMMAND) {
        predictiveCommandOn = true;
        control_tick_PID_and_predictive_command(hardwareStruct.mot);
    } else if (controlMode == COMPLIANT_KIND_OF) {
        predictiveCommandOn = true;
        control_tick_predictive_command_only(hardwareStruct.mot);
    } else {
        predictiveCommandOn = false;
            // No control
    }
    // add_benchmark_time();
    hardwareCounter++;
    if (hardwareCounter > 999) {
            //These actions are performed at 1 Hz
        hardwareCounter = 0;

            //Updating power supply value (the value is 10 times bigger than the real value)
        hardwareStruct.voltage = (unsigned char)((analogRead(POWER_SUPPLY_ADC_PIN) * 33 *766)/409600);

            //Updating the temperature
        hardwareStruct.temperature = read_temperature();
        if (hardwareStruct.temperature > MAX_TEMPERATURE) {
            motor_temperature_is_critic();
        }
    }
}


void set_ready_to_update_hardware() {
    readyToUpdateHardware = true;
}

void set_ready_to_update_current() {
    readyToUpdateCurrent = true;
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
    motor_print_motor();
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
            // digitalWrite(BOARD_LED_PIN, LOW);
        } else if (detailedCounter == 100) {
            detailedCounter = 0;
            motor_secure_pwm_write(PWM_2_PIN, 0);
            motor_secure_pwm_write(PWM_1_PIN, 500);
            // digitalWrite(BOARD_LED_PIN, HIGH);
        }
    }
}



int32 evaluate_trajectory_least_square(uint16 (*pidealTraj)(uint16)) {
    uint16 time = 0;
    uint16 idealPos = 0;
    uint16 realPos = 0;
    int16 diff = 0;
    int32 result = 0;
    int32 temp = 0;

    // digitalWrite(BOARD_TX_ENABLE, HIGH);
    // Serial1.println("");
    for (int i = 0; i < NB_POSITIONS_SAVED; i++) {
        if ((i > 100 && timeArray[i] == 0) || timeArray[i] > 9999) {
            break;
        }
        time = timeArray[i];
        idealPos = pidealTraj(time);
        realPos = positionArray[i];
        diff = idealPos - realPos;
        temp = result;
        result = result + diff*diff;

        if (result < temp) {
                // Overflowed
            return temp;
        }

    }

    // Serial1.waitDataToBeSent();
    // digitalWrite(BOARD_TX_ENABLE, LOW);

    return result;
}

float next_inertia(float pPreviousI, float pCurrentI, int32 pPreviousScore, int32 pCurrentScore) {
        /*
         * Note to the future :
         * Lets say you have to substract 2 uint and then use that result to do a floating point division.
         * Substracting 2 uint and casting the result as a float looks like a decent idea.
         *
         * It isn't.
         *
         * The reason is that the substraction will be treated as a unsigned substraction before the cast,
         * meaning that (float)((uint)1 - (uint)2) = huge positive number instead of -1.0.
         */
    float num = ((float)(pCurrentScore * (pCurrentI - pPreviousI)));
    float denum = ((float)(pCurrentScore - pPreviousScore));
    float result = pCurrentI -  num/denum;


    return result;
}

float auto_calibrate_inertia(float pPreviousI, float pCurrentI, int32 pPreviousScore, int32 pCurrentScore) {
    return addedInertia + 0.0005;//0.00005;

    if (pCurrentScore == TOO_BIG || pPreviousScore == TOO_BIG) {
            //Second iteration is blind
        return 0.001;
    } else if (pPreviousI == pCurrentI) {
            // Hack to get out of stuck situations
        if (pCurrentI == 0.001) {
            return 0.0;
        } else {
            return 1.0;
        }
    } else {
        return next_inertia(pPreviousI, pCurrentI, pPreviousScore, pCurrentScore);
    }
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
        arrayOfTimeStamps[timeIndex] = timer2.getCount();
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
    dxl_regs.ram.positionTrackerOn = true;

    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("Start");
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);

        //Waiting for the measures to be made
    while(dxl_regs.ram.positionTrackerOn == true) {
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
