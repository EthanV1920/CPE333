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
//////////////////////////////////////////////////////////////////////////////////

module CU_FSM(
    input clk,
    input [31:0] ir,
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
    
    typedef enum {ST_INIT, ST_FETCH, ST_EXEC} STATES;
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
                memRDEN1 = 1'b1;
                NS = ST_EXEC;
            end 
            //execute state sets values for proper and 
            //correctly timed execution of instructions
            ST_EXEC: begin
                NS = ST_FETCH;
                case(ir[6:0])
                    7'b0110111: begin // lui 
                        PC_WE = 1;
                        RF_WE = 1;
                    end 
                    7'b0010011: begin // slli and addi
                        PC_WE = 1;
                        RF_WE = 1;
                    end 
                    7'b0110011: begin // slt and xor 
                        PC_WE = 1;
                        RF_WE = 1;
                    end
                    7'b1100011: begin //beq 
                        PC_WE = 1;
                    end 
                    default: PC_WE = 0;// should never occur 
                endcase
            end
            default: begin // should never occur 
                NS = ST_INIT; // returns to initial state
            end
        endcase
    end   
endmodule
