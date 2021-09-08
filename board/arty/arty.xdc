# Clock pin
set_property PACKAGE_PIN E3 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]

# LEDs
set_property PACKAGE_PIN H5  [get_ports {leds[0]}]
set_property PACKAGE_PIN J5  [get_ports {leds[1]}]
set_property PACKAGE_PIN T9  [get_ports {leds[2]}]
set_property PACKAGE_PIN T10 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]

# UART
set_property PACKAGE_PIN D10 [get_ports {uart_tx}]
set_property IOSTANDARD LVCMOS33 [get_ports {uart_tx}]

# Clock constraints
create_clock -period 10.0 [get_ports {clk}]
