`define FIRMWARE "firmware.hex"
`include "soc.v"

module top (
	input clk,
	output [3:0] leds,
	output uart_tx
);

	reg slow_clk = 0;

	always @(posedge clk) begin
		slow_clk = !slow_clk;
	end

	soc #(
		.CLK_MHZ(50)
	) composed_soc (
		.clk(slow_clk),
		.leds(leds),
		.uart_tx(uart_tx)
	);

endmodule
