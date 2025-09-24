`timescale 1ns / 1ps
module VGA_Sync (
    input  wire clk,        // pixel clock (~25 MHz)
    output wire hsync,      // horizontal sync (active low)
    output wire vsync,      // vertical sync (active low)
    output wire display_en, // high during visible area
    output wire [9:0] x,    // pixel x (0–639)
    output wire [9:0] y     // pixel y (0–479)
);

    // VGA 640x480 @ 60Hz timing parameters
    localparam H_VISIBLE     = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE  = 96;
    localparam H_BACK_PORCH  = 48;
    localparam H_TOTAL       = H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;

    localparam V_VISIBLE     = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE  = 2;
    localparam V_BACK_PORCH  = 33;
    localparam V_TOTAL       = V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    // Counters
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // Horizontal counter
    always @(posedge clk) begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end

    // Sync pulses (active low)
    assign hsync = ~((h_count >= H_VISIBLE + H_FRONT_PORCH) &&
                     (h_count <  H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE));

    assign vsync = ~((v_count >= V_VISIBLE + V_FRONT_PORCH) &&
                     (v_count <  V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE));

    // Display enable
    assign display_en = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    // Clamped pixel coordinates
    assign x = display_en ? h_count : 10'd0;
    assign y = display_en ? v_count : 10'd0;

endmodule
/* `timescale 1ns / 1ps

module VGA_Sync_tb;

  // Clock period for 25 MHz pixel clock
  localparam CLK_PERIOD = 40;  // 40 ns

  // DUT signals
  reg clk = 0;
  wire hsync, vsync, display_en;
  wire [9:0] x, y;

  // Instantiate the DUT
  VGA_Sync dut (
    .clk(clk),
    .hsync(hsync),
    .vsync(vsync),
    .display_en(display_en),
    .x(x),
    .y(y)
  );

  // Clock generation
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Frame counter
  integer frame_count = 0;

  // Monitor frame transitions
  always @(posedge clk) begin
    if (x == 0 && y == 0) begin
      frame_count = frame_count + 1;
      $display("Frame %0d started at time %0t", frame_count, $time);
    end
    if (frame_count == 3) begin
      $display("Simulation complete after 3 frames.");
      $finish;
    end
  end

  // Optional waveform dump
  initial begin
    $dumpfile("vga_sync_tb.vcd");
    $dumpvars(0, VGA_Sync_tb);
  end

endmodule */
