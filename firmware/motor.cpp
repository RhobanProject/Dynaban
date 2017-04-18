#include "motor.h"
#include "control.h"
#include "dxl_HAL.h"
#include "trajectory_manager.h"

static motor mot;
static buffer previousAngleBuffer;
void init_filter_state(filter *f, float e_cte);
void motor_init_filter_speed(motor *mot, float n0p, float n1p, float n2p,
                             float d0p, float d1p, float d2p, float te);
int32 currentRawMeasures[C_NB_RAW_MEASURES];
int32 currentTimming[C_NB_RAW_MEASURES];
int currentMeasureIndex = 0;
bool currentDetailedDebugOn = false;

// Benchmarking
bool activateBenchmark = false;
const int TIME_STAMP_SIZE_MOTOR = 0;
static int32 arrayOfTimeStampsMotor[TIME_STAMP_SIZE_MOTOR];
uint16 timeIndexMotor = 0;
int changeId = 0;
bool notPrintedYet = true;

uint16 timeArray[NB_POSITIONS_SAVED];
int16 commandArray[NB_POSITIONS_SAVED];
int16 positionArray[NB_POSITIONS_SAVED];
int16 speedArray[NB_POSITIONS_SAVED];
uint16 positionIndex = 0;
// bool positionTrackerOn = false;
bool predictiveCommandOn = false;
uint16 counterUpdate = 0;
uint16 previousTime = 0;
float addedInertia = 3 * 0.00370;
uint16 trackingDivider = 1;
/* Moment of inertia added to the motor. Total moment of inertia = I0 +
 * addedInertia.
 * I0 is a constant defined in trajectory_manager */

void motor_add_benchmark_time();
void motor_print_time_stamp();

// Timer for trajectory management
HardwareTimer timer3(3);

motor *motor_get_motor() { return &mot; }

void motor_init(encoder *pEnc) {
  // Ensuring the shut down is active (inversed logic on this one)
  digitalWrite(SHUT_DOWN_PIN, LOW);
  pinMode(SHUT_DOWN_PIN, OUTPUT);
  digitalWrite(SHUT_DOWN_PIN, LOW);

  // Preparing the first PWM signal
  digitalWrite(PWM_1_PIN, LOW);
  pinMode(PWM_1_PIN, PWM);
  pwmWrite(PWM_1_PIN, 0x0000);

  // Preparing the second PWM signal
  digitalWrite(PWM_2_PIN, LOW);
  pinMode(PWM_2_PIN, PWM);
  pwmWrite(PWM_2_PIN, 0x0000);

  if (HAS_CURRENT_SENSING) {
    // ADC pin init
    pinMode(CURRENT_ADC_PIN, INPUT_ANALOG);
  }

  // Releasing the shutdown
  digitalWrite(SHUT_DOWN_PIN, HIGH);

  // Reading the magic offset in the flash
  mot.offset = -dxl_read_magic_offset();
  mot.command = 0;
  mot.previousCommand = 0;
  mot.predictiveCommand = 0;
  mot.predictiveCommandTorque = 0;
  mot.angle = pEnc->angle + mot.offset;
  mot.previousAngle = pEnc->angle + mot.offset;
  mot.angleBuffer =
      *buffer_creation(dxl_regs.ram.speedCalculationDelay + 1,
                       mot.angle);  // Works because a tick is 1 ms.
  mot.speedBuffer = *buffer_creation(NB_TICKS_BEFORE_UPDATING_ACCELERATION, 0);
  mot.targetAngle = pEnc->angle;
  mot.speed = 0;
  mot.averageSpeed = 0;
  mot.previousSpeed = 0;
  mot.signOfSpeed = 0;
  mot.targetSpeed = 0;
  mot.acceleration = 0;
  mot.targetAcceleration = 0;
  mot.state = COMPLIANT;
  mot.current = 0;
  mot.averageCurrent = 0;
  mot.targetCurrent = 0;
  mot.posAngleLimit = 0;
  mot.negAngleLimit = 0;
  mot.multiTurnOn = false;
  mot.multiTurnAngle = mot.angle;
  mot.electricalTorque = 0.0;
  mot.outputTorque = 0.0;
  mot.targetTorque = 0.0;
  mot.temperatureIsCritic = false;
  // filtre k.p /(1+2*z* p/wn+p2/wn2)
  float k = dxl_regs.ram.speedCalculationDelay + 1;
  float tau = (dxl_regs.ram.speedCalculationDelay + 1) * 0.5;
  float wn = 1 / tau;
  float csi = 0.7;
  float te = 1;
  motor_init_filter_speed(&mot, 0, k, 0, 1, 2 * csi / wn, 1 / (wn * wn), te);
  init_filter_state(&mot.filt_speed, mot.angle);

  mot.feedState[0] = 0;
  mot.feedState[1] = 0;
  mot.feedState[2] = 0;
  mot.previousGoalState[0] = 0;
  mot.previousGoalState[1] = 0;
  mot.previousGoalState[2] = 0;
  mot.previousGoalTime = 0;
  
  mot.time = 0;
  
  timer3.setPrescaleFactor(
      7200);  // 1 for current debug, 7200 => 10 tick per ms
  timer3.setOverflow(65535);
}

