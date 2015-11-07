module decoder_4x16(output reg [15:0] Y, input [3:0] I);
	always @(I)
		case (I)
			4'h0: Y=16'h0001;
			4'h1: Y=16'h0002;
			4'h2: Y=16'h0004;
			4'h3: Y=16'h0008;
			4'h4: Y=16'h0010;
			4'h5: Y=16'h0020;
			4'h6: Y=16'h0040;
			4'h7: Y=16'h0080;
			4'h8: Y=16'h0100;
			4'h9: Y=16'h0200;
			4'hA: Y=16'h0400;
			4'hB: Y=16'h0800;
			4'hC: Y=16'h1000;
			4'hD: Y=16'h2000;
			4'hE: Y=16'h4000;
			4'hF: Y=16'h8000;
		endcase
endmodule