`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2024 02:08:51 PM
// Design Name: 
// Module Name: RegFile
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


module RegFile(
    input        en,
    input logic [4:0] adr1,
    input logic [4:0] adr2,
    input logic [4:0] w_adr,
    input logic [31:0] w_data,
    input CLK,
    output logic [31:0] rs1,
    output logic [31:0] rs2
    );
    
    // Create a memory module with 16-bit width and 512 addresses
logic [31:0] ram [0:31];

// Initialize the memory to be all 0s
    initial begin
        int i;
        for (i=0; i<32; i=i+1) 
        begin
            ram[i] = 0;
        end
    end
// rs1 and rs2 will always display the register that is inputted into adr1 and adr2
      assign rs1 = ram[adr1];
      assign  rs2 = ram[adr2];
      
//      always_comb begin
//        $display("addr: ");
//      end

always@(posedge CLK) begin
    if(en == 1 && w_adr!=0) begin
     
        ram[w_adr] <= w_data;
    
    end
end
endmodule