void motor_restart_traj_timer() {
  // This timer is used as a timestamp for the trajectories
    //Attention !
  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println();
  Serial1.println("Restarted!!");
  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);

  timer3.pause();
  timer3.refresh();
  timer3.resume();
}

void motor_init_filter_speed(motor *mot, float n0p, float n1p, float n2p,
                             float d0p, float d1p, float d2p, float te) {
  filter *f = &mot->filt_speed;
  float te2 = te * te;
  float d0q = d0p * te2 + 2 * d1p * te + 4 * d2p;
  f->n2q = (n0p * te2 - 2 * n1p * te + 4 * n2p) / d0q;
  f->n1q = (2 * n0p * te2 - 8 * n2p) / d0q;
  f->n0q = (n0p * te2 + 2 * n1p * te + 4 * n2p) / d0q;
  f->d2q = (d0p * te2 - 2 * d1p * te + 4 * d2p) / d0q;
  f->d1q = (2 * d0p * te2 - 8 * d2p) / d0q;
  // icilesgars ,Attention, a initialiser en fonction des entrees intiales,
  // supposees constantes
  f->xn_1 = 0;
  f->xn_2 = 0;
}

void init_filter_state(filter *f, float e_cte) {
  // X(z)/E(z) = 1/(1+d1q.z^-1 +q2q .z^-2), a un gain statique = 1/(1+d1q+d2q) ,
  // d'ou les valeurs de xn-1 et xn-2 a l'equilibre
  f->xn_1 = e_cte / (1 + f->d1q + f->d2q);
  f->xn_2 = f->xn_2;
}

float filter_speed_update(filter *f, float en) {
  float xn = en - f->d1q * f->xn_1 - f->d2q * f->xn_2;
  float sn = f->n0q * xn + f->n1q * f->xn_1 + f->n2q * f->xn_2;
  //----------------------------
  f->xn_2 = f->xn_1;
  f->xn_1 = xn;
  return sn;
}

