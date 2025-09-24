 `timescale 1ns/1ps
 // Asynchronous FIFO - read and write clocks are not synchronized   \
 // A lot of inspiration came from https://vlsiverify.com/verilog/verilog-codes/asynchronous-fifo/
  module FIFO_TOP #(parameter DEPTH=1024, DATA_WIDTH=4) (
  input wclk, wrst_n,
  input rclk, rrst_n,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output [DATA_WIDTH-1:0] data_out,
  output wire full, empty
);
  
  parameter PTR_WIDTH = $clog2(DEPTH);
 
  wire [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
  wire [PTR_WIDTH:0] b_wptr, b_rptr;
  wire [PTR_WIDTH:0] g_wptr, g_rptr;


  FIFO_Synch #(PTR_WIDTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync); //write pointer to read clock domain
  FIFO_Synch #(PTR_WIDTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync); //read pointer to write clock domain 
  
  FIFO_WRITE #(PTR_WIDTH) wptr_h(wclk, wrst_n, w_en,g_rptr_sync,b_wptr,g_wptr,full);
  FIFO_READ #(PTR_WIDTH) rptr_h(rclk, rrst_n, r_en,g_wptr_sync,b_rptr,g_rptr,empty);

	wire [9:0] wr_addr = b_wptr[9:0];
	wire [9:0] rd_addr = b_rptr[9:0];

	BRAM_Module bram_inst (
	  .wclk(wclk),
	  .wr_en(w_en),
	  .wr_addr(wr_addr),
	  .wr_data(data_in),
	  .rclk(rclk),
	  .rd_en(r_en),
	  .rd_addr(rd_addr),
	  .rd_data(data_out)
	);

endmodule
  // wr_en: write enable

// wr_data: write data

// full: FIFO is full

// empty: FIFO is empty

// rd_en: read enable

// rd_data: read data

// b_wptr: binary write pointer

// g_wptr: gray write pointer
 
// g_wptr_next: gray write pointer next

// b_rptr: binary read pointer

// g_rptr: gray read pointer

// b_rptr_next: binary read pointer next

// g_rptr_next: gray read pointer next

// b_rptr_sync: binary read pointer synchronized

// b_wptr_sync: binary write pointer synchronized



/* `timescale 1ns / 1ps


module FIFO_TOP_tb;

  localparam DEPTH = 8;
  localparam DATA_WIDTH = 4;
  localparam WCLK_PERIOD = 20;  // 50 MHz
  localparam RCLK_PERIOD = 40;  // 25 MHz

  // DUT signals
  reg wclk = 0;
  reg rclk = 0;
  reg wrst_n = 0;
  reg rrst_n = 0;
  reg w_en = 0;
  reg r_en = 0;
  reg [DATA_WIDTH-1:0] data_in = 0;
  wire [DATA_WIDTH-1:0] data_out;
  wire full, empty;

  // Instantiate DUT
  FIFO_TOP #(DEPTH, DATA_WIDTH) dut (
    .wclk(wclk),
    .wrst_n(wrst_n),
    .rclk(rclk),
    .rrst_n(rrst_n),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );

  // Clock generation
  always #(WCLK_PERIOD / 2) wclk = ~wclk;
  always #(RCLK_PERIOD / 2) rclk = ~rclk;

  // Stimulus
  initial begin
    $dumpfile("fifo_top_tb.vcd");
    $dumpvars(0, FIFO_TOP_tb);
    $display("Starting FIFO_TOP testbench...");

    // Apply resets
    #50;
    wrst_n <= 1;
    rrst_n <= 1;

    // Write 5 values
    repeat (5) begin
      @(posedge wclk);
      w_en <= 1;
      data_in <= $random % 16;
    end
    w_en <= 0;

    // Wait a few cycles
    #100;

    // Read 5 values
    repeat (5) begin
      @(posedge rclk);
      r_en <= 1;
      $display("Read data_out = %0d | empty = %b", data_out, empty);
    end
    r_en <= 0;

    #100;
    $display("Testbench complete.");
    $finish;
  end

endmodule */