module gpo #(
    parameter NBIT = 4
) (
    input wire             clk,
    input wire             resetn,
    input wire [NBIT-1: 0] din,
    input wire             din_val,
    output reg [NBIT-1: 0] dout
);

    always @ (posedge clk) begin
        if (!resetn)        dout <= {NBIT{1'b0}};
        else if (din_val)   dout <= din;
    end
endmodule
