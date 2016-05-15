module ram_read;
	integer fd, code, i; reg[31:0] data;
	reg Enable, ReadWrite; reg[31:0] DataIn;
	reg [31:0] Address; wire [31:0] DataOut; 
	reg [1:0] wordSelector;
	wire MFC;

	reg[31:0] Inst_register, MDR;
	memory_unit ram1 (DataOut, MFC, Enable, ReadWrite, Address, DataIn, wordSelector);

	initial begin
		Address = 32'b0;
		ReadWrite = 1'b0;
		fd = $fopen("mifile.dat", "r");
		//i = 0;
		repeat(100) begin
			if (!($feof(fd))) begin	
				code = $fscanf(fd, "%b", DataIn);
				#5 begin 
					wordSelector = 01;
					Enable = 1'b1; 
					ReadWrite = 1'b0;
				end	
				#5 begin 
					wordSelector = 01;
					Enable = 1'b0;
					ReadWrite = 1'b0;
				end
				#5 begin 
					wordSelector = 01;
					Enable = 1'b1; 
					ReadWrite = 1'b1;				
				end	
				#5 begin
					Address = Address + 1; 
					wordSelector = 01;
					Enable = 1'b0; 
					ReadWrite = 1'b1;
				end	
				#5 begin 	
					wordSelector = 01;
					Enable = 1'b1; 
					ReadWrite = 1'b1;
				end	
				#5 begin 
					Address = Address + 1;
					wordSelector = 01;
					Enable = 1'b0; 
					ReadWrite = 1'b1;
				end	

			end 
		end

		$fclose(fd);
	end

	initial begin
	repeat(20) begin
		#5 		#10 ReadWrite = 1'b1;
	
		end
		$finish;
	end
	initial $monitor("Data = %h at address = %h, Enable? = %b Reading? = %b", DataOut[7:0], Address, Enable, ReadWrite);

	//initial $monitor("Data at %h = %h",Address, DataOut);
	
	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, Address, DataOut); 
	end
endmodule 