module datapath(input [31:0] instruction, input Clr, Clk);

	//Wires
	wire wShEn, wRotEn, wRegEn, wSel, wV, wC, wN, wZ, wC_rot, wC_shift, wC_alu;
	wire [1:0] wShift;
	wire [3:0] wOp, wRa, wRb, wRc, wRotIm;
	wire [4:0] wShIm;
	wire [7:0] wImm;
	wire [31:0] wRotOut, wShiftOut, wAluOut, wMuxOut, wRegY0, wRegY1, wInst;

	assign wInst = instruction;

	//register32 stat_Reg; 

	//Modules
	instruction_decoder decoder (wShEn, wRotEn, wRegEn, wSel, wOp, wRa, wRb, wRc, wRotIm, 
								 wImm, wShift, wShIm, wInst);

	register_file		registers (wRegY0, wRegY1, wAluOut, wRa, wRb, wRc, wRegEn, Clk, Clr);

	rightRotator_32		rRotator (wRotOut, wC_rot, wImm, wRotIm, wRotEn, wC);

	shifter_32			shift (wShiftOut, wC_shift, wRegY1, wShIm, wShift, wC, wShEn);

	mux_2x1				mux2_1 (wMuxOut, wSel, wRotOut, wShiftOut);

	arm_alu				alu (wAluOut, wV, wC_alu, wN, wZ, wRegY0, wMuxOut, wOp, wC );

endmodule