module arm_alu (output reg [31:0] Y, output reg V, C, N, Z, 
				input [31:0] in_1, in_2, input [4:0] opcode,
				input C_in );
	reg [31: 0] temp;
		always @ (in_1, in_2, C_in, opcode)
			case(opcode)
				5'b00000:						// Bitwise AND
						begin
							Y = in_1 & in_2;
							if (Y == 32'b0)
								Z = 1'b1;
							else
								Z = 1'b0;
						end
				5'b00001:						// Bitwise Exclusive OR 
						begin
							Y = (in_1 && !in_2) | (!in_1 && in_2);
							if (Y == 32'b0)
								Z = 1'b1;
							else
								Z = 1'b0;
						end
				5'b00010:						// Subtract
						begin
							Y = in_1 - in_2;
							if (Y == 32'b0)
								Z = 1'b1;
							else
								begin
									if (Y[31] == 1'b1)
										begin
											N = 1'b1;
											if(in_1[31] != in_2[31] && in_2[31] == Y[31])
												V = 1'b1;
										end
									else	N = 1'b0;
									if(in_1 > in_2)
										C = 1'b1;
									else	C = 1'b0;
									Z = 1'b0;

								end

						end

				5'b00011:						// Reverse Subtract
						begin
							Y = in_2 - in_1;

							if (Y == 32'b0)
								Z = 1'b1;
							else
								begin
									Z = 1'b0;
									if (Y[31] == 1'b1)
											N = 1'b1;
									else
											N = 1'b0;
									if(in_1[31] != in_2[31] && in_1[31] == Y[31])
											V = 1'b1;
									else
											V = 1'b0;
									if(in_2 > in_1)
										C = 1'b1;
									else
										C = 1'b0;
								end
						end

				5'b00100:						// Add
						begin
							Y = in_1 + in_2;

							if (Y == 32'b0)
									Z = 1'b1;
							else
								begin
									if (Y[31] == 1'b1)
											N = 1'b1;
									else
											N = 1'b0;
									Z = 1'b0;
								end
							if(in_1[31] == 1'b1 || in_2[31] == 1'b1 && Y[31] == 1'b0)
								C = 1;
							if(in_1[31] == 1'b1 && in_2[31] == 1'b1)
								C = 1;
							else
								C = 1'b0;
							if(in_1[31] == in_2[31] && Y[31] == 1'b0)
								V = 1;
							else
								V = 0;
						end

				5'b00101:						// Add with Carry
						begin
							Y = in_1 + in_2 + C_in;

							if (Y == 32'b0)
									Z = 1'b1;
							else
								begin
									if (Y[31] == 1'b1)
											N = 1'b1;
									else
											N = 1'b0;
									Z = 1'b0;
								end
							if(in_1[31] == 1'b1 || in_2[31] == 1'b1 && Y[31] == 1'b0)
								C = 1;
							if(in_1[31] == 1'b1 && in_2[31] == 1'b1)
								C = 1;
							else
								C = 1'b0;
							if(in_1[31] == in_2[31] && Y[31] == 1'b0)
								V = 1;
							else
								V = 0;
						end
				5'b00110:						// Subtract with Carry
						begin
							Y = in_1 - in_2 - !C_in;

							if (Y == 32'b0)
								Z = 1'b1;
							else
								begin
								Z = 1'b0;
									if (Y[31] == 1'b1)
											N = 1'b1;
									else
											N = 1'b0;
									if(in_1[31] != in_2[31] && in_1[31] == Y[31])
											V = 1'b1;
									else	V = 1'b0;
									if(in_2 > in_1)
										C = 1;
									else C = 1'b0;
								end
						end
				5'b00111:						// Reverse Subtract with Carry
						begin
							Y = in_2 - in_1 - !C_in;  

							if (Y == 32'b0)
								Z = 1'b1;
							else
								begin
									Z = 1'b0;
									if (Y[31] == 1'b1)
											N = 1'b1;
									else	N = 1'b0;
									if(in_2[31] != in_1[31] && in_2[31] == Y[31])
											V = 1'b1;
									else 	V = 1'b0;
									if(in_1 > in_2)
										C = 1;
									else	C = 1'b0;
								end
						end
				5'b01000:						// Test
						begin
							temp = in_1 && in_2;
							if (temp == 32'b0)
								Z = 1'b1;
							else Z = 1'b0;
						end
				5'b01001:						// Test Equivalence
						begin
							temp = (in_1 && !in_2) | (!in_1 && in_2);
							if (temp == 32'b0)
								Z = 1'b1;
							else Z = 1'b0;
						end				 
				5'b01010:						// Compare
						begin
							temp = in_1 - in_2;
							if (temp == 32'b0)
								Z = 1'b1;
							else
								begin
									Z = 1'b0;
									if (temp[31] == 1'b1)
										begin
											N = 1'b1;
											if(in_1[31] != in_2[31] && in_2[31] == temp[31])
												V = 1'b1;
											else V = 1'b0;
										end
									else	N = 1'b0; 
									if(in_1 > in_2)
										C = 1;
									else C = 1'b0;
								end
						end
				5'b01011:						// Compare Negated
						begin
							temp = in_1 + in_2;
							if (temp == 32'b0)
								Z = 1'b1;
							else
								begin
									if (temp[31] == 1'b1)
										begin
											N = 1'b1;
											if(in_1[31] != in_2[31] && in_2[31] == temp[31])
												V = 1'b1;
											else V = 1'b0;
										end
									else N = 1'b0;
									if(in_1 > in_2)
										C = 1;
									else C = 1'b0;
								end

						end
				5'b01100:						// Bitwise OR
						begin
							Y = in_1 | in_2;
							if (Y == 32'b0)
								Z = 1'b1;
							else Z = 1'b0;
						end

				5'b01101: Y = in_2;				// Move
				5'b01110:						// Bit Clear
						begin
							temp = in_1 & !in_2;
							if (temp == 32'b0)
								Z = 1'b1;
							else Z = 1'b0;
						end
				5'b01111: Y = !in_2;				// Move Not
				5'b10000: Y = in_2 + 4;				// 4-byte increment
				default: Y = in_2;					// use Move as default
			endcase
	endmodule