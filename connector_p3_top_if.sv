/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSED */
interface connector_p3_top_if ;

logic valid;
logic [7:0] data;


bit  valid_out;
bit [7:0] o_data_out;
bit freeze = 0;

always @(*)
begin
valid_out = valid;
o_data_out = data;
end

endinterface
/* verilator lint_on DECLFILENAME */
/* verilator lint_on UNUSED */
