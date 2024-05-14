`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Isaac Lake
// 
// Create Date: 05/07/2024 01:55:47 PM
// Design Name: 
// Module Name: HazardDetectionUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This should be able to stall the pipeline if a hazard is detected
//              and should flush out values if a branch is taken
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
typedef enum logic [6:0] {
  LUI    = 7'b0110111,
  AUIPC  = 7'b0010111,
  JAL    = 7'b1101111,
  JALR   = 7'b1100111,
  BRANCH = 7'b1100011,
  LOAD   = 7'b0000011,
  STORE  = 7'b0100011,
  OP_IMM = 7'b0010011,
  OP     = 7'b0110011,
  SYSTEM = 7'b1110011,
  DEFAULT = 7'b0000000
} opcode_t;

typedef struct packed {
  logic [31:0] pc;
  opcode_t opcode;
  logic [4:0] rs1_addr;
  logic [4:0] rs2_addr;
  logic [4:0] rd_addr;
  logic rs1_used;
  logic rs2_used;
  logic rd_used;
  logic [3:0] alu_fun;
  logic memWrite;
  logic memRead2;
  logic regWrite;
  logic [1:0] rf_SEL;
  logic [2:0] mem_type;  //sign, size
  // added by v and sosa
  logic [31:0] ir;
  logic [31:0] memDout2;
  logic [31:0] JALR;
  logic [31:0] BRANCH;
  logic [31:0] JAL;
  logic [31:0] alu_result;
  logic [31:0] rs1;
  logic [31:0] rs2;
  logic [31:0] RF_MUX_out;
  logic [2:0] PC_SEL;
  logic memWrite2;
  logic [31:0] IOBUS_in;
  logic IOBUS_wr;
  logic [31:0] muxB_out;
  logic [31:0] muxA_out;
  
//still need mtvec and sys location, plus pc write and memrden1
} instr_t;

module HazardDetectionUnit(
    input instr_t ID,
    input instr_t EX,
    input instr_t MEM,
    input instr_t WB,
    input WE_flag,
    output logic FmuxA,
    output logic FmuxB,
    output logic FmuxASel,
    output logic FmuxBSel,
    output logic PC_WE,
    output logic WE_flag_out,
    output logic FlushFlag,
    output instr_t ID_out
);

    always_comb begin

        if(EX.rs1_used && MEM.rd_used && (EX.rs1_addr == MEM.rd_addr)) begin
            FmuxA = MEM.alu_result;
            if(MEM.pc[6:0] == 7'b0000011 && WE_flag ==1'b0)begin
                PC_WE = 1'b0;
                WE_flag_out = 1'b1;
                FmuxASel = 1'b0;
            end else begin
                FmuxASel = 1'b1;
                PC_WE = 1'b1;
            end
        end
        else if(EX.rs1_used && WB.rd_used && (EX.rs1_addr == WB.rd_addr)) begin
            FmuxA = WB.alu_result;
            FmuxASel = 1'b1;
            PC_WE = 1'b1;
        end
    
        if(EX.rs2_used && MEM.rd_used && (EX.rs2_addr == MEM.rd_addr)) begin
            FmuxB = MEM.alu_result;
            FmuxBSel = 1'b1;
        end
        else if(EX.rs2_used && WB.rd_used && (EX.rs2_addr == WB.rd_addr)) begin
            FmuxB = WB.alu_result;
            FmuxBSel = 1'b1;
        end
        else begin
        
            FmuxB = WB.alu_result;
            FmuxBSel = 1'b0;        
        end
        
    end
    //FIX (add pcSEL to struct?)
    // Branch Predictor Hazard Detection & Flush
    always_comb begin
    
        ID_out <= ID;
        if (EX.PC_SEL != 0)begin
            ID_out.PC_SEL = EX.PC_SEL;
            FlushFlag = 1'b1;
            ID_out.memWrite = 1'b0;
            ID_out.regWrite = 1'b0; 
        end
        else if(FlushFlag == 1'b1)begin
            ID_out.memWrite = 1'b0;
            ID_out.regWrite = 1'b0;
            FlushFlag = 1'b0;
        end
    end

endmodule