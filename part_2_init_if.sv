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

parameter  number_of_blocks   =  4;
parameter  number_of_clocks   = 13;
parameter  max_rows_no	      = 16;

    
bit        valid;
bit  [7:0] o_data;
bit  [3:0] freeze_clk = 0;

string     source;      // will use later to compare   


reg        clk_0_h_d;
data_in_t  data_get;
data_in_t  data_put;   

bit        put_success;
bit        get_success;
   

   
   shunt_fringe_if Frng_if (clk_i); 
   bit 	   Result;
   cs_header_t      h;
   string  S;
   real    Temp;
   string  SrcDst_db_name;  
   bit 	   success;
/*------------------------------------  HUB Definitions  ------------------------------------------*/
 typedef enum {clk0, clk1, clk2, clk3,
              clk4, clk5, clk6, clk7,
	      clk8, clk9, clk10, clk11,
	      clk12 } all_mission_clocks;

typedef enum {part0, part1, TARGET, part3} block;

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

int                         w_cnt[ number_of_blocks];
int                         r_cnt[ number_of_clocks];                        

int                         pool2put[ number_of_blocks *  number_of_clocks];
int                         pool2get[ number_of_blocks *  number_of_clocks];
int                         entry_from_pool[number_of_blocks];
bit                         fsm_run[ number_of_blocks];
bit                         empty[ number_of_blocks];
//transaction variables
//bit                         get_state[number_of_blocks];
bit  [number_of_blocks-1:0] get_state;
bit                         socket_get_done[number_of_blocks];
string                      target_source[number_of_blocks];
string                      current_clock[number_of_blocks];


/*-------------------------------------------------------------------------------------------------*/
   
   
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
   
 /* 
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
  */
/************************** Connecting to pins (the manual part )********************************/


     //watching arriving clocks to start the communication process
      always @(posedge clk_i) begin
        arrved_clocks[6] <=  clk_0_h;   
        arrved_clocks[7] <=  clk_1_h;   
        arrved_clocks[8] <=  clk_2_h;   
        arrved_clocks[11] <= clk_3_h;   
      end

     //connect  input data ports to data exchange logic
      always @(*) begin
            
         if (arrved_clocks[6])  begin
	    row_de = cntrl_table[8];
	    row_de.data_to_send.data_bit = {wen0, i_data0};
	    cntrl_table[8]  = row_de;
	 end   
     
         if (arrved_clocks[7])  begin
	    row_de = cntrl_table[9];
	    row_de.data_to_send.data_bit = {wen1, i_data1};
	    cntrl_table[9]  = row_de;
	 end   
	       
          if (arrved_clocks[10])  begin
	    row_de = cntrl_table[8];
	    row_de.data_to_send.data_bit = {wen2, i_data2};
	    cntrl_table[10]  = row_de;
	 end
	             
          if (arrved_clocks[11])  begin
	    row_de = cntrl_table[11];
	    row_de.data_to_send.data_bit = $random;;
	    cntrl_table[11]  = row_de;
	 end  
      end

   assign  {o_valid, o_data} = received_data[11]; 


   function void set_init_masks();
       //defines the topology of clocks/per/partitions
      for (int i=0; i< number_of_clocks; i++)
	  arrved_clocks[i] = 0;   
  	  row.part = part0; row.clock = clk0;  row.mask = 0;
  	  cntrl_table[0] = row;
  	  row.part = part0; row.clock = clk1;  row.mask = 0;
  	  cntrl_table[1] = row;
  	  row.part = part0; row.clock = clk2;  row.mask = 0;
  	  cntrl_table[2] = row;
  	  row.part = part0; row.clock = clk9;  row.mask = 0;
  	  cntrl_table[3] = row;
  	  row.part = part1; row.clock = clk3;  row.mask = 0;
  	  cntrl_table[4] = row;
  	  row.part = part1; row.clock = clk4;  row.mask = 0;
  	  cntrl_table[5] = row;
  	  row.part = part1; row.clock = clk5;  row.mask = 0;
  	  cntrl_table[6] = row;
  	  row.part = part1; row.clock = clk10; row.mask = 0;
  	  cntrl_table[7] = row;
  	  row.part = TARGET; row.clock = clk6;  row.mask = 0;
  	  cntrl_table[8] = row;
  	  row.part = TARGET; row.clock = clk7;  row.mask = 0;
  	  cntrl_table[9] = row;
  	  row.part = TARGET; row.clock = clk8;  row.mask = 0;
  	  cntrl_table[10] = row;
  	  row.part = TARGET; row.clock = clk11; row.mask = 0;
  	  cntrl_table[11] = row;
  	  row.part = part3; row.clock = clk9;  row.mask = 0;
  	  cntrl_table[12] = row;
  	  row.part = part3; row.clock = clk10; row.mask = 0;
  	  cntrl_table[13] = row;
  	  row.part = part3; row.clock = clk11; row.mask = 0;
  	  cntrl_table[14] = row;
  	  row.part = part3; row.clock = clk12; row.mask = 0;
  	  cntrl_table[15] = row;
  endfunction


