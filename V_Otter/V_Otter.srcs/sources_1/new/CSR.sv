`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 03/06/2024 10:36:26 AM
// Design Name: CSR
// Module Name: CSR
// Project Name: OTTER_wrapper
// Target Devices: Basys3 Board
// Description: CSR file for handling Interrupts
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module CSR(
    input RST,
    input INT_TAKEN,
    input [11:0] ADDR,
    input WR_EN,
    input [31:0] PC,
    input [31:0] WD,
    input CLK,
    input mret_exec,
    output logic flag,
    output logic [31:0] mepc,
    output logic [31:0] mtvec,
    output logic [31:0] RD
    );
    // initialize CSR registers
    reg [31:0] MTVEC = 0;
    reg [31:0] MEPC = 0;
    reg [31:0] MSTATUS = 0;
    
    assign flag = MSTATUS[3];
    assign mepc = MEPC;
    assign mtvec = MTVEC;
    assign mstatus = MSTATUS; 
    
    // set read to register specified by instruction
    always_comb begin
        if (ADDR == 12'h305) RD = MTVEC;
        else if (ADDR == 12'h341) RD = MEPC;
        else if (ADDR == 12'h300) RD = MSTATUS;
        else RD = 32'hFFFF_FFFF;
    end
        
    always_ff @(posedge CLK)begin
        if (RST) begin
            MSTATUS <= 0;
            MEPC <= 0;
            MTVEC <= 0;
        end
        // write data to csr register specified by instruction
        else if(WR_EN) begin
            if (ADDR == 12'h305) MTVEC <= WD;
            else if (ADDR == 12'h341) MEPC <= WD;
            else MSTATUS <= WD;
        end
        // set flag in mstatus if interupt happens
        else if (INT_TAKEN) begin
            MSTATUS[7] <= MSTATUS[3];
            MSTATUS[3] <= 0;
            MEPC <= PC;
        end
        // when resturning reset flag
        else if (mret_exec) MSTATUS[3] <= MSTATUS[7];
    end
    
endmodule
