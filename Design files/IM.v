`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2025 15:39:40
// Design Name: 
// Module Name: IM
// Project Name: RISC-V RV32I Single cycle processor
// Target Devices: 
// Tool Versions: 
// Description: Instruction memory. It is a Read only memory, so it doesn't need clock.
//              The reads are combinational.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IM(
    input rst,
    input [31:0] iad,       //instr. address
    output reg [31:0] instr
    );
    integer i;
    reg [31:0] mem [0:99];  //100 locations 
    
//    initial
//        begin
//            for (i = 0; i <=5; i = i+1)
//                mem[i] = i;
//        end

    // Instruction memory initialization for testbench. Only R & I.
//    initial begin
//        // lw x1, 0(x10) - Load word from memory address in x10 to x1
//        mem[0] = 32'b000000000000_01010_010_00001_0000011;
        
//        // addi x2, x1, 5 - Add immediate 5 to x1, store result in x2  
//        mem[1] = 32'b000000000101_00001_000_00010_0010011;
        
//        // lw x3, 4(x10) - Load word from memory address (x10+4) to x3
//        mem[2] = 32'b000000000100_01010_010_00011_0000011;
        
//        // add x4, x1, x3 - Add x1 and x3, store result in x4
//        mem[3] = 32'b0000000_00011_00001_000_00100_0110011;
        
//        // sub x5, x4, x2 - Subtract x2 from x4, store result in x5
//        mem[4] = 32'b0100000_00010_00100_000_00101_0110011;
        
//        // sll x6, x5, x2 - Shift left x5 by lower 5 bits of x2, store in x6
//        mem[5] = 32'b0000000_00010_00101_001_00110_0110011;
//    end

// Instruction memory initialization for testbench, R,I,S and B.
    initial begin
        // addi x1, x0, 10 - Load immediate value 10 into x1
        mem[0] = 32'b000000001010_00000_000_00001_0010011;
        
        // addi x2, x0, 10 - Load immediate value 10 into x2
        mem[1] = 32'b000000001010_00000_000_00010_0010011;
        
        // sw x1, 0(x10) - Store word from x1 to memory address in x10
        mem[2] = 32'b0000000_00001_01010_010_00000_0100011;
        
        // beq x1, x2, skip - Branch to 'skip' if x1 equals x2 (offset = +2 locations)
        mem[3] = 32'b0000000_00010_00001_000_00010_1100011;
        
        // addi x3, x0, 99 - This instruction will be skipped
        mem[4] = 32'b000001100011_00000_000_00011_0010011;
        
        // skip: addi x4, x0, 5 - Load immediate value 5 into x4
        mem[5] = 32'b000000000101_00000_000_00100_0010011;
    end

  
    always @ (*)                            
        if (rst == 1'b1) begin
            for (i = 0; i <=99; i = i+1)
                mem[i] = 'd0;
            end
        else
            begin 
                instr = mem[iad];          //read instr. out  
            end 
    
endmodule