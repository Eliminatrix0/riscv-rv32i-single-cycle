`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Me
// 
// Create Date: 20.06.2025 15:39:40
// Design Name: Data memory
// Module Name: DM
// Project Name: RISC-V RV32I Single cycle processor
// Target Devices: 
// Tool Versions: 
// Description: The reads are combinational. Writes happen at +ve clock edge if WE is 1.
//              Mis-aligned word addressing not supported. DM is byte addressible, but
//              the processor is word-oriented.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DM(
    input clk, rst, we,     //write enable; high during store instruction only
    input [31:0] ad, wd,    //address bus and write in data bus
    output reg [31:0] rd    //read out bus
    );
    integer i;
    reg [31:0] DM [0:100];  //100 locations, one word in each location 
    
//    initial
//        begin
//            for (i = 0; i <=100; i = i+1)
//                DM[i] = i;
//        end  
    initial begin
        // Initialize memory locations to known values for verification of the R,I,S & B sample code in IM.
        DM[32'h00001000] = 32'hDEADBEEF;  // Initial value at base address
        DM[32'h00001004] = 32'hCAFEBABE;  // Adjacent memory location
        // Other locations can be initialized to 0 or random values
    end
  
    
    always @ (posedge clk)
        begin
            if(rst == 1'b1) begin
                for(i = 0; i < 100; i = i + 1)
                    DM[i] <= 'd0;
            end
            else
                begin
                    if (we == 1'b1) begin  //write enable asserted
                        DM[ad] <= wd;     //write at clk edge
                    end  
                end
        end
        
        always @ (*)     
        begin
            rd = DM[ad];
        end 
endmodule
