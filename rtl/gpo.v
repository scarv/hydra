module gpo #(
    parameter NBIT = 4
) (
    input wire             clk,
    input wire             resetn,
    input wire [3     : 0] addr_in,
    input wire [NBIT-1: 0] gpo_din,
    input wire             gpo_req,
    input wire             gpo_we,
    output reg [NBIT-1: 0] gpo_dout
);

wire din_val = gpo_req & gpo_we & (addr_in == 4'b0000);

always @ (posedge clk or negedge resetn) begin
    if (!resetn)        gpo_dout <= {NBIT{1'b0}};
    else if (din_val)   gpo_dout <= gpo_din;
end
endmodule
