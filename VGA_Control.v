/* `timescale 1ns/1ps
module VGA_Control #(
  parameter VIDEO_WIDTH = 3,
  parameter TOTAL_COLS  = 800,
  parameter TOTAL_ROWS  = 525,
  parameter ACTIVE_COLS = 640,
  parameter ACTIVE_ROWS = 480,
  parameter c_FRONT_PORCH_HORZ = 16,
  parameter c_BACK_PORCH_HORZ  = 48,
  parameter c_FRONT_PORCH_VERT = 10,
  parameter c_BACK_PORCH_VERT  = 33
)(
  input i_Clk,
  input [VIDEO_WIDTH-1:0] i_Red_Video,
  input [VIDEO_WIDTH-1:0] i_Grn_Video,
  input [VIDEO_WIDTH-1:0] i_Blu_Video,
  output reg o_HSync,
  output reg o_VSync,
  output reg [VIDEO_WIDTH-1:0] o_Red_Video,
  output reg [VIDEO_WIDTH-1:0] o_Grn_Video,
  output reg [VIDEO_WIDTH-1:0] o_Blu_Video
);

  wire w_HSync;
  wire w_VSync;
  wire [9:0] w_Col_Count;
  wire [9:0] w_Row_Count;

  reg [VIDEO_WIDTH-1:0] r_Red_Video = 0;
  reg [VIDEO_WIDTH-1:0] r_Grn_Video = 0;
  reg [VIDEO_WIDTH-1:0] r_Blu_Video = 0;

  // Sync generator
  Sync_To_Count #(
    .TOTAL_COLS(TOTAL_COLS),
    .TOTAL_ROWS(TOTAL_ROWS)
  ) sync_gen (
    .i_Clk(i_Clk),
    .i_HSync(1'b0),  // Not used
    .i_VSync(1'b0),  // Not used
    .o_HSync(w_HSync),
    .o_VSync(w_VSync),
    .o_Col_Count(w_Col_Count),
    .o_Row_Count(w_Row_Count)
  );

  // Porch logic
  always @(posedge i_Clk) begin
    if ((w_Col_Count < ACTIVE_COLS + c_FRONT_PORCH_HORZ) ||
        (w_Col_Count >= TOTAL_COLS - c_BACK_PORCH_HORZ))
      o_HSync <= 1'b1;
    else
      o_HSync <= w_HSync;

    if ((w_Row_Count < ACTIVE_ROWS + c_FRONT_PORCH_VERT) ||
        (w_Row_Count >= TOTAL_ROWS - c_BACK_PORCH_VERT))
      o_VSync <= 1'b1;
    else
      o_VSync <= w_VSync;
  end

  // Video delay alignment
  always @(posedge i_Clk) begin
    r_Red_Video <= i_Red_Video;
    r_Grn_Video <= i_Grn_Video;
    r_Blu_Video <= i_Blu_Video;

    o_Red_Video <= r_Red_Video;
    o_Grn_Video <= r_Grn_Video;
    o_Blu_Video <= r_Blu_Video;
  end

endmodule */

`timescale 1ns / 1ps
module VGA_Control #(
    parameter VIDEO_WIDTH = 3,
    parameter TOTAL_COLS = 800,
    parameter TOTAL_ROWS = 525,
    parameter ACTIVE_COLS = 640,
    parameter ACTIVE_ROWS = 480
)(
    input i_Clk,
    input [VIDEO_WIDTH-1:0] i_Red_Video,
    input [VIDEO_WIDTH-1:0] i_Grn_Video,
    input [VIDEO_WIDTH-1:0] i_Blu_Video,
    output reg o_HSync,
    output reg o_VSync,
    output [VIDEO_WIDTH-1:0] o_Red_Video,
    output [VIDEO_WIDTH-1:0] o_Grn_Video,
    output [VIDEO_WIDTH-1:0] o_Blu_Video
);

    wire w_HSync, w_VSync;
    wire [9:0] w_Col_Count, w_Row_Count;
    wire w_Frame_Start;

    Sync_To_Count sync_gen (
        .i_Clk(i_Clk),
        .o_HSync(w_HSync),
        .o_VSync(w_VSync),
        .o_Col_Count(w_Col_Count),
        .o_Row_Count(w_Row_Count)
    );

    // Directly pass sync signals to output (bypass porch logic)
    always @(posedge i_Clk) begin
        o_HSync <= w_HSync;
        o_VSync <= w_VSync;
    end

    // Drive RGB only during active video region
    assign o_Red_Video = (w_Col_Count < ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ? i_Red_Video : 0;
    assign o_Grn_Video = (w_Col_Count < ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ? i_Grn_Video : 0;
    assign o_Blu_Video = (w_Col_Count < ACTIVE_COLS && w_Row_Count < ACTIVE_ROWS) ? i_Blu_Video : 0;
endmodule