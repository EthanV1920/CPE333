`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 02/09/2024 10:11:23 AM
// Design Name: Branch_Address_Generator
// Module Name: Branch_Address_Generator
// Project Name: Branch_Addr_Gen
// Target Devices: Basys3 Board 
// Description: Calculates the address for the next instruction 
// from the immediate and PC values.
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module Branch_Address_Generator(
    input [31:0] B_Type,
    input [31:0] J_Type,
    input [31:0] I_Type,
    input [31:0] PC,
    input [31:0] rs,
    output [31:0] branch,
    output [31:0]jal,
    output [31:0] jalr
    );
    
    assign branch = B_Type + PC; //adds the 'branch-to' value to the Program Count
    assign jal = J_Type + PC; //adds 'jump-to' value to the Program Count
    assign jalr = I_Type + rs; //adds the value in the source register 
                                //to the I-type immediate
endmodule
