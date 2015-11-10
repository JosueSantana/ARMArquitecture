module control_unit (output reg regFileClr, statRegClr, irClr, statRegEn, marEn, irEn, memEn, memRW, rotatorEn, shifterEn, 
	output reg [1:0] shiftSel, wordSel, output reg [3:0] ra, rb, rc, opcode, output reg [11:0] shifterOperand, input [31:0] status_reg, instruction, input clr, clk, mfc);
	
	reg [3:0] state, nextState;
	wire [3:0] cond;
	wire [2:0] instruction_format;

	assign cond = instruction[31:28];
	assign instruction_format = instruction[27:25];

	assign state <= nextState;


	always @(posedge clk, negedge clr)
		if (!clr) begin 
			state <=4'b0000;
			regFileClr <= 1;
			marEn <= 1;
			irEn <= 1;
			memEn <= 0;
			memRW <=0;
			statRegClr <=1;
			irClr <=1;
			statRegEn <=1;

			rotatorEn = 1;
			shifterEn = 1;
		end
		else state <= nextState;

	always @ (state, mfc) // Manages the order of the states
		case(state)
			4'b0000: nextState = 4'b0001;
			4'b0001: nextState = 4'b0010;
			4'b0010: nextState = 4'b0011;
			4'b0011: if(mfc) nextState = 4'b0100; else nextState = 4'b0011;
			4'b0100: 
				case(cond)
					4'b0000: begin
						if(status_reg[30]==1) nextState = 4'b0101;
						else nextState = 4'b0001;
					end
					4'b0001: begin
						if(status_reg[30]==0) nextState = 4'b0101;
						else nextState = 4'b0001;
					end
					4'b0010: begin
						if(status_reg[29]==1) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b0011: begin
						if(status_reg[29]==0) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b0100: begin
						if(status_reg[31]==1) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b0101: begin
						if(status_reg[31]==1) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b0110: begin
						if(status_reg[28]==1) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b0111: begin 
						if(status_reg[28]==0) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b1000: begin
						if((status_reg[29]==1) && (status_reg[30]==0)) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b1001: begin
						if((status_reg[29]==0) && (status_reg[30]==1)) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b1010: begin
						if(status_reg[31]==status_reg[28]) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b1011: begin
						if(status_reg[31]!=status_reg[28]) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b1100: begin 
						if((status_reg[30]=0) && (status_reg[31]==status_reg[28])) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b1101: begin
						if((status_reg[30]=1) && (status_reg[31]!=status_reg[28])) nextState = 4'h5;
						else nextState = 4'h1;
					end
					4'b1110: begin
						nextState = 4'h5;
					end
					default: nextState = 4'b0001;
				endcase
			4'b0101: 
				case (instruction_format)
					3'b000: nextState = 4'b0110;
					3'b001: nextState = 4'b0111;
				endcase
			4'b0110: // Handles data processing instructions with 000

			4'b0111: // Handles data processing instructions with 001
		endcase

	always @(state) // Manages the control signals active at each state
		case(state)
			4'h0: begin
				regFileClr <= 0; // clears registerfile
				statRegClr <= 0; // clear status register	
			end
			4'h1: begin
				// Disabling previous signals
				regFileClr <= 1;
				statRegClr <= 1;

				// Enabling Signals
				opcode <= 4'b1101;
				rb <= 4'hFF;
				shifterOperand <= 12'h000;
				shiftSel <= 0;

				marEn <= 0;
			end
			4'h2: begin
				//Disable previous signals
				marEn<=1;

				// Set new signals
				memEn <= 1;
				memRW <= 1; // Read 1, Write 0
				wordSel <= 10;
				irEn <= 0;

			end
			4'h3: begin

			end
			4'h4: begin

			end
			4'h5: begin

			end
			4'h6: begin 

			end
		endcase


endmodule