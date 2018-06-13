/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off BLKSEQ */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off IMPLICIT */
/* verilator lint_off MULTIDRIVEN */
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
parameter wait_event = 0;
parameter  check_lut = 1;
		      
bit        wen0;
bit  [7:0] i_data0;
bit        wen1;
bit  [7:0] i_data1;
bit        wen2;
bit  [7:0] i_data2;
bit  [8:0] joined_rcv_data[3:0];
bit  [8:0] joined_sut_data[3:0];
bit  [2:0] rcv_valid; 
string     source;      // will use later to compare   
string     event_name;  // will use later to compare 
integer    event_no;
integer    watchdog;
reg        fsm_get;
reg        fsm_get_enable;

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
always @(posedge clk_0_h)
begin
   source <= "INITIATOR";
   event_no <= 0;
   event_name <= "data_clk_0";
   fsm_get <= wait_event;
   fsm_get_enable <= 1;
   freeze_clk[event_no] <= 1;
   $display ("---------------TARGET CLK_0 clock is togling---------------");
  //     get_data ( "INITIATOR", "clk_0", 0);
  //     $finish;
end  
 
 /*
always @(posedge clk_1_h)
begin
   source <= "INITIATOR";
   event_no <= 1;
   event_name <= "data_clk_1";
   fsm_get <= wait_event;
   fsm_get_enable <= 1;
   freeze_clk[event_no] <= 1;
     // get_data ( "INITATOR", "clk_1", 1);
  //    $finish;
 end


always @(posedge clk_2_h)
begin
   source <= "INITIATOR";
   event_no <= 2;
   event_name <= "data_clk_2";
   fsm_get <= wait_event;
   fsm_get_enable <= 1;
    //get_data ( "INITIATOR", "clk_2", 2);
   // $finish;
end 

// ... and export block output to initiator

always @(posedge clk_3_h)
   begin
     $display ( "TARGET to INITIATOR  send data_clk_1 vector = %h", joined_sut_data[2]);
     put_data(3, "data_clk_3", "INITIATOR");
    // $finish;
   end  
*/
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
 
always @(posedge clk_i) begin
$display ("------------TARGET PROCEEDS ------event name %s", event_name); 
case(fsm_get)
wait_event :   begin
                 watchdog <= 0;
                 rcv_valid[event_no] <= 0;
                 fsm_get <= fsm_get_enable ? check_lut : fsm_get;
               end  
check_lut  :  begin
                 T_if.fringe_get();
                 if  (T_if.signals_db[event_no].data_valid) begin
                      joined_rcv_data[event_no] <= T_if.data_payloads_db[event_no];
                      rcv_valid[event_no] <= 1;
                      T_if.signals_db[event_no].data_valid <= 0;
                      fsm_get <=  wait_event; 
                      fsm_get_enable <= 0;
					  freeze_clk[event_no] <= 0;
                      $display( "------------ TARGET got data = %h from %s clocked with %s", joined_rcv_data[event_no], source, event_name);                      

                 end
                 else  begin  
                     if (watchdog > 100) begin
                        $display ("watchdog error");
                        $finish;
                     end
                     else begin
                             watchdog<=watchdog+1;
					         $display ("----------TARGET STILL WAITING TRANSACTION ---- watchdog counter = %d", watchdog);
                         end	
                     fsm_get <= check_lut;
                 end      
              end
endcase
end
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
         if  (T_if.signals_db[event_no].data_valid)	begin
             joined_rcv_data[event_no] = T_if.data_payloads_db[event_no];
             rcv_valid[event_no] = 1;
             break;
         end else
         begin
            if (watchdog > 100) begin
                $display ("watchdog error");
                $finish;
            end   
            @(posedge  clk_i);
            watchdog++;
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
     T_if.data_payloads_db[event_no] = joined_sut_data[event_no];
     T_if.fringe_put ( destination, event_name);
     //if (!T_if.fringe_put ( destination, event_name) )   begin
     //  $display ($time, "  Transmit data error !!!");
     //  $finish;  //??
     //end		           
     $display ("Put data = %h to %s clocked with %s", joined_sut_data[event_no], destination, event_name );	            
  endtask : put_data

//=============================================================================



//==============================================================
		      
endinterface : part_2_trgt_if