void motor_update(encoder *pEnc) {
  uint16 time = timer3.getCount();
  mot.time = time;
  int16 dt = 10; /*
                  * This function should be called every 1 ms.
                  * The plan B would be to estimate dt = time - previousTime;
                  * */
  //    int16 dt = time - previousTime; // Need to check for the case where the
  //    timer overflows or resets.
  //    previousTime = time;

  // Updating the motor position (ie angle)
  buffer_add(&(mot.angleBuffer), mot.angle);
  // This command is the one from the previous tick since the control is updated
  // after the motor.
  //    buffer_add(&(mot.commandBuffer), mot.command);
  mot.previousAngle = mot.angle;
  // Taking into account the magic offset
  int tempAngle = pEnc->angle + mot.offset;
  if (tempAngle < 0) {
    tempAngle = MAX_ANGLE + tempAngle + 1;
  }

  // Should not be useful, just being careful
  tempAngle = tempAngle % (MAX_ANGLE + 1);
  
  mot.angle = tempAngle;
  if (mot.multiTurnOn == false) {
    mot.multiTurnAngle = mot.angle;
  } else {
    if ((mot.angle - mot.previousAngle) > (MAX_ANGLE + 1) / 2) {
      // Went from 3 to 4092 (4092 - 3 > 2048), the multiturn angle should be
      // what it was minus 7
      mot.multiTurnAngle =
          mot.multiTurnAngle + mot.angle - mot.previousAngle - (MAX_ANGLE + 1);
    } else if ((mot.angle - mot.previousAngle) < (-MAX_ANGLE - 1) / 2) {
      // Went from 4095 to 1, the multiturn angle should be what it was plus 2
      mot.multiTurnAngle =
          mot.multiTurnAngle + mot.angle - mot.previousAngle + (MAX_ANGLE + 1);
    } else {
      mot.multiTurnAngle = mot.multiTurnAngle + mot.angle - mot.previousAngle;
    }
  }

  int16 oldPosition = buffer_get(&(mot.angleBuffer));

  motor_update_sign_of_speed();

  // Updating the motor speed
  int32 previousSpeed = mot.speed;

  //mot.speed = mot.angle - oldPosition;
  // New way of calculating the speed
  mot.speed = filter_speed_update(&mot.filt_speed, mot.angle);
  if (abs(mot.speed) > MAX_ANGLE / 2) {
    // Position went from near max to near 0 or vice-versa
    if (mot.angle >= oldPosition) {
      mot.speed = mot.speed - MAX_ANGLE - 1;
    } else if (mot.angle < oldPosition) {
      mot.speed = mot.speed + MAX_ANGLE + 1;
    }
  }

  // The speed will be in steps/s :
  mot.speed = (mot.speed * 1000) / dxl_regs.ram.speedCalculationDelay;

  // Averaging with previous value (dangerous approach):
  mot.averageSpeed = ((previousSpeed * 99) + (mot.speed)) / 100.0;
  buffer_add(&(mot.speedBuffer), mot.speed);

  // Updating the motor acceleration
  int32 oldSpeed = buffer_get(&(mot.speedBuffer));
  mot.acceleration = mot.speed - oldSpeed;

  if (predictiveCommandOn) {
    if (changeId == 0) {
      changeId = timeIndexMotor;
    }
    
    if (counterUpdate % (dxl_regs.ram.predictiveCommandPeriod) == 0) {
        // Hum, (dxl_regs.ram.time + NB_STATES*dxl_regs.ram.dt) could overflow...
        if (time > (dxl_regs.ram.time + (NB_STATES-1)*dxl_regs.ram.dt) && controlMode != COMPLIANT_KIND_OF) {
          // Default action : forcing the motor to stay where it stands (through
          // PID)
          motor_set_default_mode();
      }
      // These 3 lines make it impossible for the bootloader to load the binary
      // file, mainly because of the cos import. -> Known bug and known solution
      // but quite time consuming.
      //             float angleRad = (mot.angle * (float)PI) / 2048.0;
      //             float weightCompensation = cos(angleRad) * 71;
      //             predictive_control_anti_gravity_tick(&mot, mot.speed,
      //             weightCompensation, addedInertia);

      if (controlMode == COMPLIANT_KIND_OF) {
        predictive_control_anti_gravity_tick(&mot, mot.speed, 0.0, 0.0);
      } else {
          //Interpolating the next goal position/speed/torque
          int32 goalPosition = 0.0;
          int32 goalSpeed = 0.0;
          float goalTorque = 0.0;
          int flag = traj_interpolate_next_state(time, dxl_regs.ram.time, dt * (dxl_regs.ram.predictiveCommandPeriod), mot.previousGoalState, &mot.previousGoalTime, &goalPosition, &goalSpeed, &goalTorque);
          if (flag != 0) {
              // Something went wrong
              motor_set_default_mode();
          }

          // The user sends the torque in mNm
          float goalTorqueSI = goalTorque/1000.0;
          //Calling the feed forward function
          predictive_control_tick(
            &mot,
            goalSpeed,
            dt * (dxl_regs.ram.predictiveCommandPeriod),
            goalTorqueSI, 0);


          // Actually, this is not the position we want to be in dt but the
          // position we should be right now (traj_interpolate_next_state
          // handles this)
          mot.targetAngle = traj_magic_modulo(goalPosition, MAX_ANGLE + 1);
          
          mot.feedState[0] = mot.targetAngle;
          mot.feedState[1] = goalSpeed;
          mot.feedState[2] = goalTorque;
      }

      if (dxl_regs.ram.positionTrackerOn == true) {
        // For arbitrary measures
        if (counterUpdate % trackingDivider == 0) {
          positionArray[positionIndex] =
              mot.angle;  // mot.targetAngle;//(int16)weightCompensation;//mot.speed;//mot.predictiveCommand;//traj_min_jerk(timer3.getCount());
          timeArray[positionIndex] = time;

          if (positionIndex == NB_POSITIONS_SAVED) {
            notPrintedYet = false;
            positionIndex = 0;
            counterUpdate = 0;
            dxl_regs.ram.positionTrackerOn = false;
            print_detailed_trajectory();
          } else {
            positionIndex++;
          }
        }
      }

      // The estimation of the outputed torque has already been done and sent to
      // the ram, updating the motor struct
      mot.electricalTorque = dxl_regs.ram.electricalTorque;
      mot.outputTorque = dxl_regs.ram.ouputTorque;
    }

    counterUpdate++;
  } else {
    if (dxl_regs.ram.positionTrackerOn == true) {
      // For arbitrary measures
      if (counterUpdate % trackingDivider == 0) {
        timeArray[positionIndex] = time;
        commandArray[positionIndex] = mot.command;
        positionArray[positionIndex] = mot.angle;
        speedArray[positionIndex] = mot.speed;

        if (positionIndex == NB_POSITIONS_SAVED) {
          positionIndex = 0;
          counterUpdate = 0;
          dxl_regs.ram.positionTrackerOn = false;
          print_detailed_trajectory();
        } else {
          positionIndex++;
        }
      }
    }
    counterUpdate++;

    // Asking for an estimation of the outputed torque
    predictive_update_output_torques(mot.command, mot.speed);
    mot.electricalTorque = dxl_regs.ram.electricalTorque;
    mot.outputTorque = dxl_regs.ram.ouputTorque;
  }
}

