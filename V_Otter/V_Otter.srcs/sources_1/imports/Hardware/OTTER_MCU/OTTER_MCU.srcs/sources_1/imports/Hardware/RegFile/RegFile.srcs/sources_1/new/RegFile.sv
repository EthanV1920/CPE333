`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CalPoly
// Engineer: Victoria Asencio-Clemens
// 
// Create Date: 01/23/2024 11:07:25 PM
// Design Name: RegFile
// Module Name: RegFile
// Project Name: RegFile
// Target Devices: Basys3 Board
// Description: Register file for OTTER MCU. 
//              Handles retreival and saving of data to/from 32x32-bit registers
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module RegFile(
    input en,
    input [4:0] adr1,
    input [4:0] adr2,
    input [4:0] w_adr,
    input [31:0] w_data,
    input CLK,
    output logic [31:0] rs1,
    output logic [31:0] rs2
    );
    
    logic [31:0] memory [0:31];
    
    //initialize all registers to zero 
    // so we can clearly see what's been written over 
    initial begin
        int i;
        for (i=0; i<32; i=i+1)
            begin
                memory[i] = 0;
            end
    end
    
    // write data stored in registers 
    // specified by the input to the output 
    assign rs1 = memory[adr1];
    assign rs2 = memory[adr2];
    
    // w_data saved to w_adr register on the rising edge 
    // of the clock when write enable(en) is high
    always_ff @(posedge CLK) begin
        if (en) 
        begin
            if(w_adr != 0) // ensures the zero register is never written over, 
            begin         // and always remains at zero
                memory[w_adr] <= w_data;
            end
        end 
    end
    
endmodule
