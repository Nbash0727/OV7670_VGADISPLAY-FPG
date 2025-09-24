 `timescale 1ns/1ps
module FIFO_Synch #(parameter WIDTH=9) (
  input clk,
  input rst_n,
  input [WIDTH:0] d_in,
  output reg [WIDTH:0] d_out
);
  reg [WIDTH:0] q1;
  always@(posedge clk) begin
    if(!rst_n) begin
      q1 <= 0;
      d_out <= 0;
    end
    else begin
      q1 <= d_in;
      d_out <= q1;
    end
  end
endmodule

/* `timescale 1ns / 1ps

module FIFO_Synch_tb;

  // Parameters
  localparam WIDTH = 3;
  localparam CLK_PERIOD = 20;  // 50 MHz

  // DUT signals
  reg clk = 0;
  reg rst_n = 0;
  reg [WIDTH:0] d_in = 0;
  wire [WIDTH:0] d_out;

  // Instantiate DUT
  FIFO_Synch #(WIDTH) dut (
    .clk(clk),
    .rst_n(rst_n),
    .d_in(d_in),
    .d_out(d_out)
  );

  // Clock generation
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Stimulus
  initial begin
    $dumpfile("fifo_synch_tb.vcd");
    $dumpvars(0, FIFO_Synch_tb);
    $display("Starting FIFO_Synch testbench...");

    // Hold reset low for a few cycles
    # (CLK_PERIOD * 2);
    rst_n <= 1;

    // Feed in values
    repeat (10) begin
      d_in <= $random % 16;  // 4-bit random value
      #CLK_PERIOD;
    end

    // Hold final value
    d_in <= 4'b1010;
    # (CLK_PERIOD * 4);

    $display("Testbench complete.");
    $finish;
  end
 */
/* endmodule */

