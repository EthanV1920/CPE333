`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// 
// Create Date: 10/12/2023 10:14:09 AM
// Design Name: MUX
// Module Name: MUX
// Project Name: ProgramCounter
// Target Devices: BASYS 3
// Description: 6 x 32-bit Multiplexor
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module MUX(
    input [31:0] MUX_A,
    input [31:0] MUX_B,
    input [31:0] MUX_C,
    input [31:0] MUX_D,
    input [31:0] MUX_E,
    input [31:0] MUX_F,
    input [2:0] MUX_SEL, // 3-bits to accomodate all inputs, but not all values are being used
    output logic [31:0] MUX_Out
    );
   
   // outputs one of 6 inputs based of the value of the selector MUX_SEL
    always_comb begin
       if (MUX_SEL == 0)
            MUX_Out = MUX_A;
       else if (MUX_SEL == 1)
            MUX_Out = MUX_B;
       else if (MUX_SEL == 2)
            MUX_Out = MUX_C;
       else if (MUX_SEL == 3)
            MUX_Out = MUX_D;
       else if (MUX_SEL == 4)
            MUX_Out = MUX_E;
       else if (MUX_SEL == 5)
            MUX_Out = MUX_F;
       else
       // default value to prevent latches and make sure there's no issues 
       // with the input (should never be used as output)
            MUX_Out = 32'hFFFFFFFF; 
    end
endmodule 
