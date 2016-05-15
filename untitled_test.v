module rightRotator_test;

wire [31:0] Y;
wire Carry;
reg EN, CarryFlag;
reg [7:0] immediate;
reg [3:0] rotate_imm;
reg [7:0] i;

parameter sim_time = 300;

rightRotator_32 rotator(Y,Carry,immediate,rotate_imm,EN,CarryFlag);

initial #sim_time $finish;


initial begin
	CarryFlag = 1;
	EN=1;
	immediate = 8'h0a;
	rotate_imm=4'h0;
	
	/* testing the array 
	i = 0;
	repeat(64) begin
		$display("%h  %b", i, rotator.array[i]);
		#1 i = i + 8'b01;
	end
	*/

	repeat(20)begin
		//$display("select %b",  rotator.select);
		#5 rotate_imm=rotate_imm +4'h1;
	end
end

initial fork
	#90 EN = 0; #125 EN=1;
join

initial begin
	$display(" EN CarryFlag rotate_imm  immediate        Y                                                               Carry");
	$monitor(" %b  %b         %b         %b        %b                                 %b", EN, CarryFlag, rotate_imm, immediate, Y, Carry);
end


endmodule