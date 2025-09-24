/* `timescale 1ns/1ps
module Sync_To_Count #(
  parameter TOTAL_COLS = 800,
  parameter TOTAL_ROWS = 525
)(
  input            i_Clk,
  input            i_HSync,
  input            i_VSync, 
  output reg       o_HSync = 0,
  output reg       o_VSync = 0,
  output reg [9:0] o_Col_Count = 0,
  output reg [9:0] o_Row_Count = 0
);

  // Preserve register to avoid synthesis sharing
  (* syn_preserve = 1 *) reg r_VSync = 0;
  wire w_Frame_Start = (~r_VSync & i_VSync);

  // Sync passthrough and edge detection
  always @(posedge i_Clk) begin
    o_HSync  <= i_HSync;
    o_VSync  <= i_VSync;
    r_VSync  <= i_VSync;
  end

  // Row/Column counters
  always @(posedge i_Clk) begin
    if (w_Frame_Start) begin
      o_Col_Count <= 0;
      o_Row_Count <= 0;
    end else begin
      if (o_Col_Count == TOTAL_COLS - 1) begin
        o_Col_Count <= 0;
        if (o_Row_Count == TOTAL_ROWS - 1)
          o_Row_Count <= 0;
        else
          o_Row_Count <= o_Row_Count + 1;
      end else begin
        o_Col_Count <= o_Col_Count + 1;
      end
    end
  end

endmodule */

// For VGA_Control/Sync
/* `timescale 1ns / 1ps

module VGA_Control_tb;

  localparam VIDEO_WIDTH = 3;
  localparam CLK_PERIOD = 40;  // 25 MHz pixel clock

  // DUT signals
  reg i_Clk = 0;
  reg i_HSync = 0;
  reg i_VSync = 0;
  reg [VIDEO_WIDTH-1:0] i_Red_Video = 0;
  reg [VIDEO_WIDTH-1:0] i_Grn_Video = 0;
  reg [VIDEO_WIDTH-1:0] i_Blu_Video = 0;

  wire o_HSync, o_VSync;
  wire [VIDEO_WIDTH-1:0] o_Red_Video;
  wire [VIDEO_WIDTH-1:0] o_Grn_Video;
  wire [VIDEO_WIDTH-1:0] o_Blu_Video;

  // Instantiate DUT
  VGA_Control #(
    .VIDEO_WIDTH(VIDEO_WIDTH),
    .TOTAL_COLS(800),
    .TOTAL_ROWS(525),
    .ACTIVE_COLS(640),
    .ACTIVE_ROWS(480)
  ) dut (
    .i_Clk(i_Clk),
    .i_HSync(i_HSync),
    .i_VSync(i_VSync),
    .i_Red_Video(i_Red_Video),
    .i_Grn_Video(i_Grn_Video),
    .i_Blu_Video(i_Blu_Video),
    .o_HSync(o_HSync),
    .o_VSync(o_VSync),
    .o_Red_Video(o_Red_Video),
    .o_Grn_Video(o_Grn_Video),
    .o_Blu_Video(o_Blu_Video)
  );

  // Clock generation
  always #(CLK_PERIOD / 2) i_Clk = ~i_Clk;

  // Stimulus
  initial begin
    $dumpfile("vga_control_tb.vcd");
    $dumpvars(0, VGA_Control_tb);
    $display("Starting VGA_Control testbench...");

    // Simulate sync pulses and grayscale video
    repeat (20) begin
      @(posedge i_Clk);
      i_HSync <= ~i_HSync;
      i_VSync <= (i_Clk % 160 == 0) ? ~i_VSync : i_VSync;
      i_Red_Video <= $random % 8;
      i_Grn_Video <= i_Red_Video;
      i_Blu_Video <= i_Red_Video;
    end

    # (CLK_PERIOD * 10);
    $display("Testbench complete.");
    $finish;
  end

endmodule */


`timescale 1ns / 1ps
module Sync_To_Count (
    input        i_Clk,
    output reg   o_HSync,
    output reg   o_VSync,
    output reg [9:0] o_Col_Count,
    output reg [9:0] o_Row_Count
    // Optional frame start signal:
    // output reg   o_Frame_Start
);

    // VGA 640x480 @ 60Hz timing (25 MHz pixel clock)
    localparam H_ACTIVE   = 640;
    localparam H_FRONT    = 16;
    localparam H_SYNC     = 96;
    localparam H_BACK     = 48;
    localparam H_TOTAL    = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;

    localparam V_ACTIVE   = 480;
    localparam V_FRONT    = 10;
    localparam V_SYNC     = 2;
    localparam V_BACK     = 33;
    localparam V_TOTAL    = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge i_Clk) begin
        // Horizontal counter
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;

            // Vertical counter
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end

        // Sync signal generation
        o_HSync <= ~(h_count >= H_ACTIVE + H_FRONT &&
                     h_count <  H_ACTIVE + H_FRONT + H_SYNC);

        o_VSync <= ~(v_count >= V_ACTIVE + V_FRONT &&
                     v_count <  V_ACTIVE + V_FRONT + V_SYNC);

        // Output pixel coordinates
        o_Col_Count <= h_count;
        o_Row_Count <= v_count;

        // Optional frame start pulse (1-cycle)
        // o_Frame_Start <= (h_count == 0 && v_count == 0);
    end
endmodule
