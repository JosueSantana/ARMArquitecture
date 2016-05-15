module shifter_32(output reg [31:0] Y, output reg carry, input [31:0] Rm, input [11:0] shifter_operand, input carryFlag, enable);
	
	wire [4:0] shift_imm;
	wire [1:0] shift;

	assign shift_imm = shifter_operand[11:7];
	assign shift = shifter_operand[6:5];

	//right rotate extend
	wire [31:0] rrx_y;
	assign rrx_y = Rm >> 1;
	
	//right rotate
	wire [63:0] doubleRm;
	wire [31:0] array [0:31];
	assign doubleRm = {Rm,Rm};
	genvar i;
	for(i=0;i<32;i=i+1) begin 
		assign array[i] = doubleRm[31+i:i];
	end


	always @ (enable, shift_imm, shift, Rm, carryFlag)
		if(enable) begin
			if(shift_imm == 5'b00000) begin
				case(shift) 
					2'b00: begin
						Y = Rm;
						carry = carryFlag;
					end
					2'b01: begin
						Y = 32'b0;
						carry = Rm[31];
					end
					2'b10: begin
						if (Rm[31]==0) begin
							Y = 32'b0;
							carry = Rm[31];
						end
						else begin
							Y = 32'hFFFFFFFF;
							carry = Rm[31];
						end
					end
					2'b11: begin
						Y = {carryFlag,rrx_y[30:0]};
						carry = Rm[0];
					end
				endcase
			end

			else begin
				case (shift)
					2'b00: begin
						Y = Rm << shift_imm;
						carry = Rm[32-shift_imm];
					end
					2'b01: begin
						Y = Rm >> shift_imm;
						carry = Rm[shift_imm - 1];
					end
					2'b10: begin
						Y = $signed(Rm) >>> shift_imm;
						carry = Rm[shift_imm - 1];
					end
					2'b11: begin
						Y = array[shift_imm];
						carry = Rm[shift_imm - 1];
					end
				endcase
			end
		end
		
		else begin
			Y = 32'bz;
			carry = 1'bz;
		end
endmodule
