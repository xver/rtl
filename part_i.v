/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
module part_i (
               input        i_clk,
               input        i_clk0,
	       input        i_clk1,
	       input        i_clk2,
	       input        i_rstn,
	       input        wen0,
	       input        wen1,
	       input        wen2,
	       input  [7:0] i_data0,
	       input  [7:0] i_data1,
	       input  [7:0] i_data2,
	       output       valid,
	       output [7:0] o_data
               );
		
   reg 			    rstn0, rstn1, rstn2;
   reg 			    rstn0_d, rstn1_d, rstn2_d;
   reg 			    rstn,  rstn_d;
   wire 		    empty0, empty1, empty2;
   wire [7:0] 		    o_data0, o_data1, o_data2;
   wire [7:0] 		    o_wfull0, o_wfull1, o_wfull2;
   reg 			    ren0, ren1, ren2, valid;
   reg [7:0] 		    o_data;
  
   always @(posedge i_clk)
     {rstn, rstn_d} <= {rstn_d, i_rstn};
   
   always @(posedge i_clk0)
     {rstn0, rstn0_d} <= {rstn0_d, i_rstn};
   
   always @(posedge i_clk1)
     {rstn1, rstn1_d} <= {rstn1_d, i_rstn};
   
   always @(posedge i_clk2)
     {rstn2, rstn2_d} <= {rstn2_d, i_rstn};
   
   always @(posedge i_clk or negedge rstn)
     if (~rstn) begin
	valid <= 0;
	ren0  <= 0;
	ren1  <= 0;
	ren2  <= 0;  
     end
     else if (~(empty0 | empty1 | empty2)) begin
        o_data <= o_data0 + o_data1*o_data2;
        valid <= 1;	
        ren0  <= 1;
        ren1  <= 1;
        ren2  <= 1;		
     end	else begin	  
	valid <= 0;
	ren0  <= 0;
        ren1  <= 0;
        ren2  <= 0;	
     end
   
   
   fifo1  fifo_inst0   
     (
      .rdata  (o_data0),
      .wfull  (o_wfull0),
      .rempty (empty0),
      .wdata  (i_data0),
      .winc   (wen0),
      .wclk	  (i_clk0),
      .wrst_n	(rstn0),
      .rinc   (ren0),
      .rclk   (i_clk),
      .rrst_n (rstn)
      );		
   
   fifo1  fifo_inst1   
     (.rdata  (o_data1),
      .wfull  (o_wfull1),
      .rempty (empty1),
      .wdata  (i_data1),
      .winc   (wen1),
      .wclk	  (i_clk1),
      .wrst_n	(rstn1),
      .rinc   (ren1),
      .rclk   (i_clk),
      .rrst_n (rstn)
      );
   
   fifo1  fifo_inst2   
     (.rdata  (o_data2),
      .wfull  (o_wfull2),
      .rempty (empty2),
      .wdata  (i_data2),
      .winc   (wen2),
      .wclk	  (i_clk2),
      .wrst_n	(rstn2),
      .rinc   (ren2),
      .rclk   (i_clk),
      .rrst_n (rstn)
	);			
   
endmodule

/* verilator lint_on WIDTH */
/* verilator lint_on UNUSED */