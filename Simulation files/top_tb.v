`timescale 1ns / 1ps

module top_tb();
    reg clk, rst;
    wire [31:0] instr;
    wire z, c, n;
    
    top_module processor (
        clk, rst,
        instr,
        z, c, n
        );
        
    initial 
        begin
            clk = 1'b0; rst = 1'b0;
            #150 rst = 1'b1;
            #150 $finish;
        end
    
    always #10 clk = ~clk;
endmodule
