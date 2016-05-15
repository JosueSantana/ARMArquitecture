module control_unit (
	output reg regFileEn, statRegEn, marEn, mdrEn, irEn, memEn, memRW, rotatorEn, shifterEn, mdrMuxS,
	output reg [1:0] aluMuxS, wordSel,
	output reg [3:0] ra, rb, rc, 
	output reg [4:0] opcode,
	output reg [11:0] shift_operand,
	//output reg [11:0] shifterOperand, 
	input [31:0] status_reg, instruction, 
	input clr, clk, mfc);
	

	//State variables
	reg[6:0] state, nextState;
	reg conditionNotMet;

	wire [3:0] cond;

	assign {cond} = instruction[31:28];

	initial begin
		state <= 7'b0000000;
	end

	always @  (posedge clk, negedge clr)
	begin
		begin
		state <= nextState; 
		$display("Current: %b, Next: %b, wordSel: %b", state, nextState, instruction[22:22]);
		end
	end

	always @ (instruction, state, mfc)
	begin
		case(state)
			//1 -> 2
			7'b0000000 : begin  nextState = 7'b0000001; end
			7'b0000001 : begin  nextState = 7'b0000010; end
			7'b0000010 : begin  nextState = 7'b0000011; end 
			7'b0000011 : begin  if(!mfc) begin $display("Inside state 3 condition, cond: %b", cond); nextState = 7'b0000011; end else nextState = 7'b0000100; end 			
			7'b0000100 : begin
							$display("Inside state 4 condition, cond: %b", cond);
						 	case(cond)
								4'b0000: begin if(status_reg[30:30] != 1'b1) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Equal (Z = 1)
								4'b0001: begin if(status_reg[30:30] != 1'b0) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Not Equal (Z=0)
								4'b0010: begin if(status_reg[29:29] != 1'b1) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Unsigned higher or same (C=1)
								4'b0011: begin if(status_reg[29:29] != 1'b0) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Unsigned lower (C=0)
								4'b0100: begin if(status_reg[31:31] != 1'b1) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Minus (N=1)
								4'b0101: begin if(status_reg[31:31] != 1'b0) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Positive or Zero (N=0)
								4'b0110: begin if(status_reg[28:28] != 1'b1) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Overflow (V=1)
								4'b0111: begin if(status_reg[28:28] != 1'b1) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // No Overflow (V=0)
								4'b1000: begin if(!(status_reg[29:29] == 1'b1 && status_reg[30:30] == 1'b0)) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Unsigned higher (C=1 and Z=0)
								4'b1001: begin if(!(status_reg[29:29] == 1'b0 || status_reg[30:30] == 1'b1)) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Unsigned lower or same (C=0 or Z=1) 
								4'b1010: begin if(status_reg[31:31] != status_reg[28:28]) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Greater or equal (N = V)
								4'b1011: begin if(!status_reg[31:31] != status_reg[28:28]) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Less than (N != V)
								4'b1100: begin if(!(status_reg[30:30] == 1'b0 && (status_reg[31:31] == status_reg[28:28]))) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Greater than (Z=0 and N=V)
								4'b1101: begin if(!(status_reg[30:30] == 1'b1 || (status_reg[31:31] == !status_reg[28:28]))) begin nextState = 7'b0000001; assign{conditionNotMet} = 1'b1;end else begin assign{conditionNotMet}  = 1'b0; end end // Less than or equal (Z=1 or N!=V)
								4'b1110: begin assign{conditionNotMet}  = 1'b0; end // Always
								4'b1111: begin assign{conditionNotMet} = 1'b1; nextState = 7'b0000001; end // Unused state	
								default: begin assign{conditionNotMet} = 1'b1; nextState = 7'b0000001; end
							endcase

							#1 if(conditionNotMet == 1'b0)
							begin
								// Shift by immediate shifter operand
						        if( (instruction[27:25] == 3'b000 && instruction[4:4] == 0))
						        begin
						            $display("Shift by immediate shifter operand");
						            nextState <= 7'b0000101;             
				          		end

				          		// 32-bit immediate shifter operand
		          		        if((instruction[27:25] == 3'b001))
						        begin
						          $display("32-bit immediate shifter operand");
						          nextState <= 7'b0000110;
						        end

				                // [<Rn>, #+/-<offset_12>] Immediate offset
						        if( (instruction[27:24] == 4'b0101) && (instruction[21:21] == 1'b0) )
						        begin
						        	$display("[<Rn>, #+/-<offset_12>] Immediate offset");
						        	// LOAD
						        	if(instruction[20:20] == 1'b1)
						        	begin
						        		nextState <= 7'b0000111;
						        	end
						        	// STORE
						        	else
						        	begin
						        		nextState <= 7'b0001011; //which state?
						        	end
					        	end     

						        // [<Rn>, +/-<Rm>] Register offset
						        if((instruction[27:24] == 4'b0111 && instruction[21:21] == 0 && instruction[11:4] == 8'b00000000))
						        begin
						            $display("[<Rn>, +/-<Rm>] Register offset");
						        
						            // LOAD
						            if(instruction[20:20] == 1'b1) 
						            begin
						            	nextState <= 7'b0001111;
						            end 
						        
						            // STORE
						            else
						            begin
						            	nextState <= 7'b0010011;          
						            end
						        end 

						        // [<Rn>, #+/-<offset_12>]! Immediate pre-indexed
						        if((instruction[27:24] == 4'b0101 && instruction[21:21] == 1))
						        begin
						            $display("[<Rn>, #+/-<offset_12>]! Immediate pre-indexed");
						        
						             // LOAD
						            if(instruction[20:20] == 1'b1) 
						            begin
						            	nextState <= 7'b0010111;
						            end 
						        
						            // STORE
						            else
						            begin
						            	nextState <= 7'b0011011;         
						            end
						        end  

				                // [<Rn>, +/-<Rm>]! Register pre-indexed
						        if((instruction[27:24] == 4'b0111 && instruction[21:21] == 1 && instruction[11:4] == 8'b00000000))
						          begin
						            $display("[<Rn>, +/-<Rm>]! Register pre-indexed");
						    
						             // LOAD
						            if(instruction[20:20] == 1'b1) 
						            begin
						            	nextState <= 7'b0011000;
						            end 
						        
						            // STORE
						            else
						            begin
						            	nextState <= 7'b0011011;        
						            end
						        end  
						      
						        // [<Rn>], #+/-<offset_12> Immediate post-indexed
						        if((instruction[27:24] == 4'b0100 && instruction[21:21] == 0))
						        begin
						            $display("[<Rn>], #+/-<offset_12> Immediate post-indexed");
						            
						            // LOAD
						            if(instruction[20:20] == 1'b1) 
						            begin
						              nextState <= 7'b0100111;
						            end 
						        
						            // STORE
						            else
						            begin
						             nextState <= 7'b0101011;        
						            end
						        end  
						      
						          // [<Rn>], +/-<Rm> Register post-indexed
						          if( (instruction[27:24] == 4'b0110 && instruction[21:21] == 0 && instruction[11:4] == 8'b00000000)) 
						          begin
						            $display("[<Rn>], +/-<Rm> Register post-indexed");
						        
						            // LOAD
						            if(instruction[20:20] == 1'b1) 
						            begin
						              nextState <= 7'b0101111;
						            end 
						        
						            // STORE
						            else
						            begin
						              nextState <= 7'b0110011;       
						            end
						          end  
							end
						 end
			7'b0000101 : begin nextState = 7'b0000001; end
			7'b0000110 : begin nextState = 7'b0000001; end
			7'b0000111 : begin nextState = 7'b0001000; end
			7'b0001000 : begin nextState = 7'b0001001; end
			7'b0001001 : begin  if(!mfc) begin $display("Inside state 9 condition, cond: %b", cond); nextState = 7'b0001001; end else nextState = 7'b0001010; end 			
			7'b0001010 : begin nextState = 7'b0000001; end
			7'b0001011 : begin nextState = 7'b0001100; end
			7'b0001100 : begin nextState = 7'b0001101; end
			7'b0001101 : begin if(!mfc) begin $display("Inside state 13 condition, cond: %b", cond); nextState = 7'b0001101; end else nextState = 7'b0001110; end 			
			7'b0001110 : begin nextState = 7'b0000001; end
			7'b0001111 : begin nextState = 7'b0010000; end
			7'b0010000 : begin nextState = 7'b0010001; end
			7'b0010001 : begin  if(!mfc) begin $display("Inside state 17 condition, cond: %b", cond); nextState = 7'b0010001; end else nextState = 7'b0010010; end 			
			7'b0010010 : begin nextState = 7'b0000001; end
			7'b0010011 : begin nextState = 7'b0010100; end
			7'b0010100 : begin nextState = 7'b0010101; end
			7'b0010101 : begin if(!mfc) begin $display("Inside state 21 condition, cond: %b", cond); nextState = 7'b0010101; end else nextState = 7'b0010110; end 			
			7'b0010110 : begin nextState = 7'b0000001; end
			7'b0010111 : begin nextState = 7'b0011000; end
			7'b0011000 : begin nextState = 7'b0011001; end
			7'b0011001 : begin  if(!mfc) begin $display("Inside state 25 condition, cond: %b", cond); nextState = 7'b0011001; end else nextState = 7'b0011010; end 			
			7'b0011010 : begin nextState = 7'b0000001; end
			7'b0011011 : begin nextState = 7'b0011100; end
			7'b0011100 : begin nextState = 7'b0011101; end
			7'b0011101 : begin if(!mfc) begin $display("Inside state 29 condition, cond: %b", cond); nextState = 7'b0011101; end else nextState = 7'b0011110; end 			
			7'b0011110 : begin nextState = 7'b0000001; end
			7'b0011111 : begin nextState = 7'b0100000; end
			7'b0100000 : begin nextState = 7'b0100001; end
			7'b0100001 : begin  if(!mfc) begin $display("Inside state 33 condition, cond: %b", cond); nextState = 7'b0100001; end else nextState = 7'b0100010; end 			
			7'b0100010 : begin nextState = 7'b0000001; end
			7'b0100011 : begin nextState = 7'b0100011; end
			7'b0100100 : begin nextState = 7'b0100101; end
			7'b0100101 : begin if(!mfc) begin $display("Inside state 37 condition, cond: %b", cond); nextState = 7'b0100101; end else nextState = 7'b0100110; end 			
			7'b0100110 : begin nextState = 7'b0000001; end
			7'b0100111 : begin nextState = 7'b0101000; end
			7'b0101000 : begin nextState = 7'b0101001; end
			7'b0101001 : begin  if(!mfc) begin $display("Inside state 41 condition, cond: %b", cond); nextState = 7'b0101001; end else nextState = 7'b0101010; end 			
			7'b0101010 : begin nextState = 7'b0000001; end
			7'b0101011 : begin nextState = 7'b0101100; end
			7'b0101100 : begin nextState = 7'b0011101; end
			7'b0101101 : begin if(!mfc) begin $display("Inside state 45 condition, cond: %b", cond); nextState = 7'b0101101; end else nextState = 7'b0011110; end 			
			7'b0101110 : begin nextState = 7'b0000001; end
			7'b0101111 : begin nextState = 7'b0110000; end
			7'b0110000 : begin nextState = 7'b0110001; end
			7'b0110001 : begin  if(!mfc) begin $display("Inside state 49 condition, cond: %b", cond); nextState = 7'b0100001; end else nextState = 7'b0100010; end 			
			7'b0110010 : begin nextState = 7'b0000001; end
			7'b0110011 : begin nextState = 7'b0110011; end
			7'b0110100 : begin nextState = 7'b0110101; end
			7'b0110101 : begin if(!mfc) begin $display("Inside state 53 condition, cond: %b", cond); nextState = 7'b0100101; end else nextState = 7'b0100110; end 			
			7'b0110110 : begin nextState = 7'b0000001; end
			default : begin nextState = 7'b0000000; end
		endcase
	end

	always @ (state)
	begin
		case(state)
			//Fetch step 1
			7'b0000001 : begin regFileEn <= 1'b0; statRegEn <= 1'b1; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; wordSel <= 2'b10; ra <= 4'b0000 ; rb <= 4'b1111; rc <= 4'b1111; 
						 opcode <= 5'b01101; shift_operand <= 12'h0; end
			//Fetch step 2
			7'b0000010 : begin regFileEn <= 1'b0; statRegEn <= 1'b1; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; wordSel <= 2'b10; ra <= 4'b0000 ; rb <= 4'b1111; rc <= 4'b1111; 
						 opcode <= 5'b10000; shift_operand <= 12'h0; end
			//Fetch step 3
			7'b0000011 : begin regFileEn <= 1'b1; statRegEn <= 1'b1; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; wordSel <= 2'b10; ra <= 4'b0000 ; rb <= 4'b1111; rc <= 4'b1111; 
						 opcode <= 5'b01101; shift_operand <= 12'h0; end
			//Fetch step 4
			7'b0000100 : begin regFileEn <= 1'b1; statRegEn <= 1'b1; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b0; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; wordSel <= 2'b10; ra <= 4'b0000 ; rb <= 4'b1111; rc <= 4'b1111; 
						 opcode <= 5'b01101; shift_operand <= 12'h0; end
			//Shift by Immediate Shifter Operand
			7'b0000101 : begin regFileEn <= 1'b0; statRegEn <= instruction[20:20]; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; wordSel <= 2'b10; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[3:0]; 
						 opcode <= instruction[24:21]; shift_operand <= instruction[11:0]; end

			//32-bit immediate shifter operand
			7'b0000110 : begin regFileEn <= 1'b0; statRegEn <= instruction[20:20]; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b1; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; wordSel <= 2'b10; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; 
						 opcode <= instruction[24:21]; shift_operand <= instruction[11:0]; end

			// [<Rn>, #+/-<offset_12>] Immediate offset LOAD STEP 1
			7'b0000111 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b11; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[15:12]; rc <= instruction[19:16]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= instruction[11:0]; end

			// [<Rn>, #+/-<offset_12>] Immediate offset LOAD STEP 2
			7'b0001000 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>] Immediate offset LOAD STEP 3
			7'b0001001 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>] Immediate offset LOAD STEP 4
			7'b0001010 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>] Immediate offset STORE STEP 1
			7'b0001011 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b11; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[15:12]; rc <= instruction[15:12]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= instruction[11:0]; end

			// [<Rn>, #+/-<offset_12>] Immediate offset STORE STEP 2
			7'b0001100 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0;  if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>] Immediate offset STORE STEP 3
			7'b0001101 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>] Immediate offset STORE STEP 4
			7'b0001110 : begin regFileEn <= 1'b1 ; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>] Register offset LOAD STEP 1
			7'b0001111 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[3:0]; rc <= instruction[15:12]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= 12'h000; end

			// [<Rn>, #+/-<Rm>] Register offset LOAD STEP 2
			7'b0010000 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>] Register offset LOAD STEP 3
			7'b0010001 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>] Register offset LOAD STEP 4
			7'b0010010 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>] Register offset STORE STEP 1
			7'b0010011 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[3:0]; rc <= instruction[15:12]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= 12'h000; end

			// [<Rn>, #+/-<Rm>] Register offset STORE STEP 2
			7'b0010100 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0;  if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; 
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>] Register offset STORE STEP 3
			7'b0010101 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>] Register offset STORE STEP 4
			7'b0010110 : begin regFileEn <= 1'b1 ; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

 			// [<Rn>, #+/-<offset_12>]! Immediate pre-indexed offset LOAD STEP 1
			7'b0010111 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b11; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[15:12]; rc <= instruction[19:16]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= instruction[11:0]; end

			// [<Rn>, #+/-<offset_12>]! Immediate pre-indexed offset LOAD STEP 2
			7'b0011000 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; rc <= rb; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>]! Immediate pre-indexed offset LOAD STEP 3
			7'b0011001 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>]! Immediate pre-indexed offset LOAD STEP 4
			7'b0011010 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>]! Immediate pre-indexed offset STORE STEP 1
			7'b0011011 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b11; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[15:12]; rc <= instruction[15:12]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= instruction[11:0]; end

			// [<Rn>, #+/-<offset_12>]! Immediate pre-indexed offset STORE STEP 2
			7'b0011100 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0;  if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>]! Immediate pre-indexed offset STORE STEP 3
			7'b0011101 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<offset_12>]! Immediate pre-indexed offset STORE STEP 4
			7'b0011110 : begin regFileEn <= 1'b1 ; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

		 	// [<Rn>, #+/-<Rm>]! Register pre-indexed offset LOAD STEP 1
			7'b0011111 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[3:0]; rc <= instruction[19:16]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= 12'h000; end

			// [<Rn>, #+/-<Rm>]! Register pre-indexed offset LOAD STEP 2
			7'b0100000 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; rc <= instruction[15:12]; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>]! Register pre-indexed offset LOAD STEP 3
			7'b0100001 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>]! Register pre-indexed offset LOAD STEP 4
			7'b0100010 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>]! Register pre-indexed offset STORE STEP 1
			7'b0100011 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[3:0]; rc <= instruction[19:16]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= 12'h000; end

			// [<Rn>, #+/-<Rm>]! Register pre-indexed offset STORE STEP 2
			7'b0100100 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0;  if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; 
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>]! Register pre-indexed offset STORE STEP 3
			7'b0100101 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

			// [<Rn>, #+/-<Rm>]! Register pre-indexed offset STORE STEP 4
			7'b0100110 : begin regFileEn <= 1'b1 ; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<offset_12> Immediate post-indexed offset LOAD STEP 1
			7'b0100111 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[19:16]; rc <= instruction[15:12]; opcode <= 5'b01101; shift_operand <= instruction[11:0]; end

			// [<Rn>], #+/-<offset_12> Immediate post-indexed offset LOAD STEP 2
			7'b0101000 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b11; mdrMuxS <= 1'b1; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b00100;  /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 rc <= ra; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<offset_12> Immediate post-indexed offset LOAD STEP 3
			7'b0101001 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<offset_12> Immediate post-indexed offset LOAD STEP 4
			7'b0101010 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<offset_12> Immediate post-indexed offset STORE STEP 1
			7'b0101011 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b11; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[15:12]; rc <= instruction[15:12]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= instruction[11:0]; end

			// [<Rn>], #+/-<offset_12> Immediate post-indexed offset STORE STEP 2
			7'b0101100 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0;  if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<offset_12> Immediate post-indexed offset STORE STEP 3
			7'b0101101 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<offset_12> Immediate post-indexed offset STORE STEP 4
			7'b0101110 : begin regFileEn <= 1'b1 ; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

		 	// [<Rn>], #+/-<Rm> Register post-indexed offset LOAD STEP 1
			7'b0101111 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[3:0]; rc <= instruction[19:16]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= 12'h000; end

			// [<Rn>], #+/-<Rm> Register post-indexed offset LOAD STEP 2
			7'b0110000 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; rc <= instruction[15:12]; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<Rm> Register post-indexed offset LOAD STEP 3
			7'b0110001 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b0; aluMuxS <= 2'b00; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<Rm> Register post-indexed offset LOAD STEP 4
			7'b0110010 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b1; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /*shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<Rm> Register post-indexed offset STORE STEP 1
			7'b0110011 : begin regFileEn <= 1'b0; statRegEn <= 1'b0; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b1; if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16]; 
						 rb <= instruction[3:0]; rc <= instruction[19:16]; if(instruction[23:23] == 1'b0) opcode <= 5'b00010; else opcode <= 5'b0100; shift_operand <= 12'h000; end

			// [<Rn>], #+/-<Rm> Register post-indexed offset STORE STEP 2
			7'b0110100 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0;  if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; 
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<Rm> Register post-indexed offset STORE STEP 3
			7'b0110101 : begin regFileEn <= 1'b1; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b0; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

			// [<Rn>], #+/-<Rm> Register post-indexed offset STORE STEP 4
			7'b0110110 : begin regFileEn <= 1'b1 ; statRegEn <= 1'b0; marEn <= 1'b1; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b1; memRW <= 1'b0; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b10; mdrMuxS <= 1'b0; /* if(instruction[22:22] == 1'b0) wordSel <= 2'b10; else wordSel <= 2'b00; ra <= instruction[19:16] ; rb <= instruction[15:12]; rc <= instruction[15:12]; */ 
						 opcode <= 5'b01101; /* shift_operand <= instruction[11:0]; */ end

			//Branch
			7'b0110111 : begin regFileEn <= 1'b0; statRegEn <= 1'b1; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; wordSel <= 2'b10; ra <= 4'b0000 ; rb <= 4'b1111; rc <= 4'b1111; 
						 opcode <= 5'b01101; shift_operand <= 12'h0; end

			//Branch w/Link
			7'b0110111 : begin regFileEn <= 1'b0; statRegEn <= 1'b1; marEn <= 1'b0; mdrEn <= 1'b1; irEn <= 1'b1; memEn <= 1'b0; memRW <= 1'b1; 
						 rotatorEn <= 1'b0; shifterEn <= 1'b1; aluMuxS <= 2'b01; mdrMuxS <= 1'b0; wordSel <= 2'b10; ra <= 4'b0000 ; rb <= 4'b1111; rc <= 4'b1111; 
						 opcode <= 5'b01101; shift_operand <= 12'h0; end


 
		endcase
	end
endmodule