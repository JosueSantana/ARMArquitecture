module alu_test;

reg [31:0] regA, regB;
reg [3:0] A;
reg C_in;
wire [31:0] Y;
wire V, C, N, Z;
parameter sim_time = 160;

arm_alu myAL (Y, V, C, N, Z, regA, regB, A, C_in );

initial #sim_time $finish;

initial begin

	A = 4'b0000;
	C_in = 1;
	//regA = 32'b1010;
	regB = 32'b1001;
	repeat(100)
	begin
		#10 A = A + 4'b0001;

		#5 regA = 32'b1010;
		
	end
end

initial begin
	$display ("	regA   regB   A   C_in   Y   V   C   N   Z	");
	$monitor (" %b     %b     %b   %b   %b   %b   %b   %b   %b", regA, regB, A, C_in, Y, V, C, N, Z);

end

endmodule