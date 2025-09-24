
 `timescale 1ns/1ps
 module FIFO_MEM #(parameter DEPTH=1024, DATA_WIDTH=4, PTR_WIDTH=9) (
  input wclk, w_en, rclk, r_en,
  input [PTR_WIDTH:0] b_wptr, b_rptr,
  input [DATA_WIDTH-1:0] data_in,
  input full, empty,
  output wire [DATA_WIDTH-1:0] data_out
);
  reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
  
  always@(posedge wclk) begin
    if(w_en & !full) begin
      fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;
    end
  end

  assign data_out = fifo[b_rptr[PTR_WIDTH-1:0]];
endmodule

/* `timescale 1ns / 1ps

module FIFO_MEM_tb;

  localparam DEPTH = 4;
  localparam DATA_WIDTH = 4;
  localparam PTR_WIDTH = 2;
  localparam WCLK_PERIOD = 20;  // 50 MHz write clock
  localparam RCLK_PERIOD = 40;  // 25 MHz read clock

  // DUT signals
  reg wclk = 0;
  reg rclk = 0;
  reg w_en = 0;
  reg r_en = 0;
  reg [PTR_WIDTH:0] b_wptr = 0;
  reg [PTR_WIDTH:0] b_rptr = 0;
  reg [DATA_WIDTH-1:0] data_in = 0;
  reg full = 0;
  reg empty = 0;
  wire [DATA_WIDTH-1:0] data_out;

  // Instantiate DUT
  FIFO_MEM #(DEPTH, DATA_WIDTH, PTR_WIDTH) dut (
    .wclk(wclk),
    .w_en(w_en),
    .rclk(rclk),
    .r_en(r_en),
    .b_wptr(b_wptr),
    .b_rptr(b_rptr),
    .data_in(data_in),
    .full(full),
    .empty(empty),
    .data_out(data_out)
  );

  // Clock generation
  always #(WCLK_PERIOD / 2) wclk = ~wclk;
  always #(RCLK_PERIOD / 2) rclk = ~rclk;

  // Stimulus
  initial begin
    $dumpfile("fifo_mem_tb.vcd");
    $dumpvars(0, FIFO_MEM_tb);
    $display("Starting FIFO_MEM testbench...");

    // Write 4 values into FIFO
    repeat (4) begin
      @(posedge wclk);
      w_en <= 1;
      data_in <= $random % 16;
      b_wptr <= b_wptr + 1;
    end
    w_en <= 0;

    // Read back 4 values
    repeat (4) begin
      @(posedge rclk);
      r_en <= 1;
      b_rptr <= b_rptr + 1;
      $display("Read data_out = %0d at b_rptr = %0d", data_out, b_rptr);
    end
    r_en <= 0;

    $display("Testbench complete.");
    $finish;
  end

endmodule */
