//`include "soc.v"
`ifdef FPGA
	`define FIRMWARE "firmware.mem"
`else
	`define FIRMWARE "build/firmware.mem"
`endif

`ifndef FR      //fault rate (%)
    `define FR 50
`endif

`ifndef NEXP    //number of experiences
    `define NEXP 10
`endif

module tb_top;

reg clk = 0;
reg rstn;
reg fault_inj;
wire uart_tx;
wire [3:0] leds;

always #1 clk = !clk;

initial begin
    rstn =0;
    #3;
    rstn =1;
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
    //$display("Reset finished, UART output follows:\n");
//    wait(leds[0] == 1);
//    $finish;
end
// Echo UART output
always @(posedge composed_soc.uart0.sendReq) begin
    $write("%c", composed_soc.uart0.sendData);
end

`ifdef redundant
reg [31:0] cnt0; //counting execution time of AES => timeout 0x9000
always@(posedge clk) begin
    if(!rstn)         cnt0 <= 0;
    else if (leds[1]) cnt0 <= cnt0+1;
    else if (|cnt0  ) cnt0 <= cnt0+1;
end

wire    timeout = (cnt0 == 32'h0000C000);
integer rand_inj;
integer rand_time;
integer rand_bit;
integer rand_regfault;
integer rand_regindex;

integer reg_index [6:0]; 
initial begin
    reg_index[0] = 9;  //s1
    reg_index[1] = 18; //s2
    reg_index[2] = 19; //s3
    reg_index[3] = 20; //s4
    reg_index[4] = 21; //s5
    reg_index[5] = 22; //s6
    reg_index[6] = 23; //s7
end
wire [4:0] fault_index = reg_index[rand_regindex];
localparam fault_prob = `FR;

initial begin

    for (int i = 0; i<`NEXP; i++) begin
        rand_inj  = $urandom % 100;  //specify probability of injecting a fault
        rand_time = 900+$urandom % 3600; //the duration of the first round of AES
        rand_bit  = $urandom % 32;
        rand_regindex =$urandom % 7; 
        rand_regfault = $urandom;
        fault_inj = 0;
        wait(leds[1]);
        if (rand_inj < fault_prob) begin
            #rand_time;
            `ifdef PC_FAULT_INJ
            $display("inject a PC fault:%d",i);
            fault_inj = 1;
            @(composed_soc.primary_cpu.reg_next_pc)
            composed_soc.primary_cpu.reg_next_pc <= composed_soc.primary_cpu.reg_next_pc + 4;
            @(posedge clk)
            fault_inj = 0;
            //release composed_soc.primary_cpu.reg_next_pc;
            `elsif REG_FAULT_INJ
            $display("inject a Register fault:%d",i);
            fault_inj = 1;
            @(posedge clk)
            composed_soc.primary_cpu.cpuregs[fault_index] = 0;
            @(posedge clk)
            fault_inj = 0;
            //release composed_soc.primary_cpu.cpuregs[9];
            `endif
        end else $display("No fault injection");
        wait(leds[0] || timeout);
        if (timeout) begin
            $display("Broken");
        end
        rstn=0;
        $readmemh(`FIRMWARE,  composed_soc.memory);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rstn=1;
        @(posedge clk);
        @(posedge clk);
    end 
    $finish;
end
`else
initial begin
    wait(composed_soc.resetn == 1);    
    wait(leds[0] == 1);
    $finish;
end
`endif


reg [255*8:0] wavesfile;    // Where to dump VCD wave files
initial begin
    if($value$plusargs("WAVES=%s",wavesfile)) begin
        $dumpfile(wavesfile);
        $dumpvars(0,tb_top);
    end

end

endmodule
