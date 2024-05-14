`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// 
// Create Date: 11/05/2023 12:03:36 AM
// Design Name: PCregister
// Module Name: PCregister
// Project Name: ProgramCounter
// Target Devices: BASYS 3
// Description: Stores the instuction (program) address for the ProgROM
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module PCregister(    
    input PC_RST,
    input PC_WE,
    input [31:0] PC_DIN,
    input CLK,
    output logic [31:0] PC_COUNT,
    output logic [31:0] PCP4
    );
    
    always_ff @ (posedge CLK) 
    begin
        if(PC_RST)
            PC_COUNT = 32'h0000; //Reset sets the output (count) to zero to restart machine code with first command
        else if (PC_WE)  //Write Enable sets the output to the input value when PC_WE = '1'
            PC_COUNT = PC_DIN; //Allows loading of input value to the output
        PCP4 = PC_COUNT + 4;
    end
 
endmodule
