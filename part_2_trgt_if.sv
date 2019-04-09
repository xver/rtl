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
   
parameter N                =   9;
parameter number_of_blocks =   1;
parameter number_of_clocks =   4;
parameter max_rows_no      =   4;

		      
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
   
/*------------------------------------  HUB Definitions  ------------------------------------------*/
// typedef enum { clk6, clk7, clk8, clk11} all_mission_clocks;
 typedef enum { data_clk_0,data_clk_1, data_clk_2, data_clk_3 } all_mission_clocks;

typedef enum {INITIATOR} block;

block                      part_name;
all_mission_clocks         clock_name; 


typedef struct    packed     {
all_mission_clocks            clock;
block                         part;
bit                           mask;
int  	                      put_ready;
data_in_t                     data_to_send;
                             }  row_t;


block                        socket_name;
row_t                        row, rowb, cntrl_table[ max_rows_no]; 
row_t                        row_de;
data_in_t                    received_data[max_rows_no];
data_in_t                    rcvd_data[number_of_blocks]; 


string                      block_name;
bit                         arrved_clocks[ number_of_clocks];

int                         w_cnt;
int                         r_cnt;			  

int                         pool2put[ number_of_blocks * number_of_clocks];
int                         pool2get[ number_of_blocks * number_of_clocks];
int                         entry_from_pool[number_of_blocks];
bit                         fsm_run;
bit                         empty_p;
bit                         empty_g;
//transaction variables
bit  [number_of_blocks-1:0] get_state;
bit                         socket_get_done;
bit                         socket_put_done;
string                      target_source;
string                      current_clock;
int                         current_active_entry;


/*-------------------------------------------------------------------------------------------------*/
      
   
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
   
/*
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
   
*/   

/************************** Connecting to pins (the manual part )********************************/


     //watching arriving clocks to start the communication process
      always @(posedge clk_i) begin
        arrved_clocks[0] <=  clk_0_h;   
        arrved_clocks[1] <=  clk_1_h;   
        arrved_clocks[2] <=  clk_2_h;   
        arrved_clocks[3] <=  clk_3_h;   
      end

     //connect  input data ports to data exchange logic
      always @(*) begin
            
         if (arrved_clocks[0])  begin
	    row_de = cntrl_table[0];
	    row_de.data_to_send.data_bit = $random;
	    cntrl_table[0]  = row_de;
	 end   
     
         if (arrved_clocks[1])  begin
	    row_de = cntrl_table[1];
	    row_de.data_to_send.data_bit = $random;
	    cntrl_table[1]  = row_de;
	 end   
	       
          if (arrved_clocks[2])  begin
	    row_de = cntrl_table[2];
	    row_de.data_to_send.data_bit = $random;
	    cntrl_table[2]  = row_de;
	 end
	             
          if (arrved_clocks[3])  begin
	    row_de = cntrl_table[3];
	    row_de.data_to_send.data_bit = {valid, o_data};
	    cntrl_table[3]  = row_de;
	 end  
      end


   function void set_init_masks();
       //defines the topology of clocks/per/partitions
      for (int i=0; i< number_of_clocks; i++) 
	  arrved_clocks[i] = 0;   
      row.part = INITIATOR; row.clock = data_clk_0;	row.mask = 0;
      cntrl_table[0] = row;
      row.part = INITIATOR; row.clock = data_clk_1;	row.mask = 0;
      cntrl_table[1] = row;
      row.part = INITIATOR; row.clock = data_clk_2;	row.mask = 0;
      cntrl_table[2] = row;
      row.part = INITIATOR; row.clock = data_clk_3;     row.mask = 0;
      cntrl_table[3] = row;

  endfunction


/************************** TARGET  LOGIC**********************************************************/

      initial begin
          set_init_masks();
          print_table();
      end

