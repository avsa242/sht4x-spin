{
    --------------------------------------------
    Filename: sensor.temp_rh.sht40.spin
    Author: Jesse Burt
    Description: Driver for Sensirion SHT4x-series sensors
    Copyright (c) 2023
    Started Oct 26, 2023
    Updated Oct 28, 2023
    See end of file for terms of use.
    --------------------------------------------
}

CON

    { I2C }
    SLAVE_WR    = core.SLAVE_ADDR
    SLAVE_RD    = core.SLAVE_ADDR|1

    DEF_SCL     = 28
    DEF_SDA     = 29
    DEF_HZ      = 100_000
    DEF_ADDR    = 0                             ' not used
    I2C_MAX_FREQ= core.I2C_MAX_FREQ


    { default I/O settings; these can be overridden in the parent object }
    SCL         = DEF_SCL
    SDA         = DEF_SDA
    I2C_FREQ    = DEF_HZ
    I2C_ADDR    = DEF_ADDR


OBJ

{ decide: Bytecode I2C engine, or PASM? Default is PASM if BC isn't specified }
#ifdef SHT40_I2C_BC
    i2c:    "com.i2c.nocog"                     ' BC I2C engine
#else
    i2c:    "com.i2c"                           ' PASM I2C engine
#endif
    core:   "core.con.sht40.spin"               ' hw-specific constants
    time:   "time"                              ' basic timing functions
    crc:    "math.crc"                          ' CRC/checksum routines


PUB null()
' This is not a top-level object


PUB start(): status
' Start using default I/O settings
    return startx(SCL, SDA, I2C_FREQ, I2C_ADDR)


PUB startx(SCL_PIN, SDA_PIN, I2C_HZ, I2C_ADDR): status
' Start using custom IO pins and I2C bus frequency
    if ( lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) )
        if ( status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ) )
            time.usleep(core.T_POR)             ' wait for device startup
            if ( i2c.present(SLAVE_WR) )        ' test device bus presence
                { set the default heater power and duration }
                _heater_cmd := core.HEATER_LO_100MSEC
                return
    ' if this point is reached, something above failed
    ' Re-check I/O pin assignments, bus speed, connections, power
    ' Lastly - make sure you have at least one free core/cog 
    return FALSE


PUB stop()
' Stop the driver
    i2c.deinit()


PUB defaults()
' Set factory defaults


PUB heater_enabled(e)
' Enable the on-chip heater
'   Valid values:
'       0: ignored
'       non-zero: enable
'   NOTE: The heater current and duration should be set prior to calling this method
'       (the driver defaults to low power, short duration)
'   NOTE: The heater will automatically shut off after the set duration
    if ( e )
        command(_heater_cmd)


VAR byte _heater_cmd
PUB heater_set_current(c)
' Set heater current, in milliamperes
'   NOTE: Values are approximate/typical, and valid only at a supply of 3.3V
    case c
        60:
            _heater_cmd := (_heater_cmd & !core.HEATER_LEVEL_MASK) | core.HEATER_HI
        33:
            _heater_cmd := (_heater_cmd & !core.HEATER_LEVEL_MASK) | core.HEATER_MED
        6:
            _heater_cmd := (_heater_cmd & !core.HEATER_LEVEL_MASK) | core.HEATER_LO
        other:
            return -1'EINVALID_ARG


PUB heater_set_duration(d)
' Set heater duration in milliseconds
'   Valid values: 1000 (1 second) or 100
'   NOTE: The heater will automatically shut off after the specified time
'   NOTE: The heater is designed for a maximum duty cycle of 5% (reference datasheet section 4.8)
'   NOTE: 100ms will automatically be chosen if the value is anything other than 1_000
    case ( _heater_cmd & core.HEATER_LEVEL_MASK )
        core.HEATER_HI:
            if ( d == 1_000 )
                _heater_cmd := core.HEATER_HI_1SEC
            else
                _heater_cmd := core.HEATER_HI_100MSEC
        core.HEATER_MED:
            if ( d == 1_000 )
                _heater_cmd := core.HEATER_MED_1SEC
            else
                _heater_cmd := core.HEATER_MED_100MSEC
        core.HEATER_LO:
            if ( d == 1_000 )
                _heater_cmd := core.HEATER_LO_1SEC
            else
                _heater_cmd := core.HEATER_LO_100MSEC
        other:
            _heater_cmd |= core.HEATER_LO

pub measure() | tmp
' Perform a measurement
    tmp := 0
    command(core.MEAS_TRH_HIGHPREC, @tmp)
    _last_temp := tmp.word[0]
    _last_rh := tmp.word[1]


PUB reset()
' Reset the device
    command(core.SOFT_RESET)
    time.msleep(core.T_SR)


PUB rh_data(): rdata
' Get relative humidity ADC word
    measure()
    return _last_rh


pub rh_word2pct(rh_word): rh_pct
' Convert RH ADC word to hundredths of a percent
'   Returns: 0..100_00
    return ((rh_word * 125_00) / 65535) - 6_00


PUB serial_num(ptr_sn): status
' Get serial number
'   ptr_sn: pointer to copy serial number to (4 bytes)
    return command(core.READ_SN, ptr_sn)


PUB temp_data(): tdata
' Get temperature ADC word
    measure()
    return _last_temp


PUB temp_word2deg(temp_word): temp_deg
' Convert temperature ADC word to degrees
'   Returns: hundredths of a degree, in chosen scale
    case _temp_scale
        C:
            return ((175 * (temp_word * 100)) / 65535)-45_00
        F:
            return ((315 * (temp_word * 100)) / 65535)-49_00
        other:
            return FALSE

PRI command(cmd, ptr_data=0): status | wd, word data, byte crc_tmp
' Issue command to sensor
'   Returns: number of bytes read
    status := 0
    case cmd
        core.MEAS_TRH_HIGHPREC, core.MEAS_TRH_MEDPREC, core.MEAS_TRH_LOWPREC, ...
        core.READ_SN, core.HEATER_HI_1SEC, core.HEATER_HI_100MSEC, ...
        core.HEATER_MED_1SEC, core.HEATER_MED_100MSEC, core.HEATER_LO_1SEC, ...
        core.HEATER_LO_100MSEC:
            i2c.start()
            i2c.write(SLAVE_WR)
            i2c.write(cmd)

            time.msleep(10)

            i2c.start()
            i2c.write(SLAVE_RD)
            repeat wd from 0 to 1
                data := i2c.rdword_msbf(i2c.ACK)
                crc_tmp := i2c.rd_byte(wd == 1) ' send NAK (-1) if i == 1 ("done reading data")
                if ( crc_tmp == crc.sensirion_crc8(@data, 2) )
                { data is good - copy it to the destination buffer }
                    wordmove(ptr_data+(wd*2), @data, 1)
                    status += 2
                else
                { CRC is bad - don't copy the data, and return an error }
                    status := -1
                    quit
            i2c.stop()
            return                              ' number of bytes read
        core.SOFT_RESET:
            i2c.start()
            i2c.write(SLAVE_WR)
            i2c.write(core.SOFT_RESET)
            i2c.stop()
            return 0


#include "sensor.temp_rh.common.spinh"


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

