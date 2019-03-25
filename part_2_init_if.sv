/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off BLKSEQ */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off IMPLICIT */
/* verilator lint_off MULTIDRIVEN */


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
//`include "../../include/shunt_fringe_if.sv"

   import shunt_dpi_pkg::*;
   import  shunt_fringe_pkg::*;
 
parameter  N = 9;
parameter  wait_event = 0;
parameter  send_vector = 1;
parameter  check_lut = 2;
parameter  empty_state = 3;
parameter  clock_number = 4;   
		      
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
reg   [1:0]     fsm_get;
reg        fsm_get_enable;

reg    clk_0_en = 1;
reg    clk_1_en = 0;
reg    clk_2_en = 0;
reg    clk_3_en = 0;

reg    get_run_en = 1;
reg    put_run_en = 1;
reg        clk_0_h_d;
data_in_t data_get;
data_in_t data_put;   

bit  put_success;
bit  get_success;
   

   
   shunt_fringe_if Frng_if (clk_i); 
   bit 	   Result;
   cs_header_t      h;
   string  S;
   real    Temp;
   string  SrcDst_db_name;  
   bit 	   success;
   initial
     begin: registration
	longint Temp1;
	int 	index;
	bit [7:0] data_in;
	
	$display("Initiator registration: START");
	begin : srcdsts_db
	   `INIT_SRCDSTS_DB
	     //TCP INIT
	   Result = Frng_if.set_iam("INITIATOR");
	   Result = Frng_if.set_mystatus(Frng_if.FRNG_INITIATOR_ACTIVE);
	   Result = Frng_if.set_simid(`SIM_ID);
	   //
	   Frng_if.print_localparams();
	   //
	   Result = Frng_if.init_SrcDsts_db(Frng_if.N_OF_SRCDSTS);
	   Result = Frng_if.set_SrcDsts_id();
	   Result = Frng_if.set_SrcDst_n_signals(,SrcDsts_n_signals);
	   Result = Frng_if.set_SrcDst_name(,SrcDsts_name);
	
	end : srcdsts_db
	//
	begin: signals_db
	   `INIT_SIGNAL_DB
	   Result = Frng_if.init_signals_db();
	   foreach(SrcDsts_name[i]) Result = Frng_if.set_signal_name_id(SrcDsts_name[i],signal_name);
	   foreach(SrcDsts_name[i]) Result = Frng_if.set_signal_type(SrcDsts_name[i],signal_type);
	   foreach(SrcDsts_name[i]) Result = Frng_if.set_signal_size(SrcDsts_name[i],signal_size);
	end : signals_db
	
	if(!Frng_if.pnp_init()) $display("ERROR: %s Frng_if.pnp_init()",Frng_if.who_iam());
	Result = Frng_if.print_SrcDsts_db();
	Result = Frng_if.print_signals_db();
	$display("i am : %s (%s) source(%s)",Frng_if.who_iam(),Frng_if.my_status.name(),Frng_if.my_source);
     end : registration
   //TEMP DEBUG!!! 
   always @(posedge clk_i) begin
      if ( Frng_if.get_time() > 2000)   begin
	  $display("EOS i am : %s (%s) source(%s)",Frng_if.who_iam(),Frng_if.my_status.name(),Frng_if.my_source);
	 Frng_if.fring_eos();
	 $finish;
      end
   end
   
  
   always @(posedge clk_i) begin
      data_put.data_bit <= "INITIATOR_SEND_DATA_CLK_0_TO_TARGET";
      if ( Frng_if.get_time() == 10) begin
	 $display("%s call Frng_if.fringe_api_put data_put.data_bit=%0h @%0d ",Frng_if.who_iam(), data_put.data_bit,Frng_if.get_time());
	 if (!Frng_if.put_status) put_success = Frng_if.fringe_api_put ("TARGET","data_clk_0",Frng_if.SHUNT_BIT,data_put);
	 if(!put_success)  $display("ERROR: %s Frng_if.fringe_api_put",Frng_if.who_iam());
      end
      if ( Frng_if.get_time() > 100) success <= Frng_if.fringe_api_get ("TARGET","data_clk_1",data_get);
      if (success)   begin
         $display("data_clk_1.data_bit=%0h",data_get.data_bit);
	 $display("data_clk_1.data_logic=%0h",data_get.data_logic);
      end
   end
 

/* -----\/----- EXCLUDED -----\/-----
   always @(posedge clk_i) begin
      Frng_if.get_status <= Frng_if.fringe_api_get(Frng_if.get_status,);
   end
 -----/\----- EXCLUDED -----/\----- */
   
/* -----\/----- EXCLUDED -----\/-----
   
//----------------------------------------------------------
//  Export related partiotion inputs to target


// Every mission clock retreive data from target 
/-* verilator lint_off COMBDLY *-/


always @(posedge clk_i) begin
   clk_0_h_d <= clk_0_h;
   fsm_get_enable <= clk_0_h & !clk_0_h_d;
   source <= "INITIATOR";
   event_name <= "data_clk_0";
   event_no <= Frng_if.get_index_by_name_signals_db(source,event_name);
   $display ("INITIATOR indexed clk_0 with %d", event_no);
   if (get_run_en)
     $display ("---------------INITIATOR CLK_0 clock is togling---------------");
end     


always @(posedge clk_i) begin
$display ("------------INITIATOR PROCEEDS ------event name %s fsm_get %h ", event_name,fsm_get);
  
   case(fsm_get)
     wait_event :   begin
        watchdog <= 0;
        rcv_valid[clock_number - event_no] <= 0;
        fsm_get <= fsm_get_enable & put_run_en ? send_vector :
                   fsm_get_enable & get_run_en ? check_lut   :	 fsm_get;	
     end				 
     send_vector :  begin
        $display ( "INITIATOR to TARGET  send data_clk_0 vector = %h", joined_sut_data[0]);
      	put_data( event_no, event_name, source);
        fsm_get <= get_run_en ? check_lut   :	 wait_event;
     end           
     check_lut   :   begin
         if (!Frng_if.fringe_get("TARGET"))
            $display ( "ERROR: %s get",Frng_if.who_iam());
        else
        $display ( "OK: %s get event_no=%0d",Frng_if.who_iam(),event_no); 
        if  (Frng_if.signals_db[event_no].data_valid) begin
           joined_rcv_data[event_no] <= Frng_if.data_payloads_db[event_no];
           rcv_valid[clock_number - event_no] <= 1;
           Frng_if.signals_db[event_no].data_valid <= 0;
           fsm_get <=  wait_event; 
	         freeze_clk[clock_number - event_no] <= 0;
           $display( "------------ INITIATOR got data = %h from TARGET clocked with %s", joined_rcv_data[event_no],  event_name);                                         
        end
        else  begin          
	         freeze_clk[clock_number - event_no] <= 1;
           if (watchdog > 10000) begin
              $display ("watchdog error");
              $finish;
           end
           else begin
              watchdog<=watchdog+1;
	            $display ("----------INITIATOR STILL WAITING TRANSACTION ---- watchdog counter = %d", watchdog);
           end	
           fsm_get <= check_lut;
        end // else: !if(Frng_if.signals_db[event_no].data_valid)
     end // case: check_lut
  
endcase
  
end
//----------------------------------------------------------


// on the edge of utility clock build array for further export to target
always @(posedge clk_i)
   begin
    joined_sut_data[0]  = {wen0, i_data0};
    joined_sut_data[1]  = {wen1, i_data1};
    joined_sut_data[2]  = {wen2, i_data2};
    joined_sut_data[3]  = 0;
   end

//...extract partial signal values from received array(s)
always @(posedge clk_i)
    {valid, o_data} = rcv_valid[3] ? joined_rcv_data[3] :  {valid, o_data};                                    


 

 /-* verilator lint_off VARHIDDEN *-/
 
   task put_data ( 
                   input int      event_no,
		   input string   event_name,
		   input string   destination
                   );
      string 			  s_me = "put_data()";
      
      $display ("INITIATOR: %s data= %h to %s.%s event_no = %0d data_payloads_db[%0d]",s_me,joined_sut_data[event_no], destination, event_name, event_no,Frng_if.get_index_by_name_signals_db(destination,event_name));
      
      if (Frng_if.get_index_by_name_signals_db(destination,event_name) >= 0)
	begin
	   Frng_if.data_payloads_db[Frng_if.get_index_by_name_signals_db(destination,event_name)] = joined_sut_data[event_no];
	   Frng_if.fringe_put (destination, event_name);
	   $display ("INITIATOR: %s data = %h to %s clocked with %s event_no=%0d",s_me,joined_sut_data[event_no], destination, event_name, event_no );	           
	end
      else $display ("ERROR: %s data= %h to %s.%s event_no = %0d data_payloads_db[%0d]",s_me,joined_sut_data[event_no], destination, event_name, event_no,Frng_if.get_index_by_name_signals_db(destination,event_name));
   endtask : put_data
   
   //==============================================================
 -----/\----- EXCLUDED -----/\----- */
  	      		      
   
		      
endinterface : part_2_init_if