void motor_read_current() {
  if (HAS_CURRENT_SENSING) {
    mot.current = analogRead(CURRENT_ADC_PIN) - 2048;

    if (abs(mot.current) > 500) {
      // Values that big are not taken into account. This is a bad hack and can
      // be optimized.
    } else {
      mot.averageCurrent =
          ((AVERAGE_FACTOR_FOR_CURRENT - 1) * mot.averageCurrent * PRESCALE +
           mot.current * PRESCALE) /
          (AVERAGE_FACTOR_FOR_CURRENT * PRESCALE);
    }

    if (currentDetailedDebugOn == true) {
      currentRawMeasures[currentMeasureIndex] = mot.current;
      currentTimming[currentMeasureIndex] = timer3.getCount();
      currentMeasureIndex++;
      if (currentMeasureIndex > (C_NB_RAW_MEASURES - 1)) {
        currentDetailedDebugOn = false;
        currentMeasureIndex = 0;
      }
    }
  }
}

void motor_update_sign_of_speed() {
  if (abs(mot.speed) < (1 * dxl_regs.ram.speedCalculationDelay)) {
    // Sign will remain what it was before to avoid oscillations when the speed
    // is low (important when trying to compensate static friction)
    return;
  }
  int8 tempSign = sign(mot.speed);
  if (tempSign == 0) {
    // Sign will remain what it was before
    return;
  } else {
    mot.signOfSpeed = tempSign;
    return;
  }

  // Plan B : use the measure of the current
  // digitalWrite(BOARD_LED_PIN, HIGH);
  // mot.signOfSpeed = sign(mot.averageCurrent);
}

void motor_set_command(int16 pCommand) {
  if (mot.temperatureIsCritic == true) {
    // Nope, go cool down yourself before you consider spinning again, motor
    // bro.
    return;
  }
  mot.previousCommand = mot.command;
  if (pCommand > MAX_COMMAND) {
    mot.command = MAX_COMMAND;
  } else if (pCommand < (-MAX_COMMAND)) {
    mot.command = -MAX_COMMAND;
  } else {
    mot.command = pCommand;
  }

  int16 command = mot.command;
  int16 previousCommand = mot.previousCommand;
  if (mot.state != COMPLIANT) {
    if (command >= 0 && previousCommand >= 0) {
      // No need to change the spin direction
      motor_secure_pwm_write(PWM_2_PIN, command);
    } else if (command <= 0 && previousCommand <= 0) {
      motor_secure_pwm_write(PWM_1_PIN, abs(command));
    } else {
      // Change of spin direction procedure
      if (command > 0) {
        motor_secure_pwm_write(PWM_1_PIN, 0);
        motor_secure_pwm_write(PWM_2_PIN, 0);
        motor_secure_pwm_write(PWM_2_PIN, command);
      } else {
        motor_secure_pwm_write(PWM_2_PIN, 0);
        motor_secure_pwm_write(PWM_1_PIN, 0);
        motor_secure_pwm_write(PWM_1_PIN, abs(command));
      }
    }
  }
}

