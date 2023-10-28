# sht40-spin 
--------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for the SHT4x-series temperature/humidity sensors.

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.


## Salient Features

* P1: I2C connection at up to 1MHz (PASM-based I2C) or ~26kHz (bytecode-based I2C)
* P2: I2C connection at up to 1MHz (NuCode build) 900kHz (PASM2 build)
* Read temperature, relative humidity (ADC words or scaled values)
* Set heater current and duration
* Set measurement repeatability
* Read the serial number


## Requirements

P1/SPIN1:
* spin-standard-library
* `sensor.temp_rh.common.spinh` (provided by spin-standard-library)
* 1 extra core/cog for the PASM-based I2C engine (none if the slower bytecode-based engine is used)

P2/SPIN2:
* p2-spin-standard-library
* `sensor.temp_rh.common.spin2h` (provided by p2-spin-standard-library)


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.5.0)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.5.0)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.5.0)       | NuCode       | OK                    |
| P2        | SPIN2    | FlexSpin (6.5.0)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* Very early in development - may malfunction, or outright fail to build

