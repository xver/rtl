module clock_gen (
                 input      [12:0] clk_en,
				 output reg [12:0] clk
				 );
				 
Parameter int [12:0] halh_period = {1,2,3,4,45,46,47,48,49, 50,51,52,53};
integer clk_no;
integer time_cnt[12:0] 
 
 initial
    for (clk_no = 0; clk_no<13; clk_no = clk_no+1) 
        clk[clk_no] = 0;
 
 always 
    for (clk_no = 0; clk_no<13; clk_no = clk_no+1)
        if (|clk_en)  begin
		    #1 time_cnt[clk_no] = time_cnt < half_period[clk_no] ? time_cnt[clk_no] + 1 : 0;
			clk[clk_no] = time_cnt < half_period[clk_no] ? clk[clk_no] : ~clk[clk_no];
		end
 		
 

endmodule