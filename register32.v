module register32 (output reg [31:0] Out, input [31:0] In, input enable, Clr, Clk);
always @ (posedge Clk, negedge Clr)
	if (!Clr) Out <= 32'h00000000;
	else if (!enable) Out <= In;
endmodule
