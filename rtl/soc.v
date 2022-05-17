//`include "picorv32.v"
//`include "uart.v"
`ifdef FPGA
	`define FIRMWARE "firmware.mem"
`else
	`define FIRMWARE "build/firmware.mem"
`endif

module soc #(
    parameter CLK_MHZ = 12
) (
    input clk, rstn,
    output wire [3:0] leds,
    output reg [6:0] dbg,
    output reg [31:0] instr_dbg,
    output uart_tx
);

localparam N_CORES = 4;
localparam N_CORES_BITS = (N_CORES == 4) ? 2 : 1;
localparam LEFT_CARRY_BITS = 5;
localparam RIGHT_CARRY_BITS = 2;

localparam M_EXTENSION = 1;

localparam N_SLAVE = 3;  // SRAM, GPO, UART
localparam MEM_WORDS = 8192;
localparam MEM_BITS = $clog2(MEM_WORDS);

// -------------------------------
// Reset && WDT Generator signal
wire self_rst;
wire resetn;
wire wdt_to;    //watchdog timeout requests interrupt


// -------------------------------
// Memory/IO Interface
// Cores <> inter_i
wire [N_CORES      - 1:0] mem_write;
wire [N_CORES * 32 - 1:0] mem_addr;
wire [N_CORES * 32 - 1:0] mem_wdata;
wire [N_CORES *  4 - 1:0] mem_wstrb;
wire [N_CORES * 32 - 1:0] mem_rdata;
wire [N_CORES      - 1:0] mem_valid;
wire [N_CORES      - 1:0] mem_ready;

wire [ 7:0] mcompose;
wire [ 1:0] mcompose_mode;
wire        mcompose_exec;
wire [31:0] mcompose_instr;
wire [31:0] mcompose_reg;
wire [31:0] mcompose_redundant;
wire [N_CORES                  -1 : 0] mcompose_right_ready;
wire [N_CORES*RIGHT_CARRY_BITS -1 : 0] mcompose_right_carry;
wire [N_CORES                  -1 : 0] mcompose_left_ready;
wire [N_CORES*LEFT_CARRY_BITS  -1 : 0] mcompose_left_carry;

wire [N_CORES-2 : 0] fault_in;
wire [N_CORES*4 - 1 : 0] dummy;
wire irq_in;
assign irq_in = |fault_in && (mcompose > 0);
assign mcompose_right_ready[N_CORES-1] = 1;

// -------------------------------
// Primary core
/* verilator lint_off PINMISSING */
picorv32 #(
    .ENABLE_COUNTERS(1),
    .ENABLE_COUNTERS64(0),
    .ENABLE_MHARTID(1),
    .ENABLE_MCOMPOSE(1),
    .ENABLE_MUL(M_EXTENSION),
    .ENABLE_DIV(M_EXTENSION),
    .ENABLE_IRQ(1),
    .LATCHED_IRQ(32'h00000000),
    .LATCHED_MEM_RDATA(1),
    .TWO_STAGE_SHIFT(0),
    .TWO_CYCLE_ALU(0),
    .CATCH_MISALIGN(0),
    .CATCH_ILLINSN(0),
    .HART_ID(0)
) primary_cpu (
    .clk            (clk),
    .resetn         (resetn),
    .mem_valid      (mem_valid[ 0  ]),
    .mem_write      (mem_write[ 0  ]),
    .mem_addr       (mem_addr[ 31:0]),
    .mem_wdata      (mem_wdata[31:0]),
    .mem_wstrb      (mem_wstrb[ 3:0]),
    .mem_rdata      (mem_rdata[31:0]),
    .mem_ready      (mem_ready[ 0  ]),
    .irq            ({30'b0, wdt_to, irq_in}),
    .mcompose_out            (mcompose),
    .mcompose_mode_out       (mcompose_mode),
    .mcompose_right_ready_in (mcompose_right_ready[0]),
    .mcompose_left_ready_out (mcompose_left_ready[0]),
    .mcompose_left_ready_in  (mcompose_left_ready[N_CORES-1]),
    .mcompose_left_carry_out (mcompose_left_carry[LEFT_CARRY_BITS-1:0]),
    .mcompose_left_carry_in  (mcompose_left_carry[N_CORES*LEFT_CARRY_BITS - 1 -: LEFT_CARRY_BITS]),
    .mcompose_right_carry_out(mcompose_right_carry[N_CORES*RIGHT_CARRY_BITS - 1 -: RIGHT_CARRY_BITS]),
    .mcompose_right_carry_in (mcompose_right_carry[RIGHT_CARRY_BITS-1:0]),
    .mcompose_instr_out      (mcompose_instr),
    .mcompose_exec_out       (mcompose_exec),
    .mcompose_reg_out        (mcompose_reg),
    .mcompose_redundant_out  (mcompose_redundant)
);
/* verilator lint_on PINMISSING */
//assign mem_write[0] = mem_valid [0] &&  (|mem_wstrb[3: 0]);
// Secondary cores
genvar core_num;
generate
    for (core_num = 1; core_num < N_CORES; core_num = core_num + 1) begin
    /* verilator lint_off PINMISSING */
        picorv32 #(
            .ENABLE_COUNTERS(1),
            .ENABLE_COUNTERS64(0),
            .ENABLE_MHARTID(1),
            .ENABLE_MCOMPOSE(1),
            .ENABLE_MUL(M_EXTENSION),
            .ENABLE_DIV(M_EXTENSION),
            .LATCHED_MEM_RDATA(1),
            .TWO_STAGE_SHIFT(0),
            .TWO_CYCLE_ALU(0),
            .CATCH_MISALIGN(0),
            .CATCH_ILLINSN(0),
            .HART_ID(core_num)
        ) cpu (
            .clk             (clk),
            .resetn          (resetn),
            .mem_valid       (mem_valid[   core_num           ]),
            .mem_write       (mem_write[   core_num           ]),
            .mem_addr        (mem_addr[ 32*core_num + 31 -: 32]),
            .mem_wdata       (mem_wdata[32*core_num + 31 -: 32]),
            .mem_wstrb       (mem_wstrb[ 4*core_num +  3 -:  4]),
            .mem_ready       (mem_ready[   core_num           ]),
            .mem_rdata       (mem_rdata[32*core_num + 31 -: 32]),
            .irq             ({32'd0}),
            .mcompose_in             (mcompose),
            .mcompose_mode_in        (mcompose_mode),
            .mcompose_right_ready_in (mcompose_right_ready[core_num]),
            .mcompose_left_ready_in  (mcompose_left_ready[core_num - 1]),
            .mcompose_left_carry_in  (mcompose_left_carry[LEFT_CARRY_BITS*(core_num - 1) + LEFT_CARRY_BITS - 1 -: LEFT_CARRY_BITS]),
            .mcompose_right_carry_in (mcompose_right_carry[RIGHT_CARRY_BITS*core_num + RIGHT_CARRY_BITS - 1 -: RIGHT_CARRY_BITS]),
            .mcompose_right_ready_out(mcompose_right_ready[core_num - 1]),
            .mcompose_left_ready_out (mcompose_left_ready[core_num]),
            .mcompose_left_carry_out (mcompose_left_carry[LEFT_CARRY_BITS*core_num + LEFT_CARRY_BITS - 1 -: LEFT_CARRY_BITS]),
            .mcompose_right_carry_out(mcompose_right_carry[RIGHT_CARRY_BITS*(core_num - 1) + RIGHT_CARRY_BITS - 1 -: RIGHT_CARRY_BITS]),
            .mcompose_instr_in       (mcompose_instr),
            .mcompose_exec_in        (mcompose_exec),
            .mcompose_reg_in         (mcompose_reg),
            .mcompose_redundant_in   (mcompose_redundant),
            .mcompose_fault          (fault_in[core_num - 1])
        );
    /* verilator lint_on PINMISSING */
    //    assign mem_write[core_num] = mem_valid [core_num] &&  (|mem_wstrb[ 4*core_num +  3 -: 4]);
    end
endgenerate

wire  [N_CORES      - 1 : 0] master_data_rvalid;
wire  [N_CORES      - 1 : 0] master_data_gnt;
assign                       mem_ready = master_data_rvalid & master_data_gnt;

wire  [N_SLAVE * 32 - 1 : 0] slave_data_addr;
wire  [N_SLAVE * 32 - 1 : 0] slave_data_wdata;
wire  [N_SLAVE * 32 - 1 : 0] slave_data_rdata;
wire  [N_SLAVE      - 1 : 0] slave_data_req;
wire  [N_SLAVE      - 1 : 0] slave_data_we;
wire  [N_SLAVE *  4 - 1 : 0] slave_data_be;
wire                         tx_ready;


inter #(
    .DATA_WIDTH(        32 ),
    .MASTER_ADDR_WIDTH( 32 ),
    .SLAVE_ADDR_WIDTH(  32 ),
    .MASTERS(      N_CORES ),
    .SLAVES(       N_SLAVE ),
    .MASTER_ADDR_MATCH( { 32'h20000000, 32'h10000000, 32'h00000000} ),
    .MASTER_ADDR_MASK(  { 32'hF0000000, 32'hF0000000, 32'hF0000000} )
) inter_i (
    .clk(clk),
    .resetn(resetn),
    .master_data_addr_i(   mem_addr),
    .master_data_wdata_i(  mem_wdata),
    .master_data_rdata_o(  mem_rdata),
    .master_data_req_i(    mem_valid),
    .master_data_we_i(     mem_write),
    .master_data_be_i(     mem_wstrb),
    .master_data_rvalid_o( master_data_rvalid),
    .master_data_gnt_o(    master_data_gnt),

    .slave_data_addr_o(   slave_data_addr  ),
    .slave_data_wdata_o(  slave_data_wdata ),
    .slave_data_rdata_i(  slave_data_rdata ),
    .slave_data_req_o(    slave_data_req   ),
    .slave_data_we_o(     slave_data_we    ),
    .slave_data_be_o(     slave_data_be    ),
    .slave_data_rvalid_i( {N_SLAVE{1'b1}}  ),
    .slave_data_gnt_i(    {N_SLAVE{1'b1}}  )
);

reg [31:0] memory [0:MEM_WORDS-1];
initial $readmemh(`FIRMWARE, memory);

