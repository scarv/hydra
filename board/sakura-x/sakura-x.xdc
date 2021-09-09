set_property PACKAGE_PIN AB2 [get_ports k_clk_osc0_clk_p]
set_property PACKAGE_PIN AC2 [get_ports k_clk_osc0_clk_n]


set_property IOSTANDARD DIFF_HSTL_I [get_ports k_clk_osc0_clk_n]
set_property IOSTANDARD DIFF_HSTL_I [get_ports k_clk_osc0_clk_p]


set_property PACKAGE_PIN L23 [get_ports k_resetb]
set_property PACKAGE_PIN N17 [get_ports uart_tx]
set_property PACKAGE_PIN G20 [get_ports {leds[0]}]
set_property PACKAGE_PIN L19 [get_ports {leds[1]}]
set_property PACKAGE_PIN K18 [get_ports {leds[2]}]
set_property PACKAGE_PIN H19 [get_ports {leds[3]}]

set_property IOSTANDARD LVCMOS25 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {leds[3]}]

set_property IOSTANDARD LVCMOS25 [get_ports uart_tx]
set_property DRIVE 12 [get_ports uart_tx]
set_property SLEW SLOW [get_ports uart_tx]

set_property IOSTANDARD LVCMOS25 [get_ports k_resetb]




