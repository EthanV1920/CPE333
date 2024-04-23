`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 02/21/2024 10:54:03 AM
// Design Name: OTTER_MCU
// Module Name: OTTER_MCU
// Project Name: OTTER_MCU
// Target Devices: Basys3 Board
// Description: Top module for the otter 
//              central processing unit
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module OTTER_MCU(
    input [31:0] IOBUS_IN,
    input RST,
    input INTR,
    input CLK,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
    );
    // ground whats not being used yet
    // assign INTR = 32'b0;
    
    // create wires to connect all internal modules
    logic cu_csr_mret, cu_csr_we, cu_csr_int_taken, cu_br_eq, cu_br_lt, 
            cu_br_ltu, cu_pc_we, cu_rf_we, cu_memWE2, cu_memRDEN1, cu_memRDEN2,
                cu_reset, int_taken, mret_exec, csr_CU;
    logic [31:0] csr_pc_mepc, csr_pc_mtvec, csr_rd, mux_a_out, mux_b_out, U_imm, 
                    I_imm, S_imm, B_imm, J_imm, RF_MUX_out, out_data2, ir, sreg1, sreg2, 
                        alu_out, pcplus4, addr_pc_jal, addr_pc_branch, addr_pc_jalr, pc_out;
    logic [1:0] cu_rf_sel, mux_a_sel;
    logic [2:0] mux_b_sel, cu_pc_sel;
    logic [3:0] cu_alu_fun;
    
    //connect all inputs/outputs of internal modules
    ProgramCounter otter_PC (.pc_rst(cu_reset), .pc_we(cu_pc_we), .clk(CLK), .JALR(addr_pc_jalr), 
                             .BRANCH(addr_pc_branch), .JAL(addr_pc_jal), .MTVEC(csr_pc_mtvec), 
                             .MEPC(csr_pc_mepc), .PC_SEL(cu_pc_sel), .pc_count(pc_out));
    
    Memory otter_memory (.MEM_ADDR2(alu_out), .MEM_DIN2(sreg2), .MEM_ADDR1(pc_out[15:2]), 
                         .MEM_RDEN1(cu_memRDEN1), .MEM_RDEN2(cu_memRDEN2), .MEM_WE2(cu_memWE2), 
                         .MEM_SIZE(ir[13:12]), .MEM_SIGN(ir[14]), .MEM_DOUT2(out_data2), .MEM_DOUT1(ir), 
                         .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_CLK(CLK));
    
    RegFile otter_reg_file (.en(cu_rf_we), .adr1(ir[19:15]), .adr2(ir[24:20]), .w_adr(ir[11:7]), 
                            .w_data(RF_MUX_out), .CLK(CLK), .rs1(sreg1), .rs2(sreg2));
    
    Immed_Gen otter_immed_gen (.Instruction(ir), .U_Type(U_imm), .I_Type(I_imm), .S_Type(S_imm), 
                               .B_Type(B_imm), .J_Type(J_imm));
    
    Branch_Address_Generator otter_addr_gen (.B_Type(B_imm), .J_Type(J_imm), .I_Type(I_imm), 
                                             .PC(pc_out), .rs(sreg1), .branch(addr_pc_branch), 
                                             .jal(addr_pc_jal), .jalr(addr_pc_jalr));
    
    ALU otter_ALU (.srcA(mux_a_out), .srcB(mux_b_out), .alu_fun(cu_alu_fun), .alu_result(alu_out));
    
    Branch_Condition_Generator otter_cond_gen (.br1(sreg1), .br2(sreg2), .br_eq(cu_br_eq), 
                                               .br_lt(cu_br_lt), .br_ltu(cu_br_ltu));
    
    CU_Decoder otter_cu_dec (.br_LTU(cu_br_ltu), .br_LT(cu_br_lt), .br_EQ(cu_br_eq), .ir(ir), 
                             .int_taken(int_taken), .ALU_FUN(cu_alu_fun), .srcA_SEL(mux_a_sel), 
                             .srcB_SEL(mux_b_sel), .PC_SEL(cu_pc_sel), .RF_SEL(cu_rf_sel)); 
    
    CU_FSM otter_cu_fsm (.clk(CLK), .ir_fsm(ir), .CU_RST(RST), .Interrupt(INTR & csr_CU), .PC_WE(cu_pc_we), 
                         .RF_WE(cu_rf_we), .memWE2(cu_memWE2), .memRDEN1(cu_memRDEN1), 
                         .memRDEN2(cu_memRDEN2), .reset(cu_reset), .csr_WE(cu_csr_we), 
                         .int_taken(int_taken), .mret_exec(cu_csr_mret));
    
    ALU_MUX_A otter_alu_muxA (.ALUmuxA0(sreg1), .ALUmuxA1(U_imm), .ALUmuxA2(~sreg1), 
                              .ALUmuxA_SEL(mux_a_sel), .ALUmuxA_out(mux_a_out));
    
    ALU_MUX_B otter_alu_muxB (.ALUmuxB0(sreg2), .ALUmuxB1(I_imm), .ALUmuxB2(S_imm), .ALUmuxB3(pc_out), 
                              .ALUmuxB4(csr_rd), .ALUmuxB_SEL(mux_b_sel), .ALUmuxB_out(mux_b_out));
    
    RF_MUX otter_rf_mux (.RFmux0(pc_out), .RFmux1(csr_rd), .RFmux2(out_data2), .RFmux3(alu_out), 
                         .RFmux_SEL(cu_rf_sel), .RFmux_out(RF_MUX_out));
                         
    CSR otter_CSR (.RST(RST), .mret_exec(cu_csr_mret), .INT_TAKEN(int_taken), .ADDR(ir[31:20]), 
                    .WR_EN(cu_csr_we), .PC(pc_out), .WD(alu_out), .CLK(CLK), .flag(csr_CU), .mepc(csr_pc_mepc), 
                    .mtvec(csr_pc_mtvec), .RD(csr_rd));
    //set Otter MCU outputs
    assign IOBUS_OUT = sreg2;
    assign IOBUS_ADDR = alu_out; 
    
endmodule
