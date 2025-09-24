`timescale 1ns / 1ps
module SCCB_Module (
  input clk,
  input send,
  input [7:0] id,
  input [7:0] rega,
  input [7:0] value,
  inout SDA,
  output SCL,
  output reg taken
);

  // FSM states
  localparam IDLE = 0, START = 1, SEND_ID = 2, SEND_REGA = 3,
             SEND_VALUE = 4, ACK_CHECK = 5, STOP = 6;

  reg [2:0] state = IDLE;
  reg [2:0] next_state;

  // Tick generator for ~100 kHz pacing
  reg [15:0] clk_div = 0;
  wire tick = (clk_div == 0);
  always @(posedge clk) clk_div <= clk_div + 1;

  // Bit counters and data registers
  reg [2:0] bit_cnt = 7;
  reg [7:0] t_id, t_rega, t_value;
  reg [1:0] ack_phase = 0;

  // SDA/SCL control
  reg t_SDA = 1, t_SCL = 1;
  reg E_SDA = 1, E_SCL = 1;

  // FSM logic
  always @(posedge clk) begin
    if (tick) begin
      case (state)
        IDLE: begin
          t_SCL <= 1;
          t_SDA <= 1;
          E_SDA <= 1;
          taken <= 0;
          if (send) begin
            t_id <= id;
            t_rega <= rega;
            t_value <= value;
            bit_cnt <= 7;
            ack_phase <= 0;
            state <= START;
          end
        end

        START: begin
          state <= SEND_ID;
        end

        SEND_ID: begin
          t_SCL <= 0;
          t_SDA <= t_id[bit_cnt];
          t_SCL <= 1;
          if (bit_cnt == 0) begin
            bit_cnt <= 7;
            ack_phase <= 0;
            state <= ACK_CHECK;
          end else begin
            bit_cnt <= bit_cnt - 1;
          end
        end

        SEND_REGA: begin
          t_SCL <= 0;
          t_SDA <= t_rega[bit_cnt];
          t_SCL <= 1;
          if (bit_cnt == 0) begin
            bit_cnt <= 7;
            ack_phase <= 1;
            state <= ACK_CHECK;
          end else begin
            bit_cnt <= bit_cnt - 1;
          end
        end

        SEND_VALUE: begin
          t_SCL <= 0;
          t_SDA <= t_value[bit_cnt];
          t_SCL <= 1;
          if (bit_cnt == 0) begin
            bit_cnt <= 7;
            ack_phase <= 2;
            state <= ACK_CHECK;
          end else begin
            bit_cnt <= bit_cnt - 1;
          end
        end

        ACK_CHECK: begin
          E_SDA <= 0; // release SDA
          t_SCL <= 0;
          t_SCL <= 1;
          E_SDA <= 1;
          case (ack_phase)
            0: state <= SEND_REGA;
            1: state <= SEND_VALUE;
            2: state <= STOP;
            default: state <= IDLE;
          endcase
        end

        STOP: begin
          t_SDA <= 0;
          t_SCL <= 1;
          t_SDA <= 1;
          taken <= 1;
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

  assign SDA = E_SDA ? t_SDA : 1'bz;
  assign SCL = E_SCL ? t_SCL : 1'bz;

endmodule

/* `timescale 1ns / 1ps

module SCCB_Module_tb;

  // Clock period for 50 MHz system clock
  localparam CLK_PERIOD = 20;  // 20 ns

  // DUT signals
  reg clk = 0;
  reg send = 0;
  reg [7:0] id = 8'h42;       // Example OV7670 write ID
  reg [7:0] rega = 8'h12;     // Example register address
  reg [7:0] value = 8'h80;    // Example value to write
  wire SDA;
  wire SCL;
  wire taken;
  int timeout;

  // Open-drain simulation for SDA
  reg SDA_driver = 1'bz;
  assign SDA = SDA_driver;

  // Instantiate DUT
  SCCB_Module dut (
    .clk(clk),
    .send(send),
    .id(id),
    .rega(rega),
    .value(value),
    .SDA(SDA),
    .SCL(SCL),
    .taken(taken)
  );

  // Clock generation
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Stimulus
  initial begin
    $display("Starting SCCB_Module testbench...");
    $dumpfile("sccb_tb.vcd");
    $dumpvars(0, SCCB_Module_tb);

    // Wait a few cycles
    #100;

    // Trigger a send transaction
    send <= 1;
    #CLK_PERIOD;
    send <= 0;
    
 // Wait for completion or timeout

    timeout = 0;
    
    while (taken !== 1 && timeout < 100000) begin
      #CLK_PERIOD;
      timeout = timeout + 1;
    end
    if (taken)
      $display("Transaction completed at time %0t", $time);
    else
      $display("Timeout reached — SCCB FSM may be stuck");

    $finish;
  end

endmodule */