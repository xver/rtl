/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off BLKSEQ */
/* verilator lint_off UNOPTFLAT */
/* verilator lint_off IMPLICIT */
/* verilator lint_off MULTIDRIVEN */
//`include "../../include/shunt_fringe_if.sv"	
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
 

   import shunt_dpi_pkg::*;
   import  shunt_fringe_pkg::*;
   
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
//
data_in_t data_get;
data_in_t data_put; 
bit put_success;
bit get_success; 
//
   bit 	   success;
   
   shunt_fringe_if Frng_if(clk_i);    
   cs_header_t      h;
   initial
     begin: registration
	bit Result;
	bit [7:0] data_in_byte;
	int 	  socket_id;
		
	$display("Target registration: START ");
	//
	begin : srcdsts_db
	   `INIT_SRCDSTS_DB
	     //TCP INIT
	   Result = Frng_if.set_iam("TARGET");
	   Result = Frng_if.set_mystatus(Frng_if.FRNG_TARGET_ACTIVE);
	   Result = Frng_if.set_simid(`SIM_ID);
	   //
	   Result = Frng_if.init_SrcDsts_db(Frng_if.N_OF_SRCDSTS);
	   Result = Frng_if.set_SrcDsts_id();
	   Result = Frng_if.set_SrcDst_n_signals(,SrcDsts_n_signals);
	   Result = Frng_if.set_SrcDst_name(,SrcDsts_name);
	   Result = Frng_if.print_SrcDsts_db();
	end : srcdsts_db
	//

	
	if(!Frng_if.pnp_init()) $display("ERROR: %s Frng_if.pnp_init()",Frng_if.who_iam());
	
	begin: signals_db
	   `INIT_SIGNAL_DB
	     Result = Frng_if.init_signals_db();
	   foreach(SrcDsts_name[i]) Result = Frng_if.set_signal_name_id(SrcDsts_name[i],signal_name);
	   foreach(SrcDsts_name[i]) Result = Frng_if.set_signal_type(SrcDsts_name[i],signal_type);
	   foreach(SrcDsts_name[i]) Result = Frng_if.set_signal_size(SrcDsts_name[i],signal_size);
	end : signals_db
	
	Result = Frng_if.print_SrcDsts_db();
	Result = Frng_if.print_signals_db();
	
	$display("i am : %s (%s) source(%s)",Frng_if.who_iam(),Frng_if.my_status.name(),Frng_if.my_source);
	//
     end : registration
   
   //TEMP DEBUG!!! 
   always @(posedge clk_i) begin
      if ( Frng_if.get_time() > 1000) begin	
	 $display("EOS i am : %s (%s) source(%s)",Frng_if.who_iam(),Frng_if.my_status.name(),Frng_if.my_source);
	 Frng_if.fring_eos();
	 $finish;
      end
   end
   

   always @(posedge clk_i) begin
       data_put.data_bit <= "TARGET_SEND_DATA_CLK_1_TO_INITIATOR";
      if ( Frng_if.get_time() > 100) success <= Frng_if.fringe_api_get ("INITIATOR","data_clk_0",data_get);
      if (success)   begin
         $display("data_clk_0.data_bit=%0h",data_get.data_bit);
	 $display("data_clk_0.data_logic=%0h",data_get.data_logic);
      end
      if ( Frng_if.get_time() == 500) begin
	 $display("%s call Frng_if.fringe_api_put Frng_if.put.data_bit=%0h @%0d ",Frng_if.who_iam(), data_put.data_bit,Frng_if.get_time());
	 if (!Frng_if.put_status) put_success = Frng_if.fringe_api_put ("INITIATOR","data_clk_1",Frng_if.SHUNT_BIT,data_put);
      end
   end // always @ (posedge clk_i)
   
   


   
/* -----\/----- EXCLUDED -----\/-----
   //to finish sims after 1000 clk_i
   always @(posedge clk_i) begin
     $display ("==================>>>> GET TIME = %d", Frng_if.get_time());
     if(Frng_if.get_time() > 1000) $finish();
    end
//----------------------------------------------------------
// Every mission clock retreive data from initiator 

always @(posedge clk_i) begin
   clk_0_h_d <= clk_0_h;
   fsm_get_enable <= clk_0_h & !clk_0_h_d;
   //source <= "TARGET";
   source <= "INITIATOR";
   event_name <= "data_clk_0";
   event_no <= Frng_if.get_index_by_name_signals_db(source,event_name);
   
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
     fsm_get <= fsm_get_enable & get_run_en ? check_lut   :
                fsm_get_enable & put_run_en ? send_vector :  fsm_get;	
  end
  
  send_vector :  begin
     $display ( "TARGET to INITIATOR  send data_clk_0 vector = %h", joined_sut_data[0]);
     put_data( event_no, event_name, "INITIATOR");
     fsm_get <=  wait_event;
  end           
  
  check_lut   :   begin
     if (!Frng_if.fringe_get("INITIATOR"))
            $display ( "ERROR: %s get",Frng_if.who_iam());
     else
            $display ( "OK: %s get event_no=%0d",Frng_if.who_iam(),event_no);
     //for (int event_index=0;event_index<$size(Frng_if.signals_db);event_index++)
     //  begin
	  if  (Frng_if.signals_db[event_no].data_valid == 1) begin
	        joined_rcv_data[event_no] <= Frng_if.data_payloads_db[event_no];
             rcv_valid[event_no] <= 1;
             Frng_if.signals_db[event_no].data_valid <= 0;
	     freeze_clk[event_no] <= 0;
             $display( "------------ TARGET got data = %h from %s clocked with %s", joined_rcv_data[event_no], source, event_name);                                         
             fsm_get <=  put_run_en ? send_vector : wait_event; 
	  end // if (Frng_if.signals_db[event_no].data_valid == 1)
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
	 end // else: !if(Frng_if.signals_db[event_no].data_valid == 1)
    //end // foreach (Frng_if.signals_db[event_no])
  end // case: check_lut
  
				 
endcase // case (fsm_get)
   
end // always @ (posedge clk_i)
 
//=============================================================================
  /-* verilator lint_off VARHIDDEN *-/
  
   task put_data ( 
                   input int      event_no,
		   input string   event_name,
		   input string   destination
                   );
      string 			  s_me = "put_data()";
      
      $display ("TARGET: %s data= %h to %s.%s event_no = %0d data_payloads_db[%0d]",s_me,joined_sut_data[event_no], destination, event_name, event_no,Frng_if.get_index_by_name_signals_db(destination,event_name));
      
	   if (Frng_if.get_index_by_name_signals_db(destination,event_name) >= 0)
	begin
		Frng_if.data_payloads_db[Frng_if.get_index_by_name_signals_db(destination,event_name)] = joined_sut_data[event_no];
	    //Frng_if.fringe_put ( destination, event_name);
	   $display ("%s data = %h to %s clocked with %s event_no=%0d",s_me,joined_sut_data[event_no], destination, event_name, event_no );	           
	end
      else $display ("ERROR: %s data= %h to %s.%s event_no = %0d data_payloads_db[%0d]",s_me,joined_sut_data[event_no], destination, event_name, event_no,Frng_if.get_index_by_name_signals_db(destination,event_name));
   endtask : put_data
  
//=============================================================================

 -----/\----- EXCLUDED -----/\----- */


//==============================================================
		      
endinterface : part_2_trgt_if
