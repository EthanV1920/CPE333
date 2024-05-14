`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer:  Isaac Lake,
//            Victoria Clemens,
//            Sam Solano,
//            Ethan Vosburg
//
// Create Date: 05/07/2024 01:55:47 PM
// Design Name: Otter Hazard Detection Unit
// Module Name: HazardDetectionUnit
// Project Name: Otter Pipelining
// Target Devices: Basys3
// Description: This should be able to stall the pipeline if a hazard is detected
//              and should flush out values if a branch is taken
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

typedef struct packed{
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
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;  //sign, size
    logic [31:0] pc;
    // added by v and sosa
    logic [31:0] mux_A_out;
    logic [31:0] mux_B_out;
    } instr_t;
    
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
  SYSTEM = 7'b1110011
} opcode_t;



//module HazardDetectionUnit(
//    input instr_t DEC,
//    input instr_t EX,
//    input instr_t MEM,
//    input instr_t WB,
//    input WE_flag,
//    input opcode_t opcode,
//    output logic FmuxA,
//    output logic FmuxB,
//    output logic FmuxASel,
//    output logic FmuxBSel,
//    output logic PC_WE,
//    output logic WE_flag_out,
//    output logic FlushFlag
//);

    always_comb begin
        if(EX.rs1_used && MEM.rd_used && (EX.rs1_addr == MEM.rd_addr)) begin
            if(MEM.opcode == LOAD && WE_flag ==1'b0)begin
                PC_WE = 1'b0;
                WE_flag_out = 1'b1;
            end else begin
                FmuxA = MEM.aluOut;
                FmuxASel = 1'b1;
                PC_WE = 1'b1;
            end
        end
        else if(EX.rs1_used && WB.rd_used && (EX.rs1_addr == WB.rd_addr)) begin
            FmuxA = WB.aluOut;
            FmuxASel = 1'b1;
            PC_WE = 1'b1;
        end

        if(EX.rs2_used && MEM.rd_used && (EX.rs2_addr == MEM.rd_addr)) begin
            FmuxB = MEM.aluOut;
            FmuxBSel = 1'b1;
        end
        else if(EX.rs2_used && WB.rd_used && (EX.rs2_addr == WB.rd_addr)) begin
            FmuxB = WB.aluOut;
            FmuxBSel = 1'b1;
        end
    end
    // FIX: (add pcSEL to struct?)
    // Branch Predictor Hazard Detection & Flush
    always_comb begin
        if (EX.PC_SEL != 0) begin
            IF.PC_SEL = EX.PC_SEL;
            FlushFlag = 1'b1;
            DEC.memWrite = 1'b0;
            DEC.regWrite = 1'b0;
        end
        else if(FlushFlag == 1'b1) begin
            DEC.memWrite = 1'b0;
            DEC.regWrite = 1'b0;
            FlushFlag = 1'b0;
        end
    end
endmodule