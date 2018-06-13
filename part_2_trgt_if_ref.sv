/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off BLKSEQ */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off IMPLICIT */
`include "../../include/cs_common.svh"
interface part_2_trgt_if 
		    ( input   clk_i,         // utility clock
		      input   clk_0_h,	     // mission/functional clocks	      
		      input   clk_1_h,		      
		      input   clk_2_h,		      
		      input   clk_3_h,	    	   
		      		    		  
		      output [3:0] freeze_clk,  // block/release mission   

		      output wen0,           // downloaded signals
		      output [7:0] i_data0,  //
		                             //
		      output wen1,           //
		      output [7:0] i_data1,  //
		      			     //	 			     
		      output wen2,           //
		      output [7:0] i_data2,  //
		      
		      input valid,           //  uploaded signals 
		      input [7:0] o_data     //
		      );
		      
parameter N = 9;

bit        wen0;
bit  [7:0] i_data0;
bit        wen1;
bit  [7:0] i_data1;
bit        wen2;
bit  [7:0] i_data2;
bit  [8:0] joined_rcv_data[3:0];
bit  [8:0] joined_sut_data[3:0];
bit  [2:0] rcv_valid; 

   import shunt_dpi_pkg::*;
   shunt_fringe_if T_if;    
   cs_header_t      h;
   initial
     begin: registration
	bit Result;
	bit [7:0] data_in_byte;
	
	$display("Target registration: START ");
	//
	//TCP INIT
	Result = T_if.set_iam("TARGET");
	Result = T_if.set_simid(`SIM_ID);
	T_if.init_signals_db();
	T_if.print_signals_db();
	$display("i am : %s",T_if.who_iam());
	T_if.tcp_init();
	//REGISTRATION
	h.trnx_id    = `SIM_ID;
	Result=0;
	Result = T_if.target_registration_request(h,"TARGET");
	if (Result) T_if.print_reg_header(h);
	else  $display("REGISTRATION ERROR : %s,",T_if.who_iam());
	//
	T_if.print_signals_db();
	$display("Target registration: End ");
	//
     end : registration
   
//----------------------------------------------------------
// Every mission clock retreive data from initiator 
always @(clk_0_h)
     // tempor.....  get_data ( "initiator", "clk_0", 0);
     $finish;
 
 
always @(clk_1_h)
    // tempor.....   get_data ( "initiator", "clk_1", 1);
    $finish;

always @(clk_2_h)
    // tempor.....   get_data ( "initiator", "clk_2", 2);
    $finish;
// ... and export block output to initiator
always @(clk_3_h)
    // tempor.....   put_data("clk_3", "initiator",  joined_sut_data[3]);
     $finish;
//-----------------------------------------------------------
// on the edge of utility clock build array for further export to initiator
always @(posedge clk_i)
    joined_sut_data[3]   = {valid, o_data} ;

//...extract target module input values
always @(posedge clk_i)
  begin
      {wen0, i_data0} = rcv_valid[0] ?   joined_rcv_data[0] : {wen0, i_data0};
      {wen1, i_data1} = rcv_valid[1] ?   joined_rcv_data[1] : {wen1, i_data1};
      {wen2, i_data2} = rcv_valid[2] ?   joined_rcv_data[2] : {wen2, i_data2};
  end



//==============================================================
 
   task get_data (input string     source,
                  input string     event_name,
		  input integer    event_no);
   
   bit error = 0;
   rcv_valid[event_no] = 0;
   forever  begin
       if (rcv_valid[event_no] == 1'b1 || error == 1'b1)
           break;
       else
//          fork 
	     begin
//names ? ... syntax	     
                //?  shunt_get_bit_req (  event_name,source, joined_rcv_data[event_no]);	  
                  if (!error)
	             rcv_valid[event_no] = 1;
	          else 
	             $display("Simulation error"); 
             end
	     //begin
	     //    watchdog?   
	     //end	       
//          join_any		  
 end
 endtask  



  task put_data ( input string      event_name,
		  input string      destination,
                  input  bit[N-1:0] send_data
                  );
// ????? names ... syntax
   /* if (!  shunt_put_bit_req ( event_name, destination, send_data))*/ begin
       $display ($time, "  Transmit data error !!!");
       $finish;
     end		           
  
  endtask : put_data

//==============================================================
		      
endinterface : part_2_trgt_if
