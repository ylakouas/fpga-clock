# FPGA Digital Clock and Programmable Controller

A digital clock built in SystemVerilog, running on an FPGA.

## Goal

Take the board's 100 MHz oscillator and turn it into a working timepiece:
hours, minutes, and seconds on the seven-segment display, with pushbutton
control for reset and time setting. Built from the ground up in modular RTL,
with every module verified in simulation before it goes near hardware.

## Hardware

- Real Digital Boolean Board
- AMD/Xilinx Spartan-7 XC7S50-CSGA324A
- 100 MHz onboard oscillator, 8-digit seven-segment display,
  16 switches, 16 LEDs, 4 pushbuttons, 2 RGB LEDs, PWM audio

## Tools

- SystemVerilog
- AMD Vivado (synthesis, implementation, simulation, programming)
- VS Code for editing

## Design approach

- Timing is derived as clock-enable pulses from the single 100 MHz clock.
  No internally generated derived clocks, so the whole design stays in
  one clock domain.
- Small, single-purpose modules rather than one large top module.
- Counters are parameterized so simulated intervals can be shortened,
  making testbenches practical to run.
- Every module is verified with a Vivado testbench before integration.
- All pushbutton inputs are synchronized and debounced.

## Status

Complete. Core clock (timebase, seconds/minutes/hours counters,
multiplexed display, pushbutton reset and time-setting) is built,
simulated, and verified on hardware. Stretch: alarm with switch-set
time, RGB and audio indication implemented and verified on hardware.

## Scope

**Core (complete):** clock enable generation, seconds/minutes/hours
counters with correct rollover, multiplexed seven-segment display
driver, pushbutton reset and time setting via a control FSM, mode
indicator LEDs.

**Stretch (complete):** alarm — hour/minute set via slide switches,
armed/disarmed via pushbutton, RGB LED and PWM audio indication on
match.

**Not implemented:** 12/24-hour mode, stopwatch, countdown timer.

## Notes

Constraints are based on the official Real Digital Boolean Board master
XDC. The board's seven-segment displays are common anode with all signals
active low, and are wired as two independent 4-digit units rather than one
8-digit unit — the display driver is built around that.