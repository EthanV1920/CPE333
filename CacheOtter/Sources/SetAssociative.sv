`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Maria Pantoja
//////////////////////////////////////////////////////////////////////////////////

module InstructionCache(
    input [31:0] Address,
    input CLK,
    input update,
    input cacheStall,
    input logic [31:0] w0,
    input logic [31:0] w1,
    input logic [31:0] w2, 
    input logic [31:0] w3,
    output logic [31:0] rd,
    output logic hit, 
    output logic miss
    );
    
    parameter NUM_WAYS = 4;
    parameter NUM_BLOCKS = 16;
    parameter BLOCK_SIZE = 4;
    parameter INDEX_SIZE = 4;
    parameter WORD_OFFSET_SIZE = 2;
    parameter BYTE_OFFSET_SIZE = 2;
    parameter TAG_SIZE = 32 - INDEX_SIZE - WORD_OFFSET_SIZE - BYTE_OFFSET;
    
    typedef struct {
        logic valid;
        logic dirty;
        logic [TAG_SIZE-1:0] cache_tag;
        logic [31:0] data[BLOCK_SIZE-1:0];
    } CacheLine;

    typedef CacheLine CacheSet[4];
    CacheSet cache[NUM_BLOCKS];
    
    logic [INDEX_SIZE-1:0] index;
    logic [TAG_SIZE-1:0] pc_tag;
    logic [WORD_OFFSET_SIZE-1:0] word_offset;
    logic [BYTE_OFFSET_SIZE-1:0] byte_offset;
    
    initial begin
        int i, j;
        for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
            for (j = 0; j < NUM_WAYS; j = j + 1) begin
                cache[i][j].valid = 1'b0;
                cache[i][j].dirty = 1'b0;
                cache[i][j].cache_tag = 24'b0;
                for (int k = 0; k < BLOCK_SIZE; k = k + 1) begin
                    cache[i][j].data[k] = 32'b0;
                end
            end
        end
    end
    
    assign index = Address[7:4];
    assign pc_tag = Address[31:8];
    assign word_offset = Address[3:2];
    assign byte_offset = Address[1:0];

    always_comb begin
        hit = 0;
        miss = 1;
        rd = 32'h00000013; //nop
        for (int i = 0; i < NUM_WAYS; i = i + 1) begin
            if(cache[index][i].valid && (cache[index][i].tag == pc_tag)) begin
                hit = 1;
                miss = 0;
                if(!cacheStall) rd = bytecache[index][i].data[word_offset];
                break;
            end
        end
    end
        
    always_ff @(negedge CLK) begin
        if(update) begin
            int random_way;
            random_way = $urandom % 4;
            cache[index][random_way].data[0] <= w0;
            cache[index][random_way].data[1] <= w1;
            cache[index][random_way].data[2] <= w2;
            cache[index][random_way].data[3] <= w3;
            cache[index][random_way].valid <= 1'b1;
            cache[index][random_way].tag <= pc_tag;
        end
    end
    
endmodule