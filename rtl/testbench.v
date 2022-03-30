//`include "soc.v"

module tb_top;

reg clk = 0;
reg rstn;
reg fault_inj;
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

initial begin
    wait(composed_soc.resetn == 1);
    $display("Reset finished, UART output follows:\n");
    wait(leds[0] == 1);
    $finish;
end
// Echo UART output
always @(posedge composed_soc.uart0.sendReq) begin
    $write("%c", composed_soc.uart0.sendData);
end



initial begin
    fault_inj = 0;
    wait(composed_soc.wdt0.din_val == 1'b1);
    #9000;
    `ifdef PC_FAULT_INJ
    $display("inject a PC fault\n");
    fault_inj = 1;
    //force composed_soc.primary_cpu.alu_out = 32'h00000000;
    //composed_soc.primary_cpu.cpuregs[9] = 0;
    @(posedge clk)
    force composed_soc.primary_cpu.reg_next_pc = composed_soc.primary_cpu.reg_next_pc + 4;
    @(posedge clk)
    fault_inj = 0;
    release composed_soc.primary_cpu.reg_next_pc;
    `elsif REG_FAULT_INJ
    $display("inject a Register fault\n");
    fault_inj = 1;
    @(posedge clk)
    composed_soc.primary_cpu.cpuregs[9] = 0;
    @(posedge clk)
    fault_inj = 0;
    //release composed_soc.primary_cpu.cpuregs[9];
    `endif
end


initial begin
    wait(leds[0] == 1);
    $finish;
end

reg [255*8:0] wavesfile;    // Where to dump VCD wave files
initial begin
    if($value$plusargs("WAVES=%s",wavesfile)) begin
    end else begin
        wavesfile="waves-icarus.vcd";
    end
    $dumpfile(wavesfile);
    $dumpvars(0,tb_top);
end

endmodule
