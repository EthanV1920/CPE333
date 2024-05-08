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
    output logic FlushFlag
);

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
//FIX (add pcSEL to struct?)
// Branch Predictor Hazard Detection & Flush
always_comb begin
    if (EX.PC_SEL != 0){
        IF.PC_SEL = EX.PC_SEL;
        FlushFlag = 1'b1;
        ID.memWrite = 1'b0;
        ID.regWrite = 1'b0;
    }
    else if(FlushFlag == 1'b1){
        ID.memWrite = 1'b0;
        ID.regWrite = 1'b0;
        FlushFlag == 1'b0;
    }
end