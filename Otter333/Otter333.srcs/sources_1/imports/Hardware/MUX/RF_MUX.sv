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


module RF_MUX(
    input [31:0] RFmux0,
    input [31:0] RFmux1,
    input [31:0] RFmux2,
    input [31:0] RFmux3,
    input [1:0] RFmux_SEL,
    output logic [31:0] RFmux_out
    );
    // outputs one of 4 inputs based of the value of the selector
    always_comb begin
       if (RFmux_SEL == 0)
            RFmux_out = (RFmux0 + 4);
       else if (RFmux_SEL == 1)
            RFmux_out = RFmux1;
       else if (RFmux_SEL == 2)
            RFmux_out = RFmux2;
       else if (RFmux_SEL == 3)
            RFmux_out = RFmux3;
       else
       // default value to prevent latches and make sure there's no issues 
       // with the input (should never be used as output)
            RFmux_out = 32'hFFFFFFFF; 
   end
endmodule
