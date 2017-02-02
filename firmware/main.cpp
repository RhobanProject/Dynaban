#include <libmaple/adc.h>
#include <libmaple/timer.h>
#include <wirish/wirish.h>
#include "control.h"
#include "dxl.h"
#include "dxl_HAL.h"
#include "flash_write.h"
#include "magnetic_encoder.h"
#include "motor.h"
#include "trajectory_manager.h"

#define POWER_SUPPLY_ADC_PIN PA2
#define TEMPERATURE_ADC_PIN PA1
#define OVER_FLOW 3000

/**
 * Schedules the hardware tasks
 */
void hardware_tick();

void set_ready_to_update_hardware();

void set_ready_to_update_current();

/**
 * Returns the temperature in degrees celcius.
 */
uint8_t read_temperature();

/**
 * Returns 10 times the voltage
 */
uint8_t read_voltage();

/**
 * Generic debug print. Will show info on the current state of the motor and its
 * control.
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
 * Automatic or manual inertial calibration helper
 **/
void inertial_calibration();

/*
 * Returns the score of the trajectory, based on a least square approach. If the
 *trajectory is perfectly followed, the score is 0.
 **/
int32 evaluate_trajectory_least_square(uint16 (*pidealTraj)(uint16));

/**
 * Returns the next moment of inertia I to be tested in order to minimize the
 * score
 * Xn+1 = Xn - f(Xn) * (Xn - Xn-1)/(f(Xn) - f(Xn-1))
 */
float next_inertia(float pPreviousI, float pCurrentI, int32 pPreviousScore,
                   int32 pCurrentScore);

float auto_calibrate_inertia(float pPreviousI, float pCurrentI,
                             int32 pPreviousScore, int32 pCurrentScore);

/**
 * Internal use. Dumps information used for model calibration
 */
void model_calibration();
/**
 * A series of movement patterns are applied. Dumps information used for the
 * model calibration.
 */
void extensive_model_calibration();

/*
 * Saves the current value of the benchmark timer in a array
 **/
void add_benchmark_time();

/*
 * Dumps the entire flash
 **/
void dump_flash();
void dump_section_of_flash(int addr, int maxAddr);
void test();
void print_flash_start_adress();

const uint32 TOO_BIG = 1 << 30;
static bool DXL_COM_ON = true;

long counter = 0;
int posCounter = 0;
unsigned int hardwareCounter = 0;
bool readyToUpdateHardware = false;
bool readyToUpdateCurrent = false;
bool firstTime = true;
bool firstTimePrint = true;
bool firstTimeNewSpeed = true;
int32 score = TOO_BIG;
int32 previousScore = TOO_BIG;
int32 averageScore = 0;
float previousInertia = 0.0;
uint8 repetitions = 0;

unsigned char controlMode = OFF;
hardware hardwareStruct;

// Benchmarking
const int TIME_STAMP_SIZE = 1000;
static long arrayOfTimeStamps[TIME_STAMP_SIZE];
HardwareTimer timer2(2);
uint16 timeIndex = 0;
bool temp = false;

void setup() {
  disableDebugPorts();

  afio_remap(AFIO_REMAP_USART1);
  gpio_set_mode(GPIOB, 6, GPIO_AF_OUTPUT_PP);
  gpio_set_mode(GPIOB, 7, GPIO_INPUT_FLOATING);

  // Hack for priting before inits
  /*  Serial1.begin(57600);
  delay(2000);
  dump_flash();
  while(1);*/

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

  // Encoder init and firt read of position
  encoder_init_sharing_pins_mode(7, 8);
  encoder_add_encoder_sharing_pins_mode(6);
  encoder_read_angles_sharing_pins_mode();

  // Dxl
  dxl_init();

  // Motor init
  motor_init(encoder_get_encoder(0));

  // Control
  control_init();

  // Traj
  predictive_control_init();

  hardwareStruct.enc = encoder_get_encoder(0);
  hardwareStruct.mot = motor_get_motor();
  hardwareStruct.temperature = read_temperature();
  hardwareStruct.voltage = read_voltage();

  // This function will block the rest of the program and print detailed current
  // debug
  // printDetailedCurrentDebug();

  timer2.pause();
  // The hardware will be read at 1Khz
  timer2.setPrescaleFactor(72);
  timer2.setOverflow(1000);
  timer2.setChannel1Mode(TIMER_OUTPUT_COMPARE);
  // Interrupt 1 count after each update
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

  // Dxl struct init. Values that depend on previous inits (motor struct mainly)
  init_dxl_ram();
  init_dxl_eeprom();

  // Heartbit
  for (int i = 0; i < 4; i++) {
    toggleLED();
    delay(250);
  }
  // HIGH means off ...
  digitalWrite(BOARD_LED_PIN, HIGH);
  controlMode = OFF;

  // Temp code :
  //    delay(2000);
  //    extensive_model_calibration();
  //    model_calibration();
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

  // Uncomment to output debug
  //     if (counter % 100*40 == 0) {
  //         print_debug();
  //     }

  // Playing with the calibration :
  //    if (counter > 2000 && firstTime) {
  //    	inertial_calibration();
  //    }
}

