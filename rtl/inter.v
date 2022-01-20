`timescale 1 ps / 1 ps

module inter #(
    parameter DATA_WIDTH = 32,
    parameter MASTER_ADDR_WIDTH = 12,
    parameter SLAVE_ADDR_WIDTH = 10,
    parameter MASTERS = 4,
    parameter SLAVES = 3,
    parameter [SLAVES * MASTER_ADDR_WIDTH - 1 :0] MASTER_ADDR_MATCH = {12'h800, 12'h400, 12'h000},
    parameter [SLAVES * MASTER_ADDR_WIDTH - 1 :0] MASTER_ADDR_MASK  = {12'hC00, 12'hC00, 12'hC00}
) (
    input clk,
    input resetn,
    input wire [(MASTERS * MASTER_ADDR_WIDTH) - 1:0] master_data_addr_i,
    input wire [(MASTERS * DATA_WIDTH)        - 1:0] master_data_wdata_i,
    input wire [(MASTERS * (DATA_WIDTH / 8))  - 1:0] master_data_be_i,
    input wire [ MASTERS                      - 1:0] master_data_req_i,
    input wire [ MASTERS                      - 1:0] master_data_we_i,
    output reg [(MASTERS * DATA_WIDTH)        - 1:0] master_data_rdata_o,
    output reg [ MASTERS                      - 1:0] master_data_rvalid_o,
    output reg [ MASTERS                      - 1:0] master_data_gnt_o,

    output reg [(SLAVES * SLAVE_ADDR_WIDTH)   - 1:0] slave_data_addr_o,
    output reg [(SLAVES * DATA_WIDTH)         - 1:0] slave_data_wdata_o,
    output reg [(SLAVES * (DATA_WIDTH / 8))   - 1:0] slave_data_be_o,
    output reg [ SLAVES                       - 1:0] slave_data_req_o,
    output reg [ SLAVES                       - 1:0] slave_data_we_o,
    input wire [(SLAVES * DATA_WIDTH)         - 1:0] slave_data_rdata_i,
    input wire [ SLAVES                       - 1:0] slave_data_rvalid_i,
    input wire [ SLAVES                       - 1:0] slave_data_gnt_i
);

wire reset = ~resetn;

reg arb_to_master_grant [MASTERS - 1:0];

reg  [(SLAVES * MASTERS) - 1:0] arbiter_request;
wire [(SLAVES * MASTERS) - 1:0] arbiter_grant;
genvar i;
generate
    for (i = 0; i < SLAVES; i = i + 1) begin : gen_arbiter_request
        integer j;
        always @(*) begin
            for (j = 0; j < MASTERS; j = j + 1) begin
                arbiter_request[(i * MASTERS) + j] = (  ( master_data_addr_i[ j * MASTER_ADDR_WIDTH +: MASTER_ADDR_WIDTH ]
                                                        &   MASTER_ADDR_MASK[ i * MASTER_ADDR_WIDTH +: MASTER_ADDR_WIDTH ])
                                                        == MASTER_ADDR_MATCH[ i * MASTER_ADDR_WIDTH +: MASTER_ADDR_WIDTH ] )
                                                        ?  master_data_req_i[ j ] : 0;
            end
        end
    end

    for (i = 0; i < MASTERS; i = i + 1) begin : gen_master_grant
        reg local_arb_grant;
        integer j;
        always @(*)begin
            local_arb_grant = 1'b0;
            for (j = 0; j < SLAVES; j = j + 1)  local_arb_grant = local_arb_grant | arbiter_grant[(j * MASTERS) + i];
            arb_to_master_grant[i] = local_arb_grant;
        end
    end
endgenerate

generate
    for (i = 0; i < SLAVES; i = i + 1) begin : generate_arbiters
        arbiter #(.NUM_PORTS(MASTERS)) i_arb(
        .clk(clk),
        .rst(reset),
        .request(arbiter_request[(i * MASTERS) + (MASTERS - 1)-:MASTERS]),
        .grant(  arbiter_grant[  (i * MASTERS) + (MASTERS - 1)-:MASTERS])
        );
    end
endgenerate

genvar a,t;
generate
    for ( a = 0; a < SLAVES; a = a + 1) begin : slave_out1
        integer t;
        always @(*) begin

            slave_data_addr_o[ a * SLAVE_ADDR_WIDTH+:SLAVE_ADDR_WIDTH] = 0;
            slave_data_wdata_o[a * DATA_WIDTH      +:DATA_WIDTH      ] = 0;
            slave_data_be_o[   a * (DATA_WIDTH / 8)+:DATA_WIDTH / 8  ] = 0;
            slave_data_we_o[   a                                     ] = 0;
            slave_data_req_o[  a                                     ] = 0;

           for (  t = 0; t < MASTERS; t = t + 1) begin : slave_out2
               if (arbiter_grant[ (   a * MASTERS) + t] == 1'b1) begin : slave_out
                   slave_data_addr_o[ a * SLAVE_ADDR_WIDTH+:SLAVE_ADDR_WIDTH] = master_data_addr_i[t * MASTER_ADDR_WIDTH+:SLAVE_ADDR_WIDTH];
                   slave_data_wdata_o[a *  DATA_WIDTH     +:DATA_WIDTH      ] = master_data_wdata_i[t * DATA_WIDTH+:DATA_WIDTH];
                   slave_data_be_o[   a * (DATA_WIDTH / 8)+:DATA_WIDTH / 8  ] = master_data_be_i[t * (DATA_WIDTH / 8)+:DATA_WIDTH / 8];
                   //need to fix
                   slave_data_we_o[   a                                     ] = master_data_we_i[t];
                   slave_data_req_o[  a                                     ] = master_data_req_i[t];
               end
            end
        end
    end
endgenerate

wire [SLAVES - 1:0]  slave_data_rvalid;
generate
    for (i = 0; i < MASTERS; i = i + 1) begin :m_data1
        integer k;
        always @(*) begin
//            master_data_rdata_o[i * DATA_WIDTH+:DATA_WIDTH] = 0;
            master_data_rvalid_o[i] = 0;
            master_data_gnt_o[i] = 0;
            for (k = 0; k < SLAVES; k = k + 1) begin
                if (arbiter_grant[(k * MASTERS) + i] == 1'b1) begin
                    master_data_rdata_o[i * DATA_WIDTH+:DATA_WIDTH] = slave_data_rdata_i[k * DATA_WIDTH+:DATA_WIDTH];
                    master_data_rvalid_o[i] = slave_data_rvalid[k];
                    master_data_gnt_o[i] = slave_data_gnt_i[k] & master_data_req_i[i] ;
                end
            end
        end
    end
endgenerate

reg  [SLAVES - 1:0]  slave_data_rvalid_write;
reg  [SLAVES - 1:0]  slave_data_rvalid_read;
assign slave_data_rvalid = slave_data_rvalid_write | slave_data_rvalid_read;

//for slaver interfaces rvalid should be high following gnt(1) + we_o(0)
generate
    for (i = 0; i < SLAVES; i = i + 1) begin : gen_slave_data_xvalid
        always @(*) begin
            slave_data_rvalid_read[ i] = slave_data_rvalid_i[i] && slave_data_req_o[   i] && ~slave_data_we_o[    i] ;
            slave_data_rvalid_write[i] = slave_data_rvalid_i[i] && slave_data_req_o[   i] &&  slave_data_we_o[    i] ;
        end
    end
endgenerate

endmodule


module arbiter # (
    parameter NUM_PORTS=5
)(
    input wire                   clk,
    input wire                   rst,
    input wire [NUM_PORTS - 1:0] request,
    output reg [NUM_PORTS - 1:0] grant
);
localparam WRAP_LENGTH = 2 * NUM_PORTS;

wire next;
wire [NUM_PORTS   - 1:0] order;
reg  [NUM_PORTS   - 1:0] token;
wire [NUM_PORTS   - 1:0] token_lookahead [NUM_PORTS - 1:0];
wire [WRAP_LENGTH - 1:0] token_wrap;
assign token_wrap = {token, token};
assign next = ~|(token & request);

genvar i;
generate
    for (i = 0; i < NUM_PORTS; i = i + 1) begin : ORDER_
        assign token_lookahead[i] = token_wrap[i +:NUM_PORTS];
        assign order[          i] = |(token_lookahead[i] & request);
    end
endgenerate

integer j;
always @(posedge clk)
    if (rst)                token <= 'b1;
    else if (next) begin
        for (j = 0; j < NUM_PORTS; j = j + 1)
            if (order[j])  token <= token_lookahead[j];
    end

always @(posedge clk) grant <= token & request;

endmodule
