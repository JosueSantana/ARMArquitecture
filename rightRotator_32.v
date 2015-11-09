module rightRotator_32(output reg [31:0] Y, output reg carry, input [11:0] shifter_operand, input enable, carryFlag);

wire [4:0] select;
wire [31:0] extended_immediate;
wire [63:0] immediate_double;
wire [31:0] array [0:31];
wire [7:0] immediate;
wire [3:0] rotate_imm;

assign immediate = shifter_operand[7:0];
assign rotate_imm = shifter_operand[11:8];

assign select = rotate_imm + rotate_imm;
assign extended_immediate = {24'h000000,immediate};
assign immediate_double = {extended_immediate,extended_immediate};

genvar i;

for(i=0;i<32;i=i+1) begin 
	assign array[i] = immediate_double[31+i:i];
end

always @(enable, immediate, rotate_imm, carryFlag)
	if(enable) begin
			if (rotate_imm == 0) begin
				carry = carryFlag;
				Y = immediate;
			end
			else begin
				Y = array[select];
				carry = Y[31];
			end
	end
	else begin
		Y = 32'bz;
		carry = 1'bz;
	end

endmodule