void hardware_tick() {
  // These actions are performed at a rate of 1kHz and cost ~98-102 us

  // add_benchmark_time();
  // Updating the encoder (~90-92 us)
  encoder_read_angles_sharing_pins_mode();
  // add_benchmark_time();
  // Updating the motor (~5-6 us with predictive control on)
  motor_update(hardwareStruct.enc);

  // add_benchmark_time();
  // Updating control (3-4 us)
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
  } else if (controlMode == PID_ONLY) {
    // PID only, but uses the trajectory system (where POSITION_CONTROL does
    // not)
    predictiveCommandOn = true;
    control_tick_PID_on_position(hardwareStruct.mot);
  } else if (controlMode == COMPLIANT_KIND_OF) {
    predictiveCommandOn = true;
    control_tick_predictive_command_only(hardwareStruct.mot);
  } else if (controlMode == CURRENT_CONTROL) {
    // Disabled, current measure is not reliable
  } else {
    predictiveCommandOn = false;
    // No control
  }
  // add_benchmark_time();
  if (hardwareCounter & (1 << 7)) {
    /*
     * These actions are performed at ~10 Hz (7.8 Hz).
     * Why the & (1 << 7) weirdness? We try to avoid % operator when possible,
     * takes too long.
     */

    // Updating power supply value (the value is 10 times bigger than the real
    // value)
    uint8_t voltageMeasure = read_voltage();
    // Mobile averaging to reduce impact of transient values of voltages
    hardwareStruct.voltage = (hardwareStruct.voltage * 3 + voltageMeasure) / 4;
  }
  hardwareCounter++;
  if (hardwareCounter & (1 << 10)) {
    // These actions are performed at ~1 Hz (0.98Hz)
    hardwareCounter = 0;

    // Updating the temperature
    hardwareStruct.temperature = read_temperature();
    if (hardwareStruct.temperature > dxl_regs.eeprom.temperatureLimit) {
      digitalWrite(BOARD_TX_ENABLE, HIGH);
      Serial1.println();
      Serial1.print("temperature = ");
      Serial1.print(hardwareStruct.temperature);
      Serial1.waitDataToBeSent();
      digitalWrite(BOARD_TX_ENABLE, LOW);
      delayMicroseconds(50000);
      motor_temperature_is_critic();
    } else if (hardwareStruct.mot->temperatureIsCritic &&
               hardwareStruct.temperature <
                   (dxl_regs.eeprom.temperatureLimit - 5)) {
      // We'll allow the motor to restart
      motor_temperature_is_okay();
    }
  }
}

void set_ready_to_update_hardware() { readyToUpdateHardware = true; }

void set_ready_to_update_current() { readyToUpdateCurrent = true; }

/* The Thermistor value is R (~4.7 kOhm at ~ 20°). We approximated the
   Temperature(Resitance) law as follows :
   T°(R) = -32.25 * ln(R) + 297.37.
   The voltage arrives at the adc pin through a bridge with a 4.7kOhm resistor :
   vThermistor = 3.3V * (R)/(4700 + R)
   => R = 4700*vThermistor / (vThermistor - 3.3)
*/
uint8_t read_temperature() {
  uint16_t input = analogRead(TEMPERATURE_ADC_PIN);

  float vThermistor = (input * 33) / (40960.0);
  float thermistor = 47000 * (vThermistor) / (33 - 10 * vThermistor);
  unsigned char temperature = (-3225 * log(thermistor) + 29737) / 100;

  return temperature;
}

