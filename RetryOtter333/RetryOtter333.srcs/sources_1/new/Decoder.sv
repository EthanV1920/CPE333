`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2024 01:39:03 PM
// Design Name: 
// Module Name: CU_DCDR
// Project Name: 
// Target es: 
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


module Decoder(
    input [31:0] ir,
    input reset,
    input br_eq,
    input br_lt,
    input br_ltu,
    input int_taken,
    output logic [3:0] ALU_FUN,
    output logic [1:0] srcA_SEL,
    output logic [2:0] srcB_SEL,
    output logic [2:0] PC_SEL,
    output logic [1:0] RF_SEL,
    //new
    output logic regWrite,
    output logic memWrite,
    output logic memRDEN2
    );
    
    
    always_comb
    begin
        ALU_FUN = 4'b0;
        srcA_SEL = 2'b0;
        srcB_SEL = 3'b0;
        PC_SEL = 3'b0;
        RF_SEL = 2'b0;  
        regWrite = 1;
        memWrite = 0;
        memRDEN2 = 0;
        
        case(ir[6:0])
            //Rtype
            7'b0110011: begin
                ALU_FUN = {ir[30],ir[14:12]};
                srcA_SEL = 2'b00;
                srcB_SEL = 3'b000;
                RF_SEL = 2'b11; 
                
                regWrite = 1;
                
                if(int_taken)
                    PC_SEL = 3'b100;
                else
                    PC_SEL = 3'b000;
            end
            
            //Itype main
            7'b0010011: begin
                srcA_SEL = 2'b00;
                srcB_SEL = 3'b001;
                RF_SEL = 2'b11; 
                if(int_taken)
                    PC_SEL = 3'b100;
                else
                    PC_SEL = 3'b000;
                if(ir[14:12] == 3'b101)
                    ALU_FUN = {ir[30],ir[14:12]};
                else
                    ALU_FUN = {1'b0,ir[14:12]};    
                 regWrite = 1;
                 memWrite = 0;
                 memRDEN2 = 0;                 
            end
            
            //Itype loads
            7'b0000011: begin
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b00;
                srcB_SEL = 3'b001;
                RF_SEL = 2'b10; 
                if(int_taken)
                    PC_SEL = 3'b100;
                else
                    PC_SEL = 3'b000;
            end
            
            //Itype jalr
            7'b1100111: begin
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b00;
                srcB_SEL = 3'b000;
                RF_SEL = 2'b00; 
                if(int_taken)
                    PC_SEL = 3'b100;
                else
                    PC_SEL = 3'b001;
            end
            
            //Stype
            7'b0100011: begin
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b00;
                srcB_SEL = 3'b010;
                RF_SEL = 2'b00; 
                regWrite = 1;
                memWrite = 1;
                memRDEN2 = 1;
                if(int_taken)
                    PC_SEL = 3'b100;
                else
                    PC_SEL = 3'b000;
            end
            

            
            //Utype lui
            7'b0110111: begin
                ALU_FUN = 4'b1001;
                srcA_SEL = 2'b01;
                srcB_SEL = 3'b000;
                RF_SEL = 2'b11; 
                regWrite = 1;
                memRDEN2 = 1;
                if(int_taken)
                    PC_SEL = 3'b100;
                else
                    PC_SEL = 3'b000;
            end
            
            //Utype auipc
            7'b0010111: begin
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b01;
                srcB_SEL = 3'b011;
                RF_SEL = 2'b11; 
                if(int_taken)
                    PC_SEL = 3'b100;
                else
                    PC_SEL = 3'b000;
            end
            
            //Jtype jal
            7'b1101111: begin
//                PC_SEL = 3'b011;
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b00;
                srcB_SEL = 3'b000;
                RF_SEL = 2'b00; 
                if(int_taken)
                    PC_SEL = 3'b100;
                else
                    PC_SEL = 3'b011;
            end

            //Btype
            7'b1100011: begin
            
                case(ir[14:12])
                    
                    3'b000: begin //beq
                        PC_SEL = {1'b0,br_eq,1'b0};
                    end
                    3'b101: begin //bge
                        PC_SEL = {1'b0,!br_lt,1'b0};
                    end
                    3'b111: begin //bgeu
                        PC_SEL = {1'b0,!br_ltu,1'b0};
                    end
                    3'b100: begin //blt
                        PC_SEL = {1'b0,br_lt,1'b0};
                    end
                    3'b110: begin //bltu
                        PC_SEL = {1'b0,br_ltu,1'b0};
                    end
                    3'b001: begin //bne
                        PC_SEL = {1'b0,!br_eq,1'b0};
                    end
                    default: PC_SEL = 0;
                endcase
                 if(int_taken)
                    PC_SEL = 3'b100;
             end
             7'b1110011: begin    //sys
                case(ir[14:12])
                    
                    3'b001: begin  //rw
                        PC_SEL = 3'b000;
                        RF_SEL = 2'b01;
                        ALU_FUN = 4'b1001;
                        srcA_SEL = 2'b00;
                    end
                    3'b011: begin   //rc
                        PC_SEL = 3'b000;
                        RF_SEL = 2'b01;
                        ALU_FUN = 4'b0111;
                        srcA_SEL = 2'b10;
                        srcB_SEL = 3'b100;
                    end
                    3'b010: begin      //rs
                        PC_SEL = 3'b000;
                        RF_SEL = 2'b01;
                        ALU_FUN = 4'b0110;
                        srcA_SEL = 2'b00;
                        srcB_SEL = 3'b100;
                    end
                    3'b000: begin     //mret
                        PC_SEL = 3'b101;
                    end
                endcase
             
             end
            //Default values
            default : begin 
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b00;
                srcB_SEL = 3'b000;
                PC_SEL = 3'b000;
                RF_SEL = 2'b00;
                regWrite = 0;
                memWrite = 0;
                memRDEN2 = 0;
            end
        endcase 
    end
endmodule