reg [MEM_BITS-1:0]  bram_addr_reg;
reg [31        :0]  bram_din_reg;
reg [31        :0]  bram_dout_reg;
reg                 bram_rd_reg;
reg                 bram_we_reg;
reg [ 3        :0]  bram_be_reg;

always @(*) begin
    bram_addr_reg = slave_data_addr[ 0*32+2 +: MEM_BITS];
    bram_din_reg  = slave_data_wdata[0*32   +: 32];
    bram_rd_reg   = slave_data_req[  0] & (~slave_data_we[0]);
    bram_we_reg   = slave_data_req[  0] & ( slave_data_we[0]);
    bram_be_reg   = slave_data_be[   0*4    +:  4];
end

always@(posedge clk) begin
    if(bram_we_reg) begin
        if(bram_be_reg[0]) memory[bram_addr_reg][7 : 0] <= bram_din_reg[7 : 0];
        if(bram_be_reg[1]) memory[bram_addr_reg][15: 8] <= bram_din_reg[15: 8];
        if(bram_be_reg[2]) memory[bram_addr_reg][23:16] <= bram_din_reg[23:16];
        if(bram_be_reg[3]) memory[bram_addr_reg][31:24] <= bram_din_reg[31:24];
    end
end
always@(negedge clk) begin
    if (~resetn)            bram_dout_reg <= 32'd0;
    else if (bram_rd_reg)   bram_dout_reg <= memory[bram_addr_reg];
