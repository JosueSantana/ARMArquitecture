module instruction_decoder(output reg shifter_en, output reg rotator_en, output reg registerFile_en, output reg ram_en, 
	output reg instRegister_en, output reg mar_en, output reg mdr_en, output reg mfc, output reg [1:0] wordSel, 
	output reg mdrSel, output reg sel, output reg [3:0] opcode, ra, rb, rc, output reg [11:0] shifter_operand, 
	input [31:0] instruction);

	wire [3:0] wopcode,wrc,wra,wrb;
	wire[11:0] wshifter_operand;
	wire wregisterFile_en;

	wire [2:0] instructionFormat;

	assign wrc = instruction[15:12];
	assign wra = instruction[19:16];
	assign wrb = instruction[3:0];
	assign wopcode = instruction[24:21];
	
	
	assign wshifter_operand = instruction[11:0];


	assign instructionFormat = instruction[27:25];

	always @(instruction)
		case(instructionFormat)
			3'b000: begin
				rc = wrc;
				ra = wra;
				rb = wrb;
				
				shifter_operand = wshifter_operand;

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
		
				shifter_operand = wshifter_operand;

				rotator_en = 1;
				shifter_en = 0;
				
				sel = 0;
				opcode = wopcode;
				
				registerFile_en = 1; //register files is enabled on 0;
			end
		endcase
endmodule