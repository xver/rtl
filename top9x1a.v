`define TOP_IF
`define SIMPLE_SINGLE0
`define SIMPLE_SINGLE1
`define SIMPLE_SINGLE2
`define SIMPLE_SINGLE3

`define PART_SINGLE0
`define PART_SINGLE1
`define PART_SINGLE2
`define PART_SINGLE3


module top_9x1( 
                input        clk_i,       
                input [12:0] clk,
                input [12:0] clk_h,
                input        reset_n,

		        input [8:0] wen,
		        input [7:0] i_data0 ,
	            input [7:0] i_data1 ,
		        input [7:0] i_data2 ,

		        input [7:0] i_data3 ,
		        input [7:0] i_data4 ,
		        input [7:0] i_data5 ,

		        input [7:0] i_data6 ,
		        input [7:0] i_data7 ,
		        input [7:0] i_data8 ,

		        input        ren,
		        output       valid,
		        output[7:0]  o_data,                
		        output[3:0] freeze_clk
				 );

parameter                   clock_number = 13;
logic                       clk_i;
wire [7:0]                  o_data_0, o_data_1, o_data_2, o_data;
wire [7:0]                  o_data_0_if, o_data_1_if, o_data_2_if, o_data_if;
wire [2:0]                  valid0;
wire [3:0]                  freeze_clk = 0;

`ifdef TOP_IF
top_if_a         top_if (

                .clk            (clk),
                .clk_h          (clk_h),
                .reset_n        (reset_n),

		        .wen            (wen),
		        .i_data0        (i_data0) ,
	            .i_data1        (i_data1) ,
		        .i_data1        (i_data1) ,

		        .i_data3        (i_data3) ,
		        .i_data4        (i_data4) ,
		        .i_data5        (i_data5) ,

		        .i_data5        (i_data5) ,
		        .i_data7        (i_data7) ,
		        .i_data8        (i_data8) ,

		        .ren            (ren),
		        .valid          (valid),
		        .o_data         (o_data),                
		        .freeze_clk     (freeze_clk)
								
                .clk_t          (clk_t),
                .clk_h_t        (clk_h_t),
                .reset_n_t      (reset_n_t),

		        .wen_t          (wen_t),
		        .i_data0_t      (i_data0_t),
	            .i_data1_t      (i_data1_t),
		        .i_data1_t      (i_data1_t),

		        .i_data3_t      (i_data3_t),
		        .i_data4_t      (i_data4_t),
		        .i_data5_t      (i_data5_t),

		        .i_data5_t      (i_data5_t),
		        .i_data7_t      (i_data7_t),
		        .i_data8_t      (i_data8_t),

		        .ren_t          (ren_t),
		        .valid_t        (valid_t),
		        .o_data_t       (o_data_t),                
		        .freeze_clk_t   (freeze_clk_t)
 
 );
`endif

`ifdef SIMPLE_SINGLE0
part_if_a part0_if_a  (
               .clk_i    (clk_i),        
               .i_clk    (clk_t[9]),
               .i_clk0   (clk_t[0]),
	           .i_clk1   (clk_t[1]),
	           .i_clk2   (clk_t[2]),
	           .i_rstn   (reset_n_t),
	           .wen0	 (wen_t[0]),
	           .wen1	 (wen_t[1]),
	           .wen2	 (wen_t[2]),
	           .i_data0  (i_data0_t),
	           .i_data1  (i_data1_t),
	           .i_data2  (i_data2_t),
	           .valid	 (valid0_t[0]),
	           .o_data   (o_data_0_t),
			   
               .i_clk_p    (clk_if[9]),
               .i_clk0_p   (clk_if[0]),
	           .i_clk1_p   (clk_if[1]),
	           .i_clk2_p   (clk_if[2]),
	           .i_rstn_p   (reset_n_if),
	           .wen0_p	   (wen_if[0]),
	           .wen1_p	   (wen_if[1]),
	           .wen2_p	   (wen_if[2]),
	           .i_data0_p  (i_data0_if),
	           .i_data1_p  (i_data1_if),
	           .i_data2_p  (i_data2_if),
	           .valid_p	   (valid0_if[0]),
	           .o_data_p   (o_data_0_if)

                       );	
