// Simple clock divider for XCLK: output toggles every DIVIDE cycles
/* module xclk_divider #(
    parameter integer DIVIDE = 1  // io = i_Clk/(2*DIVIDE)
) (
    input  wire i_Clk,
    output wire o_XCLK
);
    reg [$clog2(DIVIDE)-1:0] cnt = 0;
    reg xclk_r = 1'b0;

    always @(posedge i_Clk) begin
        if (cnt == DIVIDE-1) begin
            cnt   <= 0;
            xclk_r <= ~xclk_r;
        end else begin
            cnt <= cnt + 1;
        end
    end

    assign o_XCLK = xclk_r;
endmodule
 */
/* 
`timescale 1ns / 1ps

module xclk_divider_tb;

  // Parameters
  localparam DIVIDE = 4;
  localparam CLK_PERIOD = 10;  // 100 MHz input clock

  // DUT signals
  reg i_Clk = 0;
  wire o_XCLK;

  // Instantiate DUT
  xclk_divider #(.DIVIDE(DIVIDE)) dut (
    .i_Clk(i_Clk),
    .o_XCLK(o_XCLK)
  );

  // Clock generation
  always #(CLK_PERIOD / 2) i_Clk = ~i_Clk;

  // Stimulus
  initial begin
    $dumpfile("xclk_divider_tb.vcd");
    $dumpvars(0, xclk_divider_tb);
    $display("Starting xclk_divider testbench...");

    // Run for a few toggles of o_XCLK
    #(CLK_PERIOD * DIVIDE * 10);

    $display("Testbench complete.");
    $finish;
  end

endmodule */

module xclk_divider (
    input  wire i_Clk,   // 25 MHz input from board
    output wire o_XCLK,  // ~25 MHz output for OV7670
    output wire locked
);

SB_PLL40_CORE #(
    .FEEDBACK_PATH("SIMPLE"),
    .DIVR(4'd0),         // Divide by 1
    .DIVF(7'd31),        // Multiply by 32
    .DIVQ(3'd5),         // Divide by 32
    .FILTER_RANGE(3'b001)
) pll_inst (
    .REFERENCECLK(i_Clk),
    .PLLOUTCORE(o_XCLK),
    .LOCK(locked),
    .BYPASS(1'b0),
    .RESETB(1'b1)
);

endmodule