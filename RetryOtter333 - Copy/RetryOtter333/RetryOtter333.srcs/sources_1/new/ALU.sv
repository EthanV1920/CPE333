`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 01/31/2024 04:40:40 PM
// Design Name: ALU
// Module Name: ALU
// Project Name: ALU
// Target Devices: BASYS3 board
// Description: Algorithm Logic Unit
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module ALU(
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] alu_fun,
    output logic [31:0] alu_result
    );
    
    always_comb begin
        case(alu_fun)
            4'b0000: alu_result = srcA + srcB; //arithmetic add
            4'b1000: alu_result = srcA - srcB; //arithmetic subtract
            4'b0110: alu_result = (srcA | srcB); //logical or
            4'b0111: alu_result = (srcA & srcB); //logical and
            4'b0100: alu_result = (srcA ^ srcB); //logical exclusive or (xor)
            4'b0101: alu_result = (srcA >> srcB); //logical shift right (srl)
            4'b0001: alu_result = (srcA << srcB); //logical shift left (sll)
            4'b1101: alu_result = ($signed(srcA) >>> $signed(srcB)); //arithmetic shift right (sra)
            4'b0010: alu_result = ($signed(srcA) < $signed(srcB)); //set if less than (slt)
            4'b0011: alu_result = (srcA < srcB); //unsigned set if less than (sltu)
            4'b1001: alu_result = srcA; //load upper immediate (lui-copy)
            default: alu_result = srcA + srcB;
        endcase
    end   
endmodule
