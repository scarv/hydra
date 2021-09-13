//`include "soc.v"

module tb_top;

    reg clk = 0;
    reg rstn;
    wire uart_tx;
    wire [3:0] leds;

    always #1 clk = !clk;
    initial begin
    rstn=0;
    rstn=1;
    end

	soc #(
		.CLK_MHZ(0)
	) composed_soc (
		.clk(clk),
		.rstn(rstn),
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
        wait(composed_soc.primary_cpu.reg_pc == 32'h1020);
        //composed_soc.primary_cpu.cpuregs[15] = 32'h55555555;
        wait(leds[0] == 1);
        $finish;
    end
    
    initial begin
        wait(leds[0] == 1);
        $finish;
    end
endmodule
