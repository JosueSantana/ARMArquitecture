module arm_alu (output reg [31:0] Y, output reg V, C, N, Z, 
				input [31:0] in_1, in_2, input [3:0] opcode,
				input C_in );
	reg [31: 0] temp;
		always @ (in_1, in_2, C_in, opcode)
			case(opcode)
				4'b0000:						// Bitwise AND
						begin
							Y = in_1 & in_2;
							if (Y == 32'b0)
								Z = 1'b1;
							else
								Z = 1'b0;
						end
				4'b0001:						// Bitwise Exclusive OR 
						begin
							Y = (in_1 && !in_2) | (!in_1 && in_2);
							if (Y == 32'b0)
								Z = 1'b1;
							else
								Z = 1'b0;
						end
				4'b0010:						// Subtract
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

				4'b0011:						// Reverse Subtract
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

				4'b0100:						// Add
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

				4'b0101:						// Add with Carry
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
				4'b0110:						// Subtract with Carry
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
				4'b0111:						// Reverse Subtract with Carry
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
				4'b1000:						// Test
						begin
							temp = in_1 && in_2;
							if (temp == 32'b0)
								Z = 1'b1;
							else Z = 1'b0;
						end
				4'b1001:						// Test Equivalence
						begin
							temp = (in_1 && !in_2) | (!in_1 && in_2);
							if (temp == 32'b0)
								Z = 1'b1;
							else Z = 1'b0;
						end				 
				4'b1010:						// Compare
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
				4'b1011:						// Compare Negated
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
				4'b1100:						// Bitwise OR
						begin
							Y = in_1 | in_2;
							if (Y == 32'b0)
								Z = 1'b1;
							else Z = 1'b0;
						end

				4'b1101: Y = in_2;				// Move
				4'b1110:						// Bit Clear
						begin
							temp = in_1 & !in_2;
							if (temp == 32'b0)
								Z = 1'b1;
							else Z = 1'b0;
						end
				4'b1111: Y = !in_2;				// Move Not
			endcase
	endmodule