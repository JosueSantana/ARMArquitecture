module test_register32;
	reg [31:0] D;
	wire [31:0] Q;
	reg Clk, Clr, LE;

	parameter sim_time=200;

	register32 r0(Q, D, LE, Clr, Clk);

	initial #sim_time $finish;

	initial begin
		LE = 1'b0;
		Clk = 1'b0;
		Clr = 1'b1;
		D = 32'h00000000;

		repeat (5) begin
			#5 Clk = !Clk;
			#5 D = D + 32'h00000001;
		end

		#25 LE = 1'b1;

		repeat (5) begin
			#5 Clk=!Clk;
			#5 D = D + 32'h00000001;
		end

		#75 Clr = 1'b0;
	end

	initial begin
		$display(" Clk LE Clr D Q");
		$monitor(" %b %b %b %b %b", Clk, LE, Clr, D, Q);
	end
endmodule

