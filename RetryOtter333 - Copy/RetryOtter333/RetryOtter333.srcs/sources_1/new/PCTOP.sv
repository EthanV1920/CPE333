`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2024 10:13:57 PM
// Design Name: 
// Module Name: Top_Module_Counter_MUX
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

module PCTOP(
    input PC_RST,
    input PC_WE,
    input [31:0] JALR,
    input [31:0] BRANCH,
    input [31:0] JAL,
    input [31:0] MTVEC,
    input [31:0] MEPC,
    input [2:0] PC_SEL,
    input CLK,
    output logic [31:0] PC,
    output logic [31:0] PCplus4
    );
    logic [31:0] t1, t2, PC_Counter_PC_Count, PC_Counter_PCplus4;
    
    
    PC_MUX MUX(.JALR(JALR), .BRANCH(BRANCH), .JAL(JAL), .MTVEC(MTVEC), .MEPC(MEPC), .PC_SEL(PC_SEL), .MUX_Output(t1), .PCplus4(PCplus4));
    PC MyPC(.CLK(CLK), .PC_WE(PC_WE), .PC_RST(PC_RST), .PC_DIN(t1), .PC(PC_Counter_PC_Count), .PCplus4(PC_Counter_PCplus4));
    assign PCplus4 = PC_Counter_PCplus4;
    assign PC = PC_Counter_PC_Count;
endmodule