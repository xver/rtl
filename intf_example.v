interface intf (input clk); 
logic read, enable;
logic [7:0] addr,data; 

modport dut (input read,enable,addr,output data); 
modport tb (output read,enable,addr,input data); 
endinterface :intf 


module Dut (intf.dut dut_if); // declaring the interface with modport 
//.... 
//assign dut_if.data = temp1 ? temp2 : temp3 ; // using the signal in interface 
//always @(posedge intf.clk) 
//.... 
endmodule 


module Testbench(intf.tb tb_if); 
//..... 
//..... 
endmodule



 module top(); 
 logic clk; 
 intf bus_if(clk); // interface instantiation 
 Dut d(bus_if.dut); // Pass the interface 
 Testbench TB (Bus_if.tb); // Pass the interface 
 endmodule 