module datapath_test();

	reg Clk, Clr;
	reg [31:0] instruction; 

	parameter simTime = 400; 

	datapath d (instruction, Clr, Clk);

	initial #simTime $finish;

	initial begin 
		Clk = 0;
		Clr = 1;

		forever begin
			#5 Clk = ~Clk;
		end	
	end

	initial fork 
		#15 instruction = 32'h03B01001;

		//#15 $display(" d.registers.R0.D= %h\n d.registers.R0.Q = %h\n d.registers.R0.LE=%b\n d.registers.clr=%b\n d.registers.R0.Clk = %b", d.registers.R0.D, d.registers.R0.Q,d.registers.R0.LE, d.registers.clr, d.registers.R0.Clk);

		#25 instruction = 32'h03B0A003;

		#35 instruction = 32'h02912003;

		#45 instruction = 32'h00923001;

		#55 Clr = 0;
	join



	initial begin
		$display(" Clk R0          R1           R2           R3           R4           R5           R6           R7           R8           R9           R10          R11          R12          R13          R14          R15                     Time     ");
		$monitor(" %b  %h     %h     %h     %h     %h     %h     %h     %h     %h     %h     %h     %h     %h     %h     %h     %h", 
					 Clk, d.registers.w0, d.registers.w1, d.registers.w2, d.registers.w3, d.registers.w4, d.registers.w5,  
					 d.registers.w6, d.registers.w7, d.registers.w8, d.registers.w9, d.registers.w10, d.registers.w11,
					 d.registers.w12, d.registers.w13, d.registers.w14, d.registers.w15, $time);
	end

endmodule