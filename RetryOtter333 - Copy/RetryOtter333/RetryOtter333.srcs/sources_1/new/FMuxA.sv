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


module FMuxA (
    input [31:0] FMuxA,
    input [31:0] MuxA_out,
    input FMuxA_SEL,
    output logic [31:0] FMuxA_out
);

  always_comb begin

    if (FMuxA_SEL == 1) begin
      FMuxA_out = FMuxA;
    end else begin
      FMuxA_out = MuxA_out;
    end

  end

endmodule

