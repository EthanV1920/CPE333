`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 02/21/2024 08:15:40 PM
// Design Name: ALU_MUX_A
// Module Name: ALU_MUX_A
// Project Name: OTTER_MCU
// Target Devices: Basys3 Board
// Description: mux for source A into the ALU
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module ALU_MUX_A(
    input [31:0] ALUmuxA0,
    input [31:0] ALUmuxA1,
    input [31:0] ALUmuxA2,
    input [1:0] ALUmuxA_SEL,
    output logic [31:0] ALUmuxA_out
    ); 
   // outputs one of 4 inputs based of the value of the selector
    always_comb begin
       if (ALUmuxA_SEL == 0)
            ALUmuxA_out = ALUmuxA0;
       else if (ALUmuxA_SEL == 1)
            ALUmuxA_out = ALUmuxA1;
       else if (ALUmuxA_SEL == 2)
            ALUmuxA_out = ALUmuxA2;
       else
       // default value to prevent latches and make sure there's no issues 
       // with the input (should never be used as output)
            ALUmuxA_out = 32'hFFFFFFFF; 
    end
endmodule
