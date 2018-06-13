module connector_p0_top (input valid,
                         input [7:0] data
                         );

bit [2:0] valid0;
bit [7:0] o_data_0;
bit freeze = 0;

always @(*)
begin
valid0[0] = valid;
o_data_0 = data;
end
endmodule

module connector_p1_top (input valid,
                         input [7:0] data
                         );

bit [2:0] valid0;
bit [7:0] o_data_1;
bit freeze = 0;

always @(*)
begin
valid0[1] = valid;
o_data_1 = data;
end
endmodule

module connector_p2_top (input valid,
                         input [7:0] data
                         );

bit [2:0] valid0;
bit [7:0] o_data_2;
bit freeze = 0;

always @(*)
begin
valid0[2] = valid;
o_data_2 = data;
end
endmodule