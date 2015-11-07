module test_mux_2x1;
	wire [31:0] Y;
	reg S;
	reg [31:0] I0, I1;

	parameter sim_time = 100;

	mux_2x1 mux1(Y,S,I0,I1);

	initial #sim_time $finish;

	initial begin
		S = 1'b0;
		I0 = 32'b00000000000000000000000000000000;
		I1 = 32'b00000000000000000000000000000010;
		#10 S = 1'b1;
		#10 I0 = I0 + 32'b00000000000000000000000000000100;
		#10 I1 = I1 + 32'b10000000000000000000000000000000;
		#10 S = 1'b0;
		#10 S = 1'b1;
	end
	initial begin
		$display(" S I1 I0 Y");
		$monitor(" %b %b %b %b", S, I1, I0, Y);
	end
endmodule
