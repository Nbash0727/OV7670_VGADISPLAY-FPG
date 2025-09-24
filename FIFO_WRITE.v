 `timescale 1ns/1ps
module FIFO_WRITE #(parameter PTR_WIDTH=9) (
  input wclk, wrst_n, w_en,
  input [PTR_WIDTH:0] g_rptr_sync,
  output reg [PTR_WIDTH:0] b_wptr, g_wptr,
  output reg full
);

  wire [PTR_WIDTH:0] b_wptr_next;
  wire [PTR_WIDTH:0] g_wptr_next;
   

  wire wfull;
  
  assign b_wptr_next = b_wptr+(w_en & !full);
  assign g_wptr_next = (b_wptr_next >>1)^b_wptr_next;
  
  always@(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) begin
      b_wptr <= 0; // set default value
      g_wptr <= 0;
    end
    else begin
      b_wptr <= b_wptr_next; // incr binary write pointer
      g_wptr <= g_wptr_next; // incr gray write pointer
    end
  end
  
  always@(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) full <= 0;
    else        full <= wfull;
  end

  assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

endmodule

/* `timescale 1ns / 1ps

module FIFO_WRITE_tb;

  localparam PTR_WIDTH = 3;
  localparam CLK_PERIOD = 20;  // 50 MHz write clock

  // DUT signals
  reg wclk = 0;
  reg wrst_n = 0;
  reg w_en = 0;
  reg [PTR_WIDTH:0] g_rptr_sync = 0;
  wire [PTR_WIDTH:0] b_wptr, g_wptr;
  wire full;

  // Instantiate DUT
  FIFO_WRITE #(PTR_WIDTH) dut (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .w_en(w_en),
    .g_rptr_sync(g_rptr_sync),
    .b_wptr(b_wptr),
    .g_wptr(g_wptr),
    .full(full)
  );

  // Clock generation
  always #(CLK_PERIOD / 2) wclk = ~wclk;

  // Stimulus
  initial begin
    $dumpfile("fifo_write_tb.vcd");
    $dumpvars(0, FIFO_WRITE_tb);
    $display("Starting FIFO_WRITE testbench...");

    // Apply reset
    #CLK_PERIOD;
    wrst_n <= 1;

    // Write 10 entries
    repeat (10) begin
      w_en <= 1;
      #CLK_PERIOD;
    end

    // Stop writing
    w_en <= 0;
    #CLK_PERIOD;

    // Simulate read pointer catching up (to trigger full)
    g_rptr_sync <= g_wptr;  // simulate read pointer sync
    #CLK_PERIOD;

    $display("Testbench complete.");
    $finish;
  end

endmodule */
