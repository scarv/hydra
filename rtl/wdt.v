module wdt #(
    parameter NBIT = 32
) (
    input  wire             clk_i,
    input  wire             rstn_i,
    input  wire             rst_req_i,
    output wire             rstn_o,
    input  wire [     3: 0] addr_in,
    input  wire [NBIT-1: 0] wd_din,
    input  wire             wd_req,
    input  wire             wd_we,
    output reg              wd_to
);

wire din_val = wd_req & wd_we & (addr_in == 4'b0100);

reg [7:0] resetn_counter = 0;
wire      resetn         = (& resetn_counter) && (~rst_req_i);

always @(posedge clk_i) begin
    if      (!rstn_i) resetn_counter <= 0;
    else if (!resetn) resetn_counter <= resetn_counter + 1;
end

//wire      resetn         = rstn_i && (~rst_req_i);
assign rstn_o = resetn;

reg [NBIT-1: 0] cnt;
always @ (posedge clk_i) begin
    if (!resetn)        cnt <= {NBIT{1'b0}};
    else if (din_val)   cnt <= wd_din;
    else if (cnt != 0)  cnt <= cnt - 1'b1;
end

always @ (posedge clk_i) begin
    if (!resetn)        wd_to <= 1'b0;
    else if (cnt == 1)  wd_to <= 1'b1;
    else if (din_val)   wd_to <= 1'b0;
end
endmodule