void motor_secure_pwm_write(uint8 pPin, uint16 pCommand) {
  if (pCommand > MAX_COMMAND) {
    pwmWrite(pPin, MAX_COMMAND);
  } else {
    pwmWrite(pPin, pCommand);
  }
}

void motor_set_target_angle(int16 pAngle) {
  // Reseting the control to avoid inertia with the integral part
  control_reset();
  if (pAngle > MAX_ANGLE) {
    mot.targetAngle = MAX_ANGLE;
  } else if (pAngle < 0) {
    mot.targetAngle = 0;
  } else {
    mot.targetAngle = pAngle;
  }

  mot.targetAngle = motor_check_limit_angles(pAngle);
}

void motor_set_target_angle_multi_turn_mode(int16 pAngle) {
  // Reseting the control to avoid inertia with the integral part
  control_reset();

  mot.targetAngle = pAngle;
}

int16 motor_check_limit_angles(int16 pAngle) {
  if (motor_is_valid_angle(pAngle)) {
    return pAngle;
  }

  // pAngle is not a valid angle, the function will return the closest valid
  // angle
  int16 posDiff = control_angle_diff(pAngle, mot.posAngleLimit);
  int16 negDiff = control_angle_diff(pAngle, mot.negAngleLimit);

  if (abs(posDiff) < abs(negDiff)) {
    return mot.posAngleLimit;
  } else {
    return mot.negAngleLimit;
  }
}

bool motor_is_valid_angle(int16 pAngle) {
  if (mot.posAngleLimit == mot.negAngleLimit) {
    // Free wheel mode
    return true;
  }

  if (mot.posAngleLimit > mot.negAngleLimit) {
    // The motor shall never go higher than posLimit nor lower than negLimit
    if ((pAngle <= mot.posAngleLimit) && (pAngle >= mot.negAngleLimit)) {
      // All fine
      return true;
    }
  } else {
    // The motor shall never go outside [0, posLimit] U [negLimit, MAX_ANGLE]
    if ((pAngle <= mot.posAngleLimit) || (pAngle >= mot.negAngleLimit)) {
      // All fine
      return true;
    }
  }

  return false;
}

void motor_set_target_current(int pCurrent) {
  // Reseting the control to avoid inertia with the integral part
  control_reset();
  mot.targetCurrent = pCurrent;
}

/**
   Will make the engine brake. Note : it brakes hard.
 */
void motor_brake() {
  mot.state = BRAKE;
  mot.previousCommand = mot.command;
  mot.command = 0;
  pwmWrite(PWM_2_PIN, 0);
  pwmWrite(PWM_1_PIN, 0);
}

/**
   Will release the motor. Call motor_restart() to get out of this mode
 */
void motor_compliant() {
  mot.state = COMPLIANT;
  mot.previousCommand = mot.command;
  mot.command = 0;
  digitalWrite(SHUT_DOWN_PIN, LOW);
  pwmWrite(PWM_2_PIN, 0);
  pwmWrite(PWM_1_PIN, 0);
}

void motor_restart() {
  mot.state = MOVING;
  digitalWrite(SHUT_DOWN_PIN, HIGH);
}

void motor_temperature_is_critic() {
  mot.temperatureIsCritic = true;
  motor_compliant();
  digitalWrite(BOARD_LED_PIN, LOW);
}

void motor_temperature_is_okay() {
  mot.temperatureIsCritic = false;
  motor_restart();
  digitalWrite(BOARD_LED_PIN, HIGH);
}

void motor_set_default_mode() {
    controlMode = POSITION_CONTROL;
    dxl_regs.ram.mode = 0;
    hardwareStruct.mot->targetAngle = hardwareStruct.mot->angle;
    dxl_regs.ram.goalPosition = hardwareStruct.mot->targetAngle;
    /*
    //Attention !
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println();
    Serial1.println("Stopped!!");
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
    */
}

