module top_9x1(        
                input        clk_i,
                input [12:0] clk,
                input [12:0] clk_h,
                input        reset_n,
		input [8:0]  wen,
		input [7:0] i_data0 ,
		input [7:0] i_data1 ,
		input [7:0] i_data2 ,

		input [7:0] i_data3 ,
		input [7:0] i_data4 ,
		input [7:0] i_data5 ,

		input [7:0] i_data6 ,
		input [7:0] i_data7 ,
		input [7:0] i_data8 ,

		input         ren,
		output        valid,
		output  [7:0] o_data, 
		output [12:0] freeze_clk  				                              
		);

logic              clk_i;
wire [7:0]         o_data_0, o_data_1, o_data_2, o_data;
wire [2:0]         valid0;
wire [12:0]        freeze_clk;

`ifndef SINGLE_SIM
assign freeze_clk[5:0]  = 0;
assign freeze_clk[10:9] = 0;
assign freeze_clk[12]   = 0;
`endif

`ifdef INITIATOR

part_i  part0(
               .i_clk    (.clk[9]),
               .i_clk0   (.clk[0]),
	       .i_clk1   (.clk[1]),
	       .i_clk2   (.clk[2]),
	       .i_rstn   (.reset_n),
	       .wen0	 (wen[0]),
	       .wen1	 (wen[1]),
	       .wen2	 (wen[2]),
	       .i_data0  (i_data0),
	       .i_data1  (i_data1),
	       .i_data2  (i_data2),
	       .valid	 (valid0[0]),
	       .o_data   (o_data_0)
                );
				

								
part_i  part1(
               .i_clk    (clk[10]),
               .i_clk0   (clk[3]),
	       .i_clk1   (clk[4]),
	       .i_clk2   (clk[5]),
	       .i_rstn   (reset_n),
	       .wen0	 (wen[3]),
	       .wen1	 (wen[4]),
	       .wen2	 (wen[5]),
	       .i_data0  (i_data3),
	       .i_data1  (i_data4),
	       .i_data2  (i_data5),
	       .valid	 (valid0[1]),
	       .o_data   (o_data_1)
                );
								
								

//replace part2								
part_2_init_if if_init_part_2(
               
                 .clk_i      (clk_i),     
		 .clk_0_h    (clk_h[6]),   
		 .clk_1_h    (clk_h[7]),   
		 .clk_2_h    (clk_h[8]),   
		 .clk_3_h    (clk_h[11]),   
		 .freeze_clk ({freeze_clk[11],freeze_clk[8:6]}), 
		 .wen0       (wen[6]),
		 .wen1       (wen[7]),
		 .wen2       (wen[8]),	
		 .i_data0    (i_data6),  		
		 .i_data1    (i_data7),   		
		 .i_data2    (i_data8),  		
		 .valid      (valid0[2]),   
		 .o_data     (o_data_2)
		      );



part_i part3(
               .i_clk    (clk[12]),
               .i_clk0   (clk[9]),
	       .i_clk1   (clk[10]),
	       .i_clk2   (clk[11]),
	       .i_rstn   (reset_n),
	       .wen0	 (valid0[0]),
	       .wen1	 (valid0[1]),
	       .wen2	 (valid0[2]),
	       .i_data0  (o_data_0),
	       .i_data1  (o_data_1),
	       .i_data2  (o_data_2),
	       .valid    (valid),
		.o_data  (o_data)
                );	


`endif

`ifdef TARGET
//replace top level environment
part_2_trgt_if if_trgt_part_2(
               
                 .clk_i      (clk_i),     
		 .clk_0_h    (clk_h[6]),   
		 .clk_1_h    (clk_h[7]),   
		 .clk_2_h    (clk_h[8]),   
		 .clk_3_h    (clk_h[11]),   
		 .freeze_clk ({freeze_clk[11],freeze_clk[8:6]} ), 
		 .wen0       (wen[6]),
		 .wen1       (wen[7]),
		 .wen2       (wen[8]),	
		 .i_data0    (i_data6),  		
		 .i_data1    (i_data7),   		
		 .i_data2    (i_data8),  		
		 .valid      (valid0[2]),   
		 .o_data     (o_data_2)
		      );
part_i  part2(
               .i_clk    (clk[11]),
               .i_clk0   (clk[6]),
	       .i_clk1   (clk[7]),
	       .i_clk2   (clk[8]),
	       .i_rstn   (reset_n),
	       .wen0	 (wen[6]),
	       .wen1	 (wen[7]),
	       .wen2	 (wen[8]),
	       .i_data0  (i_data6),
	       .i_data1  (i_data7),
	       .i_data2  (i_data8),
	       .valid	 (valid0[2]),
	       .o_data   (o_data_2)
                );



`endif



endmodule

