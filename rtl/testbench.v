`define FIRMWARE "build/firmware.hex"
`include "soc.v"

module top;

    reg clk = 0;
    wire uart_tx;
    wire [3:0] leds;

    always #1 clk = !clk;

	soc #(
		.CLK_MHZ(0)
	) composed_soc (
		.clk(clk),
		.leds(leds),
		.uart_tx(uart_tx)
	);

    // Echo UART output
    always @(posedge composed_soc.tx_send) begin
        $write("%c", composed_soc.tx_data);
    end

    initial begin
        wait(composed_soc.resetn == 1);
        $display("Reset finished, UART output follows:\n");
        wait(leds[0] == 1);
        $finish;
    end

endmodule