void print_detailed_trajectory() {
  // The speed has a delay of ~speedCalculationDelay/2 ms. The delay between 2
  // recorded speed points is 1ms * trackingDivider
  uint16_t speedShift =
      (dxl_regs.ram.speedCalculationDelay / 2) * trackingDivider;
  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("");
  Serial1.println("Time Command Position Speed");
  for (int i = 0; i < (NB_POSITIONS_SAVED - speedShift); i++) {
    if (i > 100 && timeArray[i] == 0) {
      break;
    }
    Serial1.print(timeArray[i]);  // No delay when printing a position
    // Serial1.print(timeArray[i] - NB_TICKS_BEFORE_UPDATING_SPEED*10); //
    // Taking into account the speed update delay
    Serial1.print(" ");
    Serial1.print(commandArray[i]);
    Serial1.print(" ");
    Serial1.print(positionArray[i]);
    Serial1.print(" ");
    Serial1.print(speedArray[i]);
    Serial1.println("");
  }

  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
}

void motor_add_benchmark_time() {
  if (timeIndexMotor < TIME_STAMP_SIZE_MOTOR) {
    arrayOfTimeStampsMotor[timeIndexMotor] = timer3.getCount();
    timeIndexMotor++;
  }
}

void motor_print_time_stamp() {
  digitalWrite(BOARD_LED_PIN, LOW);

  digitalWrite(BOARD_TX_ENABLE, HIGH);
  Serial1.println("");
  for (int i = 0; i < TIME_STAMP_SIZE_MOTOR; i++) {
    Serial1.println("Wait for it");
  }
  for (int i = 0; i < TIME_STAMP_SIZE_MOTOR; i++) {
    if (i == changeId) {
      Serial1.println("The change is now !");
    }
    Serial1.println(arrayOfTimeStampsMotor[i]);
  }

  Serial1.waitDataToBeSent();
  digitalWrite(BOARD_TX_ENABLE, LOW);
}

#if BOARD_HAVE_SERIALUSB

void motor_print_motor() {
  SerialUSB.println();
  SerialUSB.println("*** Motor :");
  SerialUSB.print("command : ");
  SerialUSB.println(mot.command);
  SerialUSB.print("previousCommand : ");
  SerialUSB.println(mot.previousCommand);
  SerialUSB.print("angle : ");
  SerialUSB.println(mot.angle);
  SerialUSB.print("previousAngle : ");
  SerialUSB.println(mot.previousAngle);
  SerialUSB.print("targetAngle : ");
  SerialUSB.println(mot.targetAngle);
  SerialUSB.print("state : ");
  SerialUSB.println(mot.state);
  SerialUSB.print("speed : ");
  SerialUSB.println(mot.speed);
  SerialUSB.print("target speed : ");
  SerialUSB.println(mot.targetSpeed);
  SerialUSB.print("acceleration : ");
  SerialUSB.println(mot.acceleration);
  SerialUSB.print("target acceleration : ");
  SerialUSB.println(mot.targetAcceleration);
  SerialUSB.print("current : ");
  SerialUSB.println(mot.current);
  SerialUSB.print("averageCurrent : ");
  SerialUSB.println(mot.averageCurrent);
  SerialUSB.print("offset : ");
  SerialUSB.println(mot.offset);
}
#else

void motor_print_motor() {
  Serial1.println();
  Serial1.println("*** Motor :");
  Serial1.print("command : ");
  Serial1.println(mot.command);
  Serial1.print("previousCommand : ");
  Serial1.println(mot.previousCommand);
  Serial1.print("angle : ");
  Serial1.println(mot.angle);
  Serial1.print("previousAngle : ");
  Serial1.println(mot.previousAngle);
  Serial1.print("targetAngle : ");
  Serial1.println(mot.targetAngle);
  Serial1.print("state : ");
  Serial1.println(mot.state);
  Serial1.print("speed : ");
  Serial1.println(mot.speed);
  Serial1.print("averageSpeed : ");
  Serial1.println(mot.averageSpeed);
  Serial1.print("target speed : ");
  Serial1.println(mot.targetSpeed);
  Serial1.print("acceleration : ");
  Serial1.println(mot.acceleration);
  Serial1.print("target acceleration : ");
  Serial1.println(mot.targetAcceleration);
  Serial1.print("current : ");
  Serial1.println(mot.current);
  Serial1.print("averageCurrent : ");
  Serial1.println(mot.averageCurrent);
  Serial1.print("magicOffset : ");
  Serial1.println(mot.offset);
  Serial1.print("angle buffer : ");
  buffer_print_buffer(&mot.angleBuffer);
  Serial1.print("eletricalTorque : ");
  Serial1.println(mot.electricalTorque);
  Serial1.print("outputTorque : ");
  Serial1.println(mot.outputTorque);
  Serial1.print("targetTorque : ");
  Serial1.println(mot.targetTorque);
}
#endif
