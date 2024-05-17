`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer:  Sam Solano
//
// Create Date: 05/12/24
// Module Name: PIPELINED_OTTER_CPU
// Target Devices: Basys 3
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
  logic [3:0] alu_fun;
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

module Pipeline_Otter (
    input logic CLK,
    input logic INTR,
    input logic RESET,
    input logic [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
);

  logic cu_br_eq, cu_br_lt, cu_br_ltu, cu_memRDEN1;
                
  logic [31:0] csr_pc_mepc, csr_pc_mtvec, csr_rd, U_imm, I_imm,
               S_imm, B_imm, J_imm, addr_pc_jal, addr_pc_branch, addr_pc_jalr;
               
  logic [2:0] cu_pc_sel;
  
  
  //added by me
  logic [31:0] PCMuxOut;
  logic [2:0] muxB_SEL;
  logic [1:0] muxA_SEL;
  logic [31:0] pcp4Holder;
  logic intTaken;
  
    instr_t fetch_struct;
    instr_t decode_struct;
    instr_t execute_struct;
    instr_t mem_struct;
    instr_t write_struct;

  //==== Instruction Fetch ===========================================
  assign PC_WE  = 1'b1;  //Hardwired high, assuming no hazard

    PCTOP MyPCTOP(
       .PC_RST(RESET),
       .PC_WE(PC_WE), 
       .JALR(addr_pc_jalr),
       .BRANCH(addr_pc_branch), 
       .JAL(ddr_pc_jal),
       .PC_SEL(Pcu_pc_sel),
       .CLK(CLK), 
       .MTVEC(csr_pc_mtvec),
       .MEPC(csr_pc_mepc),
       //outs
       .PC(fetch_struct.pc),
       .PCplus4(PC4)
      );


    assign cu_memRDEN1 = 1'b1;  //Fetch new instruction every cycle
    assign fetch_struct.IOBUS_in = IOBUS_IN;
    
    logic [31:0] tempDout2;
    logic [31:0] tempDout1;
  
  //OG ONE
     Memory Otter_Memory (
       .MEM_ADDR2(mem_struct.alu_result),
       .MEM_CLK(CLK),
       .MEM_DIN2(mem_struct.rs2), //get from mem stage
       .IO_IN(mem_struct.IOBUS_in), //not sure
       .MEM_ADDR1(fetch_struct.pc[15:2]),
       .MEM_RDEN1(cu_memRDEN1), //change later
       .MEM_RDEN2(mem_struct.memRead2), //from mem stage
       .MEM_WE2(mem_struct.memWrite), //get from mem stage
       .MEM_SIZE(mem_struct.ir[13:12]),
       .MEM_SIGN(mem_struct.ir[14]),
       //outs
       .MEM_DOUT2(tempDout2),
       .MEM_DOUT1(tempDout1), 
       .IO_WR(fetch_struct.IOBUS_wr) //change later
   );
   
   
   assign fetch_struct.memDout2 = tempDout2;
   assign fetch_struct.ir = tempDout1;
   
   
     logic [6:0] opcodeBits;
     assign opcodeBits = fetch_struct.ir[6:0];
     opcode_t OPCODE;
      
    always_comb begin
          case (opcodeBits)
            7'b0110111: OPCODE = LUI;
            7'b0010111: OPCODE = AUIPC;
            7'b1101111: OPCODE = JAL;
            7'b1100111: OPCODE = JALR;
            7'b1100011: OPCODE = BRANCH;
            7'b0000011: OPCODE = LOAD;
            7'b0100011: OPCODE = STORE;
            7'b0010011: OPCODE = OP_IMM;
            7'b0110011: OPCODE = OP;
            7'b1110011: OPCODE = SYSTEM;
            default:    OPCODE = DEFAULT;
         endcase
    end
    
    assign fetch_struct.opcode = OPCODE;
    assign fetch_struct.rs1_addr = fetch_struct.ir[19:15];
    assign fetch_struct.rs2_addr = fetch_struct.ir[24:20];
    assign fetch_struct.rd_addr = fetch_struct.ir[11:7];



   

  //==== Instruction Decode ===========================================

    
//    always_ff @(posedge CLK) begin
//        decode_struct <= fetch_struct;
//      end
      
            always_ff @(posedge CLK) begin
        decode_struct.pc <= fetch_struct.pc;
        decode_struct.opcode <= fetch_struct.opcode;
        decode_struct.rs1_addr <= fetch_struct.rs1_addr;
        decode_struct.rs2_addr <= fetch_struct.rs2_addr;
        decode_struct.rd_addr <= fetch_struct.rd_addr;
        decode_struct.ir <= fetch_struct.ir;
        decode_struct.memDout2 <= fetch_struct.memDout2;
        decode_struct.IOBUS_in <= fetch_struct.IOBUS_in;
        decode_struct.IOBUS_wr <= fetch_struct.IOBUS_wr;
      end
      
      logic [3:0] tempFun;
      logic tempMemWrite;
      logic [1:0] tempRFSEL;
      logic [2:0] tempPCSEL;
      logic tempMemRead;
      logic tempRegWrite;

  Decoder otter_cu_dec (
      .ir(decode_struct.ir),
      .br_eq(cu_br_eq), //change later
      .br_lt(cu_br_lt), //change later
      .br_ltu(cu_br_ltu), //change later
      .reset(RESET),
      .int_taken(intTaken),
      //outs
      .ALU_FUN(tempFun),  //need to look at again
      .srcA_SEL(muxA_SEL),
      .srcB_SEL(muxB_SEL),
      .PC_SEL(tempPCSEL),
      .RF_SEL(tempRFSEL),
      .regWrite(tempRegWrite),
      .memWrite(tempMemWrite),
      .memRDEN2(tempMemRead)
  );

    assign decode_struct.alu_fun = tempFun;
    assign decode_struct.memWrite = tempMemWrite; // create
    assign decode_struct.rf_SEL = tempRFSEL; // create
    assign decode_struct.PC_SEL = tempPCSEL;
    assign decode_struct.memRead2 = tempMemRead;
    assign decode_struct.regWrite = tempRegWrite;
  
  
    logic [31:0] tempRS1;
    logic [31:0] tempRS2;
    logic [31:0] tempRfOut;

  RegFile otter_reg_file (
      .en(write_struct.regWrite), //write back tells regfile when to write
      .adr1(decode_struct.rs1_addr),
      .adr2(decode_struct.rs2_addr),
      .w_adr(write_struct.rd_addr),  // add from write back
      .w_data(tempRfOut),
      .CLK(CLK),
      //outs
      .rs1(tempRS1),
      .rs2(tempRS2)
  );
 
  
        assign decode_struct.rs2 = tempRS2; // create
        assign decode_struct.rs1 = tempRS1; // create

  
  ImmedGen otter_immed_gen (
      .Instruction(decode_struct.ir),
      //outs
      .U_Type(U_imm),
      .I_Type(I_imm),
      .S_Type(S_imm),
      .B_Type(B_imm),
      .J_Type(J_imm)
  );

    logic [31:0] tempMuxBOUT;
    logic [31:0] tempMuxAOUT;

  MUXA otter_alu_muxA (
      .ALUmuxA0(decode_struct.rs1),
      .ALUmuxA1(U_imm),
      .ALUmuxA2(~decode_struct.rs1),
      .ALUmuxA_SEL(muxA_SEL),
      //outs
      .ALUmuxA_out(decode_struct.muxA_out)
  );
  

  MUXB otter_alu_muxB (
      .ALUmuxB0(decode_struct.rs2),
      .ALUmuxB1(I_imm),
      .ALUmuxB2(S_imm),
      .ALUmuxB3(decode_struct.pc),
      .ALUmuxB4(csr_rd),
      .ALUmuxB_SEL(muxB_SEL),
      //outs
      .ALUmuxB_out(decode_struct.muxB_out)
  );
  
//  always_comb begin
//    execute_struct.muxB_out = tempMuxBOUT;
//    execute_struct.muxA_out = tempMuxAOUT;
//  end
  


  //==== Execute ======================================================
  
  
  
  
//    always_ff @(posedge CLK) begin
//        execute_struct <= decode_struct;
//     end
     
     always_ff @(posedge CLK) begin
              execute_struct.pc <= decode_struct.pc;
          execute_struct.opcode <= decode_struct.opcode;
        execute_struct.rs1_addr <= decode_struct.rs1_addr;
        execute_struct.rs2_addr <= decode_struct.rs2_addr;
         execute_struct.rd_addr <= decode_struct.rd_addr;
        execute_struct.memRead2 <= decode_struct.memRead2;
        execute_struct.regWrite <= decode_struct.regWrite;
              execute_struct.ir <= decode_struct.ir;
        execute_struct.memDout2 <= decode_struct.memDout2;
            execute_struct.JALR <= decode_struct.JALR;
          execute_struct.BRANCH <= decode_struct.BRANCH;
             execute_struct.JAL <= decode_struct.JAL;
             execute_struct.rs1 <= decode_struct.rs1;
          execute_struct.PC_SEL <= decode_struct.PC_SEL;
        execute_struct.IOBUS_in <= decode_struct.IOBUS_in;
        execute_struct.IOBUS_wr <= decode_struct.IOBUS_wr;
        execute_struct.alu_fun <= decode_struct.alu_fun;
        execute_struct.memWrite <= decode_struct.memWrite;
        execute_struct.rf_SEL <= decode_struct.rf_SEL;
        execute_struct.muxA_out <= decode_struct.muxA_out;
        execute_struct.muxB_out <= decode_struct.muxB_out;
        execute_struct.rs2 <= decode_struct.rs2;
     end
  
    logic [31:0] tempALU;

  ALU otter_ALU (
      .srcA(execute_struct.muxA_out),
      .srcB(execute_struct.muxB_out),
      .alu_fun(execute_struct.alu_fun),
      //outs
      .alu_result(execute_struct.alu_result)
  );
  

  BranchCondGen otter_cond_gen (
      .br1(execute_struct.rs1),
      .br2(execute_struct.rs2),
      //outs
      .br_eq(cu_br_eq), //change later
      .br_lt(cu_br_lt), //change later
      .br_ltu(cu_br_ltu) //change later
  );
  
  BranchAddGen otter_addr_gen (
      .B_Type(B_imm),
      .J_Type(J_imm),
      .I_Type(I_imm),
      .PC(execute_struct.pc),
      .rs(execute_struct.rs1),
      //outs
      .branch(addr_pc_branch), //change later
      .jal(addr_pc_jal),    //change later
      .jalr(addr_pc_jalr)   //change later
  );


  //==== Memory ======================================================

//     always_ff @(posedge CLK) begin
//        mem_struct <= execute_struct;
//     end
     
        always_ff @(posedge CLK) begin
            mem_struct.pc <= execute_struct.pc;
            mem_struct.opcode <= execute_struct.opcode;
            mem_struct.rs1_addr <= execute_struct.rs1_addr;
            mem_struct.rs2_addr <= execute_struct.rs2_addr;
            mem_struct.rd_addr <= execute_struct.rd_addr;
            mem_struct.memRead2 <= execute_struct.memRead2;
            mem_struct.regWrite <= execute_struct.regWrite;
            mem_struct.ir <= execute_struct.ir;
            mem_struct.memDout2 <= execute_struct.memDout2;
            mem_struct.JALR <= execute_struct.JALR;
            mem_struct.BRANCH <= execute_struct.BRANCH;
            mem_struct.JAL <= execute_struct.JAL;
            mem_struct.rs1 <= execute_struct.rs1;
            mem_struct.PC_SEL <= execute_struct.PC_SEL;
            mem_struct.IOBUS_in <= execute_struct.IOBUS_in;
            mem_struct.IOBUS_wr <= execute_struct.IOBUS_wr;
            mem_struct.alu_fun <= execute_struct.alu_fun;
            mem_struct.memWrite <= execute_struct.memWrite;
            mem_struct.rf_SEL <= execute_struct.rf_SEL;
            mem_struct.muxA_out <= execute_struct.muxA_out;
            mem_struct.muxB_out <= execute_struct.muxB_out;
            mem_struct.rs2 <= execute_struct.rs2;
            mem_struct.alu_result <= execute_struct.alu_result;
        end
     
     assign IOBUS_ADDR = mem_struct.alu_result;
     assign IOBUS_OUT  = mem_struct.rs2;
     assign IOBUS_WR  = mem_struct.IOBUS_wr;
     

  //==== Write Back ==================================================
   
   always_ff @(posedge CLK) begin
        write_struct <= mem_struct;
     end

    

  RFMUX otter_rf_mux (
      .RFmux0(write_struct.pc),
      .RFmux1(csr_rd), // look at later
      .RFmux2(write_struct.memDout2),
      .RFmux3(write_struct.alu_result),
      .RFmux_SEL(write_struct.rf_SEL),
      //outs
      .RFmux_out(tempRfOut)
  );

  
  

endmodule

//make none of the assign ff blocks not assign to rfMux out
