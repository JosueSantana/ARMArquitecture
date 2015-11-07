module ram_read;
	integer fd, code, i;	reg[7:0] data;
	reg Enable, ReadWrite; reg[7:0] DataIn;
	reg [7:0] Address; wire [7:0] DataOut; 
	ram256x8 ram1 (DataOut, Enable, ReadWrite, Address, DataIn);

	initial begin
		fd = $fopen("mifilesimple.dat", "r");
		i = 0;
		while (!($feof(fd))) begin
			code = $fscanf(fd, "%b", data);
			ram1.Mem[i] = data;
			i = i + 1; 
			$display("File Data = %h", data);
		end

		$fclose(fd);
	end

	initial begin
	Enable = 1'b0; ReadWrite = 1'b1; 
	Address = 6'b000000;
	$display("data en %d = %b", Address, DataOut);
	repeat(10) begin
		#5 Enable = 1'b1;
		#5 Enable = 1'b0; 
		Address = Address + 1;
		end
		$finish;
	end
	initial $monitor("Data at %h = %h %b %d",
		Address, DataOut, Enable, $time);
	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, Address, DataOut); 
	end
endmodule 