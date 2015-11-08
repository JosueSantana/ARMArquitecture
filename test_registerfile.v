module test_registerfile;
	wire [31:0] Y0, Y1;
	reg [31:0] I;
	reg [3:0] Ra, Rb, Rc;
	reg LE, clk, clr; //LE active on 0

	parameter sim_time = 300;

	register_file registerfile(Y0, Y1, I, Ra, Rb, Rc, LE, clk, clr);

	initial begin
		clk = 1'b0;
		clr=0;
		LE = 0;

		I=32'h00000000;
		Rc=4'b0000;
		Ra=4'b0000;
		Rb=4'b0001;

		forever begin
			#5 clk=!clk;
		end
	end

	initial fork
		
	join

	initial begin
		$display(" clk clr le Ra Rb Rc I  Y0 Y1 Time");
		$monitor(" %b  %b  %b %b %b %b %b %b %b", clk, clr, LE, Ra, Rb, Rc, I, Y0, Y1, $time);
	end
endmodule



