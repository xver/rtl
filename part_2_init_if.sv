/* WIDTH */
/* UNUSED */
/* UNDRIVEN */
/* BLKSEQ */
/* UNOPTFLAT */
/* IMPLICIT */
/* MULTIDRIVEN */


interface part_2_init_if (
                           input   clk_i,          //  utility clock
		           input   clk_0_h,	   //  mission/functional clocks	      
		           input   clk_1_h,	   //	      
		           input   clk_2_h,	   //	      
		           input   clk_3_h,        //
		      
		           output  freeze_clk,     // block/release mission
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

   import shunt_dpi_pkg::*;
   import  shunt_fringe_pkg::*;
 
parameter  N = 9;

parameter  number_of_blocks   =  4;
parameter  number_of_clocks   = 13;
parameter  max_rows_no	      = 16;

    
bit        valid;
bit  [7:0] o_data;
bit  [3:0] freeze_clk = 0;

/* verilator lint_off UNUSED */ 
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
/* verilator lint_on UNUSED */   
/*------------------------------------  HUB Definitions  ------------------------------------------*/

/* verilator lint_off UNDRIVEN */
 typedef enum {clk0, clk1, clk2, clk3,
              clk4, clk5, data_clk_0, data_clk_1,
              data_clk_2, clk9,  clk10, clk11,
              clk12 } all_mission_clocks;

 

typedef enum {part0, part1, TARGET, part3} block;
/* verilator lint_on UNDRIVEN */
 

typedef struct packed { 
bit      [8:0] data_bit;
logic    [8:0] data_logic;
                       } data_in_t;

//block                    part_name;
//all_mission_clocks       clock_name;

 

 

typedef struct    packed     {
all_mission_clocks            clock;
block                         part;
bit                           mask;
int                           put_ready;
data_in_t                     data_to_send;
                              }  row_t;

 
block                        socket_name;
row_t                        cntrl_table[max_rows_no];
row_t                        row_de;

/* verilator lint_off UNDRIVEN */
data_in_t                    received_data[max_rows_no];
/* verilator lint_on UNDRIVEN */
/* verilator lint_off UNUSED */
data_in_t                    rcvd_data[number_of_blocks];
/* verilator lint_on UNUSED */  

//string                      block_name;
/* verilator lint_off UNDRIVEN */
bit  [number_of_clocks-1:0] arrved_clocks;
/* verilator lint_on UNDRIVEN */
int                         w_cnt[number_of_blocks];
int                         r_cnt[number_of_clocks];                        

//int                         pool2put[ number_of_blocks *  number_of_clocks];
int                         pool2get[ number_of_blocks *  number_of_clocks];
int                         current_entry[number_of_blocks];


bit    [number_of_blocks-1:0]       empty_g;

//transaction variables

//bit                         get_state[number_of_blocks];

bit  [number_of_blocks-1:0] get_state;
bit  [number_of_blocks-1:0] socket_get_done;
//string                      target_source[number_of_blocks];
//string                      current_clock[number_of_blocks];

reg                         clk_0_hd;
reg                         clk_1_hd;
reg                         clk_2_hd;
reg                         clk_3_hd;
/* verilator lint_off UNUSED */
bit                         success_load_pools;
/* verilator lint_on UNUSED */
 
/*-------------------------------------------------------------------------------------------------*/
  
 /* verilator lint_off UNUSED */  
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
/* verilator lint_on UNUSED */

   //TEMP DEBUG!!! 
   always @(posedge clk_i) begin
      if ( Frng_if.get_time() > 1000)   begin
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
        clk_0_hd  <=  clk_0_h;
        clk_1_hd  <=  clk_1_h;
        clk_2_hd  <=  clk_2_h;
        clk_3_hd  <=  clk_3_h;
      end
      

     always @(posedge clk_i) begin
        arrved_clocks[6]  <=  arrved_clocks[6]   ? 0 : clk_0_h  &  !clk_0_hd;
        arrved_clocks[7]  <=  arrved_clocks[7]   ? 0 : clk_1_h  &  !clk_1_hd;
        arrved_clocks[8]  <=  arrved_clocks[8]   ? 0 : clk_2_h  &  !clk_2_hd;
        arrved_clocks[11] <=  arrved_clocks[11]  ? 0 : clk_3_h  &  !clk_3_hd;
      end

   
     always @(posedge clk_i)          
        if (check_clock_inputs()) begin
            if  (set_put_bits()) begin
                success_load_pools <= load_pools();
                $display ("Load pools competed successfully");
            end     
        end

//debug

//bit [12:0] ar_clk;
 
always @(arrved_clocks)
 for (int i=0; i<13; i++) begin
    $display ("      The clock number %d  status is changed -  %b",i, arrved_clocks[i]);
//    ar_clk[i] <=arrved_clocks[i];
 end 
   
      
//connect  input data ports to data exchange logic

      always @(posedge clk_i) begin           
         if (arrved_clocks[6])  begin
             row_de <= cntrl_table[7];
             row_de.data_to_send.data_bit <= {wen0, i_data0};
             cntrl_table[7]  <= row_de;
           end  
    
         if (arrved_clocks[7])  begin
            row_de <= cntrl_table[8];
            row_de.data_to_send.data_bit <= {wen1, i_data1};
            cntrl_table[8]  <= row_de;
          end  
                      
          if (arrved_clocks[8])  begin
            row_de <= cntrl_table[9];
            row_de.data_to_send.data_bit <= {wen2, i_data2};
            cntrl_table[9]  <= row_de;
           end                            

          if (arrved_clocks[11])  begin
            row_de <= cntrl_table[10];
	    /* verilator lint_off WIDTH */
            row_de.data_to_send.data_bit <= $random;
	    /* verilator lint_on WIDTH */
            cntrl_table[10]  <= row_de;
          end 

      end
      
      
/* verilator lint_off WIDTH */
   assign  {valid, o_data} = received_data[11]; 
/* verilator lint_on WIDTH */

   function void set_init_masks();

       //defines the topology of clocks/per/partitions
       /* verilator lint_off UNDRIVEN */
       /* verilator lint_off BLKSEQ */
       row_t   row_;
   
                  row_.part = part0; row_.clock = clk0;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[0] = row_;
                  row_.part = part0; row_.clock = clk1;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[1] = row_;
                  row_.part = part0; row_.clock = clk2;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[2] = row_;
                  row_.part = part0; row_.clock = clk9;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[3] = row_;
                  row_.part = part1; row_.clock = clk3;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[4] = row_;
                  row_.part = part1; row_.clock = clk4;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[5] = row_;
                  row_.part = part1; row_.clock = clk5;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[6] = row_;
                  row_.part = part1; row_.clock = clk10; row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[7] = row_;
                  row_.part = TARGET; row_.clock = data_clk_0;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[8] = row_;
                  row_.part = TARGET; row_.clock = data_clk_1;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[9] = row_;
                  row_.part = TARGET; row_.clock = data_clk_2;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[10] = row_;
                  row_.part = TARGET; row_.clock = clk11; row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[11] = row_;
                  row_.part = part3; row_.clock = clk9;  row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[12] = row_;
                  row_.part = part3; row_.clock = clk10; row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[13] = row_;
                  row_.part = part3; row_.clock = clk11; row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[14] = row_;
                  row_.part = part3; row_.clock = clk12; row_.mask = 0;  row_.put_ready = 0;
                  cntrl_table[15] = row_;
                 /* verilator lint_on UNDRIVEN */
		 /* verilator lint_on BLKSEQ */
  endfunction

/************************** HUB  LOGIC**********************************************************/

      initial begin
          set_init_masks();
          print_table();
      end

 genvar d;

   generate for (d=0; d< number_of_blocks; d=d+1) begin    

        
     always @(posedge clk_i)   begin
        empty_g[d] <= get_empty_g(d);           
        case (get_state[d])
            0 :   if (empty_g[d] == 0) begin
                      current_entry[d] <= fetch_entry_pg(d);       // take the task attribute from the pool 
                      get_state[d] <= 1;                                
                  end       
            1 :   if (socket_get_done[d] == 1) begin
                      socket_get_done[d] <= 0;			      
                      get_state[d] <= 0; 			  // back to idle state
                  end
                     else  begin
                             socket_get_done[d] <= run_fringe_get(current_entry[d], d);
                         end
        endcase  
      end
     end           
    endgenerate

/* verilator lint_off UNUSED */
    function  bit get_empty_g(int block_no_);
      if (r_cnt[block_no_] >= w_cnt[block_no_])
          return 1;
      else
          return 0;  
    endfunction


    function bit run_fringe_get (int entry_from_pool_, int block_n_);
    //int        pentry_;
    row_t      current_row_;
    string     current_source_;
    string     current_clock_;
    data_in_t  get_data;
    bit        done;   
         current_row_    = cntrl_table[entry_from_pool_];
         current_source_ = current_row_.part.name();
         current_clock_  = current_row_.clock.name();
         done = 1;
         $display ("    --->>>   The entry number %d is taken from the pool number %d", entry_from_pool_, block_n_);
         //done   =  Frng_if.fringe_api_get (current_source_,current_clock_,get_data);
         return done;
    endfunction
/* verilator lint_on UNUSED */
 
    /*

    function bit check_data_exch_completed ();
                for (int k=0; k< number_of_blocks; k=k+1) begin
                     if (empty[k] == 0)
                                return 0;
                end
                return 1; 
    endfunction
*/
/*   
    function void clear_pools(); // temporary, convinient for debugging  
       for (int p_add =0; p_add <  number_of_blocks* number_of_clocks; p_add++) begin
                   pool2get[p_add] = 0;
                   pool2put[p_add] = 0;
       end
    endfunction
*/
/* verilator lint_off UNUSED */
/* verilator lint_off BLKSEQ */
function bit load_pools();
    //this function extracts transactions from topology table and sorts between
    // socket pools

    int     pool_addr;
    row_t   row_;
 
       for (int socket_no=0; socket_no< number_of_blocks; socket_no++) begin
            socket_name = block'(socket_no);
            w_cnt[socket_no] = socket_no * number_of_clocks;
            r_cnt[socket_no] = w_cnt[socket_no];
            $display ("------ INITISLIZED R_CNT = %d", r_cnt[socket_no] );
            for (int entry_=0; entry_< max_rows_no; entry_++) begin
               row_ = cntrl_table[entry_];
               if ((row_.part == socket_name) && (row_.put_ready != 0)) begin
                  pool_addr = w_cnt[socket_no];
                  pool2get[pool_addr] = entry_;
                  //pool2put[pool_addr] = entry_;
                  pool_addr++;
                  w_cnt[socket_no] = pool_addr;
                  $display (" ---- Loading entry_ = %d into the pool %s, with address %d",entry_,  row_.part.name, w_cnt[socket_no]);
               end  //if
            end // for
       end // for
       return 1;
    endfunction
/* verilator lint_on BLKSEQ */
/* verilator lint_on UNUSED */

/* verilator lint_off BLKSEQ */
     function   int fetch_entry_pg  (int socket_no_);
    //for given socket, takes the tranzaction id from the pool, updates pointer
    // and checks the data avaialibility in the current pool

    int pool_addr;
    int entry_from_pool_;
                      begin
                         pool_addr = r_cnt[socket_no_];
                         entry_from_pool_ = pool2get[pool_addr];
                         pool_addr = pool_addr + 1;
                         r_cnt[socket_no_] = pool_addr;
                         $display ("----->>>>Fetch entry from pool #%d, addr = %d,  the fetched_entry = %d",socket_no_,  r_cnt[socket_no_], entry_from_pool_);
                          return   entry_from_pool_;
                     end
    endfunction
/* verilator lint_on BLKSEQ */
/*
    function void init_read_addr();
    //sets pools address pointers to initial value
       for (int no=0;no< number_of_blocks; no++) begin
    	    r_cnt[no] =  no* number_of_clocks;
       end
    endfunction
*/


    function  bit check_clock_inputs();
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
           return 1;      
       end
     endfunction

/* verilator lint_off UNUSED */
/* verilator lint_off BLKSEQ */
  function bit set_put_bits();
    // this function identifiies rows (entries of the table)
    // that supposed to be active at current time (arrived clock edges);
    all_mission_clocks clock_name_;
    int    arrved_clocks_index = 0;
    row_t  row_;
//    int    entry_;
    bit success_ = 0;

      set_init_masks();
      print_table();             
      for (int entry_=0; entry_< max_rows_no; entry_++) begin
            row_ = cntrl_table[entry_];
            clock_name_ = row_.clock;
            arrved_clocks_index  = all_mission_clocks'(clock_name_);
           // $display ("    clock = %s, entry = %d,  arrved_clocks_index = %d", row_.clock.name(), entry_, arrved_clocks_index );
            if (arrved_clocks[arrved_clocks_index] == 1)  begin
           	row_.put_ready = 1;
           	if (row_.mask == 0)  begin
           	     cntrl_table[entry_] = row_;
           	end   
            end //if (arrved_clocks[a		  
      end //  for (int entry
      print_table();
      success = 1;
      return  success_;   
     endfunction
/* verilator lint_on BLKSEQ */

    function void print_row(int entry_);
        row_t   row;
	     row =  cntrl_table[entry_];
             $display ( "entry = %d, part = %s, clock=%s, mask = %b, put_ready= %d",
                         entry_, row.part.name(), row.clock.name(), row.mask, row.put_ready);
    endfunction
/* verilator lint_on UNUSED */

 function void print_table();
     for (int r=0; r <  max_rows_no; r++) begin
          // row =  cntrl_table[r];
           print_row(r);
     end

    endfunction




		      
endinterface : part_2_init_if
