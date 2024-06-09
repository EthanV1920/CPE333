`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Maria Pantoja
//////////////////////////////////////////////////////////////////////////////////

module DataCache(
    input [31:0] Address,
    input CLK,
    input update,
    input cacheStall,
    input read,
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
    parameter TAG_SIZE = 32 - INDEX_SIZE - WORD_OFFSET_SIZE - 0;
    
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
    
    logic missTemp;

    always_comb begin
        hit = 0;
        missTemp = 0;
        rd = 32'hDEADBEEF; 
        for (int i = 0; i < NUM_WAYS; i = i + 1) begin
            missTemp = 1;
            if(cache[index][i].valid && (cache[index][i].cache_tag == pc_tag)) begin
                hit = 1;
                missTemp = 0;
                if(!cacheStall) rd = cache[index][i].data[word_offset];
                break;
            end
        end
        
      miss = missTemp;
        
    end
        
    always_ff @(posedge CLK) begin
        if(update) begin
            int random_way;
            random_way = $urandom % 4;
            cache[index][random_way].data[0] <= w0;
            cache[index][random_way].data[1] <= w1;
            cache[index][random_way].data[2] <= w2;
            cache[index][random_way].data[3] <= w3;
//            if(cache[index][random_way].valid == 1'b1) cache[index][random_way].dirty <= 1'b1;
            cache[index][random_way].valid <= 1'b1;
            cache[index][random_way].cache_tag <= pc_tag;
        end
    end
    
endmodule