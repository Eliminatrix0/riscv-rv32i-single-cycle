`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Me
// 
// Create Date: 20.06.2025 15:34:44
// Design Name: RV32I datapath
// Module Name: datapath
// Project Name: RISC-V RV32I Single cycle processor
// Target Devices: 
// Tool Versions: 
// Description: Support for R,I,S and B type instructions; only a few
// 
// Dependencies: DM, IM, Imm_sign_extend, Reg_file & ALU. 
//               Connections made with muxes wherever required.
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module datapath(
    input clk, rst,
    input RF_WEN, DM_WEN,                       //write enables to RF and DM
    input sel_srcB,                             //srcB select signal
    input [1:0] sel_ld,                         //RF write (load) in source select signal
    input br_taken,                             //Branch target(PC source) select signal
    input[1:0] sel_imm,                         //immediate field selecct signals
    input [1:0] sel_s, sel_l, sel_exec_out,     //Exec_unit operation select signals
    input sel_a,sel_comp,
    output [31:0] instr,                        //Instruction from IM
    output z, c, n                              //ALU flags
    ); 
    wire [4:0] rs1, rs2, rd;    //Register address fields
    reg [31:0] rf_wd; wire [31:0] rf_rd2, dm_rd, dm_wd; //RF write in, RF read ou port2, DM read out & DM write in lines
    wire [31:0] srcA, srcB, imm, exec_out;              //Exec(ALU) data inputs & Imm module output
    wire [31:0] pc_nxt, nxt_instr, pc_trgt;             //Next instr addr to PC, PC input wire & Branch target to PC
    reg [31:0] pc;                                      //PC register
    
    initial pc = 'd0;
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];
    assign dm_wd = rf_rd2;          //data to be written to DM comes from read port 2 of RF
    
    //Mux logic assignments
    assign srcB = ((sel_srcB)? imm : rf_rd2);               //srcB select mux
    
    always @ (*)                                            //RF write in data select mux
        begin
            case(sel_ld)
                2'b00: rf_wd = exec_out;    //ALU output
                2'b10: rf_wd = dm_rd;       //Data mem value (lw instr)
                2'b01: rf_wd = nxt_instr;   //pc + 4 value (J-type)
            endcase
        end          
    
    assign pc_nxt = ((br_taken)? pc_trgt : nxt_instr);      //PC value-in mux
    assign pc_trgt = pc + imm;                              //Branch target value
    assign nxt_instr = pc + 'd4;                            //Next instruction is the next word location, so +4 

    always  @ (posedge clk)
        begin       
            if(rst ==1'b1)
                pc <= 'd0;
            else    
                pc <= pc_nxt;
        end
    
    IM instr_memory (rst, pc, instr);
    Reg_file RF (.clk(clk), .rst(rst), .we3(RF_WEN), .ad1(rs1), .ad2(rs2), .ad3(rd), .wd3(rf_wd), .rd1(srcA), .rd2(rf_rd2));
    Imm_Sign_Extend sign_ext (sel_imm, instr, imm);
    ALU exec_unit (srcA, srcB, sel_a, sel_comp, sel_s, sel_l, sel_exec_out, z,c,n, exec_out);
    DM data_mem (clk, rst, DM_WEN, exec_out, dm_wd, dm_rd);
endmodule
