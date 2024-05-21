`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2024 08:32:51 PM
// Design Name: 
// Module Name: HDU
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

typedef enum logic [6:0] {
  LUI     = 7'b0110111,
  AUIPC   = 7'b0010111,
  JAL     = 7'b1101111,
  JALR    = 7'b1100111,
  BRANCH  = 7'b1100011,
  LOAD    = 7'b0000011,
  STORE   = 7'b0100011,
  OP_IMM  = 7'b0010011,
  OP      = 7'b0110011,
  SYSTEM  = 7'b1110011,
  DEFAULT = 7'b0000000
} opcode_t;

typedef struct packed {
  logic [31:0] pc;
  opcode_t opcode;
  logic [4:0] rs1_addr;
  logic [4:0] rs2_addr;
  logic [4:0] rd_addr;
  logic [3:0] alu_fun;
  logic rs1_used;
  logic rs2_used;
  logic rd_used;
  logic memWrite;
  logic memRead2;
  logic regWrite;
  logic [1:0] rf_SEL;
  // added by v and sosa
  logic [31:0] ir;
  logic [31:0] memDout2;
  logic [31:0] JALR;
  logic [31:0] BRANCH;
  logic [31:0] JAL;
  logic [31:0] alu_result;
  logic [31:0] rs1;
  logic [31:0] rs2;
  logic [2:0] PC_SEL;
  logic [31:0] IOBUS_in;
  logic IOBUS_wr;
  logic [31:0] muxB_out;
  logic [31:0] muxA_out;
  //still need mtvec and sys location, plus pc write and memrden1
} instr_t;

module HDU (
    input instr_t ID,
    input instr_t EX,
    input instr_t MEM,
    input instr_t WB,
    input reset,
    output logic [31:0] FmuxA,
    output logic [31:0] FmuxB,
    output logic FmuxASel,
    output logic FmuxBSel,
    output logic PC_WE,
    output logic FlushFlag
);

  always_comb begin
      // Handling the reset function
    if (reset == 1'b1) begin
        PC_WE = 1'b1;
        FmuxA = 32'b0;
        FmuxB = 32'b0;
        FmuxASel = 1'b0;
        FmuxBSel = 1'b0;
        FlushFlag = 1'b0;
    end else begin
        PC_WE = 1'b1;
        if (EX.rs1_used && MEM.rd_used && (EX.rs1_addr == MEM.rd_addr)) begin
          // Begin RS1 Logic
          if (MEM.pc[6:0] == 7'b0000011) begin
              // if we are loading we need to wait an extra step
            FmuxA = MEM.alu_result;
            PC_WE = 1'b0;
            FmuxASel = 1'b0;
          end else begin
              // if we are not loading then forward immediately
            FmuxA = MEM.alu_result;
            FmuxASel = 1'b1;
            PC_WE = 1'b1;
          end

        end else if (EX.rs1_used && WB.rd_used && (EX.rs1_addr == WB.rd_addr)) begin
            // Forwarding from WB state, we do not need to worry about load
          FmuxA = WB.alu_result;
          FmuxASel = 1'b1;
          PC_WE = 1'b1;
        end else begin
            // Filling in the MUX with dead data
            FmuxASel = 1'b0;
            FmuxA = EX.muxA_out;
        end
    
        // Begin RS2 Logic, same as RS1 without the Load condition and using MUX B
        if (EX.rs2_used && MEM.rd_used && (EX.rs2_addr == MEM.rd_addr)) begin
          FmuxB = MEM.alu_result;
          FmuxBSel = 1'b1;
        end else if (EX.rs2_used && WB.rd_used && (EX.rs2_addr == WB.rd_addr)) begin
          FmuxB = WB.alu_result;
          FmuxBSel = 1'b1;
        end else begin
          FmuxB = WB.alu_result;
          FmuxBSel = 1'b0;
        end
    
        if (EX.PC_SEL == 1'b0) begin
            FlushFlag = 1'b0;
        end else begin
            FlushFlag = 1'b1;
        end

    end




    // if (EX.PC_SEL != 0) begin
    //     ID_out.PC_SEL = EX.PC_SEL;
    //     FlushFlag = 1'b1;
    //     ID_out.memWrite = 1'b0;
    //     ID_out.regWrite = 1'b0;
    // end else if (FlushFlag == 1'b1) begin
    //     ID_out.memWrite = 1'b0;
    //     ID_out.regWrite = 1'b0;
    //     FlushFlag = 1'b0;
    // end
end
  // Branch Predictor Hazard Detection & Flush


endmodule
