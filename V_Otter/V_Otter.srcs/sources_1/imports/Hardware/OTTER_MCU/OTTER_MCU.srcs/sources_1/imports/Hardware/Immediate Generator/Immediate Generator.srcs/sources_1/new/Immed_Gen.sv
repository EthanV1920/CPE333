`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 02/01/2024 12:49:06 PM
// Design Name: Immed_Gen
// Module Name: Immed_Gen
// Project Name: Immediate Generator
// Target Devices: BASYS3 Board
// Description: Generates formatted immediate value 
//              for each type of assembly code instruction
// Revision 0.01 - File Created
// Revision 0.02 - I-Type immediate logic updated to accomodate srai, srli, and slli
//////////////////////////////////////////////////////////////////////////////////

module Immed_Gen(
    input [31:0] Instruction,
    output [31:0] U_Type,
    output [31:0] I_Type,
    output [31:0] S_Type,
    output [31:0] J_Type,
    output [31:0] B_Type
    );
   
    assign U_Type = {Instruction[31:12], {12{1'b0}}};
    assign I_Type = {{21{Instruction[31]}},Instruction[30:20]};
    assign S_Type = {{21{Instruction[31]}}, Instruction[30:25], Instruction[11:7]};
    assign B_Type = ({Instruction[31:12]} == 21'b0) ? 32'b1 : {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
    assign J_Type = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
    // assign J_Type = ({Instruction[31:12]} == 21'b0) ? 32'b00000001 : {{11{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
    //default for J-Type is register 1 if unspecified
endmodule
