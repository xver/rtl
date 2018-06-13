/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSED */
interface connector_p0_top_if ;

logic valid;
logic [7:0] data;


bit [2:0] valid0;
bit [7:0] o_data_0;
bit freeze = 0;

always @(*)
begin
valid0[0] = valid;
o_data_0 = data;
end

endinterface
/* verilator lint_on DECLFILENAME */
/* verilator lint_on UNUSED */
