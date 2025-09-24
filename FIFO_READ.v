
 `timescale 1ns/1ps

module FIFO_READ #(parameter PTR_WIDTH=9) (
  input rclk, rrst_n, r_en,
  input [PTR_WIDTH:0] g_wptr_sync,
  output reg [PTR_WIDTH:0] b_rptr, g_rptr,
  output reg empty
);

  wire [PTR_WIDTH:0] b_rptr_next;
  wire [PTR_WIDTH:0] g_rptr_next;

  assign b_rptr_next = b_rptr+(r_en & !empty);
  assign g_rptr_next = (b_rptr_next >>1)^b_rptr_next;
  assign rempty = (g_wptr_sync == g_rptr_next);
  
  always@(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) begin
      b_rptr <= 0;
      g_rptr <= 0;
    end
    else begin
      b_rptr <= b_rptr_next;
      g_rptr <= g_rptr_next;
    end
  end
  
  always@(posedge rclk or negedge rrst_n) begin
    if(!rrst_n) empty <= 1;
    else        empty <= rempty;
  end
endmodule
/* 
`timescale 1ns / 1ps

module FIFO_READ_tb;

  localparam PTR_WIDTH = 3;
  localparam CLK_PERIOD = 20;  // 50 MHz read clock

  // DUT signals
  reg rclk = 0;
  reg rrst_n = 0;
  reg r_en = 0;
  reg [PTR_WIDTH:0] g_wptr_sync = 0;
  wire [PTR_WIDTH:0] b_rptr, g_rptr;
  wire empty;

  // Instantiate DUT
  FIFO_READ #(PTR_WIDTH) dut (
    .rclk(rclk),
    .rrst_n(rrst_n),
    .r_en(r_en),
    .g_wptr_sync(g_wptr_sync),
    .b_rptr(b_rptr),
    .g_rptr(g_rptr),
    .empty(empty)
  );

  // Clock generation
  always #(CLK_PERIOD / 2) rclk = ~rclk;

  // Stimulus
  initial begin
    $dumpfile("fifo_read_tb.vcd");
    $dumpvars(0, FIFO_READ_tb);
    $display("Starting FIFO_READ testbench...");

    // Apply reset
    #CLK_PERIOD;
    rrst_n <= 1;

    // Simulate write pointer advancing (data available)
    repeat (5) begin
      g_wptr_sync <= g_wptr_sync + 1;
      #CLK_PERIOD;
    end

    // Read from FIFO
    repeat (5) begin
      r_en <= 1;
      #CLK_PERIOD;
    end

    r_en <= 0;
    #CLK_PERIOD;

    $display("Testbench complete.");
    $finish;
  end

endmodule
 */