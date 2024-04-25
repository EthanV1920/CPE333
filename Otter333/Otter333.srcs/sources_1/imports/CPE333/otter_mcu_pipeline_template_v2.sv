`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: 
// Module Name: PIPELINED_OTTER_CPU
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
           LUI      = 7'b0110111,
           AUIPC    = 7'b0010111,
           JAL      = 7'b1101111,
           JALR     = 7'b1100111,
           BRANCH   = 7'b1100011,
           LOAD     = 7'b0000011,
           STORE    = 7'b0100011,
           OP_IMM   = 7'b0010011,
           OP       = 7'b0110011,
           SYSTEM   = 7'b1110011
 } opcode_t;
        
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
    logic [31:0] mux_A_out;
    logic [31:0] mux_B_out;
    
} instr_t;

module OTTER_MCU(input CLK,
                input INTR,
                input RESET,
                input [31:0] IOBUS_IN,
                output [31:0] IOBUS_OUT,
                output [31:0] IOBUS_ADDR,
                output logic IOBUS_WR 
);           
    wire [6:0] opcode;
    wire cu_csr_mret, cu_csr_we, cu_csr_int_taken, cu_br_eq, cu_br_lt, 
            cu_br_ltu, cu_pc_we, cu_rf_we, cu_memWE2, cu_memRDEN1, cu_memRDEN2,
                cu_reset, int_taken, mret_exec, csr_CU;
    wire [31:0] csr_pc_mepc, csr_pc_mtvec, csr_rd, mux_a_out, mux_b_out, U_imm, 
                    I_imm, S_imm, B_imm, J_imm, RF_MUX_out, out_data2, ir, sreg1, sreg2, 
                        alu_out, pcplus4, addr_pc_jal, addr_pc_branch, addr_pc_jalr, pc_out;
    wire [1:0] cu_rf_sel, mux_a_sel;
    wire [2:0] mux_b_sel, cu_pc_sel;
    wire [3:0] cu_alu_fun;
    
    logic br_lt,br_eq,br_ltu;
              
//==== Instruction Fetch ===========================================

     logic [31:0] if_de_pc;
     logic [31:0] if_de_reg;
     
     always_ff @(posedge CLK) begin
            if_de_pc <= pc;
     end
     
     assign PC_WE = 1'b1; 	//Hardwired high, assuming no hazards
     assign memRDEN1 = 1'b1; 	//Fetch new instruction every cycle
     
    ProgramCounter otter_PC (.pc_rst(cu_reset), .pc_we(cu_pc_we), .clk(CLK), .JALR(addr_pc_jalr), 
                             .BRANCH(addr_pc_branch), .JAL(addr_pc_jal), .MTVEC(csr_pc_mtvec), 
                             .MEPC(csr_pc_mepc), .PC_SEL(cu_pc_sel), .pc_count(pc_out));

    Memory otter_memory (.MEM_ADDR2(alu_out), .MEM_DIN2(sreg2), .MEM_ADDR1(pc_out[15:2]), 
                         .MEM_RDEN1(cu_memRDEN1), .MEM_RDEN2(cu_memRDEN2), .MEM_WE2(cu_memWE2), 
                         .MEM_SIZE(ir[13:12]), .MEM_SIGN(ir[14]), .MEM_DOUT2(ir), .MEM_DOUT1(if_de_reg), 
                         .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_CLK(CLK));
    
     
//==== Instruction Decode ===========================================
    logic [31:0] de_ex_opA;
    logic [31:0] de_ex_opB;
    logic [31:0] de_ex_rs2;

    instr_t de_ex_struct, de_inst;
    
    opcode_t OPCODE;
    assign OPCODE_t = opcode_t'(opcode);
    
    assign de_inst.rs1_addr= if_de_reg[19:15];
    assign de_inst.rs2_addr= if_de_reg[24:20];
    assign de_inst.rd_addr= if_de_reg[11:7];
    assign de_inst.opcode=OPCODE;
   
    assign de_inst.rs1_used=    de_inst.rs1 != 0
                                && de_inst.opcode != LUI
                                && de_inst.opcode != AUIPC
                                && de_inst.opcode != JAL;
                                
    assign de_inst.rs2_used=    de_inst.rs2 != 0
                                && de_inst.opcode != JAL
                                && de_inst.opcode != JALR
                                && de_inst.opcode != BRANCH
                                && de_inst.opcode != LOAD
                                && de_inst.opcode != STORE
                                && de_inst.opcode != LUI
                                && de_inst.opcode != AUIPC
                                && de_inst.opcode != OP_IMM
                                && de_inst.opcode != SYSTEM;
               
    assign de_inst.rd_used=    de_inst.rd != 0
                                && de_inst.opcode != BRANCH
                                && de_inst.opcode != STORE
                                && de_inst.opcode != JAL;
                                
   CU_Decoder otter_cu_dec (.ir(if_de_reg), .br_EQ(cu_br_eq), .br_LT(cu_br_lt), .br_LTU(cu_br_ltu), .CU_RST(cu_reset), .ALU_FUN(cu_alu_fun), .srcA_SEL(mux_a_sel), 
                                .srcB_SEL(mux_b_sel), .PC_SEL(cu_pc_sel), .RF_SEL(cu_rf_sel), .RF_WE(cu_rf_we), .memWE2(cu_memWE2), .memRDEN2(cu_RDEN2));

    RegFile otter_reg_file (.en(cu_rf_we), .adr1(if_de_reg[19:15]), .adr2(if_de_reg[24:20]), .w_adr(), // add from write back
                            .w_data(RF_MUX_out), .CLK(CLK), .rs1(sreg1), .rs2(sreg2));
    
    Immed_Gen otter_immed_gen (.Instruction(if_de_reg), .U_Type(U_imm), .I_Type(I_imm), .S_Type(S_imm), 
                               .B_Type(B_imm), .J_Type(J_imm));
                               
                               
    ALU_MUX_A otter_alu_muxA (.ALUmuxA0(sreg1), .ALUmuxA1(U_imm), .ALUmuxA2(~sreg1), 
                              .ALUmuxA_SEL(mux_a_sel), .ALUmuxA_out(mux_a_out));
    
    ALU_MUX_B otter_alu_muxB (.ALUmuxB0(sreg2), .ALUmuxB1(I_imm), .ALUmuxB2(S_imm), .ALUmuxB3(pc_out), 
                              .ALUmuxB4(csr_rd), .ALUmuxB_SEL(mux_b_sel), .ALUmuxB_out(mux_b_out));
                               
                               
   intr_t id_ex_struct;
   
   always_ff @ (posedge CLK) begin
        id_ex_struct <= de_inst;
        id_ex_struct.alu_fun <= cu_alu_fun;
        id_ex_struct.memWrite <= cu_memWE2;
        id_ex_struct.memRead2 <= cu_RDEN2;
        id_ex_struct.regWrite <= cu_rf_we;
        id_ex_struct.rf_wr_sel <= cu_rf_sel;
        id_ex_struct.mem_type;  //sign, size
        id_ex_struct.pc;
        id_ex_struct.mux_A_out <= mux_a_out;
        id_ex_struct.mux_B_out <= mux_b_out;
   end
    
    
	
	
//==== Execute ======================================================
     logic [31:0] ex_mem_rs2;
     logic ex_mem_aluRes = 0;
     instr_t ex_mem_inst;
     logic [31:0] opA_forwarded;
     logic [31:0] opB_forwarded;
     
    // Creates a RISC-V ALU
    //OTTER_ALU ALU (de_ex_inst.alu_fun, de_ex_opA, de_ex_opB, aluResult); // the ALU (from diego)


     

    
    ALU otter_ALU (.srcA(id_ex_struct.mux_A_out), .srcB(id_ex_struct.mux_B_out), .alu_fun(id_ex_struct.alu_fun), .alu_result(id_ex_struct.regWrite));
    
    Branch_Condition_Generator otter_cond_gen (.br1(sreg1), .br2(sreg2), .br_eq(cu_br_eq), 
                                               .br_lt(cu_br_lt), .br_ltu(cu_br_ltu));
                                               
    Branch_Address_Generator otter_addr_gen (.B_Type(B_imm), .J_Type(J_imm), .I_Type(I_imm), 
                                             .PC(if_de_pc), .rs(sreg1), .branch(addr_pc_branch), 
                                             .jal(addr_pc_jal), .jalr(addr_pc_jalr));

    intr_t ex_mem_inst;

    always_ff @ (posedge CLK) begin
        ex_mem_inst.opcode = id_ex_struct.opcode;
        ex_mem_inst.rs1_addr = id_ex_struct.rs1_addr;
        ex_mem_inst.rs2_addr = id_ex_struct.rs2_addr;
        ex_mem_inst.rd_addr = id_ex_struct.rd_addr;
        ex_mem_inst.rs1_used = id_ex_struct.rs1_used;
        ex_mem_inst.rs2_used = id_ex_struct.rs2_used;
        ex_mem_inst.rd_used = id_ex_struct.rd_used;
        ex_mem_inst.alu_fun = id_ex_struct.alu_fun;
        ex_mem_inst.memWrite = id_ex_struct.memWrite;
        ex_mem_inst.memRead2 = id_ex_struct.memRead2;
        ex_mem_inst.regWrite = id_ex_struct.regWrite;
        ex_mem_inst.rf_wr_sel = id_ex_struct.rf_wr_sel;
        ex_mem_inst.mem_type = id_ex_struct.mem_type;  //sign, size
        ex_mem_inst.pc = id_ex_struct.pc;
        ex_mem_inst.mux_A_out = id_ex_struct.mux_A_out;
        ex_mem_inst.mux_B_out = id_ex_struct.mux_B_out;
    end
    
   

//==== Memory ======================================================
     
     
    assign IOBUS_ADDR = ex_mem_aluRes;
    assign IOBUS_OUT = ex_mem_rs2;
    
 
 Memory otter_memory (.MEM_ADDR2(alu_out), .MEM_DIN2(sreg2), .MEM_ADDR1(pc_out[15:2]), 
                         .MEM_RDEN1(cu_memRDEN1), .MEM_RDEN2(cu_memRDEN2), .MEM_WE2(cu_memWE2), 
                         .MEM_SIZE(if_de_reg[13:12]), .MEM_SIGN(if_de_reg[14]), .MEM_DOUT2(out_data2), .MEM_DOUT1(if_de_reg), 
                         .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_CLK(CLK));
 
     
//==== Write Back ==================================================



     
RF_MUX otter_rf_mux (.RFmux0(pc_out), .RFmux1(csr_rd), .RFmux2(out_data2), .RFmux3(alu_out), 
                         .RFmux_SEL(cu_rf_sel), .RFmux_out(RF_MUX_out));


 RegFile otter_reg_file (.en(cu_rf_we), .adr1(ir[19:15]), .adr2(ir[24:20]), .w_adr(ir[11:7]), 
                            .w_data(RF_MUX_out), .CLK(CLK), .rs1(sreg1), .rs2(sreg2));
 

       
            
endmodule
