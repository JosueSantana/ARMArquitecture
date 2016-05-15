module rightRotator_32(output reg [31:0] Y, output reg carry, input [11:0] shifter_operand, input enable, carryFlag);

wire [4:0] select, select2;
wire [31:0] extended_immediate;
wire [31:0] array;
wire [63:0] immediate_double;
wire [7:0] immediate;
wire [3:0] rotate_imm;

assign immediate = shifter_operand[7:0];
assign rotate_imm = shifter_operand[11:8];

assign select = rotate_imm + rotate_imm;
assign select2 = select + 32;
assign extended_immediate = {24'h000000,immediate};
assign immediate_double = {extended_immediate,extended_immediate};

assign array = immediate_double[select +: 32];

always @(enable, immediate, rotate_imm, carryFlag)

	if(enable) begin
			if (rotate_imm == 0) begin
				carry = carryFlag;
				Y = immediate;
			end
			else begin
				//$display("select : %d", select);
				//$display("immediate_double: %b\n", immediate_double);
				$display("Array select: %h\n", array);
				Y = array;
				carry = Y[31];
			end
	end
	else begin
		Y = 32'bz;
		carry = 1'bz;
	end

endmodule
