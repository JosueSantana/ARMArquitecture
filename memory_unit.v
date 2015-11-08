module memory_unit (output reg [31:0] DataOut, output reg MFC,  
					input Enable, ReadWrite, input [31:0] Address, DataIn, input [1:0] wordSelector );

	reg [7:0] Mem[0:255]; //256 localizaciones de 8 bits
	
	always @ (Enable, ReadWrite, wordSelector, DataIn)
		begin
			case(wordSelector)
			2'b00:
				if(Enable)
				begin
					MFC = 1'b0;
					if(ReadWrite) DataOut[7:0] = Mem[Address]; 								
					else
					begin 
						Mem[Address] = DataIn[7:0];
					end
					MFC = 1'b1;
				end
				else DataOut = 32'bz;
			2'b01:
				if(Enable)
				begin
					MFC = 1'b0;
					if(ReadWrite)
						begin
							DataOut[15:8] = Mem[Address];
							DataOut[7:0] = Mem[Address+1];
						end
					else
						begin
							Mem[Address] = DataIn[15:8];
							Mem[Address + 1] = DataIn[7:0];		
						end
					MFC = 1'b1;
				end
				else DataOut = 32'bz;
			2'b10:
				if(Enable)
				begin
					MFC = 1'b0;
					if(ReadWrite)
						begin
							DataOut[31:24] = Mem[Address];
							DataOut[23:16] = Mem[Address+1];
							DataOut[15:8] = Mem[Address+2];
							DataOut[7:0] = Mem[Address+3];													
						end

					else
						begin
							Mem[Address] = DataIn[31:24];
							Mem[Address + 1] = DataIn[23:16];
							Mem[Address + 2] = DataIn[15:8];
							Mem[Address + 3] = DataIn[7:0];					
						end	
					MFC = 1'b1;	
				end
				else DataOut = 32'bz;
			default:
				if(Enable)
				begin
					MFC = 1'b0;
					if(ReadWrite) DataOut[7:0] = Mem[Address]; 
					else Mem[Address] = DataIn[7:0];
					MFC = 1'b1;
				end	
				else DataOut = 32'bz;
			endcase
		end
endmodule