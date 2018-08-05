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
parameter  wait_event = 0;
parameter  send_vector = 1;
parameter  check_lut = 2;
parameter  empty_state = 3;
		      
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
reg  [1:0]   fsm_get = wait_event;
reg        fsm_get_enable = 0;
reg        clk_0_en = 1;
reg        clk_1_en = 0;
reg        clk_2_en = 0;
reg        clk_3_en = 0;
//Enables
reg        get_run_en = 1;  //enables get
reg        put_run_en = 1;  //enables put
reg        clk_0_h_d;      // retiming
reg  [8:0] vect_dbg = 0;

   import shunt_dpi_pkg::*;
   shunt_fringe_if T_if(clk_i);    
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

   //to finish sims after 1000 clk_i
   always @(posedge clk_i)
     if(T_if.get_time() > 1000) $finish();
    
//----------------------------------------------------------
// Every mission clock retreive data from initiator 

always @(posedge clk_i) begin
   clk_0_h_d <= clk_0_h;
   fsm_get_enable <= clk_0_h & !clk_0_h_d;
   source <= "TARGET";
   event_name <= "data_clk_0";
   event_no <= T_if.get_index_by_name_signals_db(source,event_name);
   
   $display ("TARGET indexed clk_0 with %d", event_no);
   if (get_run_en)
   $display ("---------------TARGET CLK_0 clock is togling---------------");
end       

//git debug


// ... and export block output to initiator



//for clocks clk_0 ... clk_2 we send empty vectors. The purpose of that, is confirmation, that current clock simulation is finished

//-----------------------------------------------------------
// on the edge of utility clock build array for further export to initiator
always @(posedge clk_i) begin
    vect_dbg <= vect_dbg+1;
    joined_sut_data[0]   <= vect_dbg ;   //just to observe transactions
    joined_sut_data[1]   <= 0 ;
    joined_sut_data[2]   <= 0 ;
    joined_sut_data[3]   <= {valid, o_data} ;
	end



//...extract target module input values
always @(posedge clk_i)
  begin
      {wen0, i_data0} = rcv_valid[0] ?   joined_rcv_data[0] : {wen0, i_data0};
      {wen1, i_data1} = rcv_valid[1] ?   joined_rcv_data[1] : {wen1, i_data1};
      {wen2, i_data2} = rcv_valid[2] ?   joined_rcv_data[2] : {wen2, i_data2};
  end
//==============================================================
 
always @(posedge clk_i) begin
$display ("------------TARGET PROCEEDS ------event name %s fsm_get %h", event_name,fsm_get); 
case(fsm_get)
  wait_event :   begin
     watchdog <= 0;
     rcv_valid[event_no] <= 0;
     fsm_get <= fsm_get_enable & put_run_en ? send_vector :
                fsm_get_enable & get_run_en ? check_lut   :	 fsm_get;
  end
  
  send_vector :  begin
     $display ( "TARGET to INITIATOR  send data_clk_0 vector = %h", joined_sut_data[0]);
     put_data( event_no, event_name, "INITIATOR");
     fsm_get <= get_run_en ? check_lut   :	 wait_event;
  end           
  
  check_lut   :   begin
     if (!T_if.fringe_get())
            $display ( "ERROR: %s get",T_if.who_iam());
     else
            $display ( "OK: %s get event_no=%0d",T_if.who_iam(),event_no);
     //for (int event_index=0;event_index<$size(T_if.signals_db);event_index++)
     //  begin
	  if  (T_if.signals_db[event_no].data_valid == 1) begin
	        joined_rcv_data[event_no] <= T_if.data_payloads_db[event_no];
             rcv_valid[event_no] <= 1;
             T_if.signals_db[event_no].data_valid <= 0;
             fsm_get <=  wait_event; 
	         freeze_clk[event_no] <= 0;
             $display( "------------ TARGET got data = %h from %s clocked with %s", joined_rcv_data[event_no], source, event_name);                                         
	  end // if (T_if.signals_db[event_no].data_valid == 1)
	  else  begin  
	         freeze_clk[event_no] <= 1;
             if (watchdog > 10000) begin
		          $display ("watchdog error");
		          $finish;
               end // if (watchdog > 10000)
	         else begin
		           watchdog<=watchdog+1;
		           $display ("----------TARGET STILL WAITING TRANSACTION ---- watchdog counter = %d", watchdog);
            end // else: !if(watchdog > 10000)
            fsm_get <= check_lut;
	 end // else: !if(T_if.signals_db[event_no].data_valid == 1)
    //end // foreach (T_if.signals_db[event_no])
  end // case: check_lut
  
				 
endcase // case (fsm_get)
   
end // always @ (posedge clk_i)
   
 
//=============================================================================
  /* verilator lint_off VARHIDDEN */
  
   task put_data ( 
                   input int      event_no,
		           input string   event_name,
		           input string   destination
                   );
      string 			  s_me = "put_data()";
      
      $display ("%s data= %h to %s.%s event_no = %0d data_payloads_db[%0d]",s_me,joined_sut_data[event_no], destination, event_name, event_no,T_if.get_index_by_name_signals_db(destination,event_name));
      
	   if (T_if.get_index_by_name_signals_db(destination,event_name) >= 0)
	begin
		T_if.data_payloads_db[T_if.get_index_by_name_signals_db(destination,event_name)] = joined_sut_data[event_no];
	    T_if.fringe_put ( destination, event_name);
	   $display ("%s data = %h to %s clocked with %s event_no=%0d",s_me,joined_sut_data[event_no], destination, event_name, event_no );	           
	end
      else $display ("ERROR: %s data= %h to %s.%s event_no = %0d data_payloads_db[%0d]",s_me,joined_sut_data[event_no], destination, event_name, event_no,T_if.get_index_by_name_signals_db(destination,event_name));
   endtask : put_data
  
//=============================================================================



//==============================================================
		      
endinterface : part_2_trgt_if
