/*verilator lint_off UNUSED */
/* verilator lint_off PINMISSING */
/* verilator lint_off UNDRIVEN */
module  top_sim(
	       input	       clk_i
	       );



 reg  [8:0]  wen;
 reg         wen0, wen1, wen2, wen3,  wen4, wen5,  wen6,  wen7, wen8; 
 reg         wen_d0, wen_d1, wen_d2, wen_d3,  wen_d4, wen_d5,  wen_d6,  wen_d7, wen_d8;
 reg         wen_ds0, wen_ds1, wen_ds2, wen_ds3,  wen_ds4, wen_ds5,  wen_ds6,  wen_ds7, wen_ds8;
  reg [7:0]  din0, din1, din2, din3, din4, din5, din6, din7, din8;
 reg         reset;
 reg         ren;
 wire        o_valid;
 wire [12:0] clk;
 wire [12:0] clk_h;
 wire [7:0]  o_data;
 wire        freeze;
 bit [5:0]   wcnt = 0 ;
 integer     rcnt = 0;
 bit         wen_trigg;
 wire [12:0] freeze_i;
 

 
 
 



always @(*)
 reset = rcnt > 40;


event_scheduler             clk_gen (
                                     .clk_i   (clk_i),
                                     .freeze  (freeze),
				     .clk     (clk),
				     .clk_h   (clk_h)
                                    );

always @(*)
  wen =  {wen8, wen7, wen6, wen5, wen4,
	       wen3, wen2, wen1, wen0};

always @(posedge clk_i)   
    begin
	$display ("for Clock # 0%d cnt %d",clk_i, wcnt );
	wcnt <= wcnt + 1;
     end


always @(posedge clk_i)
   
     begin
	$display ("for Clock # 0%d cnt %d",clk_i, rcnt );
	rcnt <= rcnt + 1;
     end

top_9x1        dut(
                 .clk_i       (clk_i),       
                 .clk         (clk),
                 .clk_h       (clk_h),
                 .reset_n     (reset),
`ifndef target		 
		 .wen         (wen),
		 .i_data0     (din0),
		 .i_data1     (din1),
		 .i_data2     (din2),

		 .i_data3     (din3),
		 .i_data4     (din4),
		 .i_data5     (din5),

		 .i_data6     (din6),
	         .i_data7     (din7),
		 .i_data8     (din8),

		 .ren	      (ren),
		 .valid       (o_valid),
		 .o_data      (o_data),
`endif		 
		 .freeze_clk  (freeze_i)
                  );
		  
		  
assign freeze = |(freeze_i);


always @(posedge clk_i)
`ifdef target
$display ("----------------TARGET FREEZE CLK VECTOR = %b --------------------", freeze_i);
`endif
`ifdef initiator
  $display ("----------------INITIATOR FREEZE CLK VECTOR = %b --------------------", freeze_i);
`endif


always @(posedge clk_i)
 $display("output = %h", o_data);


//-******************* Input Vectors **********************************-//
always @(posedge clk[12])
 ren <= o_valid;

//assign clk = clk_gen.clk;

always @(posedge clk[0])
  if (reset == 0)
  din0 <= 0;
  else
  din0 <= din0+1;

always @(posedge clk[1])
  if (reset == 0)
     din1 <= 0;
  else
    din1 <= din1+1;

always @(posedge clk[2])
  if (reset == 0)
     din2 <= 0;
  else
    din2 <= din2+1;

always @(posedge clk[3])
  if (reset == 0)
     din3 <= 0;
  else
    din3 <= din3+1;

always @(posedge clk[4])
  if (reset == 0)
     din4 <= 0;
  else
    din4 <= din4+1;

always @(posedge clk[5])
  if (reset == 0)
     din5 <= 0;
  else
    din5 <= din5+1;

always @(posedge clk[6])
  if (reset == 0)
     din6 <= 0;
  else
    din6 <= din6+1;

always @(posedge clk[7])
  if (reset == 0)
     din7 <= 0;
  else
    din7 <= din7+1;

always @(posedge clk[8])
  if (reset == 0)
     din8 <= 0;
  else
    din8 <= din8+1;

/* verilator lint_off STMTDLY */

always @(posedge clk_i) begin
     wen_trigg <= wcnt > 31;
end

//resync to input clocks
always @(posedge clk[0])
  wen_d0 <= wen_trigg;

always @(posedge clk[1])
  wen_d1 <= wen_trigg;

always @(posedge clk[2])
  wen_d2 <= wen_trigg;

always @(posedge clk[3])
  wen_d3 <= wen_trigg;

always @(posedge clk[4])
  wen_d4 <= wen_trigg;

always @(posedge clk[5])
  wen_d5 <= wen_trigg;

always @(posedge clk[6])
  wen_d6 <= wen_trigg;

always @(posedge clk[7])
  wen_d7 <= wen_trigg;

always @(posedge clk[8])
  wen_d8 <= wen_trigg;



always @(posedge clk[0]) begin
    wen_ds0 <=   wen_d0;
       wen0 <= ~wen_ds0 && wen_d0;
end
always @(posedge clk[1]) begin
    wen_ds1 <=   wen_d1;
       wen1 <= ~wen_ds1 && wen_d1;
end
always @(posedge clk[2]) begin
    wen_ds2 <=   wen_d2;
       wen2 <= ~wen_ds2 && wen_d2;
end
always @(posedge clk[3]) begin
    wen_ds3 <=   wen_d3;
       wen3 <= ~wen_ds3 && wen_d3;
end
always @(posedge clk[4]) begin
    wen_ds4 <=   wen_d4;
       wen4 <= ~wen_ds4 && wen_d4;
end
always @(posedge clk[5]) begin
    wen_ds5 <=   wen_d5;
       wen5 <= ~wen_ds5 && wen_d5;
end
always @(posedge clk[6]) begin
    wen_ds6 <=   wen_d6;
       wen6 <= ~wen_ds6 && wen_d6;
end
always @(posedge clk[7]) begin
    wen_ds7 <=   wen_d7;
       wen7 <= ~wen_ds7 && wen_d7;
end
always @(posedge clk[8]) begin
    wen_ds8 <=   wen_d8;
       wen8 <= ~wen_ds8 && wen_d8;
end

endmodule /*-----/\----- EXCLUDED -----/\----- */
