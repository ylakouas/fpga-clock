# Boolean Board constraints
# Lines copied from the official Real Digital master XDC.
# Only the pins actually used by the current design are listed.

# Configuration bank voltage - required, applies to the whole design
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# 100 MHz oscillator, pin F14
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}]

# Tell Vivado this clock has a 10 ns period, i.e. 100 MHz
create_clock -period 10.000 -name sys_clk [get_ports {clk}]

# LED 0, pin G1
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {led}]