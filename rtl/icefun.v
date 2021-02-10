`define FIRMWARE "build/firmware.hex"
`include "led_display.v"
`include "soc.v"

module top (
	input clk,
	output reg led1, led2, led3, led4, led5, led6, led7, led8,
	output lcol1, lcol2, lcol3, lcol4, uart_tx
);
	wire [3:0] soc_leds;
	wire [2:0] dbg_signals;

	soc #(
		.CLK_MHZ(12)
	) composed_soc (
		.clk(clk),
		.leds(soc_leds),
		.dbg(dbg_signals),
		.uart_tx(uart_tx)
	);

    // -------------------------------
	// LED Display

	reg [2:0] brightness = 3'b111;

	led_display display (
		.clk12MHz(clk),
		.led1,
		.led2,
		.led3,
		.led4,
		.led5,
		.led6,
		.led7,
		.led8,
		.lcol1,
		.lcol2,
		.lcol3,
		.lcol4,

		.leds1   ({30'b0, soc_leds[0]}),
		.leds2   ({29'b0, dbg_signals[0], soc_leds[1]}),
		.leds3   ({29'b0, dbg_signals[1], soc_leds[2]}),
		.leds4   ({29'b0, dbg_signals[2], soc_leds[3]}),
		.leds_pwm(brightness)
	);

endmodule
