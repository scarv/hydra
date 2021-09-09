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
	output reg [3:0] leds,
	output reg [6:0] dbg,
	output reg [31:0] instr_dbg,
    output uart_tx
);

	localparam N_CORES = 4;
	localparam N_CORES_BITS = (N_CORES == 4) ? 2 : 1;

	localparam M_EXTENSION = 1;

	// -------------------------------
	// Reset Generator

	reg [7:0] resetn_counter = 0;
	wire resetn = &resetn_counter;

	always @(posedge clk) begin
		if       (!rstn)  resetn_counter <= 0; 
		else if (!resetn) resetn_counter <= resetn_counter + 1;		
	end

	// -------------------------------
	// Memory/IO Interface

	localparam MEM_WORDS = 16384;
	localparam MEM_BITS = $clog2(MEM_WORDS);
	reg [31:0] memory [0:MEM_WORDS-1];
	initial $readmemh(`FIRMWARE, memory);

	wire [N_CORES - 1:0]    mem_la_read;
	wire [N_CORES - 1:0]    mem_la_write;
	wire [N_CORES - 1:0]    mem_la_access = mem_la_read | mem_la_write;
	wire [32*N_CORES - 1:0] mem_la_addr;
	wire [32*N_CORES - 1:0] mem_la_wdata;
	wire [4*N_CORES - 1:0]  mem_la_wstrb;

	reg [3:0]           mem_addr_high;
	reg [MEM_BITS-1:0]  mem_addr_low;
	reg [31:0]          mem_wdata;
	reg [ 3:0]          mem_wstrb;
	reg [N_CORES - 1:0] mem_read = 0;
	reg [N_CORES - 1:0] mem_write = 0;

	wire [N_CORES - 1:0] mem_access = mem_read | mem_write;

	reg [32*N_CORES - 1:0] mem_rdata;
	reg [N_CORES - 1:0]    mem_ready;

	reg [N_CORES_BITS-1:0] mem_arb_counter = 0;
	reg [N_CORES_BITS-1:0] mem_la_arb_counter = 1;

	wire [ 7:0] mcompose;
	wire        mcompose_mode;
	wire        mcompose_exec;
	wire [31:0] mcompose_instr;
	wire [31:0] mcompose_reg;
	wire [31:0] mcompose_redundant;
	wire [N_CORES*4 - 1 : 0] dummy;
	wire [N_CORES-1 : 0] mcompose_right_ready;
	wire [N_CORES-1 : 0] mcompose_left_ready;
	wire [N_CORES-2 : 0] fault_in;
	wire irq_in;
	assign irq_in = |fault_in && (mcompose > 0);
	assign mcompose_right_ready[N_CORES-1] = 1;

	localparam LEFT_CARRY_BITS = 5;
	localparam RIGHT_CARRY_BITS = 2;

	wire [N_CORES*LEFT_CARRY_BITS-1 : 0] mcompose_left_carry;
	wire [N_CORES*RIGHT_CARRY_BITS-1 : 0] mcompose_right_carry;

	// -------------------------------
	// PicoRV32 Cores

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
		.clk               (clk),
		.resetn            (resetn),
		.mem_la_read       (mem_la_read [0]),
		.mem_la_write      (mem_la_write[0]),
		.mem_ready         (mem_ready   [0]),
		.mem_la_addr       (mem_la_addr [31: 0]),
		.mem_la_wdata      (mem_la_wdata[31: 0]),
		.mem_la_wstrb      (mem_la_wstrb[ 3: 0]),
		.mem_rdata         (mem_rdata   [31: 0]),
		.irq               ({31'b0, irq_in}),
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
		.mcompose_reg_out        (mcompose_reg),
		.mcompose_redundant_out  (mcompose_redundant),
		.mcompose_exec_out       (mcompose_exec)
	);
	/* verilator lint_on PINMISSING */

	// // Secondary cores
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
				.clk      		   (clk),
				.resetn   		   (resetn),
				.mem_la_read	   (mem_la_read  [core_num]),
				.mem_la_write	   (mem_la_write [core_num]),
				.mem_ready		   (mem_ready    [core_num]),
				.mem_la_addr	   (mem_la_addr  [32*core_num + 31 -: 32]),
				.mem_la_wdata	   (mem_la_wdata [32*core_num + 31 -: 32]),
				.mem_la_wstrb      (mem_la_wstrb [4*core_num  + 3  -: 4]),
				.mem_rdata         (mem_rdata    [32*core_num + 31 -: 32]),
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
				.mcompose_reg_in         (mcompose_reg),
				.mcompose_redundant_in   (mcompose_redundant),
		   		.mcompose_exec_in        (mcompose_exec),
				.mcompose_fault          (fault_in[core_num - 1])
			);
			/* verilator lint_on PINMISSING */

		end
	endgenerate

	// -------------------------------
	// UART Transmitter

    reg [7:0] tx_data;
	reg       tx_send;

	wire      tx_ready;

	uart #(.CLK_MHZ(CLK_MHZ)) uart0 (
		.clk     (clk),
		.tx      (uart_tx),
		.sendData(tx_data),
		.sendReq (tx_send),
		.ready   (tx_ready)
	);

	always @(posedge clk) begin

		if (|mem_la_access) begin
			mem_read  <= mem_read | mem_la_read;
			mem_write <= mem_write | mem_la_write;
		end

		if (mem_access[mem_la_arb_counter] | mem_la_access[mem_la_arb_counter]) begin
			mem_addr_low <= mem_la_addr[32*mem_la_arb_counter + MEM_BITS+1 -: MEM_BITS];
			mem_addr_high <= mem_la_addr[32*mem_la_arb_counter + 31 -: 4];
			mem_wdata <= mem_la_wdata[32*mem_la_arb_counter + 31 -: 32];
			mem_wstrb <= mem_la_wstrb[4*mem_la_arb_counter + 3 -: 4];
		end

		mem_arb_counter <= mem_arb_counter + 1;
		mem_la_arb_counter <= mem_la_arb_counter + 1;

		mem_ready <= 0;
        tx_send   <= 0;

		dbg[2:0] <= mcompose_right_ready;
		dbg[6:3] <= mcompose[3:0];

		if (mcompose_exec)
			instr_dbg <= mcompose_instr;

		if (resetn && mem_access[mem_arb_counter] && !mem_ready[mem_arb_counter]) begin
			(* parallel_case *)
			case (1)
				mem_read[mem_arb_counter] && mem_addr_high == 4'h0: begin
					mem_rdata[32*mem_arb_counter + 31 -: 32] <= memory[mem_addr_low];
					mem_ready[mem_arb_counter] <= 1;
				end
				mem_write[mem_arb_counter] && mem_addr_high == 4'h0: begin
					if (mem_wstrb[0]) memory[mem_addr_low][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr_low][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr_low][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr_low][31:24] <= mem_wdata[31:24];
					mem_ready[mem_arb_counter] <= 1;
				end
				mem_write[mem_arb_counter] && mem_addr_high == 4'h1: begin
					if (mem_wstrb[0]) leds[0] <= mem_wdata[0];
					if (mem_wstrb[1]) leds[1] <= mem_wdata[8];
					if (mem_wstrb[2]) leds[2] <= mem_wdata[16];
					if (mem_wstrb[3]) leds[3] <= mem_wdata[24];
					mem_ready[mem_arb_counter] <= 1;
				end
                mem_read[mem_arb_counter] && mem_addr_high == 4'h2: begin
					mem_rdata[32*mem_arb_counter + 31 -: 32] <= {31'b0, tx_ready};
					mem_ready[mem_arb_counter] <= 1;
				end
                mem_write[mem_arb_counter] && mem_addr_high == 4'h2: begin
					tx_data   <= mem_wdata[7:0];
					tx_send   <= 1;
					mem_ready[mem_arb_counter] <= 1;
				end
			endcase
			mem_read[mem_arb_counter]  <= 0;
			mem_write[mem_arb_counter] <= 0;
		end
	end

endmodule
