`include "picorv32.v"
`include "uart.v"

module soc #(
    parameter CLK_MHZ = 12
) (
	input clk,
	output reg [3:0] leds,
	output reg [2:0] dbg,
    output uart_tx
);

	localparam N_CORES = 4;
	localparam N_CORES_BITS = (N_CORES == 4) ? 2 : 1;

	// -------------------------------
	// Reset Generator

	reg [7:0] resetn_counter = 0;
	wire resetn = &resetn_counter;

	always @(posedge clk) begin
		if (!resetn)
			resetn_counter <= resetn_counter + 1;
	end

	// -------------------------------
	// Memory/IO Interface

	localparam MEM_WORDS = 2048;
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

	wire [3:0] mcompose;
	wire [N_CORES*4 - 1 : 0] dummy;
	wire [N_CORES-2 : 0] mcompose_ready;

	// -------------------------------
	// PicoRV32 Cores

	// Primary core
	/* verilator lint_off PINMISSING */
	picorv32 #(
		.ENABLE_COUNTERS(1),
		.ENABLE_COUNTERS64(0),
		.ENABLE_MHARTID(1),
		.ENABLE_MCOMPOSE(1),
		.LATCHED_MEM_RDATA(1),
		.TWO_STAGE_SHIFT(0),
		.TWO_CYCLE_ALU(0),
		.CATCH_MISALIGN(1),
		.CATCH_ILLINSN(1),
		.HART_ID(0)
	) primary_cpu (
		.clk              (clk),
		.resetn           (resetn),
		.mem_la_read      (mem_la_read [0]),
		.mem_la_write     (mem_la_write[0]),
		.mem_ready        (mem_ready   [0]),
		.mem_la_addr      (mem_la_addr [31: 0]),
		.mem_la_wdata     (mem_la_wdata[31: 0]),
		.mem_la_wstrb     (mem_la_wstrb[ 3: 0]),
		.mem_rdata        (mem_rdata   [31: 0]),
		.mcompose_out     (mcompose),
		.mcompose_ready_in(mcompose_ready[0])
	);
	/* verilator lint_on PINMISSING */

	// // Secondary cores
	genvar core_num;
	generate
		for (core_num = 1; core_num < N_CORES; core_num = core_num + 1) begin
			
			/* verilator lint_off PINMISSING */
			picorv32 #(
				.ENABLE_COUNTERS(0),
				.ENABLE_COUNTERS64(0),
				.ENABLE_MHARTID(1),
				.ENABLE_MCOMPOSE(1),
				.LATCHED_MEM_RDATA(1),
				.TWO_STAGE_SHIFT(0),
				.TWO_CYCLE_ALU(0),
				.CATCH_MISALIGN(1),
				.CATCH_ILLINSN(1),
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
				.mcompose_in       (mcompose),
				.mcompose_ready_in ((core_num == N_CORES - 1) ? 1'b1 : mcompose_ready[core_num]),
				.mcompose_ready_out(mcompose_ready[core_num - 1])
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

		dbg <= mcompose_ready;

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
