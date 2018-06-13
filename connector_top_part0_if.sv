/* verilator lint_off UNUSED */
interface connector_top_part0_if;

logic clk0;
logic clk1;
logic clk2;
logic clk3;
logic resetn;
logic wen0;
logic wen1;
logic wen2;
logic [7:0] data0;
logic [7:0] data1;
logic [7:0] data2;


bit [12:0]  clk;
bit	    reset_n;
bit [8:0]   wen;
bit [7:0]   i_data0, i_data1, i_data2;
bit	    freeze = 0;
   
   
  always @(*)
     begin
	clk[9]  = clk0;
	clk[0]  = clk1;
	clk[1]  = clk2;
	clk[2]  = clk3;
	reset_n = resetn;
   end
   
always @(*)
begin
wen[0]  = wen0;
i_data0 = data0;
end

always @(*)
begin
wen[1]  = wen1;
i_data1 = data1;
end			    


always @(*)
begin
wen[2]  = wen2;
i_data2 = data2;
end


endinterface // connector_top_part0_if
/* verilator lint_on UNUSED */
