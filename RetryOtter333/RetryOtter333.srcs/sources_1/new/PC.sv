`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/18/2024 03:18:48 PM
// Design Name: 
// Module Name: PC_Counter
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


module PC(
    input PC_RST,
    input PC_WE,
    input [31:0] PC_DIN,
    input CLK,
    output logic [31:0] PC,
    output logic [31:0] PCplus4
    );
    
  
    assign PCplus4 = PC + 4;
    
    
    always_ff @(posedge CLK) begin
    if(PC_RST)
        PC <= 32'h00000000;
    else if(PC_WE)
        PC <= PC_DIN;
    else if(~PC_WE)
        PC <= PC;
    end   
    

     
endmodule
