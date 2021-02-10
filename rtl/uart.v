module uart #(parameter CLK_MHZ = 12) (
    input clk,
    input [7:0] sendData,
    input sendReq,
    output tx,
    output reg ready
);

    localparam TICKS_PER_CYCLE = (1000000 * CLK_MHZ) / 9600;
    reg [13:0] serialClock = 0;
	always @ (posedge clk) begin
		if (serialClock != 0)
			serialClock <= serialClock - 1;
		else
			serialClock <= TICKS_PER_CYCLE;
    end

	reg [4:0] sendBitCount = 0;
	reg [9:0] sendBits;
	reg sending = 0;

	reg txReg = 1;
    assign tx = txReg;

	always @ (posedge clk) begin
        ready <= 1;
	    if (sendReq) begin
            ready <= 0;
            if (!sending) begin
            	sendBits <= {1'b1, sendData, 1'b0};
                sendBitCount <= 10;
                sending <= 1;
            end
        end
        if (sending) begin
            ready <= 0;
            if (serialClock == 0) begin
                if (sendBitCount > 0) begin
                    sendBitCount <= sendBitCount - 1;
                    txReg <= sendBits[0];
                    sendBits <= sendBits >> 1;
                end else begin
                    txReg <= 1;
                    sending <= 0;
                end
            end
        end
    end

endmodule
