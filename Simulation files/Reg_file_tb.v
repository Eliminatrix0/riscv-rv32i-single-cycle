`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2025 16:19:29
// Design Name: 
// Module Name: Reg_file_tb
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


module Reg_file_tb();
    reg clk, rst, we3;
    reg [31:0] wd3, ad1, ad2, ad3;
    wire [31:0] rd1, rd2;
    integer i;
    Reg_file RF (clk,rst,we3,ad1,ad2,ad3,wd3,rd1,rd2);
    always #5 clk = ~clk;
    initial
        begin
            clk = 0; rst = 1'bx;
            #7 rst = 0;
            for(i = 0; i<31; i=i+1)
                begin
                    #2 ad1 = i;
                    ad2 = i+1;
                end
            #2 we3 = 1; wd3 = 'hffffffff; ad3 = 'd15;
            #12 ad1 = 'd15; 
            #10 rst = 1'b1;
            for(i = 0; i<31; i=i+1)
                begin
                    #2 ad1 = i;
                    ad2 = i+1;
                end
            #12 $finish;
        end
endmodule
