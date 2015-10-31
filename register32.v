module register32(output reg [31:0] Q, input [31:0] D, input LE, Clr, Clk);
	always @(posedge Clk, negedge Clr)
		if(!Clr) Q <= 32'h00000000;
		else if(!LE) Q <= D;
endmodule
