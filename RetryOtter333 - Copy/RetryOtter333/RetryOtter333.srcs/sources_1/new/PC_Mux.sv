`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2024 03:18:48 PM
// Design Name: 
// Module Name: MUX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PC_MUX(
    input [31:0] PCplus4,
    input [31:0] JALR,
    input [31:0] BRANCH,
    input [31:0] JAL,
    input [31:0] MTVEC,
    input [31:0] MEPC,
    input [2:0] PC_SEL,
    output logic [31:0] MUX_Output
    );
    
    logic [2:0] pcSEL;
    assign pcSEL = 3'b0;
    
    always_comb begin
    case (pcSEL)
    3'b000 : MUX_Output = PCplus4;
    3'b001 : MUX_Output = JALR;
    3'b010 : MUX_Output = BRANCH;
    3'b011 : MUX_Output = JAL;
    3'b100 : MUX_Output = MTVEC;
    3'b101 : MUX_Output = MEPC;
    3'b110 : MUX_Output = 32'hfa000110;
    3'b111 : MUX_Output = 32'hfa000111;
    default: MUX_Output = 32'hfa111111;
    endcase
    end
endmodule
