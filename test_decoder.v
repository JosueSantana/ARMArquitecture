module test_decoder;
	wire [15:0] Y;
	reg [3:0] I;

	parameter sim_time = 200;

	decoder_4x16 decoder (Y,I);

	initial #sim_time $finish;

	initial begin
		I = 4'b0000;
		repeat (15) #10 I = I + 4'b0001;
	end

	initial begin
		$display(" I Y0 Y1 Y2 Y3 Y4 Y5 Y6 Y7 Y8 Y9 Y10 Y11 Y12 Y13 Y14 Y15");
		$monitor(" %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b %b", I, Y[0],Y[1],Y[2],Y[3],Y[4],Y[5],Y[6],Y[7],Y[8],Y[9],Y[10],Y[11],Y[12],Y[13],Y[14],Y[15]);
	end
endmodule