interface  part_if_a  (
input               clk_i,    
input               i_clk,   
input               i_clk0,   
input	            i_clk1,  
input	            i_clk2,   
input	            wen0,	   
input	            wen1,	  
input	            wen2,	   
input  [8:0]	    i_data0,  
input  [8:0]	    i_data1,  
input  [8:0]	    i_data2,  
ouput	            valid,   
output [8:0]	    o_data,   
			   

output              i_clk_p,     
output              i_clk0_p,      
output	            i_clk1_p,      
output	            i_clk2_p,      
output	            i_rstn_p,     
output	            wen0_p, 	   
output	            wen1_p, 	   
output	            wen2_p, 	   
output [8:0]	    i_data0_p,     
output [8:0]	    i_data1_p,     
output [8:0]	    i_data2_p,     
input	            valid_p,       
input  [8:0]	    o_data_p     	   



assign      clk_i_p    = clk_i;    
assign      i_clk_p    = i_clk;    
assign      i_clk0_p   = i_clk0;    
assign	    i_clk1_p   = i_clk1;      
assign	    i_clk2_p   = i_clk2;      
assign	    i_rstn_p   = i_rstn;     
assign	    wen0_p     = wen0; 	   
assign	    wen1_p     = wen1	   
assign	    wen2_p     = wen2; 	   
assign	    i_data0_p  = i_data0;     
assign	    i_data1_p  = i_data1;    
assign	    i_data2_p  = i_data2;     
assign	    valid      = valid_p;          
assign	    o_data     = o_valid_p;  

endinterface
