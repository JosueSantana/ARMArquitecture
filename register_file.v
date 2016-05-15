module register_file(output [31:0] DataOutA, DataOutB, input [31:0] DataIn, input [3:0] AddressOutA, AddressOutB, AddressIn, input Enable, Clk, Clr);
  //wire [31:0] A_Out, B_Out;
  wire [15:0] D_Out;
  wire [31:0] R_Out[15:0];
  //reg [3:0] Address_A, Address_B;
  reg D_Enable;

  always @(Enable)
    if(!Enable)
    begin
      //$display("Entro al que deberia poner D_Enable = 1");
      assign D_Enable = 1'b1;
    end
    else
      assign D_Enable = 1'b0;
     
  Decoder_4to16 Decoder(D_Out, AddressIn, D_Enable);
  
  register32 Register0(R_Out[0], DataIn, ~(D_Out[0]), Clr, Clk);
  register32 Register1(R_Out[1], DataIn, ~(D_Out[1]), Clr , Clk);
  register32 Register2(R_Out[2], DataIn, ~(D_Out[2]), Clr, Clk);
  register32 Register3(R_Out[3], DataIn, ~(D_Out[3]), Clr , Clk);
  register32 Register4(R_Out[4], DataIn, ~(D_Out[4]), Clr , Clk);
  register32 Register5(R_Out[5], DataIn, ~(D_Out[5]), Clr , Clk);
  register32 Register6(R_Out[6], DataIn, ~(D_Out[6]), Clr , Clk);
  register32 Register7(R_Out[7], DataIn, ~(D_Out[7]), Clr , Clk);
  register32 Register8(R_Out[8], DataIn, ~(D_Out[8]), Clr , Clk);
  register32 Register9(R_Out[9], DataIn, ~(D_Out[9]), Clr , Clk);
  register32 Register10(R_Out[10], DataIn, ~(D_Out[10]), Clr , Clk);
  register32 Register11(R_Out[11], DataIn, ~(D_Out[11]), Clr , Clk);
  register32 Register12(R_Out[12], DataIn, ~(D_Out[12]), Clr , Clk);
  register32 Register13(R_Out[13], DataIn, ~(D_Out[13]), Clr , Clk);
  register32 Register14(R_Out[14], DataIn, ~(D_Out[14]), Clr , Clk);
  register32 Register15(R_Out[15], DataIn, ~(D_Out[15]), Clr , Clk);

  mux_16x1 Mux_A(DataOutA, AddressOutA, R_Out[0], R_Out[1], R_Out[2], R_Out[3], R_Out[4], R_Out[5], R_Out[6], R_Out[7], R_Out[8], R_Out[9], R_Out[10], R_Out[11], R_Out[12], R_Out[13], R_Out[14], R_Out[15]);
  mux_16x1 Mux_B(DataOutB, AddressOutB, R_Out[0], R_Out[1], R_Out[2], R_Out[3], R_Out[4], R_Out[5], R_Out[6], R_Out[7], R_Out[8], R_Out[9], R_Out[10], R_Out[11], R_Out[12], R_Out[13], R_Out[14], R_Out[15]);
  
endmodule
