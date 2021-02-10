`define FIRMWARE "firmware.hex"
`include "soc.v"

module top (
	input clk,
	output [3:0] leds,
	output uart_tx
);

	soc #(
		.CLK_MHZ(100)
	) composed_soc (
		.clk(clk),
		.leds(leds),
		.uart_tx(uart_tx)
	);

endmodule
