/* verilator lint_off UNUSED */
interface connector_top_part2_if; 
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
bit [8:0] wen;
bit [7:0] i_data6, i_data7, i_data8;
bit freeze = 0;

always @(*)
begin
clk[11]  = clk0;
clk[6]  = clk1;
clk[7]  = clk2;
clk[8]  = clk3;
reset_n = resetn;
end

always @(*)
begin
wen[6]  = wen0;
i_data6 = data0;
end

always @(*)
begin
wen[7]  = wen1;
i_data7 = data1;
end

always @(*)
begin
wen[8]  = wen2;
i_data8 = data2;
end

endinterface // connector_top_part2
/* verilator lint_on UNUSED */
