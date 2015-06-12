#include "motor.h"
#include "control.h"
#include "trajectory_manager.h"
#include "dxl_HAL.h"

#define TRAJ_CALC_FREQ 2

static motor mot;
static int nbUpdates = 0;
static buffer previousAngleBuffer;

long currentRawMeasures[C_NB_RAW_MEASURES];
long currentTimming[C_NB_RAW_MEASURES];
int currentMeasureIndex = 0;
bool currentDetailedDebugOn = false;
bool temperatureIsCritic = false;

int16 positionArray[NB_POSITIONS_SAVED];
uint16 timeArray[NB_POSITIONS_SAVED];
uint16 positionIndex = 0;
// bool positionTrackerOn = false;
bool predictiveCommandOn = false;
uint16 counterUpdate = 0;
uint16 previousTime = 0;
float addedInertia = 3*0.00370;
uint16 trackingDivider = 3;
                         /* Moment of inertia added to the motor. Total moment of inertia = I0 + addedInertia.
                         * I0 is a constant defined in trajectory_manager */


//Debug timer
HardwareTimer timer3(3);

motor * motor_get_motor() {
    return &mot;
}

void motor_init(encoder * pEnc) {
    //Ensuring the shut down is active (inversed logic on this one)
    digitalWrite(SHUT_DOWN_PIN, LOW);
    pinMode(SHUT_DOWN_PIN, OUTPUT);
    digitalWrite(SHUT_DOWN_PIN, LOW);

    //Preparing the first PWM signal
    digitalWrite(PWM_1_PIN, LOW);
    pinMode(PWM_1_PIN, PWM);
    pwmWrite(PWM_1_PIN, 0x0000);

    //Preparing the second PWM signal
    digitalWrite(PWM_2_PIN, LOW);
    pinMode(PWM_2_PIN, PWM);
    pwmWrite(PWM_2_PIN, 0x0000);

    if (HAS_CURRENT_SENSING) {
        // ADC pin init
        pinMode(CURRENT_ADC_PIN, INPUT_ANALOG);
    }

    //Releasing the shutdown
    digitalWrite(SHUT_DOWN_PIN, HIGH);

    mot.command = pEnc->angle;
    mot.previousCommand = pEnc->angle;
    mot.angle = pEnc->angle;
    mot.previousAngle = pEnc->angle;
    //mot.angleBuffer = previousAngleBuffer;
    buffer_init(&(mot.angleBuffer), NB_TICKS_BEFORE_UPDATING_SPEED, mot.angle);
    buffer_init(&(mot.speedBuffer), NB_TICKS_BEFORE_UPDATING_ACCELERATION, 0);
    mot.targetAngle = pEnc->angle;
    mot.speed = 0;
    mot.averageSpeed = 0;
    mot.previousSpeed = 0;
    mot.signOfSpeed = 0;
    mot.targetSpeed = 0;
    mot.acceleration = 0;
    mot.targetAcceleration = 0;
    mot.state = MOVING;
    mot.current = 0;
    mot.averageCurrent = 0;
    mot.targetCurrent = 0;
    mot.posAngleLimit = 2047;//3584;
    mot.negAngleLimit = 2049;//512;


    timer3.setPrescaleFactor(7200); // 1 for current debug, 7200 => 10 tick per ms
    timer3.setOverflow(65535);
}

void motor_restart_traj_timer() {
    timer3.pause();
    timer3.refresh();
    timer3.resume();
}

