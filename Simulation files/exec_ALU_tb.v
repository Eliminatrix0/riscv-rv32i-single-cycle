`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2025 15:06:10
// Design Name: 
// Module Name: exec_ALU_tb
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


module exec_ALU_tb();
    reg signed[31:0] srcA, srcB;              //Two 32-bit inputs to the ALU
    reg sel_a, sel_comp;                //add/sub & slt/sltu operation select
    reg [1:0] sel_s, sel_l;             //shift type and logical operation select
    reg [1:0] sel_exec_out;             //selecting exec unit output (Mux sel)
    wire z, c, n;                       //Zero, carry, negative flags
    wire [31:0] exec_out;               //exec unit final output
    
    ALU exec_unit_dut (srcA,srcB,sel_a,sel_comp,sel_s,sel_l,sel_exec_out,z,c,n,exec_out);
    
    initial begin
            srcA = 0;srcB = 0;
            sel_a = 'bx; sel_comp = 'bx;sel_s = 'bx; sel_l = 'bx;
            sel_exec_out = 'bx;
            
            #10 srcA = 1;srcB = 1;  //add
            sel_a = 'b0; sel_comp = 'bx;sel_s = 'bx; sel_l = 'bx;
            sel_exec_out = 'b00;
            
            #10 srcA = -10;srcB = 9; //sub
            sel_a = 'b1; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
            sel_exec_out = 'b00;
            
            #10 srcA = 555;srcB = 555;    //sub with zero result
            sel_a = 'b1; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
            sel_exec_out = 'b00;
            
            #10 srcA = 555;srcB = 34;        //sltu
            sel_a = 'b1; sel_comp = 'b0;sel_s = 'bxx; sel_l = 'bxx;
            sel_exec_out = 'b01;
            
            #10 srcA = 'hf0000000; srcB = 'd34;        //slt
            sel_a = 'b1; sel_comp = 'b1;sel_s = 'bxx; sel_l = 'bxx;
            sel_exec_out = 'b01;
            
            #10 srcA = 'd2;srcB = 'd5;    //sll
            sel_a = 'bx; sel_comp = 'bx;sel_s = 'b0x; sel_l = 'bxx;
            sel_exec_out = 'b11;
            
            #10 srcA = 'd32;srcB = 'd5;    //srl
            sel_a = 'bx; sel_comp = 'bx;sel_s = 'b10; sel_l = 'bxx;
            sel_exec_out = 'b11;
            
            #10 srcA = -32'd128;srcB = 'd7;    //sra
            sel_a = 'bx; sel_comp = 'bx;sel_s = 'b11; sel_l = 'bxx;
            sel_exec_out = 'b11; 
            
            #10 srcA = 'b111;srcB = 'b111;    //xor
            sel_a = 'bx; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'b00;
            sel_exec_out = 'b10;
            
            #10 srcA = 'b111;srcB = 'b000;    //or
            sel_a = 'bx; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'b01;
            sel_exec_out = 'b10;
            
            #10 srcA = 'b111;srcB = 'b110;    //and
            sel_a = 'bx; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'b10;
            sel_exec_out = 'b10;
            
            #10 $finish;
            
            end

endmodule
