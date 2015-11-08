module instruction_decoder(output reg shifter_en, output reg rotator_en, output reg registerFile_en, output reg sel, output reg [3:0] opcode, ra, rb, rc, rotate_imm, output reg [7:0] immediate, output reg [1:0] shift, output reg [4:0] shift_imm, input [31:0] instruction);

	wire [3:0] wopcode,wrc,wra,wrb,wrotate_imm;
	wire[7:0] wimmediate;
	wire[1:0] wshift;
	wire [4:0] wshift_imm;
	wire wregisterFile_en;

	wire [2:0] instructionFormat;

	assign wrc = instruction[15:12];
	assign wra = instruction[19:16];
	assign wrb = instruction[3:0];
	assign wopcode = instruction[24:21];
	
	
	assign wrotate_imm = instruction[11:8];
	assign wimmediate = instruction[7:0];

	assign wshift = instruction[6:5];
	assign wshift_imm = instruction[11:7];


	assign instructionFormat = instruction[27:25];

	always @(instruction)
		case(instructionFormat)
			3'b000: begin
				rc = wrc;
				ra = wra;
				rb = wrb;
				
				rotate_imm = wrotate_imm;
				immediate = wimmediate;

				shift = wshift;
				shift_imm = wshift_imm;
				
				rotator_en = 0;
				shifter_en = 1;

				sel = 1;
				opcode = wopcode;

				registerFile_en = 1; //register files is enabled on 1;
			end
			3'b001: begin
				rc = wrc;
				ra = wra;
				rb = wrb;
		
				rotate_imm = wrotate_imm;
				immediate = wimmediate;

				shift = wshift;
				shift_imm = wshift_imm;

				rotator_en = 1;
				shifter_en = 0;
				
				sel = 0;
				opcode = wopcode;
				
				registerFile_en = 1; //register files is enabled on 0;
			end
		endcase
endmodule