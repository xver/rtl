interface top_if (

 input               clk,            
 input               clk_h,          
 input               reset_n,        
 
 input [8:0]		 wen ,           
 input [8:0]		 i_data0,       
 input [8:0]	     i_data1,        
 input [8:0]		 i_data2,        

 input [8:0]		 i_data3,        
 input [8:0]		 i_data4,        
 input [8:0]		 i_data5,        

 input [8:0]		 i_data6,        
 input [8:0]		 i_data7,        
 input [8:0]		 i_data8,        

 input		         ren,            
 output		         valid,          
 output [8:0]		 o_data,                       
 output		         freeze_clk,   
								
output                clk_t,          
output                clk_h_t,        
output                reset_n_t,      

output [8:0]		  wen_t,          
output [8:0]		  i_data0_t,      
output [8:0]	      i_data1_t,      
output [8:0]		  i_data2_t,      

output [8:0]		  i_data3_t,      
output [8:0]		  i_data4_t,     
output [8:0]		  i_data5_t,      

output [8:0]		  i_data6_t,      
output [8:0]		  i_data7_t,      
output [8:0]		  i_data8_t,      

output 		          ren_t,          
input 		          valid_t,        
input  [8:0]		  o_data_t,                       
input		          freeze_clk_t   
      );
				  

assign clk_t = clk;          
assign clk_h_t = clk_h;,        
assign reset_n_t = reset_;      

assign wen_t = wen;          
assign i_data0_t = i_data0;      
assign i_data1_t = i_data1;      
assign i_data2_t = i_data2;      

assign i_data3_t = i_data3;      
assign i_data4_t = i_data4;     
assign i_data5_t = i_data5;      

assign i_data6_t = i_data6;      
assign i_data7_t = i_data7;      
assign i_data8_t = i_data8;      

assign  ren_t   =   ren;           
assign  valid   =   valid_t;   
assign  o_data  =   o_valid_t;                   
assign  freeze_clk = 0;   

				  
				  
endinterface
