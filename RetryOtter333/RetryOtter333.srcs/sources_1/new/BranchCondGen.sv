`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 02/09/2024 10:59:00 AM
// Design Name: Branch_Condition_Generator
// Module Name: Branch_Condition_Generator
// Project Name: Branch_Cond_Gen
// Target Devices: Basys3 Board
// Description: Evaluation for conditional
// assembly instructions
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module BranchCondGen(
    input [31:0] br1,
    input [31:0] br2,
    output logic br_eq,
    output logic br_lt,
    output logic br_ltu
    );
        //checking for equality
    assign br_eq = (br1 == br2) ? 1'b1 : 1'b0;
        //checking if rs1 is less than rs2 when evaluated as signed values
    assign br_lt = ($signed(br1) < $signed(br2)) ? 1'b1 : 1'b0;
        //checking if rs1 is less than rs2 when evaluated as unsigned values
    assign br_ltu = (br1 < br2) ? 1'b1 : 1'b0; 
endmodule
