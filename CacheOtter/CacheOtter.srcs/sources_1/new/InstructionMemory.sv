`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////

module InstructionMemory(
input logic [31:0] a,
output logic [31:0] w0,
output logic [31:0] w1,
output logic [31:0] w2,
output logic [31:0] w3,
);

    logic [31:0] ram[0:16383];
    initial $readmemh("debug.mem", ram, 0, 16383);
    
    //changed memory so it does output 8 words
    assign w0 = ram[a[31:2]];
    assign w1 = ram[a[31:2]+1];
    assign w2 = ram[a[31:2]+2];
    assign w3 = ram[a[31:2]+3];
endmodule