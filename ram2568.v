module ram256x8 (output reg [7:0] DataOut, input
	Enable, ReadWrite, input [7:0] Address, input [7:0]
	DataIn);
	reg [7:0] Mem[0:255]; //256 localizaciones de 8 bits
	always @ (Enable, ReadWrite)
		if (Enable)
			if (ReadWrite) DataOut = Mem[Address];
			else Mem[Address] = DataIn;
		else DataOut = 8'bz;
	endmodule