void motor_update(encoder * pEnc) {
    uint16 time;
    int16 dt = 10; /*
                    * This function should be called every dt*10 ms.
                    * The plan B would be to estimate dt = time - previousTime;
                    * */
    //Updating the motor position (ie angle)
    buffer_add(&(mot.angleBuffer), mot.angle);
    mot.previousAngle = mot.angle;
    mot.angle = pEnc->angle;
    long oldPosition = buffer_get(&(mot.angleBuffer));

    motor_update_sign_of_speed();
    if (predictiveCommandOn) {
        if (counterUpdate%TRAJ_CALC_FREQ == 0) {
            time = timer3.getCount();
            if (time > dxl_regs.ram.duration1 && controlMode != COMPLIANT_KIND_OF) {
                motor_restart_traj_timer();
                if (dxl_regs.ram.copyNextBuffer != 0) {
                        // Copying the buffer into the actual trajs
                    dxl_regs.ram.copyNextBuffer = 0;
                    dxl_copy_buffer_trajs();
                    time = 0;
                } else {
                        // Default action : forcing the motor to stay where it stands (through PID)
                    controlMode = POSITION_CONTROL;
                    hardwareStruct.mot->targetAngle = hardwareStruct.mot->angle;
                    dxl_regs.ram.goalPosition = hardwareStruct.mot->targetAngle;
                }

            }
            // float angleRad = (mot.angle * (float)PI) / 2048.0;
            // float weightCompensation = cos(angleRad) * 71;
            // predictive_control_anti_gravity_tick(&mot, mot.speed, dt*TRAJ_CALC_FREQ, weightCompensation, addedInertia);

                // Put all of this back, hacking off code to reduce the bin size that overloads when using a cos...

            if (controlMode == COMPLIANT_KIND_OF) {
                predictive_control_compliant_kind_of(&mot, dt*TRAJ_CALC_FREQ);
            } else {
                predictive_control_tick(&mot,
                                    traj_eval_poly_derivate(dxl_regs.ram.trajPoly1, dxl_regs.ram.trajPoly1Size, dxl_regs.ram.duration1, time),
                                    dt*TRAJ_CALC_FREQ,
                                    traj_eval_poly(dxl_regs.ram.torquePoly1, dxl_regs.ram.torquePoly1Size, dxl_regs.ram.duration1, time),
                                    0);
            }


            if (controlMode == PID_AND_PREDICTIVE_COMMAND) {
                mot.targetAngle = traj_magic_modulo(
                traj_eval_poly(dxl_regs.ram.trajPoly1, dxl_regs.ram.trajPoly1Size, dxl_regs.ram.duration1, time), MAX_ANGLE+1
                                                );
            }

            if (dxl_regs.ram.positionTrackerOn == true) {
                if (counterUpdate%trackingDivider == 0) {
                    positionArray[positionIndex] = mot.angle;//mot.targetAngle;//(int16)weightCompensation;//mot.speed;//mot.predictiveCommand;//traj_min_jerk(timer3.getCount());
                    timeArray[positionIndex] = time;

                    if (positionIndex == NB_POSITIONS_SAVED || time > dxl_regs.ram.duration1) {
                        positionIndex = 0;
                        dxl_regs.ram.positionTrackerOn = false;
                        print_detailed_trajectory();
                    } else {
                        positionIndex++;
                    }
                }
            }

        }
        if (counterUpdate%40 == 0) {
                //mot.targetAngle = traj_constant_speed(2048, 10000, timer3.getCount());
            // mot.targetAngle = traj_min_jerk(timer3.getCount());
        }

        counterUpdate++;
    }

        //Updating the motor speed
    long previousSpeed = mot.speed;

    mot.speed = mot.angle - oldPosition;//((mot.speed*12) + ((mot.angle - oldPosition)*speedCoef)*4)/16.0;
    if (abs(mot.speed) > MAX_SPEED) {
        //Position went from near max to near 0 or vice-versa
        if (mot.angle >= oldPosition) {
            mot.speed = mot.speed - MAX_ANGLE;
        } else if (mot.angle < oldPosition) {
            mot.speed = mot.speed + MAX_ANGLE;
        }
    }
    mot.speed = mot.speed * SPEED_COEF;

        //Averaging with previous value :
    mot.averageSpeed = ((previousSpeed*99) + (mot.speed))/100.0;
    buffer_add(&(mot.speedBuffer), mot.speed);

    //Updating the motor acceleration
    long oldSpeed = buffer_get(&(mot.speedBuffer));
    mot.acceleration = mot.speed - oldSpeed;

    nbUpdates++;
}

void motor_read_current() {
    if (HAS_CURRENT_SENSING) {
        mot.current = analogRead(CURRENT_ADC_PIN) - 2048;

        if (abs(mot.current) > 500) {
            // Values that big are not taken into account. This is a bad hack and can be optimized.
        } else {
            mot.averageCurrent = ((AVERAGE_FACTOR_FOR_CURRENT - 1) * mot.averageCurrent * PRESCALE + mot.current * PRESCALE) / (AVERAGE_FACTOR_FOR_CURRENT * PRESCALE);
        }

        if (currentDetailedDebugOn == true) {
            currentRawMeasures[currentMeasureIndex] = mot.current;
            currentTimming[currentMeasureIndex] = timer3.getCount();
            currentMeasureIndex++;
            if (currentMeasureIndex > (C_NB_RAW_MEASURES-1)) {
                currentDetailedDebugOn = false;
                currentMeasureIndex = 0;
            }
        }
    }
}

void motor_update_sign_of_speed() {
    if (abs(mot.speed) < (1*SPEED_COEF)) {
            // Sign will remain what it was before
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

void motor_set_command(long pCommand) {
    if (temperatureIsCritic == true) {
        // Nope, go cool down yourself before you consider spin again, motor bro.
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

    long command = mot.command;
    long previousCommand = mot.previousCommand;
    if (mot.state == COMPLIANT) {
        mot.state = MOVING;
        motor_restart();
    }

    if (command >= 0 && previousCommand >= 0) {
        //No need to change the spin direction
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

void motor_secure_pwm_write(uint8 pPin, uint16 pCommand){
    if (pCommand > MAX_COMMAND) {
        pwmWrite(pPin, MAX_COMMAND);
    } else {
        pwmWrite(pPin, pCommand);
    }
}

void motor_set_target_angle(long pAngle) {
    //Reseting the control to avoid inertia with the integral part
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

long motor_check_limit_angles(long pAngle) {
    if (motor_is_valid_angle(pAngle)) {
        return pAngle;
    }

        // pAngle is not a valid angle, the function will return the closest valid angle
    long posDiff = control_angle_diff(pAngle, mot.posAngleLimit);
    long negDiff = control_angle_diff(pAngle, mot.negAngleLimit);

    if (abs(posDiff) < abs(negDiff)) {
        return mot.posAngleLimit;
    } else {
        return mot.negAngleLimit;
    }
}

bool motor_is_valid_angle(long pAngle) {
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
    //Reseting the control to avoid inertia with the integral part
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
    temperatureIsCritic = true;
    motor_compliant();
    // digitalWrite(BOARD_LED_PIN, HIGH);
}

void print_detailed_trajectory() {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("");
    for (int i = 0; i < NB_POSITIONS_SAVED; i++) {
        if (i > 100 && timeArray[i] == 0) {
            break;
        }
        Serial1.print(timeArray[i]); // No delay when printing a position
        // Serial1.print(timeArray[i] - NB_TICKS_BEFORE_UPDATING_SPEED*10); // Taking into account the speed update delay
        Serial1.print(" ");
        Serial1.println(positionArray[i]);
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
}
#else
void motor_printMotor() {
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
}
#endif
