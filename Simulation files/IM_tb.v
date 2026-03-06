`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2025 15:49:00
// Design Name: 
// Module Name: IM_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IM_tb();
    reg rst;
    reg [31:0] iad;
    wire [31:0] instr;
    integer i;
    IM instr_mem (rst, iad, instr);
    
    initial
        begin
            for(i = 0;i<100;i=i+1)
                #2 iad = i;
            #2 rst = 1'b1;
            #5 $finish;   
        end
endmodule
