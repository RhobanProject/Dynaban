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

## License

This is under [CC by-nc](http://creativecommons.org/licenses/by-nc/3.0/) license