uint8_t read_voltage() {
  return (uint8_t)((analogRead(POWER_SUPPLY_ADC_PIN) * 33 * 766) / 409600);
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

  while (true) {
    detailedCounter++;
    delay(50);
    timer3.resume();
    currentDetailedDebugOn = true;

    // Waiting for the measures to be made
    while (currentDetailedDebugOn != false) {
      // delayMicroseconds(1);
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

void inertial_calibration() {
  if (counter > 2000 && firstTime && false) {
    firstTime = false;
    // Taking care of the V(0) problem (static annoying stuff)
    // controlMode = OFF;

    // motor_set_command(80);
    // while (hardwareStruct.mot->angle > 5 && hardwareStruct.mot->angle < 4091)
    // {
    //     hardware_tick();
    //     delay(1);
    // }

    timer3.pause();
    timer3.refresh();
    timer3.resume();

    // hardwareStruct.mot->targetAngle = (hardwareStruct.mot->angle +
    // 2048)%4096;
    // controlMode = POSITION_CONTROL;
    controlMode = PREDICTIVE_COMMAND_ONLY;  // PID_AND_PREDICTIVE_COMMAND
    dxl_regs.ram.positionTrackerOn = true;
    // motor_set_command(2700); // max speed
  }

  // if (counter > 68000 && firstTimeNewSpeed == true) {
  //     firstTimeNewSpeed = false;
  //     motor_set_command(2700); // max speed
  // }

  if (firstTime == false && dxl_regs.ram.positionTrackerOn == false &&
      firstTimePrint == true) {
    // Used for manual calibration :
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
    // Used for Auto-calibration :
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
      // This score is way too high, the least-square must have over-flowed.
      // We'll redo the move
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
      score = averageScore / 3;
      averageScore = 0;
      float temp = addedInertia;
      addedInertia = auto_calibrate_inertia(previousInertia, addedInertia,
                                            previousScore, score);
      previousInertia = temp;

      digitalWrite(BOARD_TX_ENABLE, HIGH);
      Serial1.println();
      Serial1.print("Previous least square : ");
      Serial1.println(previousScore);
      Serial1.print("Current least square  : ");
      Serial1.println(score);
      Serial1.print("With inertia : ");
      Serial1.println(previousInertia * 1000);
      Serial1.print("Next inertia to be tested : ");
      Serial1.println(addedInertia * 1000);
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
    result = result + diff * diff;

    if (result < temp) {
      // Overflowed
      return temp;
    }
  }

  // Serial1.waitDataToBeSent();
  // digitalWrite(BOARD_TX_ENABLE, LOW);

  return result;
}

float next_inertia(float pPreviousI, float pCurrentI, int32 pPreviousScore,
                   int32 pCurrentScore) {
  /*
   * Note to the future :
   * Lets say you have to substract 2 uint and then use that result to do a
   * floating point division.
   * Substracting 2 uint and casting the result as a float looks like a decent
   * idea.
   *
   * It isn't.
   *
   * The reason is that the substraction will be treated as a unsigned
   * substraction before the cast,
   * meaning that (float)((uint)1 - (uint)2) = huge positive number instead of
   * -1.0.
   */
  float num = ((float)(pCurrentScore * (pCurrentI - pPreviousI)));
  float denum = ((float)(pCurrentScore - pPreviousScore));
  float result = pCurrentI - num / denum;

  return result;
}

float auto_calibrate_inertia(float pPreviousI, float pCurrentI,
                             int32 pPreviousScore, int32 pCurrentScore) {
  return addedInertia + 0.0005;  // 0.00005;

  if (pCurrentScore == TOO_BIG || pPreviousScore == TOO_BIG) {
    // Second iteration is blind
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
  timer3.pause();

  controlMode = OFF;
  hardwareStruct.mot->state = MOVING;

  dxl_regs.ram.positionTrackerOn = true;

  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("Start");
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);

  timer3.refresh();
  motor_set_command(2950);
  timer3.resume();
  // Waiting for the measures to be made
  while (dxl_regs.ram.positionTrackerOn == true) {
    if (readyToUpdateHardware) {
      readyToUpdateHardware = false;
      hardware_tick();
    }
    delayMicroseconds(10);
  }
  motor_compliant();
  toggleLED();
  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("Finished");
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);

  while (true)
    ;
}

void print_flash_start_adress() {
  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("Flash Adress = ");
  Serial1.println(flashStartAdress(), 16);
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
}

void extensive_model_calibration() {
  controlMode = OFF;
  hardwareStruct.mot->state = MOVING;
  int16_t command = 0;
  int16_t step = 50;
  int16_t maxCommand = 2950;
  uint16_t nbTicks = 0;

  // The first calibration test is a step by step increase in the command. Each
  // step is ~1 s, so this test is ~1 minute long
  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("StartOfNewTest 0");
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
  for (command = 0; abs(command) <= abs(maxCommand); command = command + step) {
    timer3.pause();
    timer3.refresh();
    command = command + step;

    // Making at least speedCalculationDelay hardware_ticks to make sure the
    // position buffer is fully charged (since we're manually ticking
    // hardware_ticks, between tests we wait to much before ticking it)
    while (nbTicks < (dxl_regs.ram.speedCalculationDelay + 5)) {
      if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
        nbTicks++;
      }
      delayMicroseconds(10);
    }
    nbTicks = 0;
    motor_restart();
    motor_set_command(command);
    timer3.resume();
    // Activating the tracking
    dxl_regs.ram.positionTrackerOn = true;
    // Waiting for the measures to be made
    while (dxl_regs.ram.positionTrackerOn == true) {
      if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
      }
      delayMicroseconds(10);
    }
  }
  motor_compliant();
  delayMicroseconds(100 * 1000);

  // The second test is a series of saw tooth command patterns
  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("StartOfNewTest 1");
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
  command = 0;
  step = 1;
  uint16_t counter = 0;
  for (int i = 0; i < 9; i++) {
    step = 3 * i + 1;
    timer3.pause();
    timer3.refresh();

    // Making at least speedCalculationDelay hardware_ticks to make sure the
    // position buffer is fully charged (since we're manually ticking
    // hardware_ticks, between tests we wait to much before ticking it)
    while (nbTicks < (dxl_regs.ram.speedCalculationDelay + 5)) {
      if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
        nbTicks++;
      }
      delayMicroseconds(10);
    }
    nbTicks = 0;

    motor_restart();
    timer3.resume();
    // Activating the tracking
    dxl_regs.ram.positionTrackerOn = true;
    // Waiting for the measures to be made
    while (dxl_regs.ram.positionTrackerOn == true) {
      if (readyToUpdateHardware) {
        if (counter % 250 == 0) {
          // Changing the direction of the command increase
          step = step * -1;
        }
        command = command + step;
        motor_set_command(command);
        readyToUpdateHardware = false;
        hardware_tick();
        counter++;
      }
      delayMicroseconds(10);
    }

    command = 0;
    motor_set_command(0);
    delayMicroseconds(500 * 1000);
  }

  motor_compliant();
  delayMicroseconds(500 * 1000);

  // The third calibration is 0 to step jump from 0 speed.
  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("StartOfNewTest 2");
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
  step = 80;
  command = 0;
  for (command = 0; abs(command) <= abs(maxCommand);
       command = abs(command) + step) {
    timer3.pause();
    timer3.refresh();

    // Making at least speedCalculationDelay hardware_ticks to make sure the
    // position buffer is fully charged (since we're manually ticking
    // hardware_ticks, between tests we wait to much before ticking it)
    while (nbTicks < (dxl_regs.ram.speedCalculationDelay + 5)) {
      if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
        nbTicks++;
      }
      delayMicroseconds(10);
    }
    nbTicks = 0;

    motor_restart();
    motor_set_command(command);
    timer3.resume();
    // Activating the tracking
    dxl_regs.ram.positionTrackerOn = true;

    // Waiting for the measures to be made
    while (dxl_regs.ram.positionTrackerOn == true) {
      if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
      }
      delayMicroseconds(10);
    }

    motor_set_command(0);
    delayMicroseconds(500 * 1000);

    // Same but with the opposite sign
    timer3.pause();
    timer3.refresh();
    command = -command;

    // Making at least speedCalculationDelay hardware_ticks to make sure the
    // position buffer is fully charged (since we're manually ticking
    // hardware_ticks, between tests we wait to much before ticking it)
    while (nbTicks < (dxl_regs.ram.speedCalculationDelay + 5)) {
      if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
        nbTicks++;
      }
      delayMicroseconds(10);
    }
    nbTicks = 0;

    motor_restart();
    motor_set_command(command);
    timer3.resume();
    // Activating the tracking
    dxl_regs.ram.positionTrackerOn = true;

    // Waiting for the measures to be made
    while (dxl_regs.ram.positionTrackerOn == true) {
      if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
      }
      delayMicroseconds(10);
    }
    motor_set_command(0);
    delayMicroseconds(500 * 1000);
  }
  motor_compliant();
  while (true)
    ;
}

