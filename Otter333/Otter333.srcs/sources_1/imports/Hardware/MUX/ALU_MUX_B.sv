`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 02/21/2024 08:15:40 PM
// Design Name: ALU_MUX_B
// Module Name: ALU_MUX_B
// Project Name: OTTER_MCU
// Target Devices: Basys3 Board
// Description: mux for source B into the ALU
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module ALU_MUX_B(
    input [31:0] ALUmuxB0,
    input [31:0] ALUmuxB1,
    input [31:0] ALUmuxB2,
    input [31:0] ALUmuxB3,
    input [31:0] ALUmuxB4,
    input [2:0] ALUmuxB_SEL,
    output logic [31:0] ALUmuxB_out
    );
    // outputs one of 4 inputs based of the value of the selector
    always_comb begin
       if (ALUmuxB_SEL == 0)
            ALUmuxB_out = ALUmuxB0;
       else if (ALUmuxB_SEL == 1)
            ALUmuxB_out = ALUmuxB1;
       else if (ALUmuxB_SEL == 2)
            ALUmuxB_out = ALUmuxB2;
       else if (ALUmuxB_SEL == 3)
            ALUmuxB_out = ALUmuxB3;
       else if (ALUmuxB_SEL == 4)
            ALUmuxB_out = ALUmuxB4;
       else
       // default value to prevent latches and make sure there's no issues 
       // with the input (should never be used as output)
            ALUmuxB_out = 32'h00000000; 
    end
endmodule
