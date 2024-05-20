`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2024 05:23:35 PM
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


module MUX (
    input [31:0] in1,
    input [31:0] in2,
    input MuxSel,
    output logic [31:0] MuxOut
);

  always_comb begin
    if (MuxSel == 1) begin
      MuxOut = in1;
    end else begin
      MuxOut = in2;
    end
  end

endmodule
