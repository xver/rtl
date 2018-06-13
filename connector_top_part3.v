
/* verilator lint_off UNUSED */
module connector_top_part3( input clk0,
                            input clk1,
			                input clk2,
			                input clk3,
			                input resetn,
			                input wen0,
			                input wen1,
			                input wen2,
			                input [7:0] data0,
			                input [7:0] data1,
			                input [7:0] data2
			                );
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




endmodule // connector_top_part3
/* verilator lint_on UNUSED */