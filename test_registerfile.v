module test_registerfile;
	wire [31:0] Y0, Y1;
	reg [31:0] I;
	reg [3:0] Ra, Rb, Rc;
	reg LE, clk, clr; //LE active on 0

	//parameter sim_time = 300;

	RegFile registerfile(Y0, Y1, I, Ra, Rb, Rc, LE, clk, clr);

	initial begin
		clk = 1'b0;
		clr= 1;
		LE = 0;

		I=32'h12;
		Rc=4'b0000;
		Ra=4'b0000;
		Rb=4'b0001;

		repeat(10) begin
			#5 begin
				clk=!clk;
				Rc=4'b0001;	
				I=32'h12;
			end 
			
			#5 begin
				clk=!clk;
				LE = 1;
				Rc=4'b1001;
			end 
			
			#5 begin
				clk=!clk;
				LE = 0;
				I=32'hAA;	
			end

			#5 begin
				clk=!clk;
				LE = 1;
				Rc=4'b0001;	
			end 
		end
	end

	initial begin
		$monitor("Reg 1: %b\nReg 9: %b\nTime: %d", registerfile.R_Out[1], registerfile.R_Out[9], $time);
	end
endmodule



