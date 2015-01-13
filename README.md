![Dynaban: An alternative firmware for Dynamixel servos](docs/logo.png)

This repository contains an open-source alternative firmware for Dynamixel servos.

**Note 1: A bad firmware can break your servo, we are not responsible for any damage
that could be caused by these manipulations.**

**Note 2: Using an alternative firmware may voids the warranty of your servo.**

## Supported servos

The currently supported servos are:

* `mx64`: MX-64 & MX-64A

## Building and programming

You'll have to install the arm cross-compilation tools. On debian-like distributions,
you can get it with:

```
    sudo aptitude install build-essential git-core dfu-util openocd python \
        python-serial binutils-arm-none-eabi gcc-arm-none-eabi
```

Then, go to the `firmware/` directory and edit the `Makefile` to set the appropriate 
`BOARD` variable, targetting your servo.

You can then run:

```
make
```

Use an USB2Dynamixel, a USB2AX or any hardware that allows communication with your servo,
and bring an appropriate external power supply. Power it off and type:

```
make install
```

This should run the flash script (see `scripts/` directory), that will wait for the servo
to boot for flashing it. Then, simply power on your servo.

## What's new ?

The hardware detection part of the firmware is complete. We can read the magnetic encoder, control the 2 half-bridges that command the motor,  read/write into the ram and the eeprom (flash actually), read the motor's current, read the temperature and read the input voltage.

The hardware abstraction layers we created (motor.*, magnetic_encoder.*, dxl*) are intended to be safe and easy to use. The control.cpp file implements a PID type of control.

A servo using our firmware will be recognized as a MX-64. You can talk with it using the same protocol you've always used.

Here is the list of what is and is not currently implemented when you write into the MX's RAM:

     - LED : mapped.
     - D Gain : mapped (applies to the position control only).
     - I Gain : mapped (applies to the position control only).
     - P Gain : mapped (applies to the position control only).
     - Goal Position : mapped.
     - Moving Speed : mapped. Currently, setting a speed will put the motor in wheel mode.
     - Torque Limit : NOT mapped.
     - Present Position : mapped.
     - Present Speed : Needs to be enhanced though, currently has a 128 ms delay.
     - Present Load : NOT mapped.
     - Present Voltage : mapped.
     - Present Temperature : mapped. Still needs to be tested.
     - Registered : NOT mapped.
     - Moving : mapped.
     - Lock : NOT mapped.
     - Punch : NOT mapped.
     - Current : mapped but very hard to exploit because it is very noisy and is not the same if the motor is going CW or CCW.
       This is the biggest issue we encountered, more about that problem in the notes.
     - Torque Control Mode Enable : mapped.
     - Goal Torque : mapped but does not work that well due to the bad current measurement.
     - Goal Acceleration : NOT mapped.

No EEPROM functionality has been implemented yet. Hence, you can't set angle limitations. Will be implemented soon.

What needs to be done :

Better control loops for speed and acceleration. Make it possible to set a speed in joint mode (connect control loops to each other)
Better current filtering (or read the current at the good moments, in phase with the PWM)
a finir

## License

This is under [CC by-nc](http://creativecommons.org/licenses/by-nc-sa/3.0/) license
