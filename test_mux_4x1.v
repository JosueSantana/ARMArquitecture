module test_mux_4x1;
	wire [31:0] Y;
	reg [1:0] S;
	reg [31:0] I0, I1, I2, I3;

	parameter sim_time = 100;

	mux_4x1 mux2 (Y,S, I0, I1, I2, I3);

	initial #sim_time $finish;

	initial begin
		S = 2'b00;
		I0 = 32'b00000000000000000000000000000000;
		I1 = 32'b00000000000000000000000000000010;
		I2 = 32'b00000000000000000000000000000100;
		I3 = 32'b00000000000000000000000000001000;

		repeat (4) #10 S = S + 2'b01;
	end

	initial begin
		$display(" S I0 I1 I2 I3 Y");
		$monitor(" %b %b %b %b %b %b", S, I0, I1, I2, I3, Y);
	end
endmodule