void model_calibration() {
  controlMode = OFF;
  hardwareStruct.mot->state = MOVING;
  int16_t command = 0;
  int16_t step = 100;
  int16_t maxCommand = 2900;
  uint16_t delayMs = 1000;
  uint16_t nbTicks = 0;

  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println();
  Serial1.print("Command ");
  Serial1.print("Speed ");
  Serial1.print("AverageSpeed ");
  Serial1.print("Temperature ");
  Serial1.print("Voltage ");
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
  for (command = 0; abs(command) <= abs(maxCommand); command = command + step) {
    motor_set_command(command);
    while (nbTicks < delayMs) {
      if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardware_tick();
        nbTicks++;
      }
      delayMicroseconds(10);
    }
    nbTicks = 0;
    // Sending results
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println();
    Serial1.print(command);
    Serial1.print(" ");
    Serial1.print(hardwareStruct.mot->speed);
    Serial1.print(" ");
    Serial1.print(hardwareStruct.mot->averageSpeed);
    Serial1.print(" ");
    Serial1.print(hardwareStruct.temperature);
    Serial1.print(" ");
    Serial1.print(hardwareStruct.voltage);
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
  }
  motor_compliant();
  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println();
  Serial1.print("Done.");
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
}

void dump_flash() {
  int const arraySize = 1024;
  unsigned char cdata[arraySize];
  unsigned int i;
  unsigned int addr = 0x08000000;  // 0;
  unsigned int maxAddr = 0x08000000 + 131072;
  unsigned int localMaxAddr = 0;
  unsigned int bufferSize = arraySize;
  boolean endOfMemory = false;

  while (addr < maxAddr) {
    for (i = 0; i < arraySize; i++) {
      cdata[i] = *(volatile unsigned char*)(addr++);
      if (addr == maxAddr) {
        localMaxAddr = i + 1;
        endOfMemory = true;
        break;
      }
    }

    if (endOfMemory) {
      bufferSize = localMaxAddr;
    } else {
      bufferSize = arraySize;
    }

    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("");
    Serial1.print("from ");
    Serial1.print(addr - bufferSize, 16);
    Serial1.print(" to ");
    Serial1.print(addr, 16);
    Serial1.println("");
    for (unsigned int i = 0; i < bufferSize; i++) {
      // We want 0x05 to be printed "05" instead of "5"
      if (cdata[i] < 16) {
        Serial1.print("0");
      }
      Serial1.print(cdata[i], 16);
    }

    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
  }
}