end
assign slave_data_rdata[0*32 +: 32] = bram_dout_reg;
//assign slave_data_rdata[0*32 +: 32] = memory[bram_addr_reg];


// -------------------------------
// Watch Dog Timer and reset control
wdt #(
    .NBIT(32)
) wdt0 (
    .clk_i ( clk  ),
    .rstn_i( rstn ),
    .rst_req_i( self_rst ),
    .addr_in  ( slave_data_addr [ 1 * 32 +: 4] ),
    .wd_din   ( slave_data_wdata[ 1 * 32 +:32] ),
    .wd_req   ( slave_data_req  [ 1          ] ),
    .wd_we    ( slave_data_we   [ 1          ] ),
    .rstn_o   ( resetn   ),
    .wd_to    ( wdt_to   )
);

// -------------------------------
// GPO
wire gpo_sel;
gpo # (
    .NBIT(5)
) gpo0 (
    .clk     ( clk    ),
    .resetn  ( resetn ),
    .addr_in ( slave_data_addr [ 1 * 32 +: 4] ),
    .gpo_din ( slave_data_wdata[ 1 * 32 +: 5] ),
    .gpo_req ( slave_data_req  [ 1          ] ),
    .gpo_we  ( slave_data_we   [ 1          ] ),
    .gpo_dout( {self_rst,leds}                )        
);
assign slave_data_rdata[1*32 +: 32] = 32'd0;


// -------------------------------
// UART Transmitter

uart #(
    .CLK_MHZ(CLK_MHZ)
) uart0 (
    .clk     (clk),
    .tx      (uart_tx),
    .sendData(slave_data_wdata[2*32 +:8] ),
    .sendReq (slave_data_req[2] & slave_data_we[2]),
    .ready   (tx_ready)
);
assign slave_data_rdata[2*32 +: 32] = {31'b0, tx_ready};

always @(posedge clk) begin
    dbg[2:0] <= mcompose_right_ready;
    dbg[6:3] <= mcompose[3:0];
    if (mcompose_exec)   instr_dbg <= mcompose_instr;
end

endmodule