/************************** HUB  LOGIC**********************************************************/

      initial begin
          set_init_masks();
          print_table();
      end

// Launch data exchange for available sockets according the queuee in the pool
      genvar c;
      generate for (c=0; c< number_of_blocks; c=c+1) begin
 	  always @(posedge clk_i) begin
 	     if (empty[c] == 0) begin                        // pool is not empty
 	  	 if (fsm_run[c] == 0) begin		     //fsm is not working
 		     fetch_entry_pg(c);  		     //take the task attribute from the pool
 		     if (r_cnt[c] <= w_cnt[c]) begin       
 		   	 fsm_run[c] = 1;
 		   	 if (socket_get_done[c] == 1) begin       // get operation with c socket completed success
 		   	     fsm_run[c] = 0;
			 end    
 	  	     end
 	  	 end
 	     end
 	  end
      end
                
  endgenerate      


   genvar d;
   generate for (d=0; d< number_of_blocks; d=d+1) begin     
         
     always @(posedge clk_i)  
      
        case (get_state[d])	
            0 :   if (fsm_run[d] == 1) begin
	              get_state[d] = 1;	 
		 end        
	    1 :   if (socket_get_done[d] == 1) 
		       get_state[d] = 0;                        // back to idle state
		  else 
		       socket_get_done[d] <= run_fringe_get(entry_from_pool[d], d);
        endcase
   
     end            
    endgenerate

    function bit run_fringe_get (int pentry_, int block_n_);
    row_t      current_row_;
    string     current_source_;
    string     current_clock_;
    data_in_t  get_data;
    bit        done;
    
         current_row_    = cntrl_table[pentry_];
	 current_source_ = current_row_.part.name();
         current_clock_  = current_row_.clock.name();
	 done   =  Frng_if.fringe_api_get (current_source_,current_clock_,get_data);
         return done;
    
    endfunction


    function bit check_data_exch_completed ();
    	for (int k=0; k< number_of_blocks; k=k+1) begin
    	     if (empty[k] == 0)
    		return 0;
    	end
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
 	   w_cnt[socket_no] = socket_no* number_of_clocks;
 	   for (int entry=0; entry< max_rows_no; entry++) begin
 	      row = cntrl_table[entry];
 	      if ((row.part == socket_name) && (row.put_ready != 0)) begin
 		 empty[socket_no] = 0;
 		 pool_addr = w_cnt[socket_no];
 		 pool2get[pool_addr] = entry;
 		 pool2put[pool_addr] = entry;
 		 pool_addr++;
 		 w_cnt[socket_no] = pool_addr;
 	      end  //if
 	   end // for
       end // for
    endfunction
 

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
 		    empty[socket_no] = 1;
 	     end
    endfunction


    function void init_read_addr();
    //sets pools address pointers to initial value
       for (int no=0;no< number_of_blocks; no++) begin
    	    r_cnt[no] =  no* number_of_clocks;
       end
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
    	      empty = '{ number_of_blocks{1'b1}};
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


		      
endinterface : part_2_init_if