void dump_section_of_flash(int addr, int maxAddr) {
  int const arraySize = 1024;
  unsigned char cdata[arraySize];
  unsigned int i;
  unsigned int localMaxAddr = 0;
  unsigned int bufferSize = arraySize;
  boolean endOfMemory = false;

  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("");
  Serial1.print("Reading from ");
  Serial1.print(addr, 16);
  Serial1.print("to ");
  Serial1.print(maxAddr, 16);
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);

  while (addr < maxAddr) {
    for (i = 0; i < arraySize; i++) {
      cdata[i] = *(volatile unsigned char*)(addr++);
      if (addr == maxAddr) {
        endOfMemory = true;
        localMaxAddr = i + 1;
        break;
      }
    }
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("");
    if (endOfMemory) {
      bufferSize = localMaxAddr;
    } else {
      bufferSize = arraySize;
    }
    for (unsigned int i = 0; i < bufferSize; i++) {
      // We want 0x05 to be printed "05" instead of "5"
      if (cdata[i] < 16) {
        Serial1.print("0");
      }
      Serial1.print(cdata[i], 16);
    }

    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
  }
}

void test() {
  int const arraySize = 1024;
  unsigned char cdata[arraySize];
  unsigned int i;
  unsigned int addr = 0x08000000;  // 0;

  for (i = 0; i < arraySize; i++) {
    cdata[i] = *(volatile unsigned char*)(addr++);
  }

  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("");
  Serial1.print("end addr == ");
  Serial1.print(addr, 16);
  Serial1.println("");

  for (unsigned int i = 0; i < arraySize; i++) {
    Serial1.print(cdata[i], 16);
  }

  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
}

// Force init to be called *first*, i.e. before static object allocation.
// Otherwise, statically allocated objects that need libmaple may fail.
__attribute__((constructor)) void premain() { init(); }

int main(void) {
  setup();

  while (true) {
    loop();
  }

  return 0;
}
