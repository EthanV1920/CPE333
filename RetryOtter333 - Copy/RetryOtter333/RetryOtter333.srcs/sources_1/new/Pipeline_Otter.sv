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

  logic cu_br_eq, cu_br_lt, cu_br_ltu, cu_memRDEN1, WE_flag, FmuxASel, FmuxBSel;
                
  logic [31:0] csr_pc_mepc, csr_pc_mtvec, csr_rd, U_imm, I_imm,
               S_imm, B_imm, J_imm, addr_pc_jal, addr_pc_branch, addr_pc_jalr,
               Fmux, FmuxB, FmuxA_out, FmuxB_out;
               
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
    instr_t HDU_ID_out;

  //==== Instruction Fetch ===========================================  
//  assign fetch_struct.pc = 32'b0;

//  PC otter_PC (
//      .pc_rst(RESET),
//      .pc_we(PC_WE), //change later
//      .clk(CLK),
//      .JALR(addr_pc_jalr), //change later
//      .BRANCH(addr_pc_branch), //change later
//      .JAL(addr_pc_jal), //change later
//      .MTVEC(csr_pc_mtvec), //change later
//      .MEPC(csr_pc_mepc), //change later
//      .PC_SEL(cu_pc_sel), //change later
//      //outs
//      .pc_count(fetch_struct.pc)
//  );
    HazardDetectionUnit HDU(
        .ID(decode_struct),
        .EX(execute_struct),
        .MEM(mem_struct),
        .WB(write_struct),
        .WE_flag(WE_flag),
        .FmuxA(FmuxA),
        .FmuxB(FmuxB),
        .FmuxASel(FmuxASel),
        .FmuxBSel(FmuxBSel),
        .PC_WE(PC_WE),
        .WE_flag_out(WE_flag),
        .FlushFlag(FlushFlag),
        .ID_out(HDU_ID_out)
    );
    
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
       .PCplus4(pcp4Holder)
      );


//    PC_MUX Otter_PcMux(
//        .MUX_A(pcp4),
//        .MUX_B(addr_pc_jalr),
//        .MUX_C(addr_pc_branch),
//        .MUX_D(addr_pc_jal),
//        .MUX_E(csr_pc_mtvec),
//        .MUX_F(csr_pc_mepc),
//        .MUX_SEL(cu_pc_sel), // 3-bits to accomodate all inputs, but not all values are being used
//        //outs
//        .MUX_Out(PCMuxOut)
//    );
//    PC Otter_PC(    
//        .PC_RST(RESET),
//        .PC_WE(PC_WE),
//        .PC_DIN(PCMuxOut),
//        .CLK(CLK),
//        //outs
//        .PC_COUNT(fetch_struct.pc),
//        .PCP4(pcp4)
//    );


    
    

    assign cu_memRDEN1 = 1'b1;  //Fetch new instruction every cycle
    assign fetch_struct.IOBUS_in = IOBUS_IN;
    
//new one
//    logic error;
//     MemoryReadOnly Otter_MemoryREAD (
//       .MEM_ADDR2(mem_struct.alu_result),
//       .MEM_CLK(CLK),
//       .MEM_DIN2(mem_struct.rs2), //get from mem stage
//       .IO_IN(mem_struct.IOBUS_in), //not sure
//       .MEM_ADDR1(fetch_struct.pc[15:2]),
//       .MEM_READ1(cu_memRDEN1), //change later
//       .MEM_READ2(mem_struct.memRead2), //from mem stage
//       .MEM_WRITE2(mem_struct.memWrite), //get from mem stage
//       .ERR(error),
//       //outs
//       .MEM_DOUT2(fetch_struct.memDout2),
//       .MEM_DOUT1(fetch_struct.ir), 
//       .IO_WR(fetch_struct.IOBUS_wr) //change later
//   );

  
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
       .MEM_DOUT2(fetch_struct.memDout2),
       .MEM_DOUT1(fetch_struct.ir), 
       .IO_WR(fetch_struct.IOBUS_wr) //change later
   );
   
   
   
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
    
    // this is to check if the instruction uses rs1, rs2, or has a destination register
    assign fetch_struct.rs1_used = fetch_struct.rs1_addr != 0
                                && fetch_struct.opcode != LUI
                                && fetch_struct.opcode != AUIPC
                                && fetch_struct.opcode != JAL;

    assign fetch_struct.rs2_used = fetch_struct.rs2_addr != 0
                                && fetch_struct.opcode != JAL
                                && fetch_struct.opcode != JALR
                                && fetch_struct.opcode != BRANCH
                                && fetch_struct.opcode != LOAD
                                && fetch_struct.opcode != STORE
                                && fetch_struct.opcode != LUI
                                && fetch_struct.opcode != AUIPC
                                && fetch_struct.opcode != OP_IMM
                                && fetch_struct.opcode != SYSTEM;

    assign fetch_struct.rd_used = fetch_struct.rd_addr != 0
                                && fetch_struct.opcode != BRANCH
                                && fetch_struct.opcode != STORE
                                && fetch_struct.opcode != JAL;
                                
    assign fetch_struct.regWrite =    fetch_struct.opcode != BRANCH
                                   && fetch_struct.opcode != STORE
                                   && fetch_struct.opcode != DEFAULT;


   

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
        decode_struct.rs1_used <= fetch_struct.rs1_used;
        decode_struct.rs2_used <= fetch_struct.rs2_used;
        decode_struct.rd_used <= fetch_struct.rd_used;
        decode_struct.memRead2 <= fetch_struct.memRead2;
        decode_struct.regWrite <= fetch_struct.regWrite;
        decode_struct.mem_type <= fetch_struct. mem_type; 
        decode_struct.ir <= fetch_struct.ir;
        decode_struct.memDout2 <= fetch_struct.memDout2;
        decode_struct.JALR <= fetch_struct.JALR;
        decode_struct.BRANCH <= fetch_struct.BRANCH;
        decode_struct.JAL <= fetch_struct.JAL;
        decode_struct.alu_result <= fetch_struct.alu_result;
