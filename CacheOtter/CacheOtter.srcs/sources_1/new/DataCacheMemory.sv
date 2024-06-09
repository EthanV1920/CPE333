`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////

module DataMemory(
input CLK,
input read,
input write,
input logic [31:0] addressIn,
input logic [31:0] dataIn,
output logic [31:0] w0,
output logic [31:0] w1,
output logic [31:0] w2,
output logic [31:0] w3
);

    logic [31:0] dataMem[0:16383];
    initial $readmemh("data.mem", dataMem, 0, 16383);
    
    always_ff @ (posedge CLK) begin
//      always_comb begin
        if(read && addressIn != 16'h6008) begin
            //changed memory so it does output 8 words
            w0 <= dataMem[(({addressIn[31:2],2'b00}-24576)/4)];
            w1 <= dataMem[(({addressIn[31:2],2'b00}-24576)/4)+1];
            w2 <= dataMem[(({addressIn[31:2],2'b00}-24576)/4)+2];
            w3 <= dataMem[(({addressIn[31:2],2'b00}-24576)/4)+3];
        end
        else if(read && addressIn == 16'h6008) begin
                w0 <= 28'h1000770;
                w1 <= 0;
                w2 <= 0;
                w3 <= 0;
        end
        else if(write) begin
            dataMem[addressIn[31:2]] <= dataIn;
        end 
        else begin
            w0 <= 0;
            w1 <= 0;
            w2 <= 0;
            w3 <= 0;
        end
    end     
endmodule   




// We need a read, write, data, address, and 128 bit out