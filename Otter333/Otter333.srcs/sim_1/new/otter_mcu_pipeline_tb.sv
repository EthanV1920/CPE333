`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Ethan Vosburg
//
// Create Date: 04/25/2024 07:28:17 PM
// Design Name: Otter MCU Test Bench for Pipelinine
// Module Name: otter_mcu_pipeline_tb
// Target Devices: Basys3
// Description: Test bench for nop instructions for the Otter MCU with
// pipeline implementation
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module otter_mcu_pipeline_tb ();
  // Inputs
  logic CLK_TB;
  logic INTR_TB;
  logic RESET_TB;
  logic [31:0] IOBUS_IN_TB;
  //
  // Outputs
  logic [31:0] IOBUS_OUT_TB;
  logic [31:0] IOBUS_ADDR_TB;
  logic IOBUS_WR_TB;

  otter_mcu_pipeline_tb MCU (
      .CLK(CLK_TB),
      .INTR(INTR_TB),
      .RESET(RESET_TB),
      .IOBUS_IN(IOBUT_IN_TB),
      .IOBUS_OUT(IOBUS_OUT_TB),
      .IOBUS_ADDR(IOBUS_ADDR_TB),
      .IOBUS_WR(IOBUS_WR_TB)
  );

  initial begin
      CLK_TB = 0;
  end


  // Instantiate the clock
  always #5 CLK_TB = ~CLK_TB;


endmodule
