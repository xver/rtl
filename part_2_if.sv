/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off BLKSEQ */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off IMPLICIT */

interface part_2_if ( input clk_i,
// design clocks/freeze		   
		      input   clk_0_h,
		      input   clk_0_s,
		      output  freeze_clk_0,
		      input   clk_1_h,
		      input   clk_1_s,
		      output  freeze_clk_1,
		      input   clk_2_h,
		      input   clk_2_s,
		      output  freeze_clk_2,
		      
		      input   clk_3_h,
		      input   clk_3_s,
		      output  freeze_clk_3,
`ifdef SERVER			 
		  
		   input wen0_s,
		   input [7:0] i_data0_s,
`endif
`ifdef CLIENT		   
        	   output  wen0_c,
        	   output  [7:0] i_data0_c,
`endif
`ifdef SERVER			 
		  
		   input wen1_s,
		   input [7:0] i_data1_s,
`endif
`ifdef CLIENT		   
        	   output wen1_c,
        	   output [7:0] i_data1_c,
`endif
`ifdef SERVER			 
		  
		   input wen2_s,
		   input [7:0] i_data2_s,
`endif
`ifdef CLIENT		   
        	   output wen2_c,
        	   output [7:0] i_data2_c,
`endif
`ifdef SERVER			 
		  
		   output valid_s,
		   output [7:0] o_data_s
		   
`endif
`ifdef CLIENT		     
		     input  valid_c,
		     input  [7:0] o_data_c
		     
`endif	    
                      );

parameter client_id = "client";
parameter server_id = "server";
parameter m = 9;


integer  time_val = 0;   // temporary
integer  i_clk_cnt = 0;

`ifdef SERVER                    
bit        valid_s;
bit  [7:0] o_data_s;
bit  [8:0] joined_rcv_data_s[3:0];
bit  [8:0] joined_sut_data_s[3:0];       
`endif


`ifdef CLIENT		     
bit        wen0_c;
bit  [7:0] i_data0_c;
bit        wen1_c;
bit  [7:0] i_data1_c;
bit        wen2_c;
bit  [7:0] i_data2_c;
bit  [8:0] joined_rcv_data_c[3:0];
bit  [8:0] joined_sut_data_c[3:0];
`endif
   
bit  [3:0] rcv_valid;
bit  [3:0] freeze_clk;
//debugging
bit   [8:0] shuntbox[3:0];
bit   rcvd_err[4];


always @(posedge clk_i)
  i_clk_cnt <= i_clk_cnt + 1;


`ifdef SERVER    

always @(clk_0_s)
     put_data(0, client_id, joined_sut_data_s[0]);


always @(clk_1_s)
     put_data(1, client_id, joined_sut_data_s[1]);


always @(clk_2_s)
     put_data(2, client_id, joined_sut_data_s[2]);


always @(clk_3_h)
     get_data (3, client_id);


always @(posedge clk_i)
    joined_sut_data_s[0]  = {wen0_s, i_data0_s};
   

always @(posedge clk_i)
      {valid_s, o_data_s} = rcv_valid[3] ? joined_rcv_data_s[3] :
                                             {valid_s, o_data_s};
`endif

`ifdef CLIENT

always @(clk_0_s)
     get_data (0, server_id);


always @(clk_1_s)
     get_data (1, server_id);


always @(clk_2_s)
     get_data (2, server_id);


always @(clk_3_h)
     put_data(3, server_id,  joined_sut_data_c[3]);


always @(posedge clk_i)
    joined_sut_data_c[3]   = {valid_c, o_data_c} ;

always @(posedge clk_i)
      {wen0_c, i_data0_c} = rcv_valid[0] ?   joined_rcv_data_c[0] : 
                                             {wen0_c, i_data0_c};
`endif

task put_data  (input integer      event_no,
	        input string      destination_id,
                input bit [m-1:0] joined_sut_data
		 );
     shunt_put(event_no, destination_id, time_val,  joined_sut_data[event_no], 1'b0); 
     $display ("Put vector  %h ---  # %d to remote %s", joined_sut_data[event_no], event_no, destination_id);

endtask : put_data

task get_data( input integer  event_no,
               input string  source_id
	       
               );
forever   
     if (!rcv_valid[event_no]) begin
          freeze_clk[event_no] = 1; 
`ifdef CLIENT
	  shunt_get(event_no, server_id, time_val, joined_rcv_data_c[event_no], rcvd_err[event_no]);
`endif 
`ifdef  SERVER
	  shunt_get(event_no, client_id, time_val, joined_rcv_data_c[event_no], rcvd_err[event_no);
`endif
	          
     end else begin
             freeze_clk[event_no] = 0;
	     wait_clk_i(1, i_clk_cnt);
	     rcv_valid[event_no] = 0;
	     break;	      	 
     end   
     $display ("Received vector  # %d from remote %s",  event_no, source_id);

endtask : get_data


function void shunt_get( input integer event_no,
                         input string  source_id,
                         input integer time_v,
			 output bit[m-1:0] rcvd_data,
			 output bit error  //?
		          );
`ifdef SERVER  
 joined_rcv_data_s[event_no] = shuntbox[event_no];
 rcv_valid[event_no] = 1'b1;
`endif
`ifdef CLIENT 
 joined_rcv_data_c[event_no] = shuntbox[event_no];
 rcv_valid[event_no] = 1'b1;
`endif 

endfunction: shunt_get
/* verilator lint_off ENDLABEL */
function void shunt_put ( input integer event_no, 
                          input string  destination_id,
			  input integer time_v, 
                          input bit [m-1:0] send_data,
			  input bit         error
			  );

shuntbox[event_no] = send_data;
endfunction: shunt_write


task wait_clk_i(input integer clock_num, input integer current_cnt);
   forever
     if (current_cnt + clock_num > i_clk_cnt)
         break;
     
endtask:wait_clk
		    
		    
endinterface : part_2_if
		    
		     
