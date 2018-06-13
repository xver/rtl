/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off BLKSEQ */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off IMPLICIT */
/* verilator lint_off MULTIDRIVEN */
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
parameter wait_event = 0;
parameter  check_lut = 1;
		      
bit        valid;
bit  [7:0] o_data;
bit  [8:0] joined_rcv_data[3:0];
bit  [3:0] rcv_valid;
bit  [3:0] freeze_clk = 0;
bit  [8:0] joined_sut_data[3:0];
string     source;      // will use later to compare   
string     event_name;  // will use later to compare 
integer    event_no;
integer    watchdog;
reg        fsm_get;
reg        fsm_get_enable;

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
	//$display("i am : %s free_entry index=%0d ,",I_if.who_iam(),index);
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

always @(posedge clk_0_h)
     begin
		 $display ( "-------    INITIATOR -------to-------- TARGET send data_clk_0 vector = %h", joined_sut_data[0]);
		 put_data(0, "data_clk_0", "TARGET");
         //$finish;
     end
/* 
always @(posedge clk_1_h)
    begin
         put_data(1, "data_clk_1", "TARGET");
 	     $display ("INITIATOR  to TARGET send data_clk_1 vector = %h", joined_sut_data[1]);
         //$finish;
    end  

always @(posedge clk_2_h)
   begin
         put_data(2, "data_clk_2", "TARGET");
   	     $display ( "INITIATOR  to TARGET send data_clk_1 vector = %h", joined_sut_data[2]);
         //$finish;
   end
*/
// Every mission clock retreive data from target 
/* verilator lint_off COMBDLY */
/*
always @(posedge clk_3_h)    
   begin
      source <= "TARGET";
      event_no <= 3;
      event_name <= "data_clk_3";
      fsm_get <= wait_event;
      fsm_get_enable <= 1;
	  freeze_clk[event_no] <= 1;
   // get_data ( "TARGET", "clk_3", 3);
   end


always @(posedge clk_i)begin
$display ("------------INITIATOR PROCEEDS ------event name %s", event_name); 
case(fsm_get)
wait_event :   begin
                 watchdog <= 0;
                 rcv_valid[event_no] <= 0;
                 fsm_get <= fsm_get_enable ? check_lut : fsm_get;
               end  
check_lut  :  begin
                 I_if.fringe_get();
                 if  (I_if.signals_db[event_no].data_valid) begin
                      joined_rcv_data[event_no] <= I_if.data_payloads_db[event_no];
                      rcv_valid[event_no] <= 1;
                      I_if.signals_db[event_no].data_valid <= 0;
                      fsm_get <=  wait_event; 
                      fsm_get_enable <= 0;
					  freeze_clk[event_no] <= 0;
                      $display( "---------- INITIATOR got data = %h from %s clocked with %s", joined_rcv_data[event_no], source, event_name);                      

                 end
                 else  begin  
                     if (watchdog > 100) begin
                       $display ("watchdog error");
                        $finish;
                     end
                     else begin
					         $display ("----------INITIATOR STILL WAITING TRANSACTION ---- watchdog counter = %d", watchdog);	
                             watchdog <= watchdog+1;
						end 
                      fsm_get <= check_lut;
                 end      
              end
endcase
end
*/
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
   task get_data (input string     source,      // will use later to compare   
                  input string     event_name,  // will use later to compare 
		              input integer    event_no);
   
   bit error = 0;
   integer watchdog = 0;
   rcv_valid[event_no] = 0;
   
   forever
     begin
         fringe_get();                
         if  (I_if.signals_db[event_no].data_valid)	begin
             I_if.signals_db[event_no].data_valid = 1'b1;
             joined_rcv_data[event_no] = I_if.data_payloads[event_no];
             rcv_valid[event_no] = 1;
             break;
         end else
         begin
            if (watchdog > 100) begin
                $display ("watchdog error");
                $finish;
            end
            watchdog++;   
            @(posedge  clk_i);
        end 
     end
     $display( "Get data = %h from %s clocked with %s", joined_rcv_data[event_no], source, event_name);
    endtask
   */            
//=============================================================================
 /* verilator lint_off VARHIDDEN */
 
 task put_data ( 
                  input int      event_no,
		          input string   event_name,
		          input string   destination
                  );
     
     
     
     I_if.data_payloads_db[event_no] = joined_sut_data[event_no];
     I_if.fringe_put ( destination, event_name);
     //begin
     //if (!I_if.fringe_put ( destination, event_name))    begin
     //  $display ($time, "  Transmit data error !!!");
    //   $finish;  //??
    // end	
     $display ("Put data = %h to %s clocked with %s", joined_sut_data[event_no], destination, event_name );	           
      
  endtask : put_data
  
//==============================================================
/*
task wait_clk_i(input integer clock_num, input integer current_cnt);
   forever
     if (current_cnt + clock_num > i_clk_cnt)
         break;
     
 endtask: wait_clk_i
*/		 		      		      
		      
		      
endinterface : part_2_init_if
