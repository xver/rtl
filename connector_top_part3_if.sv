/* verilator lint_off UNUSED */
interface connector_top_part3_if;

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

bit [12:0] clk;
bit reset_n;
bit [2:0] valid0;
bit [7:0] o_data_0, o_data_1, o_data_2;
bit freeze = 0;

always @(*)
begin
clk[12]   = clk0;
clk[9]    = clk1;
clk[10]    = clk2;
clk[11]    = clk3;
reset_n   = resetn;
end

always @(*)
begin
valid0[0]  = wen0;
o_data_0   = data0;
end


always @(*)
begin
valid0[1]  = wen1;
o_data_1   = data1;
end



always @(*)
begin
valid0[2]  = wen2;
o_data_2   = data2;
end




endinterface // connector_top_part3_if
/* verilator lint_on UNUSED */
