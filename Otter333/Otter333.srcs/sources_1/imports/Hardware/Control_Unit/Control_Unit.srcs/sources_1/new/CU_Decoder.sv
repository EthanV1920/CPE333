`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 02/20/2024 10:47:20 PM
// Design Name: CU_Decoder
// Module Name: CU_Decoder
// Project Name: Control_Unit
// Target Devices: Basys3 Board
// Description: Docoder for machine instructions 
//              that don't have critical timing
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module CU_Decoder(
    input [31:0] ir,
    input br_EQ,
    input br_LT,
    input br_LTU,
    input CU_RST,
    output logic [3:0] ALU_FUN,
    output logic [1:0] srcA_SEL,
    output logic [2:0] srcB_SEL,
    output logic [2:0] PC_SEL,
    output logic [1:0] RF_SEL,
//    output logic PC_WE,
    output logic RF_WE,
    output logic memWE2,
//    output logic memRDEN1,
    output logic memRDEN2,
    );

    always_comb begin
    // initialize all ouputs to zero
        ALU_FUN = 4'b0000;
        srcA_SEL = 2'b00;
        srcB_SEL = 3'b000;
        PC_SEL = 3'b000;
        RF_SEL = 2'b00;
        RF_WE = 1;
        memWE2 = 0;
        memRDEN2 = 0;
    // decode outputs based off input OpCode  
        case (ir[6:0])
            7'b0110111: begin // lui
                ALU_FUN = 4'b1001;
                srcA_SEL = 2'b01; 
                srcB_SEL = 3'b000;
                PC_SEL = 3'b000;
                RF_SEL = 2'b11;
            end        
            7'b0010011: begin // addi and slli
                if (ir[14:12] == 3'b101) ALU_FUN = {ir[30], ir[14:12]}; // must check formatt of instruction
                else ALU_FUN = {1'b0, ir[14:12]}; // concatenate for correct alu_fun value
                srcA_SEL = 2'b00; 
                srcB_SEL = 3'b001;
                PC_SEL = 3'b000;
                RF_SEL = 2'b11;
            end
            7'b0110011: begin // slt and xor
                ALU_FUN = {ir[30], ir[14:12]};
                srcA_SEL = 2'b00; 
                srcB_SEL = 3'b000;
                PC_SEL = 3'b000;
                RF_SEL = 2'b11;
            end
            7'b1100011: begin //beq 
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b00; 
                srcB_SEL = 3'b000;
                if (br_EQ) PC_SEL = 3'b010; //check if branch is taken for PC control
                else PC_SEL = 3'b000; //proceed like normal if condition evaluates as false
                RF_SEL = 2'b00;
            end
            7'b0100011: begin // S-type
                RF_WE = 0;
                memWE2 = 1;
                memRDEN2 = 0;
            end
            7'b1100011: RF_WE = 0; // B-type 
            
     
            default: ALU_FUN = 4'b0000; // defaul signals, ALU_FUN = 4'b0000;
        endcase
    end  
endmodule
