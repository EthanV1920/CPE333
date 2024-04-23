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
// Revision 0.02 - Updated with all instructions
//////////////////////////////////////////////////////////////////////////////////

module CU_Decoder(
    input [31:0] ir,
    input int_taken,
    input br_EQ,
    input br_LT,
    input br_LTU,
    output logic [3:0] ALU_FUN,
    output logic [1:0] srcA_SEL,
    output logic [2:0] srcB_SEL,
    output logic [2:0] PC_SEL,
    output logic [1:0] RF_SEL
    );
   
    always_comb begin
    // initialize all ouputs to zero
        ALU_FUN = 4'b0000;
        srcA_SEL = 2'b00;
        srcB_SEL = 3'b000;
        PC_SEL = 3'b000;
        RF_SEL = 2'b00;
       // interrupt routine
        if(int_taken) PC_SEL = 3'h4;
        else begin
        // decode outputs based off input OpCode  
            case (ir[6:0])
                7'b0110111: begin // lui
                    ALU_FUN = 4'b1001;
                    srcA_SEL = 2'b01;
                    RF_SEL = 2'b11;
                end
                7'b0010111: begin // auipc
                    srcA_SEL = 2'b01; 
                    srcB_SEL = 3'b011;
                    RF_SEL = 2'b11;
                end      
                7'b0010011: begin // I-Type excluding load instructions
                    if (ir[14:12] == 3'b101) ALU_FUN = {ir[30], ir[14:12]}; // srai and srli
                    else ALU_FUN = {1'b0, ir[14:12]}; // concatenate for correct alu_fun value 
                    srcB_SEL = 3'b001;
                    RF_SEL = 2'b11;
                end
                7'b0000011: begin // I-Type load instructions
                    srcA_SEL = 2'b00;
                    srcB_SEL = 3'b001;
                    RF_SEL = 2'b10;
                end
                7'b1100111: begin // jalr
                    PC_SEL = 3'b001;
                    RF_SEL = 2'b00;
                end          
                7'b0110011: begin // R-Type
                    ALU_FUN = {ir[30], ir[14:12]};
                    srcA_SEL = 2'b00; 
                    srcB_SEL = 3'b000;
                    PC_SEL = 3'b000;
                    RF_SEL = 2'b11;
                end
                7'b0100011: begin // S-Type
                    srcB_SEL = 3'b10;
                end
                7'b1100011: begin // B-Type
                    case(ir[14:12])// funct3 value
                       3'b000: begin // beq
                            if (br_EQ) PC_SEL = 3'b010; //check if branch is taken for PC control
                            else PC_SEL = 3'b000; //proceed like normal if condition evaluates as false
                       end                      
                       3'b101: begin // bge
                            if (br_EQ | !br_LT) PC_SEL = 3'b010; 
                            else PC_SEL = 3'b000; 
                       end
                       3'b111: begin // bgeu
                            if (br_EQ | !br_LTU) PC_SEL = 3'b010; 
                            else PC_SEL = 3'b000; 
                       end
                       3'b100: begin // blt
                            if (br_LT) PC_SEL = 3'b010; 
                            else PC_SEL = 3'b000; 
                       end
                       3'b110: begin // bltu
                            if (br_LTU) PC_SEL = 3'b010; 
                            else PC_SEL = 3'b000; 
                       end
                       3'b001: begin // bne
                            if (!br_EQ) PC_SEL = 3'b010; 
                            else PC_SEL = 3'b000; 
                       end
                       default: PC_SEL = 3'b001; // fails exceptionally :)
                   endcase
                end
                7'b1101111: begin // J-Type = jal
                    PC_SEL = 3'b011;
                    RF_SEL = 2'b00;
                end
                7'b1110011: begin // control & status register read intructions
                        case(ir[14:12]) // end mret
                            3'b011: begin // csrrc
                                ALU_FUN = 4'b0111;
                                srcA_SEL = 2'b10;
                                srcB_SEL = 3'b100;
                                RF_SEL = 2'b01;
                            end
                            3'b010: begin // csrrs
                                ALU_FUN = 4'b0110;
                                srcB_SEL = 3'b100;
                                RF_SEL = 2'b01;
                            end
                            3'b001: begin // csrrw
                                ALU_FUN = 4'b1001;
                                RF_SEL = 2'b01;
                            end
                            3'b000: begin // mret
                                PC_SEL = 3'b101;
                            end
                            default: PC_SEL = 3'b010; // fails exceptionally
                        endcase
                end
                default: ALU_FUN = 4'b0000; // default is all signals off ALU_FUN = 4'b0000;
            endcase
        end
    end
endmodule