`endif	


`ifdef  SIMPLE_SINGLE1
part_if_a part1_if_a  (
               .clk_i      (clk_i),
               .i_clk_p    (clk_if[10]),
               .i_clk0_p   (clk_if[3]),
	           .i_clk1_p   (clk_if[4]),
	           .i_clk2_p   (clk[5]),
	           .i_rstn_p   (reset_n_if),
	           .wen0_p	   (wen_if[3]),
	           .wen1_p	   (wen_if[4]),
	           .wen2_p	   (wen_if[5]),
	           .i_data0_p  (i_data3_if),
	           .i_data1_p  (i_data4_if),
	           .i_data2_p  (i_data5_if),
	           .valid_p    (valid0_if[1]),
	           .o_data_p   (o_data_1_if),
			   
               .i_clk      (clk_t[10]),
               .i_clk0     (clk_t[3]),
	           .i_clk1     (clk_t[4]),
	           .i_clk2     (clk_t[5]),
	           .i_rstn     (reset_n_t),
	           .wen0	   (wen_t[3]),
	           .wen1	   (wen_t[4]),
	           .wen2	   (wen_t[5]),
	           .i_data0    (i_data3_t),
	           .i_data1    (i_data4_t),
	           .i_data2    (i_data5_t),
	           .valid      (valid0[1]_t),
	           .o_data     (o_data_1_t)			   
)
`endif		

`ifdef SIMPLE_SINGLE3	
part_if_a part3_if_a  (
               .clk_i    (clk_i),
               .i_clk    (clk_t[12]),
               .i_clk0   (clk_t[9]),
	           .i_clk1   (clk_t[10]),
	           .i_clk2   (clk_t[11]),
	           .i_rstn   (reset_n_t),
	           .wen0	 (valid0_t[0]),
		       .wen1	 (valid0_t[1]),
		       .wen2	 (valid0_t[2]),
		       .i_data0  (o_data_0_t),
		       .i_data1  (o_data_1_t),
		       .i_data2  (o_data_2_t),
		       .valid    (valid_t),
		       .o_data   (o_data_t),
			   
               .i_clk_p    (clk_if[12]),
               .i_clk0_p   (clk_if[9]),
	           .i_clk1_p   (clk_if[10]),
	           .i_clk2_p   (clk_if[11]),
	           .i_rstn_p   (reset_n_if),
	           .wen0_p	   (valid0_if[0]),
		       .wen1_p	   (valid0_if[1]),
		       .wen2_p	   (valid0_if[2]),
		       .i_data0_p  (o_data_0_if),
		       .i_data1_p  (o_data_1_if),
		       .i_data2_p  (o_data_2_if),
		       .valid_p    (valid_if),
		       .o_data_p   (o_data_if),			   
);

`endif



		

`ifdef SIMPLE_SINGLE2
part_if_a part2_if_a  (
           .clk_i    (clk_i),
           .i_clk    (clk_t[11]),
           .i_clk0   (clk_t[6]),
	       .i_clk1   (clk_t[7]),
	       .i_clk2   (clk_t[8]),
	       .i_rstn   (reset_n_t),
	       .wen0     (wen_t[6]),
	       .wen1     (wen_t[7]),
	       .wen2     (wen_t[8]),
	       .i_data0  (i_data6_t),
	       .i_data1  (i_data7_t),
	       .i_data2  (i_data8_t),
	       .valid    (valid0_t[2]),
	       .o_data   (o_data_2_t),
		   
           .i_clk_p    (clk_if[11]),
           .i_clk0_p   (clk_if[6]),
	       .i_clk1_p   (clk_if[7]),
	       .i_clk2_p   (clk_if[8]),
	       .i_rstn_p   (reset_n_if),
	       .wen0_p     (wen_if[6]),
	       .wen1_p     (wen_if[7]),
	       .wen2_p     (wen_if[8]),
	       .i_data0_p  (i_data6_if),
	       .i_data1_p  (i_data7_if),
	       .i_data2_p  (i_data8_if),
	       .valid_p    (valid0_if[2]),
	       .o_data_p   (o_data_2_if)		   
)
`endif

`ifdef PART_SINGLE0
part_i  part0(
               .i_clk    (clk_if[9]),
               .i_clk0   (clk_if[0]),
	           .i_clk1   (clk_if[1]),
	           .i_clk2   (clk_if[2]),
	           .i_rstn   (reset_n_if),
	           .wen0	 (wen_if[0]),
	           .wen1	 (wen_if[1]),
	           .wen2	 (wen_if[2]),
	           .i_data0  (i_data0_if),
	           .i_data1  (i_data1_if),
	           .i_data2  (i_data2_if),
	           .valid	 (valid0[0]_if),
	           .o_data   (o_data_0_if)
                );
				
`endif
	   
`ifdef PART_SINGLE1
part_i  part1(
               .i_clk    (clk_if[10]),
               .i_clk0   (clk_if[3]),
	           .i_clk1   (clk_if[4]),
	           .i_clk2   (clk_if[5]),
	           .i_rstn   (reset_n_if),
	           .wen0	 (wen_if[3]),
	           .wen1	 (wen_if[4]),
	           .wen2	 (wen_if[5]),
	           .i_data0  (i_data3_if),
	           .i_data1  (i_data4_if),
	           .i_data2  (i_data5_if),
	           .valid    (valid0_if[1]),
	           .o_data   (o_data_1_if)
                );
				
`endif
				
`ifdef PART_SINGLE3
part_i part3(
               .i_clk    (clk_if[12]),
               .i_clk0   (clk_if[9]),
	           .i_clk1   (clk_if[10]),
	           .i_clk2   (clk_if[11]),
	           .i_rstn   (reset_n_if),
	           .wen0	 (valid0_if[0]),
		       .wen1	 (valid0_if[1]),
		       .wen2	 (valid0_if[2]),
		       .i_data0  (o_data_0_if),
		       .i_data1  (o_data_1_if),
		       .i_data2  (o_data_2_if),
		       .valid    (valid_if),
		       .o_data   (o_data_if)
                );	
`endif

`ifdef PART_SINGLE2
part_i  part2(
           .i_clk    (clk_if[11]),
           .i_clk0   (clk_if[6]),
	       .i_clk1   (clk_if[7]),
	       .i_clk2   (clk_if[8]),
	       .i_rstn   (reset_n_if),
	       .wen0     (wen_if[6]),
	       .wen1     (wen_if[7]),
	       .wen2     (wen_if[8]),
	       .i_data0  (i_data6_if),
	       .i_data1  (i_data7_if),
	       .i_data2  (i_data8_if),
	       .valid    (valid0_if[2]),
	       .o_data   (o_data_2_if)
                );
`endif

endmodule

