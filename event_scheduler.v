/*verilator lint_off UNUSED */

module event_scheduler (input clk_i,
                        input freeze,
			output [12:0] clk,
			output [12:0] clk_h
			);

parameter               clock_number = 13;
int                     clk_hp[clock_number-1:0];
parameter               mem_size  =  32;  // exceeds the longest clock period
//integer                 clock_ind;
reg     [12:0]          mem[mem_size-1:0];
integer                 time_slot,i;
reg  [12:0]             clk;
reg  [12:0]             clk_s, clk_u;
reg  [12:0]             clk_h;
//reg     clk[clock_number-1:0];

`ifdef target  
initial   $display ("------------------ CLKGEN COMPILED FOR TARGET ----------------------"); 
`endif

`ifdef initiator  
initial   $display ("------------------ CLKGEN COMPILED FOR INITIATOR ----------------------"); 
`endif

initial begin
 clk_hp[0]  = 14;
 clk_hp[1]  = 13;
 clk_hp[2]  = 12;
 clk_hp[3]  = 11;
 clk_hp[4]  = 10;
 clk_hp[5]  = 9;
 clk_hp[6]  = 8;
 clk_hp[7]  = 7;
 clk_hp[8]  = 6;
 clk_hp[9]  = 5;
 clk_hp[10] = 4;
 clk_hp[11] = 3;
 clk_hp[12] = 2;
 for (i=0; i<13;i=i+1)
     $display ("Clock # 0%d equals %d", i, clk_hp[i] );
end

initial 
 begin
   for (time_slot = 0; time_slot <mem_size; time_slot = time_slot+1) begin
         mem[time_slot] = {clock_number{1'b0}};
   end
   mem[0] =   {clock_number{1'b1}};
   clk_s =    {clock_number{1'b0}};
end

always @(posedge clk_i )
if (freeze == 0) begin
      clk_u <= clk_s;
      clk <= clk_u;
end



always @(posedge clk_i)
if (freeze == 0) begin
    clk_h <= clk;
end

//always @(posedge clk_i or negedge clk_i) 
always @(posedge clk_i) 
 begin
   if (freeze == 0) begin 
      schedule_event;
      time_slot = time_slot < mem_size ? time_slot + 1 : 0;
   end //if   
end


task schedule_event ;
//input integer time_slot_num;
integer clock_ind_task,  scheduled_time_slot;
reg [12:0] current_clk_state, scheduled_clk_state;

current_clk_state = mem[time_slot];

for (clock_ind_task = 0; clock_ind_task < clock_number; clock_ind_task = clock_ind_task + 1) begin
    if (current_clk_state[clock_ind_task] == 1) begin

         // Togle clock value
        /*verilator lint_off BLKSEQ */
	 clk_s[clock_ind_task] = ~clk_s[clock_ind_task];
	
         // Set next clock tougle event
         scheduled_time_slot = calc_scheduled_slot(clock_ind_task);
         scheduled_clk_state = mem[scheduled_time_slot];
         scheduled_clk_state[clock_ind_task] = 1'b1;
         mem[scheduled_time_slot] = scheduled_clk_state;
        // debugging
        // $display($time, "  time slot = %0d, current_state = %h, scheduled slot = %0d, scheduled_state = %h",
        //         time_slot, current_clk_state, scheduled_time_slot ,  scheduled_clk_state);
    end
end
//Cleaning current time slot
mem[time_slot] = {clock_number {1'b0}};

endtask

function integer calc_scheduled_slot;
input integer  clock_ind_task_i;
integer scheduled_time_slot;

if (time_slot + clk_hp[clock_ind_task_i]<mem_size) begin
    scheduled_time_slot = time_slot + clk_hp[clock_ind_task_i];
end else begin
    scheduled_time_slot = time_slot + clk_hp[clock_ind_task_i] - mem_size;
end

return scheduled_time_slot;

endfunction

endmodule

