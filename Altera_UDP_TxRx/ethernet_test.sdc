## Generated SDC file "ethernet_test.out.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.1.0 Build 590 10/25/2017 SJ Standard Edition"

## DATE    "Wed Apr 03 23:55:52 2019"

##
## DEVICE  "EP4CE10F17C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {E_TXC} -period 40.000 -waveform { 0.000 20.000 } [get_nets {E_TXC~input}]
create_clock -name {E_RXC} -period 40.000 -waveform { 0.000 20.000 } [get_ports { E_RXC }]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {E_RXC}] -rise_to [get_clocks {E_TXC}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {E_RXC}] -fall_to [get_clocks {E_TXC}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {E_RXC}] -rise_to [get_clocks {E_TXC}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {E_RXC}] -fall_to [get_clocks {E_TXC}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {E_TXC}] -rise_to [get_clocks {E_RXC}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {E_TXC}] -fall_to [get_clocks {E_RXC}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {E_TXC}] -rise_to [get_clocks {E_RXC}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {E_TXC}] -fall_to [get_clocks {E_RXC}]  0.030  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

