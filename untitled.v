module shifter_32(output reg [31:0] Y, output reg carryOut, input [23:0] shifter_operand, input carryFlag, enable);
	reg[31:0] extender;

	shifter_operand = shifter_operand << 2;

	always @ (enable, carryFlag)
	begin
		if(carryFlag == 1'b1)
		begin
			extender = 32'b1;
			Y = extender & shifter_operand;
		end	
		else begin
			extender = 32'b0;
			Y = extender | shifter_operand;
		end
	end
endmodule
