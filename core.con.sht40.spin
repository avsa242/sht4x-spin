{
    --------------------------------------------
    Filename: core.con.sht40.spin
    Author: Jesse Burt
    Description: SHT40-specific constants
    Copyright (c) 2023
    Started Oct 26, 2023
    Updated Oct 28, 2023
    See end of file for terms of use.
    --------------------------------------------
}

CON

    { I2C configuration }
    I2C_MAX_FREQ        = 1_000_000             ' device max I2C bus freq
    SLAVE_ADDR          = $44 << 1              ' 7-bit format slave address

    { timings }
    T_POR               = 1_000                 ' startup time (usecs)
    T_SR                = 1_000                 ' soft-reset
    T_W                 = 1_000                 ' min. wait time between I2C commands
    T_MEAS_L            = 1_700                 '\
    T_MEAS_M            = 4_500                 ' - measurement duration
    T_MEAS_H            = 8_200                 '/

    { commands (all return 6 bytes unless otherwise noted) }
    MEAS_TRH_HIGHPREC   = $fd
    MEAS_TRH_MEDPREC    = $f6
    MEAS_TRH_LOWPREC    = $e0
    READ_SN             = $89
    SOFT_RESET          = $94                   ' returns no data

    { activate heater and high-precision meaurements }
    HEATER_LEVEL_MASK   = $f0
    HEATER_DUR_MASK     = $0f
    HEATER_HI           = $30
    HEATER_HI_1SEC      = HEATER_HI | $09
    HEATER_HI_100MSEC   = HEATER_HI | $02
    HEATER_MED          = $20
    HEATER_MED_1SEC     = HEATER_MED | $0f
    HEATER_MED_100MSEC  = HEATER_MED | $04
    HEATER_LO           = $10
    HEATER_LO_1SEC      = HEATER_LO | $0e
    HEATER_LO_100MSEC   = HEATER_LO | $05


PUB null()
' This is not a top-level object

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