//        decode_struct.rs1 <= fetch_struct.rs1;
        decode_struct.RF_MUX_out <= fetch_struct.RF_MUX_out;
        decode_struct.PC_SEL <= fetch_struct.PC_SEL;
        decode_struct.memWrite2 <= fetch_struct.memWrite2;
        decode_struct.IOBUS_in <= fetch_struct.IOBUS_in;
        decode_struct.IOBUS_wr <= fetch_struct.IOBUS_wr;
      end
      
      logic [3:0] tempFun;
      logic tempMemWrite;
      logic [1:0] tempRFSEL;

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
      .PC_SEL(decode_struct.PC_SEL),
      .RF_SEL(tempRFSEL),
      .regWrite(decode_struct.regWrite),
      .memWrite(tempMemWrite),
      .memRDEN2(decode_struct.memRead2)
  );
    always_comb begin
    decode_struct.alu_fun = tempFun;
    decode_struct.memWrite = tempMemWrite; // create
     decode_struct.rf_SEL = tempRFSEL; // create
    
  end
  


    logic [31:0] tempRS1;
    logic [31:0] tempRS2;

  RegFile otter_reg_file (
      .en(write_struct.regWrite), //write back tells regfile when to write
      .adr1(decode_struct.rs1_addr),
      .adr2(decode_struct.rs2_addr),
      .w_adr(write_struct.rd_addr),  // add from write back
      .w_data(write_struct.RF_MUX_out),
      .CLK(CLK),
      //outs
      .rs1(tempRS1),
      .rs2(tempRS2)
  );
 
  
    always_comb begin
        decode_struct.rs2 = tempRS2; // create
        decode_struct.rs1 = tempRS1; // create
//          $display("outside rs2: %h", tempRS2);
    end
  
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
        execute_struct <= HDU_ID_out;
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
        execute_struct.mem_type <= decode_struct. mem_type; 
        execute_struct.ir <= decode_struct.ir;
        execute_struct.memDout2 <= decode_struct.memDout2;
        execute_struct.JALR <= decode_struct.JALR;
        execute_struct.BRANCH <= decode_struct.BRANCH;
        execute_struct.JAL <= decode_struct.JAL;
//      execute_struct.alu_result <= decode_struct.alu_result;
        execute_struct.rs1 <= decode_struct.rs1;
        execute_struct.RF_MUX_out <= decode_struct.RF_MUX_out;
        execute_struct.PC_SEL <= decode_struct.PC_SEL;
        execute_struct.memWrite2 <= decode_struct.memWrite2;
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
    
  FMuxA FMuxA(
      .FMuxA(FMuxA),
      .MuxA_out(execute_struct.muxA_out),
      .FMuxA_SEL(FMuxA_SEL),
      .FMuxA_out(FMuxA_out)
  );
  
  FMuxB FMuxB(
      .FMuxB(FMuxB),
      .MuxB_out(execute_struct.muxB_out),
      .FMuxB_SEL(FMuxB_SEL),
      .FMuxB_out(FMuxB_out)
  );

  ALU otter_ALU (
      .srcA(FMuxA_out),
      .srcB(FMuxB_out),
      .alu_fun(execute_struct.alu_fun),
      //outs
      .alu_result(execute_struct.alu_result)
  );
  
//    always_comb begin
//        execute_struct.alu_result = tempALU;
//    end

  BranchCondGen otter_cond_gen (
      .br1(execute_struct.rs1),
      .br2(execute_struct.rs2),
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

     always_ff @(posedge CLK) begin
        mem_struct <= execute_struct;
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
      .RFmux_out(write_struct.RF_MUX_out)
  );
  
    
 //not sure 
//MemoryReadWrite Otter_Memory_READWRITE(
//       .MEM_ADDR2(mem_struct.alu_result),
//       .MEM_CLK(CLK),
//       .MEM_DIN2(mem_struct.rs2), //get from mem stage
//       .IO_IN(mem_struct.IOBUS_in), //not sure
//       .MEM_ADDR1(fetch_struct.pc[15:2]),
//       .MEM_READ1(cu_memRDEN1), //change later
//       .MEM_READ2(mem_struct.memRead2), //from mem stage
//       .MEM_WRITE2(mem_struct.memWrite), //get from mem stage
//       .MEM_SIZE(mem_struct.ir[13:12]),
//       .MEM_SIGN(mem_struct.ir[14]),
//       .ERR(error),
//       //outs
//       .MEM_DOUT2(fetch_struct.memDout2),
//       .MEM_DOUT1(fetch_struct.ir), 
//       .IO_WR(fetch_struct.IOBUS_wr) //change later
//       );

endmodule


//issues with the decoder and why stuff doesnt show up properly