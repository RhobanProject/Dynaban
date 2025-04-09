![Dynaban: An alternative firmware for Dynamixel servos](docs/logo.png)

This repository contains an open-source alternative firmware for Dynamixel servos, offering complete control over the hardware and predictive control capabilities.

## What's New?

**The firmware is stable and usable.**

**New, powerful functionalities have been implemented. More on this [below](#advanced-functionalities).**

Setting CW and CCW limits to the same value enables wheel mode. Now, setting both to 4095 puts the servo in "multi-turn" mode. In that mode, the goal position ranges from -32768 to +32768.  
Example: if the servo is at 0° and you command 720°, it will rotate twice before stopping.

## RoboCup 2016 Symposium Paper
[Available here](docs/DynabanRoboCup2016.pdf)

## Supported Servos

Currently supported servos:

* `mx64`: MX-64 & MX-64A

## Videos

- [Cursive written "Hello world" with a 6 DoF arm](https://www.youtube.com/watch?v=dzXZ_eCfBkI)
- [Trajectory demo (training part not filmed)](https://www.youtube.com/watch?v=J7hV0yLmQu0)
- [Torque-controlled arm tests](https://www.youtube.com/watch?v=g23DFRDJjfQ)

## Install

### Tested on Ubuntu 22.04
```bash
sudo apt install build-essential dfu-util binutils-arm-none-eabi gcc-arm-none-eabi libstdc++-arm-none-eabi-newlib
```


## Building and Programming

Go to the `firmware/` directory and edit the `Makefile` to set the appropriate `BOARD` variable for your servo.

Then run:
```bash
make
```

Use a USB2Dynamixel, USB2AX, or any device that allows communication with your servo, and connect a suitable external power supply. Power off the servo and run:

```bash
make install
```

This runs a flash script (see `scripts/`), which waits for the servo to boot into flash mode. Then power on the servo.

⚠️ **When prompted with 'Trying to enter bootloader...', restart the servo by unplugging/replugging its power (not the USB). The bootloader only listens for firmware commands at startup.**

## How to Control the Servo Once Dynaban is Flashed

Anything that works with the default firmware should work with Dynaban.

However, to access advanced features, we recommend using this modified version of Pypot:
[https://bitbucket.org/RemiFabre/pypotdynabanedition](https://bitbucket.org/RemiFabre/pypotdynabanedition)

The videos above use this code:
[https://bitbucket.org/RemiFabre/dear](https://bitbucket.org/RemiFabre/dear)


## Basic Functionalities

### RAM (volatile memory)

| Field | Status |
|-------|--------|
| LED | Mapped |
| D Gain | Mapped |
| I Gain | Mapped |
| P Gain | Mapped |
| Torque Enable | Mapped (default 0) |
| Goal Position | Mapped |
| Moving Speed | Mapped (enables wheel mode if `mode` is 5) |
| Torque Limit | Not mapped |
| Present Position | Mapped |
| Present Speed | Mapped |
| Present Load | Not mapped |
| Present Voltage | Mapped |
| Present Temperature | Mapped |
| Registered | Not mapped |
| Moving | Mapped |
| Lock | Not mapped |
| Punch | Not mapped |
| Current | Mapped but noisy and unreliable |
| Torque Control Mode Enable | Mapped |
| Goal Torque | Mapped, but not very accurate |
| Goal Acceleration | Not mapped |

### EEPROM (flash)

| Field | Status |
|-------|--------|
| Model Number | Mapped |
| Firmware Version | Mapped |
| ID | Mapped |
| Baud Rate | Mapped |
| Return Delay Time | Not mapped |
| CW/CCW Angle Limits | Mapped |
| Temperature Limit | Not mapped (fixed at 70°C) |
| Voltage Limits | Not mapped |
| Max Torque | Not mapped |
| Status Return Level | Not mapped |
| Alarm LED | Not mapped |
| Multi-turn Offset | Not mapped |
| Resolution Divider | Not mapped |

## <a name="advanced-functionalities"></a>Advanced Functionalities

### RAM Mapping Extension

The RAM map has been extended beyond the default `goalAcceleration` at address `0x49`.  
New fields include trajectory and torque splines, mode control, friction parameters, debug flags, etc.

| Address Range | Name                         | Type             | Description                                 |
|---------------|------------------------------|------------------|---------------------------------------------|
| `0x4A`        | `trajPoly1Size`              | `unsigned char`  | Degree of position polynomial (traj1)       |
| `0x4B–0x5B`   | `trajPoly1`                  | `float[5]`       | Position trajectory polynomial (traj1)      |
| `0x5F`        | `torquePoly1Size`           | `unsigned char`  | Degree of torque polynomial (traj1)         |
| `0x60–0x70`   | `torquePoly1`               | `float[5]`       | Torque trajectory polynomial (traj1)        |
| `0x75`        | `duration1`                 | `uint16`         | Duration of first trajectory (traj1)        |
| `0x76`        | `trajPoly2Size`             | `unsigned char`  | Degree of position polynomial (traj2)       |
| `0x77–0x87`   | `trajPoly2`                 | `float[5]`       | Position trajectory polynomial (traj2)      |
| `0x8B`        | `torquePoly2Size`           | `unsigned char`  | Degree of torque polynomial (traj2)         |
| `0x8C–0x9C`   | `torquePoly2`               | `float[5]`       | Torque trajectory polynomial (traj2)        |
| `0xA0`        | `duration2`                 | `uint16`         | Duration of second trajectory (traj2)       |
| `0xA2`        | `mode`                      | `unsigned char`  | Current control mode                        |
| `0xA3`        | `copyNextBuffer`            | `unsigned char`  | Flag to copy traj2 to traj1 after exec      |
| `0xA4`        | `positionTrackerOn`         | `bool`           | Internal position tracker (debug use)       |
| `0xA5`        | `debugOn`                   | `bool`           | Enables serial debug output                 |
| `0xA6`        | `staticFriction`            | `uint16`         | Static friction value                       |
| `0xA8`        | `i0`                        | `float`          | Motor model parameter (no-load current)     |
| `0xAC`        | `r`                         | `float`          | Motor resistance                            |
| `0xB0`        | `ke`                        | `float`          | Back EMF constant                           |
| `0xB4`        | `kvis`                      | `float`          | Viscous friction coefficient                |
| `0xB8`        | `statToCoulTrans`           | `uint16`         | Transition value from static to Coulomb     |
| `0xBA`        | `coulombCommandDivider`     | `float`          | Divider for Coulomb friction compensation   |
| `0xBE`        | `speedCalculationDelay`     | `int16`          | Delay used for speed computation (ms)       |
| `0xC0`        | `outputTorque`              | `float`          | Estimated current output torque             |
| `0xC4`        | `outputTorqueWithoutFriction` | `float`        | Torque estimate without friction            |
| `0xC8`        | `frozenRamOn`               | `unsigned char`  | Locks RAM parameters (freeze current state) |
| `0xC9`        | `useValuesNow`              | `unsigned char`  | Applies RAM values immediately              |
| `0xCA`        | `torqueKp`                  | `uint16`         | Proportional gain for torque control        |
| `0xCC`        | `goalTorque`                | `float`          | Target torque                               |


### Servo Modes (via `mode` at address 0xA2)

| Mode | Description |
|------|-------------|
| 0 | Default mode. Uses the PID to follow the goal position. The behaviour should be almost identical to the default firmware |
| 1 | Predictive command only. Follows the trajectory set in the traj1 fields but only relying on the model of the motor. This mode can be useful when calibrating the model  |
| 2 | PID only. Follows the trajectory set in the traj1 fields but only relying on the PID. |
| 3 | PID and predictive command. Follows the trajectory set in the traj1 fields using both the PID and the predictive command. This should be the default mode when following a trajectory |
| 4 | Compliant-kind-of mode. In this mode, the servo will try to act compliant |

## Predictive control background
One strong limitation of the default firmware is that the only control loop that is available is a PID (which is already an enhancement compared to the RX family that has only a P).
A PID is meant to compensate the differences between what is predicted by the model of our system and what actually happens. 
Those differences come from :
- The model limitations (how is the friction modelized? Is the inertia taken in concideration? Etc.)
- The loopback imprecisions (accuracy and delay) 
- The external pertubations. 
**The default firmware has no model**, so the PID has a lot of work to do !
Let's say that we want to follow a predefined trajectory, like a min-jerk trajectory. The servo is attached to a weight of 270g at a distance of 12cm. With a PID-only approach, we compare the ideal trajectory with 3 actual trajectories the motor did with orders sent at 25Hz, 50Hz and 1000Hz :
![Following a trajectory with a PID only approach](trajectory/half_turn_min_jerk.png)

Even though the static precision is perfect (the I part of the PID ensures a null static error), the dynamic precision is not and even reaches ~8° when the speed is maximum. In a 6 DOF robotic linear arm, where the errors stack up, the lack of dynamic precision is prohibitive. Increasing the frequency of the orders improves the quality of the result but the enhancement is capped, there would be almost no diference in quality between the 1000Hz curve and a 2000Hz curve. By construction, a PID-only approach will always lag behind a moving command.

In order to overcome this problem, the Dynaban firmware implements a model of the motor. More precisely :

- A model of the electric motor (essentialy the relationship between input voltage, rotation speed and output torque)
- A model of the frictions (with an estimation of the static friction and the coulomb friction)
- An inertial model

After tuning the model, we managed to get decent results with a **full open loop approach** : 
![Following a trajectory with a PID only approach and with a model only approach (open loop)](trajectory/open_loop_speed_trajectory_270g_12cm_45degrees_weight_compensation.png)

And almost perfect results (< 0.4°) when we combine the model and the PID :
![Following a trajectory with a PID only approach and with a model only approach (open loop)](trajectory/speed_control_and_pid.png)

## How to use the predictive control?
The idea here is to tell the servo what it will have to do in the near future and let it try to match it. More precisely :
- The servo needs to know the positions it should be at in the near future
- The servo needs to know the torques it should output in the near future

In order to achieve that, you'll have to :
- Choose the duration of the spline (i.e. what we called "near future"). **Beware though**, the duration is an integer in tenth of milliseconds (10000 is 1 s)
- Send a polynome describing the expected positions for the duration. You can choose the degree of the polynome between 0 and 4. If the polynome looks like a0 + a1*t + a2*t², then you'll have to send the 3 floats a0, a1 and a2 to the servo and set trajPoly1Size to 3.
- Send a polynome describing the expected torque for the duration. The 2 polynomes don't need to be of equal degrees.

Once these informations have been set, the servo will try to follow the trajectory as soon as the field "mode" is set to 1, 2 or 3 (cf [Using the field mode](#Using the field mode)).

When the trajectory ends, the field "mode" will automatically be set to 0 (default, position control mode). Basically, the servo will try to stay where it landed at the end of the trajectory. [Unless you want to continue your trajectory with an other one.](#How do I smoothly continue a trajectory after the first one ended ?)

## How do I smoothly continue a trajectory after the first one ended ?
As you can notice in the [RAM mapping extention](#RAM mapping extention), the fields needed to use the predictive control are present twice. Once under the name of traj1 and once under the name of traj2 (trajPoly2Size, trajPoly2, torquePoly2, etc).
The fields traj2 are a buffer that will be copied into the traj1 fields once the traj1 finishes. 

For this behaviour to happen, you'll have to set copyNextBuffer to 1. copyNextBuffer is automatically set to 0 when the buffer is copied. So, in order to continue a trajectory several times, the procedure would be :
- Update traj2 and set copyNextBuffer to 1
- Once traj1 is finished, update traj2 and set copyNextBuffer to 1
- Once traj1 is finished, update traj2 and set copyNextBuffer to 1
etc.

The transitions between the trajectories should be made in a way that ensures the continuity of both torque and position trajectories and their derivates. Don't do this :>)
![Don't do this :>)](docs/piece_wise_continuity.png)
    
## Model parameters
Dynaban uses a model of the electrical motor and a model of friction. These models have parameters that can be adjusted by the user with the following fields :
- staticFriction
- i0
- r
- ke
- kvis
- statToCoulTrans
- coulombCommandDivider
    

## Speed calculation 
The speedCalculationDelay field is expressed in ms and affects how the speed is calculated. The greater speedCalculationDelay is, the greater the granularity on the speed calculation and vice-versa. The current speed calculation implementation is approximately equivalent to :
speed(t) = position (t) - position (t - speedCalculationDelay)

The granularity (or LSB) of the speed is as follows :  
LSB = 1000/speedCalculationDelay  
Where LSB is in steps/s and speedCalcultaionDelay is in ms.  
=> With a speedCalculationDelay of 50 ms, the speed value will be a multiple of 20 steps/s (1.76 deg/s).  

There is a pitfall though, if you set the speedCalculationDelay so high that the servo is fast enough to do more than half a rotation during speedCalculationDelay, then bad things will happen. This could be solved by the firmware but the cons seem to outweight the pros since this only happens with extreme values.  
Respect the following formula and it will be fine:  
**speedCalculationDelay < 2048 * 1000 / maxServoSpeed**   
Where speedCalculationDelay is in ms and maxServoSpeed is in steps/s.  
8096 steps/s (2 rotations/s) is a comfortable max speed for a MX64 => maximum value of speedCalculationDelay = 252 ms

## Miscellaneous
When the debugOn field is set to 1, debug information will be printed through the serial interface every time something is written by the user on the serial interface.

Don't mind the positionTrackerOn field, it's used by us when testing and benchmarking but it's not meant to be user-friendly. The idea here is to store information (typically the present position) on the RAM as fast as possible and, only when the experience is over, send the data through the serial port. The position sensor is currently read at 1KHz (could be read up to 10KHz) which is way more than what's achievable through the dxl protocol.


## Is using floating point values a good idea ?
Dynaban started on a MX-64 which is powered by a Cortex M3 with a 72MHz clock. The embedded micro controller doesn't have a FPU, which means that both floating point multiplications and floating point divisions take a lot of time to process. 
We did some benchmarks. Measures were done with a hardware timer with a precision of 0.1 ms :
1 000 000 floating point multiplications done in 1.1431 seconds, which implies ~82 clock cycles per multiplication.
1 000 000 floating point divisions done in 1.0995 seconds, which implies ~79 clock cycles per division.

~80 cycles for an operation is a lot, but Dynaban works well even though the hardware is ticked at 1 kHz. Using floats when talking torques and following timed trajectories is handy but we might need fixed point arithmetics if this is needed on a device with lesser uC performances.



## Warnings
⚠️ **Warning 1:** A bad firmware can break your servo. Be careful when you code.

⚠️ **Warning 2:** Using an alternative firmware may void the warranty of your servo.

## License

This is under [CC by-nc-sa](http://creativecommons.org/licenses/by-nc-sa/3.0/) license
