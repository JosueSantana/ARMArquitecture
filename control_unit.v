module control_unit (output reg regFileClr, statRegClr, irClr, statRegEn, marEn, irEn, memEn, memRW, rotatorEn, shifterEn, 
	output reg [1:0] shiftSel, wordSel, output reg [3:0] ra, rb, rc, opcode, output reg [11:0] shifterOperand, input [31:0] status_reg, instruction, input clr, clk, mfc);
	

	// status_reg
	// 31: N, 30: Z, 29: C, 28: V, 27: Q

	reg [6:0] state, nextState;
	reg condNotMet;

	wire [3:0] cond;
	wire [2:0] instruction_format;

	assign cond = instruction[31:28];
	assign instruction_format = instruction[27:25];

	assign state <= nextState;


	always @(posedge clk, negedge clr)
  begin
    $display("New state"); 
    state <= nextState;
  end

 	always @ (state, mfc) //state order management 
 		case(state)
 			7'b0000000: nextState = 7'b0000001;
 			7'b0000001: nextState = 7'b0000010;
 			7'b0000010: 
 			begin
 				case(cond)
 					4'b0000: begin if(status_reg[30:30] != 1'b1) begin nextstate = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Equal (Z = 1)
 					4'b0001: begin if(status_reg[30:30] != 1'b0) begin nextstate = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Not Equal (Z=0)
 					4'b0010: begin if(status_reg[29:29] != 1'b1) begin nextstate = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Unsigned higher or same (C=1)
 					4'b0011: begin if(status_reg[29:29] != 1'b0) begin nextstate = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Unsigned lower (C=0)
 					4'b0100: begin if(status_reg[31:31] != 1'b1) begin nextstate = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Minus (N=1)
 					4'b0101: begin if(status_reg[31:31] != 1'b0) begin nextstate = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Positive or Zero (N=0)
 					4'b0110: begin if(status_reg[28:28] != 1'b1) begin nextstate = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Overflow (V=1)
 					4'b0111: begin if(status_reg[28:28] != 1'b1) begin nextstate = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // No Overflow (V=0)
 					4'b1000: begin if(!(status_reg[29:29] == 1'b1 && status_reg[30:30] == 1'b0)) begin NextState = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Unsigned higher (C=1 and Z=0)
 					4'b1001: begin if(!(status_reg[29:29] == 1'b0 || status_reg[30:30] == 1'b1)) begin NextState = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Unsigned lower or same (C=0 or Z=1) 
 					4'b1010: begin if(status_reg[31:31] != status_reg[28:28]) begin NextState = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Greater or equal (N = V)
 					4'b1011: begin if(!status_reg[31:31] != status_reg[28:28]) begin NextState = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Less than (N != V)
 					4'b1100: begin if(!(status_reg[30:30] == 1'b0 && (status_reg[31:31] == status_reg[28:28]))) begin NextState = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Greater than (Z=0 and N=V)
 					4'b1101: begin if(!(status_reg[30:30] == 1'b1 || (status_reg[31:31] == !status_reg[28:28]))) begin NextState = 7'b0000000; assign{condNotMet} = 1'b1;end else begin assign{condNotMet}  = 1'b0; end end; // Less than or equal (Z=1 or N!=V)
 					4'b1110: begin assign{condNotMet}  = 1'b0; end; // Always
 					4'b1111: begin assign{condNotMet}  = 1'b0; NextState = 7'b0000000; end; // Unused state	
 				endcase				 					 					 					 					 					 					 					
 			end

 			7'b0000011: nextState = 7'b0000000;

 			7'b0000100: nextState = 7'b0000000;

 			7'b0000101: nextState = 7'b0000110;
 			7'b0000110: nextState = 7'b0000111;
 			7'b0000111: nextState = 7'b0000000;

 			7'b0001000: nextState = 7'b0001001;
 			7'b0001001: nextState = 7'b0001010;
 			7'b0001010: nextState = 7'b0000000; //10

 			7'b0001011: nextState = 7'b0001100;
 			7'b0001100: nextState = 7'b0001101;
 			7'b0001101: nextState = 7'b0000000;

 			7'b0001110: nextState = 7'b0001111;
 			7'b0001111: nextState = 7'b0010000;
 			7'b0010000: nextState = 7'b0000000;

 			7'b0010001: nextState = 7'b0010010;
 			7'b0010010: nextState = 7'b0010011; 
 			7'b0010011: nextState = 7'b0000000;

 			7'b0010100: nextState = 7'b0010101; //20
 			7'b0010101: nextState = 7'b0010110;
 			7'b0010110: nextState = 7'b0000000;

 			7'b0010111: nextState = 7'b0011000;
 			7'b0011000: nextState = 7'b0011001;
 			7'b0011001: nextState = 7'b0000000;

 			7'b0011010: nextState = 7'b0011011;
 			7'b0011011: nextState = 7'b0011100;
 			7'b0011100: nextState = 7'b0000000;

 			7'b0011101: nextState = 7'b0011110;
 			7'b0011110: nextState = 7'b0011111; //30
 			7'b0011111: nextState = 7'b0100000; 
 			7'b0100000: nextState = 7'b0000000; 

 			7'b0100001: nextState = 7'b0100010; 
 			7'b0100010: nextState = 7'b0100011; 
 			7'b0100011: nextState = 7'b0100100; 
 			7'b0100100: nextState = 7'b0000000; 
 
 			7'b0100101: nextState = 7'b0100110; 
 			7'b0100110: nextState = 7'b0100111;
 			7'b0100111: nextState = 7'b0101000; 
 			7'b0101000: nextState = 7'b0000000; //40

 			7'b0101001: nextState = 7'b0101010;
 			7'b0101010: nextState = 7'b0101011;
 			7'b0101011: nextState = 7'b0101100;
 			7'b0101100: nextState = 7'b0000000;

 			7'b0101101: nextState = 7'b0101110;
 			7'b0101110: nextState = 7'b0101111;
 			7'b0101111: nextState = 7'b0000000;

 			7'b0110000: nextState = 7'b0110001;
 			7'b0110001: nextState = 7'b0110010;
 			7'b0110010: nextState = 7'b0000000; //50

 			7'b0110011: nextState = 7'b0110100;
 			7'b0110100: nextState = 7'b0110101;
 			7'b0110101: nextState = 7'b0000000;

 			7'b0110110: nextState = 7'b0110111;
 			7'b0110111: nextState = 7'b0111000;
 			7'b0111000: nextState = 7'b0000000;

 			7'b0111001: nextState = 7'b0111010;
 			7'b0111010: nextState = 7'b0111011;
 			7'b0111011: nextState = 7'b0111100;
 			7'b0111100: nextState = 7'b0000000; //60

 			7'b0111101: nextState = 7'b0111110; 
 			7'b0111110: nextState = 7'b0111111;
 			7'b0111111: nextState = 7'b1000000;
 			7'b1000000: nextState = 7'b0000000;

 			7'b1000001: nextState = 7'b0000000;

 			7'b1000010: nextState = 7'b1000011;
 			7'b1000010: nextState = 7'b0000000;

 		endcase

 		#1 if(condNotMet == 1'b0)
 		begin
 			$display("if passed");
 			begin

		        // 32-bit immediate shifter operand
		        if((instruction[27:25] == 3'b001))
		        begin
		            $display("32-bit immediate shifter operand");
		            NextState <= 7'b0000011;
		        end   

		         // Shift by immediate shifter operand
		        if( (instruction[27:25] == 3'b000 && instruction[4:4] == 0))
		        begin
		            $display("Shift by immediate shifter operand");
		            NextState <= 7'b0000100;             
          		end

          		// [<Rn>, #+/-<offset_12>] Immediate offset
		        if( (instruction[27:24] == 4'b0101) && (instruction[21:21] == 1'b0) )
		        begin
		            $display("[<Rn>, #+/-<offset_12>] Immediate offset");
		            // LOAD
		            if(instruction[20:20] == 1'b1)
			            begin
			              NextState <= 7'b0000101;
			            end
		            // STORE
		            else
			            begin
			              NextState <= 7'b0001000;
			            end
		        end  
		      
		        // [<Rn>, +/-<Rm>] Register offset
		        if((instruction[27:24] == 4'b0111 && instruction[21:21] == 0 && instruction[11:4] == 8'b00000000))
		        begin
		            $display("[<Rn>, +/-<Rm>] Register offset");
		        
		            // LOAD
		            if(instruction[20:20] == 1'b1) 
		            begin
		              NextState <= 7'b0001011;
		            end 
		        
		            // STORE
		            else
		            begin
		              NextState <= 7'b0001110;          
		            end
		        end

		        // [<Rn>, #+/-<offset_12>]! Immediate pre-indexed
		        if((instruction[27:24] == 4'b0101 && instruction[21:21] == 1))
		        begin
		            $display("[<Rn>, #+/-<offset_12>]! Immediate pre-indexed");
		        
		             // LOAD
		            if(instruction[11] == 1'b1) 
		            begin
		              NextState <= 7'b0010001;
		            end 
		        
		            // STORE
		            else
		            begin
		             NextState <= 7'b0010100;         
		            end
		        end


		        // [<Rn>, +/-<Rm>]! Register pre-indexed
		        if((instruction[27:24] == 4'b0111 && instruction[21:21] == 1 && instruction[11:4] == 8'b00000000))
		        begin
		            $display("[<Rn>, +/-<Rm>]! Register pre-indexed");
		    
		             // LOAD
		            if(instruction[20:20] == 1'b1) 
		            begin
		              NextState <= 7'b0010111;
		            end 
		        
		            // STORE
		            else
		            begin
		             NextState <= 7'b0011010;        
		            end
		        end  

		        // [<Rn>], #+/-<offset_12> Immediate post-indexed
		        if((instruction[27:24] == 4'b0100 && instruction[21:21] == 0))
		          begin
		            $display("[<Rn>], #+/-<offset_12> Immediate post-indexed");
		            
		            // LOAD
		            if(instruction[20:20] == 1'b1) 
		            begin
		              NextState <= 7'b0011101;
		            end 
		        
		            // STORE
		            else
		            begin
		             NextState <= 7'b0100001;        
		            end
		        end  
		      
		        // [<Rn>], +/-<Rm> Register post-indexed
		        if( (instruction[27:24] == 4'b0110 && instruction[21:21] == 0 && instruction[11:4] == 8'b00000000)) 
		          begin
		            $display("[<Rn>], +/-<Rm> Register post-indexed");
		        
		            // LOAD
		            if(instruction[20:20] == 1'b1) 
		            begin
		              NextState <= 7'b0100101;
		            end 
		        
		            // STORE
		            else
		            begin
		              NextState <= 7'b0101001;       
		            end
		        end  

		        // [<Rn>, #+/-<offset_8>] Misc. Immediate offset
		        if(( instruction[27:24] == 4'b0001 && instruction[22:21] == 2'b10 && instruction[7:7] == 1 && instruction[4:4] == 1))
		        begin
		            $display("[<Rn>, #+/-<offset_8>] Misc. Immediate offset");
		        
		            statRegEn <= 1'b1;
		        
		            // LOAD
		            if(instruction[20:20] == 1'b1) 
		            begin
		              NextState <= 7'b0101101;
		              
		              // unsigned halfword
		              if(instruction[6:6] == 1'b0 && instruction[5:5] == 1'b1 )
		              begin
		                wordSel <= 2'b01;
		                sign <= 1'b0;
		              end
		              // signed byte
		              if(instruction[6:6] == 1'b1 && instruction[5:5] == 1'b0 )
		              begin
		                wordSel <= 2'b00;
		                sign <= 1'b1;
		              end
		              // signed halfword
		              if(instruction[6:6] == 1'b1 && instruction[5:5] == 1'b1 )
		              begin
		                wordSel <= 2'b01;
		                sign <= 1'b1;
		              end
		            end 
		        
		            // STORE
		            else
		            begin
		              if(instruction[6:6] == 1'b0 && instruction[5:5] == 1'b1) 
		              begin
		                // halfword
		                wordSel <= 2'b10;
		                NextState <= 7'b0110000;
		              end

		              // Special Case : Load doubleword
		              if(instruction[6:6] == 1'b1 && instruction[5:5] == 1'b0)
		              begin
		                // doubleword
		                wordSel <= 2'b01;
		                NextState <= 7'b0101101;
		              end
		              if(instruction[6:6] == 1'b1 && instruction[5:5] == 1'b1)
		              begin
		                // doubleword
		                wordSel <= 2'b01;
		                NextState <= 7'b0110000;
		              end
		            end
		        end  
		      
		        // [<Rn>, #+/-<offset_8>]! Misc. Immediate pre-indexed
		        if((instruction[27:24] == 4'b0001 && instruction[22:21] == 2'b11 && instruction[7:7] == 1 && instruction[4:4] == 1))
		          begin
		            $display("[<Rn>, #+/-<offset_8>]! Misc. Immediate pre-indexed");
		            
		            statRegEn <= 1'b1;
		            
		            // LOAD
		            if(instruction[20:20] == 1'b1) 
		            begin
		              $display("Load");
		              NextState <= 7'b0110011;
		              if(instruction[25] == 1'b0 && instruction[26] == 1'b1)
		                begin
		                  // unsigned
		                  sign <= 1'b0;
		                  // halfword
		                  wordSel <= 2'b10;
		                end
		              if(instruction[25] == 1'b1 && instruction[26] == 1'b0)
		                begin
		                  // signed
		                  sign <= 1'b1;
		                  // byte
		                  wordSel <= 2'b00;
		                end
		              if(instruction[25] == 1'b1 && instruction[26] == 1'b1)
		                begin
		                  // signed
		                  sign <= 1'b1;
		                  // halfword
		                  wordSel <= 2'b10;
		                end
		            end 
		        
		            // STORE
		            else
		            begin
		              //NextState <= 7'b0110111;
		              $display("Store");
		              if(instruction[25] == 1'b0 && instruction[26] == 1'b1) 
		              begin
		                // halfword
		                wordSel <= 2'b10;
		                NextState <= 7'b0110110;
		              end
		              // Special Case : Load doubleword
		              if(instruction[25] == 1'b1 && instruction[26] == 1'b0)
		              begin
		                // doubleword
		                wordSel <= 2'b01;
		                NextState <= 7'b0110011;
		              end
		              if(instruction[25] == 1'b1 && instruction[26] == 1'b1)
		              begin
		                // doubleword
		                wordSel <= 2'b01;
		                NextState <= 7'b0110110;
		              end
		            end  
		        end  
		      
		        // [<Rn>], #+/-<offset_8> Misc. Immediate post-indexed
		        if((instruction[27:24] == 4'b0000 && instruction[22:21] == 2'b10 && instruction[7] == 1 && instruction[4] == 1))
		          begin
		            $display("[<Rn>], #+/-<offset_8> Misc. Immediate post-indexed");
		        
		            statRegEn <= 1'b1;
		        
		            // LOAD
		            if(instruction[20:20] == 1'b1) 
		            begin
		              NextState <= 7'b0111001;
		              if(instruction[25] == 1'b0 && instruction[26] == 1'b1)
		                begin
		                  // unsigned
		                  sign <= 1'b0;
		                  // halfword
		                  wordSel <= 2'b10;
		                end
		              if(instruction[25] == 1'b1 && instruction[26] == 1'b0)
		                begin
		                  // signed
		                  sign <= 1'b1;
		                  // byte
		                  wordSel <= 2'b00;
		                end
		              if(instruction[25] == 1'b1 && instruction[26] == 1'b1)
		                begin
		                  // signed
		                  sign <= 1'b1;
		                  // halfword
		                  wordSel <= 2'b10;
		                end
		            end 
		        
		            // STORE
		            else
		            begin
		              if(instruction[25] == 1'b0 && instruction[26] == 1'b1) 
		              begin
		                // halfword
		                wordSel <= 2'b10;
		                NextState <= 7'b0111101;
		              end
		              // Special Case : Load doubleword
		              if(instruction[25] == 1'b1 && instruction[26] == 1'b0)
		              begin
		                // doubleword
		                wordSel <= 2'b01;
		                NextState <= 7'b0111001;
		              end
		              if(instruction[25] == 1'b1 && instruction[26] == 1'b1)
		              begin
		                // doubleword
		                wordSel <= 2'b01;
		                NextState <= 7'b0111101;
		              end
		            end
		        end 

		        // Branch
		          if(in[4:6] == 3'b101 && in[7] == 0)
		          begin
		            $display("Branch");
		        
		            // Branch 65
		            NextState <= 7'b1000010;
		            sren <= 1'b1;
		          end  
		      
		        // Branch with Link
		        if( (in[4:6] == 3'b101 && in[7] == 1))
		        begin
		            $display("Branch with Link");
		            
		            // 66
		            NextState <= 7'b1000100;
		            sren <= 1'b1; 
		        end
 			end
 		end

 	always @ (state)
    // 1. Fetch
    7'b0000001 : begin muxB <= 2'b00; mux0 <= 2'b10; mux1 <= 3'b000; mux3 <= 2'b01; rfen <= 1'b1; sh_select <= 1'b0; sh_type <= 2'b00; ALU <= 4'b1101; iren <= 1'b1; mdren <= 1'b1; maren <= 1'b0; mfa <= 1'b0; r_w <= 1'b1; memEn <= 1'b0; sren <= 1'b1; end
    // 2. Fetch Parte 2
    7'b0000010 : begin muxB <= 2'b00; mux1 <= 3'b000; mux2 <= 1'b1; mux3 <= 2'b01; rfen <= 1'b1; maren <= 1'b1;  mdren <= 1'b0; iren <= 1'b0; sren <= 1'b1; mfa <= 1'b1; r_w <= 1'b0; B_W_HW <= 2'b01; memEn <= 1'b1; sren <= 1'b1; sign <= 1'b0; end
    // 3. Fetch Parte 3
    7'b0000011 : begin muxB <= 2'b00; muxD <= 2'b00; mux0 <= 2'b01; mux1 <= 3'b000; mux3 <= 2'b01; rfen <= 1'b0; sh_type <= 2'b00; sh_select <= 1'b0; ALU <= 4'b0100; iren <= 1'b0; mdren <= 1'b0; maren <= 1'b1; mfa <= 1'b0; memEn <= 1'b0; sren <= 1'b1; end
    

    //output reg regFileClr, statRegClr, irClr, statRegEn, marEn, irEn, memEn, memRW, rotatorEn, shifterEn, 
	//output reg [1:0] shiftSel, wordSel, output reg [3:0] ra, rb, rc, opcode, output reg [11:0] shifterOperand
			//Fetch
			//Step 1:
 		 	7'b0000000: begin regFileClr <= 1'b0; statRegClr <= 1'b0; irClr <= 1'b0; statRegEn <= 1'b1; marEn <= 1'b0; irEn <= 1'b0; memEn <= 1'b0; memRW <= 1'b1; 
 		 	rotatorEn <= 1'b1; shifterEn <= 1'b1; shiftSel <= 2'b00; wordSel <= 2'b00 ; ra <= 4'b0000 ; rb <= 4'b1111; rc <= 4'b0000; opcode <= 4'b1101;
 		 	shifterOperand <= 12'b000000000000 ; end
 		 	
 		 	//Step 2:
 			7'b0000001: begin regFileClr <= 1'b0; statRegClr <= 1'b0; irClr <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; irEn <= 1'b0; memEn <= 1'b1; memRW <= 1'b1; 
 		 	rotatorEn <= 1'b0; shifterEn <= 1'b0; shiftSel <= 2'b00; wordSel <= 2'b10 ; ra <= 4'b0000 ; rb <= 4'b00000; rc <= 4'b0000; opcode <= 4'b0000;
 		 	shifterOperand <= 12'b000000000000 ; end

 		 	//Step 3:
 			7'b0000010: begin regFileClr <= 1'b0; statRegClr <= 1'b0; irClr <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
 		 	rotatorEn <= 1'b0; shifterEn <= 1'b0; shiftSel <= 2'b00; wordSel <= 2'b10; ra <= 4'b0000 ; rb <= 4'b0000; rc <= 4'b0000; opcode <= 4'b0000;
 		 	shifterOperand <= 12'b000000000000 ; end

 			7'b0000011: nextState = 7'b0000000;

 			7'b0000100: nextState = 7'b0000000;

 			7'b0000101: nextState = 7'b0000110;
 			7'b0000110: nextState = 7'b0000111;
 			7'b0000111: nextState = 7'b0000000;

 			7'b0001000: nextState = 7'b0001001;
 			7'b0001001: nextState = 7'b0001010;
 			7'b0001010: nextState = 7'b0000000; //10

 			7'b0001011: nextState = 7'b0001100;
 			7'b0001100: nextState = 7'b0001101;
 			7'b0001101: nextState = 7'b0000000;

 			7'b0001110: nextState = 7'b0001111;
 			7'b0001111: nextState = 7'b0010000;
 			7'b0010000: nextState = 7'b0000000;

 			7'b0010001: nextState = 7'b0010010;
 			7'b0010010: nextState = 7'b0010011; 
 			7'b0010011: nextState = 7'b0000000;

 			7'b0010100: nextState = 7'b0010101; //20
 			7'b0010101: nextState = 7'b0010110;
 			7'b0010110: nextState = 7'b0000000;

 			7'b0010111: nextState = 7'b0011000;
 			7'b0011000: nextState = 7'b0011001;
 			7'b0011001: nextState = 7'b0000000;

 			7'b0011010: nextState = 7'b0011011;
 			7'b0011011: nextState = 7'b0011100;
 			7'b0011100: nextState = 7'b0000000;

 			7'b0011101: nextState = 7'b0011110;
 			7'b0011110: nextState = 7'b0011111; //30
 			7'b0011111: nextState = 7'b0100000; 
 			7'b0100000: nextState = 7'b0000000; 

 			7'b0100001: nextState = 7'b0100010; 
 			7'b0100010: nextState = 7'b0100011; 
 			7'b0100011: nextState = 7'b0100100; 
 			7'b0100100: nextState = 7'b0000000; 
 
 			7'b0100101: nextState = 7'b0100110; 
 			7'b0100110: nextState = 7'b0100111;
 			7'b0100111: nextState = 7'b0101000; 
 			7'b0101000: nextState = 7'b0000000; //40

 			7'b0101001: nextState = 7'b0101010;
 			7'b0101010: nextState = 7'b0101011;
 			7'b0101011: nextState = 7'b0101100;
 			7'b0101100: nextState = 7'b0000000;

 			7'b0101101: nextState = 7'b0101110;
 			7'b0101110: nextState = 7'b0101111;
 			7'b0101111: nextState = 7'b0000000;

 			7'b0110000: nextState = 7'b0110001;
 			7'b0110001: nextState = 7'b0110010;
 			7'b0110010: nextState = 7'b0000000; //50

 			7'b0110011: nextState = 7'b0110100;
 			7'b0110100: nextState = 7'b0110101;
 			7'b0110101: nextState = 7'b0000000;

 			7'b0110110: nextState = 7'b0110111;
 			7'b0110111: nextState = 7'b0111000;
 			7'b0111000: nextState = 7'b0000000;

 			7'b0111001: nextState = 7'b0111010;
 			7'b0111010: nextState = 7'b0111011;
 			7'b0111011: nextState = 7'b0111100;
 			7'b0111100: nextState = 7'b0000000; //60

 			7'b0111101: nextState = 7'b0111110; 
 			7'b0111110: nextState = 7'b0111111;
 			7'b0111111: nextState = 7'b1000000;
 			7'b1000000: nextState = 7'b0000000;

 			7'b1000001: nextState = 7'b0000000;

 			7'b1000010: nextState = 7'b1000011;
 			7'b1000010: nextState = 7'b0000000;
 		case(state)

endmodule