module test_registerfile;
	wire [31:0] Y0, Y1;
	reg [31:0] I;
	reg [3:0] Ra, Rb, Rc;
	reg LE, clk, clr; //LE active on 0

	parameter sim_time = 300;

	register_file registerfile(Y0, Y1, I, Ra, Rb, Rc, LE, clk, clr);

	initial begin
		clk = 1'b0;
		repeat (60) #5 clk=!clk;
	end

	initial fork
		I=32'h0000000A;
		Rc=4'b0000;
		Ra=4'b0000;
		Rb=4'b0001;
		clr=0;
		#3 LE = 0;
		#7 I=32'h00000008;
		#7 Rc=4'b0001;
		#16 LE = 1;
		#21 clr=1;
	join

	initial begin
		$display(" clk clr le Ra Rb Rc I  Y0 Y1 Time");
		$monitor(" %b  %b  %b %b %b %b %b %b %b", clk, clr, LE, Ra, Rb, Rc, I, Y0, Y1, $time);
	end
endmodule



