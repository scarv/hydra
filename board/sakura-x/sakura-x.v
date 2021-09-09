module sakura_x(
    input k_clk_osc0_clk_p,   // input clk_in1_p
    input k_clk_osc0_clk_n,  // input clk_in1_n
    input k_resetb,
	output [3:0] leds,
	output uart_tx
);

wire clk_50M;
clk_wiz_0 clk_gen
   (
    // Clock out ports
    .clk_out1(clk_50M),             // output clk_out1
    // Status and control signals
    .reset(k_resetb),               // input reset
    .locked(locked),                // output locked
   // Clock in ports
    .clk_in1_p(k_clk_osc0_clk_p),   // input clk_in1_p
    .clk_in1_n(k_clk_osc0_clk_n));  // input clk_in1_n

	soc #(
		.CLK_MHZ(50)
	) composed_soc (
		.clk(clk_50M),
		.rstn(locked),
		.leds(leds),
		.uart_tx(uart_tx)
	);

endmodule
