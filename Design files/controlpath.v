`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Me
// 
// Create Date: 20.06.2025 15:34:44
// Design Name: 
// Module Name: controlpath
// Project Name: RISC-V RV32I Single cycle processor
// Target Devices: 
// Tool Versions: 
// Description: Control unit of the processor. Decodes the instruction word and genreates 
//              required control signals for the sub-blocks.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: for R & I-types, func7_5 doesn't matter much as just the func3 field is different. The only place where decoding became problematic
// was for add, addi & sub. No prob for SRL and SRA also as only lower 5-bits are considered for shift. Awesome ISA encoding.
//////////////////////////////////////////////////////////////////////////////////


module controlpath(
    input [31:0] instr,         //full instruction from IM, not needed as only a few bits needed by CU
    input z, c, n,              //ALU status flags
    output reg RF_WEN, DM_WEN,                          //write enables to RF and DM
    output reg sel_srcB,                                //srcB select signal
    output reg [1:0] sel_ld,                            //RF write (load) in source select signal
    output reg br_taken,                                //Branch target(PC source) select signal
    output reg [1:0] sel_imm,                           //immediate field select signals
    output reg [1:0] sel_s, sel_l, sel_exec_out,        //Exec_unit operation select signals
    output reg sel_a, sel_comp
    );
    wire [6:0] op;          //Opcode
    wire [2:0] func3;       //func3 field
    wire func7_5;           //5th bit(MSB-1) of the func7 field
    
    assign op = instr[6:0];
    assign func3 = instr[14:12];
    assign func7_5 = instr[30];
    
    always @ (*)
        begin
            case(op)
                7'b0110011, 7'b0010011: begin   //R-type & I-type instructions; only op[5] is different
                                RF_WEN = 1'b1; DM_WEN = 1'b0;   //Writes to RF and not DM 
                                sel_srcB = op[5]?1'b0 : 1'b1;   //srcB selection based on I or R-type 
                                sel_ld = 2'b00;                  //Not loading anything from DM
                                br_taken = 1'b0;                //No branching in R or I-type, so 0.
                                sel_imm = op[5]?2'bxx:2'b00;    //if I-type, set imm select lines to 00 
                                casex({func3, func7_5})
                                    4'b000x: begin  //add, addi & sub
                                                if ((op[5] == 1'b0)) begin   //addi condition
                                                    sel_a = 'b0; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
                                                    sel_exec_out = 'b00;    end
                                                else                        //means R-type
                                                begin
                                                    case (func7_5)
                                                        1'b0: begin    //add condition
                                                            sel_a = 'b0; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
                                                            sel_exec_out = 'b00;
                                                              end
                                                        1'b1: begin    //sub condition
                                                            sel_a = 'b1; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
                                                            sel_exec_out = 'b00; 
                                                              end
                                                    endcase
                                                end
                                             end
                                    4'b011x: begin  //sltu and sltui
                                                sel_a = 'b1; sel_comp = 'b0;sel_s = 'bxx; sel_l = 'bxx;
                                                sel_exec_out = 'b01;
                                             end
                                    4'b010x: begin  //slt and slti
                                                sel_a = 'b1; sel_comp = 'b1;sel_s = 'bxx; sel_l = 'bxx;
                                                sel_exec_out = 'b01;
                                             end
                                    4'b0010: begin  //sll and slli
                                                sel_a = 'bx; sel_comp = 'bx;sel_s = 'b0x; sel_l = 'bxx;
                                                sel_exec_out = 'b11;
                                             end
                                    4'b1010: begin //srl & srli
                                                sel_a = 'bx; sel_comp = 'bx;sel_s = 'b10; sel_l = 'bxx;
                                                sel_exec_out = 'b11;
                                             end
                                    4'b1011: begin //sra & srai
                                                sel_a = 'bx; sel_comp = 'bx;sel_s = 'b11; sel_l = 'bxx;
                                                sel_exec_out = 'b11;
                                             end
                       //since shifter takes only the lower 5 bits of imm, the func7_5 being 1 won't be a problem
                                    4'b100x: begin //xor
                                                sel_a = 'bx; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'b00;
                                                sel_exec_out = 'b10;
                                             end
                                    4'b110x: begin  //or
                                                sel_a = 'bx; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'b01;
                                                sel_exec_out = 'b10;
                                             end
                                    4'b111x: begin  //and
                                                sel_a = 'bx; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'b10;
                                                sel_exec_out = 'b10;
                                             end
                                    default: begin  //add
                                                sel_a = 'b0; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
                                                sel_exec_out = 'b00;
                                             end
                                endcase
                            end
                7'b0000011: begin   // LOAD (I-type) instruction
                                RF_WEN = 1'b1; DM_WEN = 1'b0;   //Writes to RF and not DM 
                                sel_srcB = 1'b1;                //srcB needs to be imm
                                sel_ld = 2'b10;                  //Loading from DM, so load enable is 1.
                                br_taken = 1'b0;                //No branching in I-type, so 0.
                                sel_imm = 2'b00;                //select imm fields for I-type 
                                case(func3)
                                    3'b010: begin //load word
                                                sel_a = 'b0; sel_comp = 'bx;sel_s = 'bx; sel_l = 'bx;
                                                sel_exec_out = 'b00;
                                            end
                                    default: begin //load word
                                                sel_a = 'b0; sel_comp = 'bx;sel_s = 'bx; sel_l = 'bx;
                                                sel_exec_out = 'b00;
                                            end
                                endcase
                            end
                7'b0100011: begin   //S-type instruction
                                //case(func3)                   Not needed as I am implementing only store word.
                                RF_WEN = 1'b0; DM_WEN = 1'b1;   //Writes to DM and not RF
                                sel_srcB = 1'b1;                //only imm used here
                                sel_ld = 2'b00;                  //Not loading from DM, so load enable is 0.
                                br_taken = 1'b0;                //No branching in S-type, so 0.
                                sel_imm = 2'b01;                //select imm fields for S-type
                                //need to add offset, so alu needs to do add    
                                sel_a = 'b0; sel_comp = 'bx;sel_s = 'bx; sel_l = 'bx;
                                sel_exec_out = 'b00;
                            end 
                7'b1100011: begin   //B-type instruction
                                RF_WEN = 1'b0; DM_WEN = 1'b0;   //Writes to neither DM nor RF
                                sel_srcB = 1'b0;                //only imm used here
                                sel_ld = 2'b00;                  //Not loading from DM, so load enable is 0.
                                sel_imm = 2'b10;                //select imm fields for B-type
                                case(func3)
                                    3'b000: begin //beq consition
                                //need to subtract and check if result = 0. This would mean operands are equal    
                                                sel_a = 'b1; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
                                                sel_exec_out = 'b00; 
                                                br_taken = z;                //depends on zero flag     
                                            end   
                                    default: begin //beq
                                //need to subtract and check if result = 0. This would mean operands are equal    
                                                sel_a = 'b1; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
                                                sel_exec_out = 'b00; 
                                                br_taken = z;                //depends on zero flag     
                                             end 
                                endcase
                            end
                7'b1101111: begin   //J-type instruction
                                RF_WEN = 1'b1; DM_WEN = 1'b0;   //Writes to RF and not DM 
                                sel_srcB = 1'b1;                //srcB needs to be imm
                                sel_ld = 2'b01;                  //Not loading anything from DM
                                br_taken = 1'b1;                //Unconditional branch, branch is always taken.
                                sel_imm = 2'b11;                //if J-type, set imm select lines to 11 
                                //ALU doesn't need to do anything, so lets put add controls
                                sel_a = 'b0; sel_comp = 'bx;sel_s = 'bxx; sel_l = 'bxx;
                                sel_exec_out = 'b00;                                
                            end
                                                                                           
            endcase
        end
endmodule
