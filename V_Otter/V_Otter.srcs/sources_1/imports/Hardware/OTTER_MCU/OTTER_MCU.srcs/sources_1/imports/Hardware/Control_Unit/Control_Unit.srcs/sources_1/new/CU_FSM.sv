`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Victoria Asencio-Clemens
// Create Date: 02/20/2024 10:47:20 PM
// Design Name: CU_FSM
// Module Name: CU_FSM
// Project Name: Control_Unit
// Target Devices: Basys3 Board
// Description: Finite state machine for setting 
//              time sensitive control values
// Revision 0.01 - File Created
// Revision 0.02 - Updated with all instructions
//////////////////////////////////////////////////////////////////////////////////

module CU_FSM(
    input clk,
    input [31:0] ir_fsm,
    input CU_RST,
    input Interrupt,
    output logic PC_WE,
    output logic RF_WE,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset,
    output logic csr_WE,
    output logic int_taken,
    output logic mret_exec
    );
    
    typedef enum {ST_INIT, ST_FETCH, ST_EXEC, ST_WRITE, ST_INTR} STATES;
    STATES PS, NS;
    // state register 
    always_ff@(posedge clk) begin
        if (CU_RST == 1'b1) PS <= ST_INIT;
        else PS <= NS;
    end
    // input/output logic
    always_comb begin
        // initialize all outputs to zero
        PC_WE = 0;
        RF_WE = 0;
        memWE2 = 0;
        memRDEN1 = 0;
        memRDEN2 = 0;
        reset = 0;
        csr_WE = 0;
        int_taken = 0;
        mret_exec = 0;
        case(PS) 
            //initial state
            ST_INIT: begin
                reset = 1'b1;
                NS = ST_FETCH;
            end 
            //fetch state retrieves the next instruction from memory
            ST_FETCH: begin
                memRDEN1 = 1'b1; // load address of new instruction
                NS = ST_EXEC; // go to execution
            end 
            //execute state sets values for proper and 
            //correctly timed execution of instructions
            ST_EXEC: begin
                if (Interrupt) NS = ST_INTR;
                else NS = ST_FETCH;
                case({ir_fsm[6:0]})
                    7'b0000011: begin // I-Type load instructions
                        memRDEN2 = 1'b1;
                        NS = ST_WRITE;
                    end 
                    7'b0100011: begin // S-Type store instuctions
                        PC_WE = 1'b1;
                        memWE2 = 1;
                        RF_WE = 0; // no destination register
                    end
                    7'b1100011: begin // B-Type branch instructions
                        PC_WE = 1'b1;
                        RF_WE = 0; // no destination register
                    end
                    7'b1110011: begin // control & status register read
                        PC_WE = 1'b1;
                        case(ir_fsm[14:12]) // intructions and mret
                            3'b011: begin // csrrc
                                RF_WE = 1;
                                csr_WE = 1;
                            end
                            3'b010: begin // csrrs
                                RF_WE = 1;
                                csr_WE = 1;
                            end
                            3'b001: begin // csrrw
                                RF_WE = 1;
                                csr_WE = 1;
                            end
                            3'b000: begin // mret
                                mret_exec = 1;
                            end
                            default: csr_WE = 1;
                        endcase
                    end
                    default: begin
                        if (Interrupt) NS = ST_INTR;
                        else NS = ST_FETCH;
                        PC_WE = 1'b1;
                        RF_WE = 1; // most instructions write to destination register
                    end
                endcase
            end
            ST_WRITE: begin // for load instructions
                if (Interrupt) NS = ST_INTR;
                else NS = ST_FETCH;
                RF_WE = 1;
                PC_WE = 1'b1;
            end
            ST_INTR: begin
                int_taken = 1;
                PC_WE = 1'b1;
                NS = ST_FETCH;
            end
            default: begin // should never occur 
                NS = ST_INIT; // returns to initial state
            end
        endcase
    end   
endmodule
