`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2024 09:18:03 PM
// Design Name: 
// Module Name: OTTER_TB
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


module OTTER_TB();
//    logic CLK_TB;
//    //logic BTNL _TB,
//    logic BTNC_TB;
//    logic [15:0] SWITCHES_TB;
//    logic [15:0] LED_TB;
//    logic [7:0] CATHODES_TB;
//    logic [3:0] ANODES_TB;
    logic [31:0]IOBUS_IN_TB;
    logic RST_TB;
    logic INTR_TB;
    logic CLK_TB;
    logic [31:0] IOBUS_OUT_TB;
    logic [31:0] IOBUS_ADDR_TB;
    logic IOBUS_WR_TB;

  OTTER_MCU UUT (.IOBUS_IN(IOBUS_IN_TB), .RST(RST_TB), .INTR(INTR_TB), .CLK(CLK_TB), .IOBUS_OUT(IOBUS_OUT_TB), .IOBUS_ADDR(IOBUS_ADDR_TB), .IOBUS_WR(IOBUS_WR_TB));
 //  OTTER_Wrapper UUT (.CLK(CLK_TB), .BTNC(BTNC_TB), .SWITCHES(SWITCHES_TB), .LEDS(LED_TB), .CATHODES(CATHODES_TB), .ANODES(ANODES_TB));

// initialize all inputs to zero
//   assign BTNC = 0;
//   assign SWITCHES = 15'b0;
//    assign IOBUS_IN_TB = 32'h1;
    assign IOBUS_IN_TB = 32'h0;
    assign RST_TB = 0;

    //test cases
    always begin
    CLK_TB = 0;
    #5;
    CLK_TB = 1;
    #5;
    end
    
//    initial begin
//    INTR_TB = 0;
//    #1030;
//    INTR_TB = 1;
//    #70 
//    INTR_TB = 0;
//    #50;
//    end
//    initial begin
//        RST_TB = 1;
//        INTR_TB = 0;
//        CLK_TB = 1;
//        IOBUS_IN_TB = 32'haaaa_aaa2;
        
//        // Apply reset
//        #5 RST_TB = 0;
//        end
        
//        always begin
//            #5 CLK_TB = ~CLK_TB;
//        end  
endmodule
