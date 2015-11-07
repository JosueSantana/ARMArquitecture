module register_file(output [31:0] Y0, Y1, input [31:0] I, input [3:0] Ra, Rb, Rc, input LE, clk, clr); // LE has to be 0 to activate, clk and clr have to be 1

	// wires for the outpu of the registers
	wire [31:0] w0, w1, w2, w3, w4, w5, w6, w7, w8 ,w9, w10, w11, w12, w13, w14, w15;

	// wire for the output of the decoder
	wire [15:0] wD;

	// wires for the And that goes into the clock
	wire wandClk0, wandClk1, wandClk2, wandClk3, wandClk4, wandClk5, wandClk6, wandClk7, wandClk8, wandClk9, wandClk10, wandClk11, wandClk12, wandClk13, wandClk14, wandClk15;

	// wires for the nand that go into the clear
	wire wnandClr0, wnandClr1, wnandClr2, wnandClr3, wnandClr4, wnandClr5, wnandClr6, wnandClr7, wnandClr8, wnandClr9, wnandClr10, wnandClr11, wnandClr12, wnandClr13, wnandClr14, wnandClr15;

	decoder_4x16 decoder(wD, Rc);

	and andClk0(wandClk0, wD[0], clk);
	and andClk1(wandClk1, wD[1], clk);
	and andClk2(wandClk2, wD[2], clk);
	and andClk3(wandClk3, wD[3], clk);
	and andClk4(wandClk4, wD[4], clk);
	and andClk5(wandClk5, wD[5], clk);
	and andClk6(wandClk6, wD[6], clk);
	and andClk7(wandClk7, wD[7], clk);
	and andClk8(wandClk8, wD[8], clk);
	and andClk9(wandClk9, wD[9], clk);
	and andClk10(wandClk10, wD[10], clk);
	and andClk11(wandClk11, wD[11], clk);
	and andClk12(wandClk12, wD[12], clk);
	and andClk13(wandClk13, wD[13], clk);
	and andClk14(wandClk14, wD[14], clk);
	and andClk15(wandClk15, wD[15], clk);

	nand nandClr0(wnandClr0, wD[0], clr);
	nand nandClr1(wnandClr1, wD[1], clr);
	nand nandClr2(wnandClr2, wD[2], clr);
	nand nandClr3(wnandClr3, wD[3], clr);
	nand nandClr4(wnandClr4, wD[4], clr);
	nand nandClr5(wnandClr5, wD[5], clr);
	nand nandClr6(wnandClr6, wD[6], clr);
	nand nandClr7(wnandClr7, wD[7], clr);
	nand nandClr8(wnandClr8, wD[8], clr);
	nand nandClr9(wnandClr9, wD[9], clr);
	nand nandClr10(wnandClr10, wD[10], clr);
	nand nandClr11(wnandClr11, wD[11], clr);
	nand nandClr12(wnandClr12, wD[12], clr);
	nand nandClr13(wnandClr13, wD[13], clr);
	nand nandClr14(wnandClr14, wD[14], clr);
	nand nandClr15(wnandClr15, wD[15], clr);

	register32 R0(w0, I, LE, wnandClr0, wandClk0);
	register32 R1(w1, I, LE, wnandClr1, wandClk1);
	register32 R2(w2, I, LE, wnandClr2, wandClk2);
	register32 R3(w3, I, LE, wnandClr3, wandClk3);
	register32 R4(w4, I, LE, wnandClr4, wandClk4);
	register32 R5(w5, I, LE, wnandClr5, wandClk5);
	register32 R6(w6, I, LE, wnandClr6, wandClk6);
	register32 R7(w7, I, LE, wnandClr7, wandClk7);
	register32 R8(w8, I, LE, wnandClr8, wandClk8);
	register32 R9(w9, I, LE, wnandClr9, wandClk9);
	register32 R10(w10, I, LE, wnandClr10, wandClk10);
	register32 R11(w11, I, LE, wnandClr11, wandClk11);
	register32 R12(w12, I, LE, wnandClr12, wandClk12);
	register32 R13(w13, I, LE, wnandClr13, wandClk13);
	register32 R14(w14, I, LE, wnandClr14, wandClk14);
	register32 R15(w15, I, LE, wnandClr15, wandClk15);

	mux_16x1 mux_A( Y0, Ra, w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15);

	mux_16x1 mux_B( Y1, Rb, w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15);

endmodule



