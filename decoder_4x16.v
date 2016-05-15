module Decoder_4to16(output [15:0] Out, input [0:3] In, input enable);
    assign Out[0]=  (~In[0]) & (~In[1]) &(~In[2]) & (~In[3]) & (enable) ;
    assign Out[1]=  (~In[0]) & (~In[1]) &(~In[2]) & (In[3]) & (enable) ;
    assign Out[2]=  (~In[0]) & (~In[1]) &(In[2]) & (~In[3]) & (enable) ;
    assign Out[3]=  (~In[0]) & (~In[1]) &(In[2])  & (In[3]) & (enable) ;
    assign Out[4]=  (~In[0]) & (In[1]) &(~In[2]) & (~In[3]) & (enable) ;
    assign Out[5]=  (~In[0]) & (In[1]) &(~In[2])  & (In[3]) & (enable) ;
    assign Out[6]=  (~In[0]) & (In[1]) &(In[2])  & (~In[3]) & (enable) ;
    assign Out[7]=  (~In[0]) & (In[1]) &(In[2])  & (In[3]) & (enable) ;
    assign Out[8]=  (In[0]) & (~In[1]) &(~In[2]) & (~In[3]) & (enable) ;
    assign Out[9]=  (In[0]) & (~In[1]) &(~In[2]) & (In[3]) & (enable) ;
    assign Out[10]= (In[0]) & (~In[1]) &(In[2]) & (~In[3]) & (enable) ;
    assign Out[11]= (In[0]) & (~In[1]) &(In[2])  & (In[3]) & (enable) ;
    assign Out[12]= (In[0]) & (In[1]) &(~In[2]) & (~In[3]) & (enable) ;
    assign Out[13]= (In[0]) & (In[1]) &(~In[2])  & (In[3]) & (enable) ;
    assign Out[14]= (In[0]) & (In[1]) &(In[2])  & (~In[3]) & (enable) ;
    assign Out[15]= (In[0]) & (In[1]) &(In[2])  & (In[3]) & (enable) ;
    
endmodule