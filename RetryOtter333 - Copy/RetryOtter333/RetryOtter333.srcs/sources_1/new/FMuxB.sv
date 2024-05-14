`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2024 08:15:40 PM
// Design Name: 
// Module Name: RF_MUX
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


module FMuxB(
    input [31:0] FMuxB,
    input [31:0] MuxB_out,
    input FMuxB_SEL,
    output logic [31:0] FMuxB_out
    );
    
    always_comb begin
    
        if(FMuxB_SEL == 1) begin
            FMuxB_out = FMuxB;
        end
        else begin
            FMuxB_out = MuxB_out;
        end
    
    end
    
endmodule

