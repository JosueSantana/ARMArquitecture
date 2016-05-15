module datapath(input Clr, Clk);

	//Wires
	wire wShEn, wRotEn, wRegEn, wRamEn, wInstEn, wMarEn, wMdrEn, wMdrMuxSel,  
		 wV, wC, wN, wZ, wC_rot, wC_shift, wC_alu, wMFC, wRW;

	wire [1:0] wWordSel, wAluMuxSel;
	wire [3:0] wRa, wRb, wRc;
	wire [4:0] wOp;
	wire [31:0] wRotOut, wShiftOut, wAluOut, wAluMuxOut, wMdrMuxOut, wUOut, wRegY0, wRegY1, wInst, wRamOut, wMar, wMdr , wStatReg;
	wire [11:0] wShifter_operand;

	assign wInst = instruction;

	//register32 stat_Reg; 

	//Modules
/*	instruction_decoder decoder (wShEn, wRotEn, wRegEn, wRamEn, wInstEn, wMarEn, wMdrEn, wMFC, wWordSel, wMdrSel, wSel, wOp, wRa, wRb, 
								 wRc, wShifter_operand, wInst);*/
	control_unit		cu (wRegEn, wStatRegEn, wMarEn, wMdrEn, wInstEn, wRamEn, wRW, wRotEn, wShEn, wMdrMuxSel, wAluMuxSel, wWordSel, wRa, wRb, wRc, wOp, wShifter_operand, wStatReg, wMdr, Clr, Clk, wMFC);

	register_file		registers (wRegY0, wRegY1, wAluOut, wRa, wRb, wRc, wRegEn, Clk, Clr);

	rightRotator_32		rRotator (wRotOut, wC_rot, wShifter_operand, wRotEn, wC);
	
	shifter_32			shift (wShiftOut, wC_shift, wRegY1, wShifter_operand, wC, wShEn);

	mux_4x1				aluMux (wAluMuxOut, wAluMuxSel, wRotOut, wShiftOut, wMdr, {20'h0, wShifter_operand});

	mux_2x1				mdrMux (wMdrMuxOut, wMdrMuxSel, wAluOut, wRamOut);

	arm_alu				alu (wAluOut, wV, wC_alu, wN, wZ, wRegY0, wAluMuxOut, wOp, wC );

	memory_unit			ram (wRamOut, wMFC, wRamEn, wRW, wMar, wMdr, wWordSel);

	register32 			instRegister (wInst, wMdr, wInstEn, Clr, Clk);

	register32 			mdr (wMdr, wMdrMuxOut, wMdrEn, Clr, Clk);

	register32 			mar (wMar, wAluOut, wMarEn, Clr, Clk);

	register32			stat_Reg (wStatReg, 32'h0, wStatRegEn, Clr, Clk);

endmodule