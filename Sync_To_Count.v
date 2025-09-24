

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
/*
`timescale 1ns / 1ps

module Sync_To_Count_tb;

  reg i_Clk = 0;
  wire o_HSync, o_VSync;
  wire [9:0] o_Col_Count, o_Row_Count;

  // Instantiate DUT
  Sync_To_Count dut (
    .i_Clk(i_Clk),
    .o_HSync(o_HSync),
    .o_VSync(o_VSync),
    .o_Col_Count(o_Col_Count),
    .o_Row_Count(o_Row_Count)
  );

  // Clock generation
  always #20 i_Clk = ~i_Clk;  // 25 MHz

  initial begin
    $dumpfile("sync_to_count_tb.vcd");
    $dumpvars(0, Sync_To_Count_tb);
    $display("Starting Sync_To_Count testbench...");

    #1000000;  // Run for a few frames
    $display("Testbench complete.");
    $finish;
  end
/*