// Launch data exchange for available sockets according the queuee in the pool
 
      	  always @(posedge clk_i) begin
 	     if (empty_p == 0) begin                        // poot pool is not empty
 	  	 if (fsm_run == 0) begin		     //fsm is not working
 		     fetch_entry_pp();  		     //take the task attribute from the pool
 		     if (r_cnt <= w_cnt) begin               //check pool read/write pointers    
 		     	 fsm_run <= 1;
 		   	 if (socket_put_done == 1) begin       // get operation with c socket completed success
 		   	     fsm_run <= 0;
			 end    
 	  	     end
 	  	 end
 	     end
 	  end




        
     always @(posedge clk_i)  
        case (get_state)	
            0 :   if (fsm_run == 1) begin
	              get_state <= 1;	 
		 end        
	    1 :   if (socket_put_done == 1) 
		       get_state <= 0;                        // back to idle state
		  else  begin		       
		           current_active_entry <= entry_from_pool[0];
                           socket_put_done <= run_fringe_put(current_active_entry);
		  end    
        endcase
   

    function bit run_fringe_put (int pentry_);
       row_t      current_row_;
       string     current_destination_;
       string     current_clock_;
       data_in_t  put_data_;
       bit        put_success_ = 0;
    
         current_row_         = cntrl_table[pentry_];
	 current_destination_ = current_row_.part.name();
         current_clock_       = current_row_.clock.name();
	 put_data_            = current_row_.data_to_send;	 
	 if (!Frng_if.put_status)
	      put_success_  = Frng_if.fringe_api_put (current_destination_, current_clock_, 1'b1, put_data_);
         return put_success_;    
    endfunction


    function bit check_data_exch_completed ();
    	//for (int k=0; k< number_of_blocks; k=k+1) begin
    	  if (empty_p == 0)
    		return 0;
    	//end
    	return 1;
 
    endfunction
    
    function void clear_pools(); // temporary, convinient for debugging   
       for (int p_add =0; p_add <  number_of_blocks* number_of_clocks; p_add++) begin
   	   pool2get[p_add] = 0;
   	   pool2put[p_add] = 0;
       end
    endfunction

    function void load_pools();
    //this function extracts tranzactions from topology table and sorts between
    // socket pools
    int pool_addr;

       for (int socket_no=0; socket_no< number_of_blocks; socket_no++) begin
 	   socket_name = block'(socket_no);
 	   w_cnt = 0;
 	   for (int entry=0; entry< max_rows_no; entry++) begin
 	      row = cntrl_table[entry];
 	      if ((row.part == socket_name) && (row.put_ready != 0)) begin
 		 empty_p = 0;
 		 pool_addr = w_cnt;
 		 pool2get[pool_addr] = entry;
 		 pool2put[pool_addr] = entry;
 		 pool_addr++;
 		 w_cnt = pool_addr;
 	      end  //if
 	   end // for
       end // for
    endfunction
 
/*
    function   void fetch_entry_pg  (int socket_no);
    //for given socket, takes the tranzaction id from the pool, updates pointer
    // and checks the data avaialibility in the current pool
    int pool_addr;
 	      begin
 		 pool_addr = r_cnt[socket_no];
 		 entry_from_pool[socket_no] = pool2get[pool_addr];
 		 pool_addr++;
 		 r_cnt[socket_no] = pool_addr;
 		 if (r_cnt[socket_no] > w_cnt[socket_no])
 		    empty_g[socket_no] = 1;
 	     end
    endfunction
*/

    function   void fetch_entry_pp ();
    //for given socket, takes the tranzaction id from the get transactions pool, updates pointer
    // and checks the data avaialibility in the current pool
    int pool_addr;
 	      begin
 		 pool_addr = r_cnt;
 		 entry_from_pool[0] = pool2put[pool_addr];
 		 pool_addr++;
 		 r_cnt = pool_addr;
 		 if (r_cnt > w_cnt)
 		    empty_p = 1;
 	     end
    endfunction



    function void init_read_addr();
    //sets pools address pointers to initial value
       //for (int no=0;no< number_of_blocks; no++) begin
       //    r_cnt[no] =  no* number_of_clocks;
       //end
       r_cnt = 0;
    endfunction


    function  check_clock_inputs();
    //  whenever appears one or more clokc edges
    //  initiates the following steps:
    // 1) defines what partitions participate in data exchange
    // 2) loads pools with sequence of actions
    // 3) resets read pools address counter
    
    
    integer total_clocks;
       total_clocks = 0;
       for (int clock_no=0; clock_no< number_of_clocks; clock_no++) begin
    	   if (  arrved_clocks[clock_no] == 1'h1 ) begin
    	      total_clocks++;
    	   end  //if
       end //for
       if (total_clocks == 0) begin
    	   return 0;
    	end
       else begin
    	      /* defines how many data exchanges required with each block   */
    	      set_put_bits();
    	      print_table();
    	      empty_p = 1'b1;
    	      empty_g = 1'b1;
    	      load_pools();
    	      init_read_addr();
       end 
     endfunction


    function void set_put_bits();
    // this function identifiies rows (entries of the table)
    // that supposed to be active at current time (arrived clock edges);

    all_mission_clocks clock_name_;
    int    arrved_clocks_index = 0;

      for (int entry=0; entry< max_rows_no; entry++) begin
    	  row = cntrl_table[entry];
    	  clock_name_ = row.clock;
    	  arrved_clocks_index  = all_mission_clocks'(clock_name_);
    	  if (arrved_clocks[arrved_clocks_index] == 1)  begin
    	      row.put_ready = 1; 
    	  end //if (arrved_clocks[a
    	  if (row.mask == 0)
    	    cntrl_table[entry] = row;
      end //  for (int entry 
     endfunction


    function void print_row(int entry);
    	  $display ( "entry = %d, part = %s, clock=%s, mask = %b, put_ready= %d",
    				   entry, row.part, row.clock, row.mask, row.put_ready);
    endfunction


    function void print_table();
     for (int r=0; r <  max_rows_no; r++) begin
    	   row =  cntrl_table[r];
    	   print_row(r);
     end
    endfunction


		      
endinterface : part_2_trgt_if
