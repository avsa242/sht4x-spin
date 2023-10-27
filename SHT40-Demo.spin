{
    --------------------------------------------
    Filename: SHT40-Demo.spin
    Author: Jesse Burt
    Description: SHT40 driver demo
        * Temp/RH data output
    Copyright (c) 2023
    Started Oct 27, 2023
    Updated Oct 27, 2023
    See end of file for terms of use.
    --------------------------------------------

    Build-time symbols supported by driver:
        -DSHT40_I2C (default if none specified)
        -DSHT40_I2C_BC
}

'#define SHT40_I2C_BC                           ' use the bytecode-based I2C engine
'#pragma exportdef(SHT40_I2C_BC)                '

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq


OBJ

    cfg:    "boardcfg.flip"
    sensor: "sensor.temp_rh.sht40" | SCL=28, SDA=29, I2C_FREQ=1_000_000
    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    time:   "time"


PUB setup()

    ser.start()
    time.msleep(30)
    ser.clear()
    ser.strln(string("Serial terminal started"))

    if ( sensor.start() )
        ser.strln(string("SHT40 driver started"))
    else
        ser.strln(string("SHT40 driver failed to start - halting"))
        repeat

    sensor.temp_scale(sensor.C)
    demo()

#include "temp_rhdemo.common.spinh"             ' code common to all temp/RH demos

DAT
{
Copyright 2023 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

