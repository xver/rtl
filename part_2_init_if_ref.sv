/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off BLKSEQ */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off IMPLICIT */
`include "../../include/cs_common.svh"
interface part_2_init_if (
                      input   clk_i,     //  utility clock
		      input   clk_0_h,	 //  mission/functional clocks	      
		      input   clk_1_h,	 //	      
		      input   clk_2_h,	 //	      
		      input   clk_3_h,   //
		      
		      output  freeze_clk, // block/release mission
                                              // clock generator, if 
                                              // data is not received
		      		  
		      input wen0,             // signals exported to target
		      input [7:0] i_data0,    //
		      
		      input wen1,             //
		      input [7:0] i_data1,    //
		      
		      input wen2,             //
		      input [7:0] i_data2,    //
		      
		      output valid,           //  imported from target
		      output [7:0] o_data     //
		      );
		      
parameter N = 9;
		      
bit        valid;
bit  [7:0] o_data;
bit  [8:0] joined_rcv_data[3:0];
bit  [3:0] rcv_valid;
bit  [3:0] freeze_clk = 0;
bit  [8:0] joined_sut_data[3:0];

   import shunt_dpi_pkg::*;
   shunt_fringe_if I_if; 
   bit 	   Result;
   cs_header_t      h;
   string  S;
   real    Temp;
   
   
   string 	target_db_name;  

   initial
     begin: registration
	longint Temp1;
	bit 	is_free_entry;
	int 	index;
	bit [7:0] data_in;
	
	$display("Initiator registration: START");
	//TCP INIT
	is_free_entry = 0;
	Result = I_if.set_iam("INITIATOR");
	Result = I_if.set_simid(`SIM_ID);
	Result = I_if.init_targets_db();
	//REGISTRATION
	I_if.Target.n_signals = 10;
	Result = I_if.print_targets_db();
	I_if.init_signals_db();
	I_if.print_signals_db();
	$display("i am : %s",I_if.who_iam());
	I_if.tcp_init();

	//Target registration
	index =  I_if.check_idle_entry_targets_db();
	$display("i am : %s free_entry index=%0d ,",I_if.who_iam(),index);
	//if(is_free_entry && I_if.check_free_entry_targets_db()>=0)  
	//
	while(index >= 0)
	  begin
	     Result=0;
	     Result = I_if.initiator_registration(h);
	     if (Result) I_if.print_reg_header(h);
	     else begin
	        index = -1;
		$display("REGISTRATION ERROR : %s,",I_if.who_iam());
	     end
	     if(index>=0) index =  I_if.check_idle_entry_targets_db();
	     //
	  end // while (index >= 0)
	Result = I_if.print_targets_db();
	$display("Initiator registration: End");
	//
     end : registration
   
   
//----------------------------------------------------------
//  Export related partiotion inputs to target
always @(clk_0_h)
  // tempor.....        put_data("clk_0", "target", joined_sut_data[0]);
  $finish;

always @(clk_1_h)
   // tempor.....    put_data("clk_1", "target", joined_sut_data[1]);
    $finish;

always @(clk_2_h)
//   // tempor.....    put_data("clk_2", "target", joined_sut_data[2]);
   $finish;

// Every mission clock retreive data from target 
always @(clk_3_h)
      $finish;
     // tempor.....get_data ( "target", "clk_3", 3);

//----------------------------------------------------------


// on the edge of utility clock build array for further export to target
always @(posedge clk_i)
   begin
    joined_sut_data[0]  = {wen0, i_data0};
    joined_sut_data[1]  = {wen1, i_data1};
    joined_sut_data[2]  = {wen2, i_data2};
   end

//...extract partial signal values from received array(s)
always @(posedge clk_i)
    {valid, o_data} = rcv_valid[3] ? joined_rcv_data[3] :  {valid, o_data};                                    



//==============================================================
 /*
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
                  shunt_get_bit_req (  event_name,source, joined_rcv_data[event_no]); 		   
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
*/
/*

  task put_data ( input string      event_name,
		  input string      destination,
                  input  bit[N-1:0] send_data
                  );
// ????? names ... syntax
     if (!  shunt_put_bit_req ( event_name, destination, send_data))   begin
       $display ($time, "  Transmit data error !!!");
       $finish;
     end		           
  
  endtask : put_data
*/
//==============================================================
/*
task wait_clk_i(input integer clock_num, input integer current_cnt);
   forever
     if (current_cnt + clock_num > i_clk_cnt)
         break;
     
 endtask: wait_clk_i
*/		 		      		      
		      
		      
endinterface : part_2_init_if
