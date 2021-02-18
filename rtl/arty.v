`define FIRMWARE "firmware.hex"
`include "soc.v"

module top (
	input clk,
	output [3:0] leds,
	output uart_tx
);

	reg slow_clk = 0;
	reg counter = 0;

	always @(posedge clk) begin
		counter <= counter + 1;
		if (counter == 1'b0)
			slow_clk = !slow_clk;
	end

	soc #(
		.CLK_MHZ(25)
	) composed_soc (
		.clk(slow_clk),
		.leds(leds),
		.uart_tx(uart_tx)
	);

endmodule
