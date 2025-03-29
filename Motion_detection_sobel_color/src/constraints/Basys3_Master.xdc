## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {threshold[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {threshold[1]}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {threshold[2]}]
set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {threshold[3]}]
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {threshold[4]}]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {threshold[5]}]
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {threshold[6]}]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {threshold[7]}]
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports {detection_threshold[0]}]
set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports {detection_threshold[1]}]
set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports {detection_threshold[2]}]
set_property -dict { PACKAGE_PIN R3    IOSTANDARD LVCMOS33 } [get_ports {detection_threshold[3]}]
set_property -dict { PACKAGE_PIN W2    IOSTANDARD LVCMOS33 } [get_ports {detection_threshold[4]}]
set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports {detection_threshold[5]}]
set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports {detection_threshold[6]}]
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports {detection_threshold[7]}]


## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[3]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[4]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[5]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[6]}]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[7]}]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[8]}]
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[9]}]
set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[10]}]
set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[11]}]
set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[12]}]
set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[13]}]
set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[14]}]
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports {motion_detected_led[15]}]



##Buttons
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports reset]


##Pmod Header JA
#set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports {trigger}];#Sch name = JA1
set_property -dict { PACKAGE_PIN L2   IOSTANDARD LVCMOS33 } [get_ports {motion_detected_signal}];#Sch name = JA2
#set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports {JA[2]}];#Sch name = JA3
#set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports {echo}];#Sch name = JA4
#set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVCMOS33 } [get_ports {JA[4]}];#Sch name = JA7
#set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVCMOS33 } [get_ports {JA[5]}];#Sch name = JA8
#set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVCMOS33 } [get_ports {JA[6]}];#Sch name = JA9
#set_property -dict { PACKAGE_PIN G3   IOSTANDARD LVCMOS33 } [get_ports {trigger}];#Sch name = JA10

##Pmod Header JB

set_property -dict { PACKAGE_PIN A14  IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[0] }]; #IO_L6P_T0_16       ,Sch=JB1
set_property -dict { PACKAGE_PIN A16  IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[2] }]; #IO_L12P_T1_MRCC_16 ,Sch=JB2
set_property -dict { PACKAGE_PIN B15  IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[4] }]; #IO_L11N_T1_SRCC_16 ,Sch=JB3
set_property -dict { PACKAGE_PIN B16  IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[6] }]; #IO_L13N_T2_MRCC_16 ,Sch=JB4
set_property -dict { PACKAGE_PIN A15  IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[1] }]; #IO_L6N_T0_VREF_16  ,Sch=JB7
set_property -dict { PACKAGE_PIN A17  IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[3] }]; #IO_L12N_T1_MRCC_16 ,Sch=JB8
set_property -dict { PACKAGE_PIN C15  IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[5] }]; #IO_L11P_T1_SRCC_16 ,Sch=JB9
set_property -dict { PACKAGE_PIN C16  IOSTANDARD LVCMOS33 } [get_ports { ov7670_data[7] }]; #IO_L13P_T2_MRCC_16 ,Sch=JB10


##Pmod Header JC

set_property -dict { PACKAGE_PIN K17  IOSTANDARD LVCMOS33 } [get_ports { xclk }]; #IO_L12N_T1_MRCC_14 ,Sch=JC1
set_property -dict { PACKAGE_PIN M18  IOSTANDARD LVCMOS33 } [get_ports { href }]; #IO_L11P_T1_SRCC_14 ,Sch=JC2
set_property -dict { PACKAGE_PIN N17  IOSTANDARD LVCMOS33 } [get_ports { sda }]; #IO_L13P_T2_MRCC_14 ,Sch=JC3
##set_property -dict { PACKAGE_PIN P18  IOSTANDARD LVCMOS33 } [get_ports {  }]; #IO_L14P_T2_SRCC_14 ,Sch=JC4
set_property -dict { PACKAGE_PIN L17  IOSTANDARD LVCMOS33 } [get_ports { pclk }]; #IO_L12P_T1_MRCC_14 ,Sch=JC7
set_property -dict { PACKAGE_PIN M19  IOSTANDARD LVCMOS33 } [get_ports { vref }]; #IO_L11N_T1_SRCC_14 ,Sch=JC8
set_property -dict { PACKAGE_PIN P17  IOSTANDARD LVCMOS33 } [get_ports { scl }]; #IO_L13N_T2_MRCC_14 ,Sch=JC9
#set_property -dict { PACKAGE_PIN R18  IOSTANDARD LVCMOS33 } [get_ports { scl }]; #IO_L14N_T2_SRCC_14 ,Sch=JC10



##VGA Connector
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports {red_port[0]}]
set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS33 } [get_ports {red_port[1]}]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports {red_port[2]}]
set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [get_ports {red_port[3]}]
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports {blue_port[0]}]
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports {blue_port[1]}]
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports {blue_port[2]}]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports {blue_port[3]}]
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports {green_port[0]}]
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {green_port[1]}]
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports {green_port[2]}]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports {green_port[3]}]
set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports h_sync]
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports v_sync]



## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pclk_IBUF]