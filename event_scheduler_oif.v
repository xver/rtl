
module event_scheduler (input clk_i);

parameter       clock_number = 9;
parameter       mem_size  =  32;  // exceeds the longest clock period
integer         clock_ind;
reg [clock_number-1:0]mem[mem_size];
integer time_slot;

initial 
 begin
   for (time_slot = 0; time_slot <mem_size; time_slot = time_slot+1) begin
         mem[time_slot] = {clock_number{1'b0}};
   end
   mem[0] = {clock_number{1'b1}};
   tb.cgif.clk =  {clock_number{1'b0}};
end

always @(tb.cgif.clk_i) 
 begin
   if (cgif.freeze == 0) begin 
      schedule_event(time_slot);
      time_slot = time_slot < mem_size ? time_slot + 1 : 0;
   end //if   
end


task schedule_event ;
input integer time_slot_num;
integer clock_ind,  scheduled_time_slot;
bit [clock_number-1:0] current_clk_state, scheduled_clk_state;

current_clk_state = mem[time_slot];

for (clock_ind = 0; clock_ind < clock_number; clock_ind = clock_ind + 1) begin
    if (current_clk_state[clock_ind] == 1) begin

         // Tougle clock value
         tb.cgif.clk[clock_ind] = ~tb.cgif.clk[clock_ind];
         // Set next clock tougle event
         scheduled_time_slot = calc_scheduled_slot(time_slot, clock_ind);
         scheduled_clk_state = mem[scheduled_time_slot];
         scheduled_clk_state[clock_ind] = 1'b1;
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
input integer time_slot, clock_ind;
integer scheduled_time_slot;

if (time_slot + tb.cgif.clk_hp[clock_ind]<mem_size) begin
    scheduled_time_slot = time_slot + tb.cgif.clk_hp[clock_ind];
end else begin
    scheduled_time_slot = time_slot + tb.cgif.clk_hp[clock_ind] - mem_size;
end

return scheduled_time_slot;

endfunction

endmodule

/*
module tb;

clk_gen_if       cgif();
event_scheduler  dut();


initial begin
   #1000 $finish;
end

always #1 cgif.clk_i++;

initial begin
   $dumpfile("clk_gen.vcd");
   $dumpvars(0, tb);
end

endmodule
*/

interface clk_gen_if;
parameter     clock_number = 9;

logic [clock_number-1:0] clk;
logic freeze = 0;
logic clk_i = 0;
int         clk_hp[clock_number-1:0] ;

initial begin
 clk_hp[0] = 3;
 clk_hp[1] = 4;
 clk_hp[2] = 5;
 clk_hp[3] = 6;
 clk_hp[4] = 7;
 clk_hp[5] = 8;
 clk_hp[6] = 9;
 clk_hp[7] = 10;
 clk_hp[8] = 11;
 foreach (clk_hp[i]) $display ("Clock # 0%d equals %d", i, clk_hp[i] );
end


endinterface
