`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2024 03:26:54 PM
// Design Name: 
// Module Name: CacheFSM
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


module DataCacheFSM(
input hit, 
input miss, 
input read,
input write,
input CLK, 
input RST, 
output logic update, 
output logic pc_stall,
output logic readFrom
);

    typedef enum{
        ST_IDLE,
        ST_READ,
        ST_WRITE
    } state_type;
    
    state_type PS, NS;
    
    always_ff @(posedge CLK) begin
        if(RST == 1)
            PS <= ST_IDLE;
        else
            PS <= NS;
    end
    
    always_comb begin
        update = 0;
        pc_stall = 0;
        readFrom = 0;
        
        case (PS)
            ST_IDLE: begin
                if(read)
                    NS = ST_READ;
                else if(write)
                    NS = ST_WRITE;
                else
                    NS = ST_IDLE;
            end
            ST_READ: begin
                if(hit) begin
                    NS = ST_IDLE;
                    readFrom = 1;
                end
                if(miss) begin
                    NS = ST_READ;
                    update = 1;
                    pc_stall = 1'b1;   
                end
            end
            ST_WRITE: begin
                update = 1;
                if(read)
                    NS = ST_READ;
                else if(write)
                    NS = ST_WRITE;
                else
                    NS = ST_IDLE;
            end
            default: NS = ST_IDLE;
        endcase
    end
    
endmodule
