`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Arun
// 
// Create Date: 22.06.2025 12:10:44
// Design Name: RISC-V processor
// Module Name: top_module
// Project Name: RISC-V RV32I Single cycle processor implementing R, I, S, B & J-type instructions
// Description: Integrates datapath and control path. Outputs just for verification purpose.
// 
// Dependencies: datapath, controlpath
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module(
    input clk, rst,
    output [31:0] instr,                        //Instruction from IM
    output z, c, n                             //ALU flags
    );
    wire RF_WEN, DM_WEN;                       //write enables to RF and DM
    wire sel_srcB, br_taken;                   //srcB & branch target(PC source) select signals
    wire [1:0] sel_imm, sel_ld;                //immediate field & load RF select signals
    wire [1:0] sel_s, sel_l, sel_exec_out;     //Exec_unit operation select signals
    wire sel_a,sel_comp;
    
    //wire [31:0] instr;
    
    datapath D1 (
        clk, rst,
        RF_WEN, DM_WEN,                     //write enables to RF and DM
        sel_srcB, sel_ld, br_taken,         //srcB, load & branch target(PC source) select signals
        sel_imm,                            //immediate field selecct signals
        sel_s, sel_l, sel_exec_out,         //Exec_unit operation select signals
        sel_a,sel_comp,
        instr,                              //Instruction from IM
        z, c, n                             //ALU flags
        ); 
        
    controlpath CU (
        instr,                              //full instruction from IM, not needed as only a few bits needed by CU
        z, c, n,                            //ALU status flags
        RF_WEN, DM_WEN,                     //write enables to RF and DM
        sel_srcB, sel_ld, br_taken,         //srcB, load & branch target(PC source) select signals
        sel_imm,                            //immediate field selecct signals
        sel_s, sel_l, sel_exec_out,         //Exec_unit operation select signals
        sel_a, sel_comp 
    );
endmodule
