`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2024 11:52:54 AM
// Design Name: 
// Module Name: ProgramCounter
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

module ProgramCounter(
    input pc_rst,
    input pc_we,
    input clk,
    input [31:0] JALR,
    input [31:0] BRANCH,
    input [31:0] JAL,
    input [31:0] MTVEC,
    input [31:0] MEPC,
    input [2:0] PC_SEL,
    output reg [31:0] pc_count
    );
    
    logic [31:0] plus4; 
    logic [31:0] mux_pc;
    logic [2:0] pcSel;
    
    assign pcSel = 3'b000;
//    assign pc_count = 32'b0;


    assign plus4 = 32'b0;


//    always_comb begin
//        if(pc_rst) begin
//            pcSel = 3'b000;
////            plus4 = 32'b0;
//        end
//        else
//            pcSel = PC_SEL;
//    end
    
    
    
    MUX PCMUX (.MUX_A(plus4), .MUX_B(JALR), .MUX_C(BRANCH), .MUX_D(JAL), .MUX_E(MTVEC), .MUX_F(MEPC), .MUX_SEL(pcSel), .MUX_Out(mux_pc));
    PCregister pc_register (.PC_RST(pc_rst), .PC_WE(pc_we), .PC_DIN(mux_pc), .CLK(clk), .PC_COUNT(pc_count), .PCP4(plus4));
       
endmodule
