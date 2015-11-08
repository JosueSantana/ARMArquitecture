module shifter_test;

wire [31:0] Y;
wire carryOut;
reg [31:0] Rm;
reg [4:0] shift_imm;
reg [1:0] shift;
reg carryFlag;
reg enable;

parameter sim_time = 600;

shifter_32 shifter(Y,carryOut,Rm, shift_imm, shift, carryFlag, enable);

initial #sim_time $finish;

initial begin
	Rm = 10;
	carryFlag = 1'b1;
	enable = 1'b1;
	shift = 2'b00;
	shift_imm = 5'b00000;
	

	repeat (31) #8 begin
		repeat (4) #2 begin
			shift = shift + 2'b01;
			carryFlag = carryOut;
		end
		shift_imm = shift_imm + 5'b00001;
	end

	

end

initial begin
	$display(" enable carryFlag shift shift_imm  Rm                                Y                                 carryOut ");
	$monitor(" %b       %b         %b     %h       %b  %b  %b", enable, carryFlag, shift, shift_imm, Rm, Y, carryOut);
end

endmodule