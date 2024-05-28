`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer:  Sam Solano
//
// Create Date: 05/12/24
// Module Name: PIPELINED_OTTER_CPU
// Target Devices: Basys 3
//////////////////////////////////////////////////////////////////////////////////


module Pipeline_Otter (
    input logic CLK,
    input logic INTR,
    input logic RESET,
    input logic [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
);

  logic cu_br_eq, cu_br_lt, cu_br_ltu, cu_memRDEN1, FmuxASel, FmuxBSel, FlushFlag, PC_WE;

  logic [31:0] csr_pc_mepc, csr_pc_mtvec, csr_rd, U_imm, I_imm,
               S_imm, B_imm, J_imm, addr_pc_jal, addr_pc_branch, addr_pc_jalr,
               FmuxA, FmuxB, MuxA_out, MuxB_out, FMuxA_out, FMuxB_out;

  logic [2:0] cu_pc_sel;
  logic [1:0] flushCount;


  //added by me
  logic [31:0] PCMuxOut;
  logic [2:0] muxB_SEL;
  logic [1:0] muxA_SEL;
  logic [31:0] pcp4Holder;

    instr_t fetch_struct;
    instr_t decode_struct;
    instr_t execute_struct;
    instr_t mem_struct;
    instr_t write_struct;

  //==== Instruction Fetch ===========================================
  
    logic cacheStall, pcStall;
    
        always_comb begin
        if(cacheStall || !pcStall)
            PC_WE = 0;
        else
            PC_WE = 1;
    end
   

    PCTOP MyPCTOP(
       .PC_RST(RESET),
       .PC_WE(PC_WE), 
       .JALR(mem_struct.JALR),
       .BRANCH(mem_struct.BRANCH), 
       .JAL(mem_struct.JAL),
       .PC_SEL(mem_struct.PC_SEL),
       .CLK(CLK), 
       .MTVEC(csr_pc_mtvec),
       .MEPC(csr_pc_mepc),
       //outs
       .PC(fetch_struct.pc),
       .PCplus4(pcp4Holder)
      );


    assign cu_memRDEN1 = 1'b1;  //Fetch new instruction every cycle
    assign fetch_struct.IOBUS_in = IOBUS_IN;

    logic [31:0] v0, v1, v2, v3, v4, v5, v6, v7, currInstruction;
    logic cacheUpdate, cacheHit, cacheMiss;
        
     InstructionMemory OtterImem (
        .a(fetch_struct.pc),
        .w0(v0),
        .w1(v1),
        .w2(v2),
        .w3(v3),
        .w4(v4),
        .w5(v5),
        .w6(v6),
        .w7(v7)
    );
    
    
        CacheFSM cachefsm(
           .hit(cacheHit),
           .miss(cacheMiss), 
            .CLK(CLK), 
            .RST(RESET), 
         .update(cacheUpdate), 
        .pc_stall(cacheStall)
    );
    

    
      Cache Otter_Cache(
       .PC(fetch_struct.pc),
      .CLK(CLK),
     .update(cacheUpdate),
     .cacheStall(cacheStall),
       .w0(v0),
       .w1(v1),
       .w2(v2), 
       .w3(v3),
       .w4(v4), 
       .w5(v5),
       .w6(v6), 
       .w7(v7),
       .rd(currInstruction),
      .hit(cacheHit), 
     .miss(cacheMiss)
    );
    
    assign fetch_struct.ir = currInstruction;

    
    
    
    logic [31:0] tempDout2;
    logic [31:0] tempDout1;
    

//  OG ONE
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
//   assign fetch_struct.ir = tempDout1;






   
   
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


  always_ff @(posedge CLK) begin
      case (decode_struct.opcode)
          LUI: begin 
            decode_struct.rs1_used <= 1'b0;
            decode_struct.rs2_used <= 1'b0;
            decode_struct.rd_used <= 1'b1;
          end
          AUIPC: begin 
            decode_struct.rs1_used <= 1'b0;
            decode_struct.rs2_used <= 1'b0;
            decode_struct.rd_used <= 1'b1;
          end
          JAL: begin
            decode_struct.rs1_used <= 1'b0;
            decode_struct.rs2_used <= 1'b0;
            decode_struct.rd_used <= 1'b1;
        end
          JALR: begin
            decode_struct.rs1_used <= 1'b1;
            decode_struct.rs2_used <= 1'b0;
            decode_struct.rd_used <= 1'b1;
        end
          BRANCH: begin
            decode_struct.rs1_used <= 1'b1;
            decode_struct.rs2_used <= 1'b1;
            decode_struct.rd_used <= 1'b0;
        end
          LOAD: begin
            decode_struct.rs1_used <= 1'b1;
            decode_struct.rs2_used <= 1'b0;
            decode_struct.rd_used <= 1'b1;
        end
          STORE: begin
            decode_struct.rs1_used <= 1'b1;
            decode_struct.rs2_used <= 1'b1;
            decode_struct.rd_used <= 1'b0;
        end
        OP_IMM: begin
            decode_struct.rs1_used <= 1'b1;
            decode_struct.rs2_used <= 1'b0;
            decode_struct.rd_used <= 1'b1;
        end
          OP: begin
            decode_struct.rs1_used <= 1'b1;
            decode_struct.rs2_used <= 1'b1;
            decode_struct.rd_used <= 1'b1;
        end
          SYSTEM: begin
            decode_struct.rs1_used <= 1'b1;
            decode_struct.rs2_used <= 1'b0;
            decode_struct.rd_used <= 1'b1;
        end 
          default: begin
            decode_struct.rs1_used <= 1'b0;
            decode_struct.rs2_used <= 1'b0;
            decode_struct.rd_used <= 1'b0;
        end
    endcase
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
      .ALU_FUN(tempFun), 
      .srcA_SEL(muxA_SEL),
      .srcB_SEL(muxB_SEL),
      .PC_SEL(tempPCSEL),
      .RF_SEL(tempRFSEL),
      .regWrite(tempRegWrite),
      .memWrite(tempMemWrite),
      .memRDEN2(tempMemRead)
  );

HDU otterHazards(
    .ID(fetch_struct),
    .EX(execute_struct),
    .MEM(mem_struct),
    .WB(write_struct),
    .reset(RESET),
    .FmuxA(FmuxA),
    .FmuxB(FmuxB),
    .FmuxASel(FmuxASel),
    .FmuxBSel(FmuxBSel),
    .PC_WE_FLAG(pcStall),
    .FlushFlag(FlushFlag)
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
  
  assign decode_struct.U_Type = U_imm;
  assign decode_struct.I_Type = I_imm;
  assign decode_struct.S_Type = S_imm;
  assign decode_struct.B_Type = B_imm;
  assign decode_struct.J_Type = J_imm;

  MUXA otter_alu_muxA (
      .ALUmuxA0(decode_struct.rs1),
      .ALUmuxA1(decode_struct.U_Type),
      .ALUmuxA2(~decode_struct.rs1),
      .ALUmuxA_SEL(muxA_SEL),
      //outs
      .ALUmuxA_out(MuxA_out)
  );
  

  MUXB otter_alu_muxB (
      .ALUmuxB0(decode_struct.rs2),
      .ALUmuxB1(decode_struct.I_Type),
      .ALUmuxB2(decode_struct.S_Type),
      .ALUmuxB3(decode_struct.pc),
      .ALUmuxB4(csr_rd),
      .ALUmuxB_SEL(muxB_SEL),
      //outs
      .ALUmuxB_out(MuxB_out)
  );
  
  MUX ForwardmuxA (
    .in1(FmuxA),
    .in2(MuxA_out),
    .MuxSel(FmuxASel),
    .MuxOut(FMuxA_out)
  );
  
  MUX ForwardmuxB (
    .in1(FmuxB),
    .in2(MuxB_out),
    .MuxSel(FmuxBSel),
    .MuxOut(FMuxB_out)
  );
  
  assign decode_struct.muxA_out = FMuxA_out;
  assign decode_struct.muxB_out = FMuxB_out;
  
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
        execute_struct.rs1_used <= decode_struct.rs1_used;
        execute_struct.rs2_used <= decode_struct.rs2_used;
        execute_struct.rd_used <= decode_struct.rd_used;
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
        execute_struct.U_Type <= decode_struct.U_Type;
        execute_struct.I_Type <= decode_struct.I_Type;
        execute_struct.S_Type <= decode_struct.S_Type;
        execute_struct.J_Type <= decode_struct.J_Type;
        execute_struct.B_Type <= decode_struct.B_Type;
     end
  
    logic [31:0] tempALU;

  ALU otter_ALU (
      .srcA(execute_struct.muxA_out),
      .srcB(execute_struct.muxB_out),
      .alu_fun(execute_struct.alu_fun),
      //outs
      .alu_result(tempALU)
  );
  
  assign execute_struct.alu_result = tempALU;
  

  BranchCondGen otter_cond_gen (
      .br1(execute_struct.rs1),
      .br2(execute_struct.rs2),
      //outs
      .br_eq(cu_br_eq), //change later
      .br_lt(cu_br_lt), //change later
      .br_ltu(cu_br_ltu) //change later
  );
  
  BranchAddGen otter_addr_gen (
      .B_Type(execute_struct.B_Type),
      .J_Type(execute_struct.J_Type),
      .I_Type(execute_struct.I_Type),
      .PC(execute_struct.pc),
      .rs(execute_struct.rs1),
      //outs
      .branch(addr_pc_branch),
      .jal(addr_pc_jal),
      .jalr(addr_pc_jalr)
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
            mem_struct.rs1_used <= execute_struct.rs1_used;
            mem_struct.rs2_used <= execute_struct.rs2_used;
            mem_struct.rd_used <= execute_struct.rd_used;
            mem_struct.memRead2 <= execute_struct.memRead2;
            mem_struct.regWrite <= execute_struct.regWrite;
            mem_struct.ir <= execute_struct.ir;
            mem_struct.memDout2 <= execute_struct.memDout2;
            mem_struct.JALR <= addr_pc_jalr;
            mem_struct.BRANCH <= addr_pc_branch;
            mem_struct.JAL <= addr_pc_jal;
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
            mem_struct.U_Type <= execute_struct.U_Type;
            mem_struct.I_Type <= execute_struct.I_Type;
            mem_struct.S_Type <= execute_struct.S_Type;
            mem_struct.J_Type <= execute_struct.J_Type;
            mem_struct.B_Type <= execute_struct.B_Type;
        end
     
     assign IOBUS_ADDR = mem_struct.alu_result;
     assign IOBUS_OUT  = mem_struct.rs2;
     assign IOBUS_WR  = mem_struct.IOBUS_wr;
     

  //==== Write Back ==================================================
   
   always_ff @(posedge CLK) begin
            write_struct.pc <= mem_struct.pc;
            write_struct.opcode <= mem_struct.opcode;
            write_struct.rs1_addr <= mem_struct.rs1_addr;
            write_struct.rs2_addr <= mem_struct.rs2_addr;
            write_struct.rd_addr <= mem_struct.rd_addr;
            write_struct.rs1_used <= mem_struct.rs1_used;
            write_struct.rs2_used <= mem_struct.rs2_used;
            write_struct.rd_used <= mem_struct.rd_used;
            write_struct.memRead2 <= mem_struct.memRead2;
            write_struct.ir <= mem_struct.ir;
            write_struct.memDout2 <= mem_struct.memDout2;
            write_struct.JALR <= mem_struct.JALR;
            write_struct.BRANCH <= mem_struct.BRANCH;
            write_struct.JAL <= mem_struct.JAL;
            write_struct.rs1 <= mem_struct.rs1;
            write_struct.PC_SEL <= mem_struct.PC_SEL;
            write_struct.IOBUS_in <= mem_struct.IOBUS_in;
            write_struct.IOBUS_wr <= mem_struct.IOBUS_wr;
            write_struct.alu_fun <= mem_struct.alu_fun;
            write_struct.memWrite <= mem_struct.memWrite;
            write_struct.rf_SEL <= mem_struct.rf_SEL;
            write_struct.muxA_out <= mem_struct.muxA_out;
            write_struct.muxB_out <= mem_struct.muxB_out;
            write_struct.rs2 <= mem_struct.rs2;
            write_struct.alu_result <= mem_struct.alu_result;
            write_struct.U_Type <= mem_struct.U_Type;
            write_struct.I_Type <= mem_struct.I_Type;
            write_struct.S_Type <= mem_struct.S_Type;
            write_struct.J_Type <= mem_struct.J_Type;
            write_struct.B_Type <= mem_struct.B_Type;
            if(FlushFlag == 1)begin
                flushCount <= 2'b10;
            end
            if(flushCount>0)begin
                write_struct.regWrite <= 1'b0;
                flushCount <= flushCount - 1;
            end
            else begin
                write_struct.regWrite <=1'b1;
            end
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
