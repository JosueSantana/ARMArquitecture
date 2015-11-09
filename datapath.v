module datapath(input [31:0] instruction, input Clr, Clk);

	//Wires
	wire wShEn, wRotEn, wRegEn, wRamEn, wInstEn, wMarEn, wMdrEn, wSel, wMdrSel, 
		 wV, wC, wN, wZ, wC_rot, wC_shift, wC_alu, wMFC, wRW;

	wire [1:0] wWordSel;
	wire [3:0] wOp, wRa, wRb, wRc;
	wire [31:0] wRotOut, wShiftOut, wAluOut, wMuxOut, wMdrMuxOut, wRegY0, wRegY1, wInst, wRamOut, wMar, wMdr;
	wire [11:0] wShifter_operand;

	assign wInst = instruction;

	//register32 stat_Reg; 

	//Modules
	instruction_decoder decoder (wShEn, wRotEn, wRegEn, wRamEn, wInstEn, wMarEn, wMdrEn, wMFC, wWordSel, wMdrSel, wSel, wOp, wRa, wRb, 
								 wRc, wShifter_operand, wInst);

	register_file		registers (wRegY0, wRegY1, wAluOut, wRa, wRb, wRc, wRegEn, Clk, Clr);

	rightRotator_32		rRotator (wRotOut, wC_rot, wShifter_operand, wRotEn, wC);
	
	shifter_32			shift (wShiftOut, wC_shift, wRegY1, wShifter_operand, wC, wShEn);

	mux_2x1				mux2_1 (wMuxOut, wSel, wRotOut, wShiftOut);

	mux_2x1				mdrMux (wMdrMuxOut, wMdrSel, wAluOut, wRamOut);

	arm_alu				alu (wAluOut, wV, wC_alu, wN, wZ, wRegY0, wMuxOut, wOp, wC );

	memory_unit			ram (wRamOut, wMFC, wRamEn, wRW, wMar, wMdr, wWordSel);

	register32 			instRegister (wInst, wRamOut, wInstEn, Clr, Clk);

	register32 			mdr (wMdr, wMdrMuxOut, wMdrEn, Clr, Clk);

	register32 			mar (wMar, wAluOut, wMarEn, Clr, Clk);

endmodule