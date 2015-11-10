module control_unit (output reg regClr, marEn, irEn, memEn, memRW, input [31:0] status_reg, instruction, input clr, clk, mfc);
	
	reg [3:0] state, nextState;
	wire [3:0] cond;

	assign cond = instruction[31:28];
	assign state <= nextState;

	always @(posedge clk, negedge clr)
		if (!clr) begin 
			state <=4'b0000;
			regClr <= 1;
			marEn <= 1;
			irEn <= 1;
			memEn <= 0;
			memRW <=0;
		end
		else state <= nextState;

	always @ (state, mfc)
		case(state)
			4'b0000: nextState = 4'b0001;
			4'b0001: nextState = 4'b0010;
			4'b0010: if(mfc) nextState = 4'b0011; else nextState = 4'b0010;
			4'b0011: 
				case(cond)
					4'b0000: begin
						if(status_reg[30]==1) nextState = 4'b0100;
						else nextState = 4'b0001;
					end
					4'b0001: begin
						if(status_reg[30]==0) nextState = 4'b0100;
						else nextState = 4'b0001;
					end
					4'b0010: begin
						if(status_reg[29]==1) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b0011: begin
						if(status_reg[29]==0) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b0100: begin
						if(status_reg[31]==1) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b0101: begin
						if(status_reg[31]==1) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b0110: begin
						if(status_reg[28]==1) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b0111: begin 
						if(status_reg[28]==0) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b1000: begin
						if((status_reg[29]==1) && (status_reg[30]==0)) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b1001: begin
						if((status_reg[29]==0) && (status_reg[30]==1)) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b1010: begin
						if(status_reg[31]==status_reg[28]) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b1011: begin
						if(status_reg[31]!=status_reg[28]) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b1100: begin 
						if((status_reg[30]=0) && (status_reg[31]==status_reg[28])) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b1101: begin
						if((status_reg[30]=1) && (status_reg[31]!=status_reg[28])) nextState = 4'h4;
						else nextState = 4'h1;
					end
					4'b1110: begin
						nextState = 4'h4;
					end
					default: nextState = 4'b0001;
				endcase
			4'b0100: 

		endcase



endmodule