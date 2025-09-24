/* `timescale 1ns/1ps
module Top_Module (
    input        i_Clk,
	//LEDs
	output led_vga_sync,
	output led_cam_active,
	output led_fifo_read,


    // PMOD Inputs
    input        io_PMOD_1,  // D3
    input        io_PMOD_2,  // HS
    input        io_PMOD_3,  // VSYNC
    output       io_PMOD_4,  // XCLK
    input      io_PMOD_7,  // SCL then D0
    input      io_PMOD_8,  // SDA then D0
    input        io_PMOD_9,  // PCLK
    input        io_PMOD_10, // D2

    // VGA Outputs
    output       o_VGA_HSync,
    output       o_VGA_VSync,
    output       o_VGA_Red_0,
    output       o_VGA_Red_1,
    output       o_VGA_Red_2,
    output       o_VGA_Grn_0,
    output       o_VGA_Grn_1,
    output       o_VGA_Grn_2,
    output       o_VGA_Blu_0,
    output       o_VGA_Blu_1,
    output       o_VGA_Blu_2
);

    // Named slave address for OV7670
    localparam [7:0] SLAVE_ADDRESS = 8'h42;

    // Dummy retention logic to prevent optimization

    // Pixel input bus (phase 1)
    wire [3:0] pixd;
    assign pixd[0] = io_PMOD_7;
    assign pixd[1] = io_PMOD_8;
    assign pixd[2] = io_PMOD_10;
    assign pixd[3] = io_PMOD_1;

    // SCCB control signals
    wire [15:0] control;
    wire        finished;
    wire        taken;
    wire [7:0]  rega  = control[15:8];
    wire [7:0]  value = control[7:0];
    wire        send  = ~finished;

    // Camera capture
    wire [3:0] WDATA;
    wire [9:0] WADDR;
    wire       WE;

    Camera_to_ICE40 cam_capture (
        .pclk(io_PMOD_9),
        .pixd(pixd),
        .vsync(io_PMOD_3),
        .href(io_PMOD_2),
        .WDATA(WDATA),
        .WADDR(WADDR),
        .WE(WE)
    );

    // FIFO
    wire [3:0] pixel_out;
    wire       full, empty;
    wire       r_en;

    FIFO_TOP #(.DEPTH(1024), .DATA_WIDTH(4)) fifo_inst (
        .wclk(io_PMOD_9),
        .wrst_n(1'b1),
        .rclk(i_Clk),
        .rrst_n(1'b1),
        .w_en(WE),
        .r_en(r_en),
        .data_in(WDATA),
        .data_out(pixel_out),
        .full(full),
        .empty(empty)
    );

    // VGA timing
    wire [9:0] pixel_x, pixel_y;
    wire       active_video;
    wire       raw_hs, raw_vs;

    VGA_Sync vga_sync_timing (
        .clk(i_Clk),
        .hsync(raw_hs),
        .vsync(raw_vs),
        .x(pixel_x),
        .y(pixel_y),
        .display_en(active_video)
    );

    // VGA control
    wire [2:0] red_in = {pixel_out[2], pixel_out[1], pixel_out[0]};
    wire [2:0] grn_in = red_in;
    wire [2:0] blu_in = red_in;

  VGA_Control #(
    .VIDEO_WIDTH(3),
    .TOTAL_COLS(640), .TOTAL_ROWS(480),
    .ACTIVE_COLS(640), .ACTIVE_ROWS(480)) 
	 vga_ctrl(
    .i_Clk(i_Clk),
    .i_Red_Video(red_in),
    .i_Grn_Video(grn_in),
    .i_Blu_Video(blu_in),
    .o_HSync(o_VGA_HSync),
    .o_VSync(o_VGA_VSync),
    .o_Red_Video({o_VGA_Red_2, o_VGA_Red_1, o_VGA_Red_0}),
    .o_Grn_Video({o_VGA_Grn_2, o_VGA_Grn_1, o_VGA_Grn_0}),
    .o_Blu_Video({o_VGA_Blu_2, o_VGA_Blu_1, o_VGA_Blu_0})
);
/*     // SCCB configuration
    Camera_Interface_Registers config_inst (
        .clk(i_Clk),
        .resend(1'b0),
        .advance(taken),
        .control(control),
        .finished(finished)
    );

    SCCB_Module sccb_inst (
        .clk(i_Clk),
        .taken(taken),
        .SDA(io_PMOD_8),
        .SCL(io_PMOD_7),
        .send(send),
        .id(SLAVE_ADDRESS),
        .rega(rega),
        .value(value)
    ); */

 /*    // XCLK generation
    wire xclk_sig;
    xclk_divider #(.DIVIDE(4)) xclk_gen (
        .i_Clk(i_Clk),
        .o_XCLK(xclk_sig)
    );

    assign io_PMOD_4 = xclk_sig;

    // FIFO read enable gating
    assign r_en = active_video &&
                  (pixel_x >= 304 && pixel_x < 336) &&
                  (pixel_y >= 224 && pixel_y < 256) &&
                  !empty;
	
	
	// assign LEDs status 
	assign led_vga_sync = o_VGA_HSync;  // toggles at horizontal rate (~31.5 kHz)
	assign led_cam_active = WE;  // pulses when camera writes pixel data
	assign led_fifo_read = r_en;
endmodule */
`timescale 1ns/1ps
module Top_Module (
    input        i_Clk,
    output       led_vga_sync,
    output       led_cam_active,
    output       led_fifo_read,
    output       led_sccb_done,
    // PMOD Inputs
    input        io_PMOD_1,   // D3
    input        io_PMOD_2,   // HREF
    input        io_PMOD_3,   // VSYNC
    output       io_PMOD_4,   // XCLK
    input        io_PMOD_7,   // SCL / D0
    input        io_PMOD_8,   // SDA / D1
    input        io_PMOD_9,   // PCLK
    input        io_PMOD_10,  // D2

    // VGA Outputs
    output       o_VGA_HSync,
    output       o_VGA_VSync,
    output       o_VGA_Red_0,
    output       o_VGA_Red_1,
    output       o_VGA_Red_2,
    output       o_VGA_Grn_0,
    output       o_VGA_Grn_1,
    output       o_VGA_Grn_2,
    output       o_VGA_Blu_0,
    output       o_VGA_Blu_1,
    output       o_VGA_Blu_2
);

    localparam [7:0] SLAVE_ADDRESS = 8'h42;

    wire [3:0] pixd;
    assign pixd[0] = io_PMOD_7;
    assign pixd[1] = io_PMOD_8;
    assign pixd[2] = io_PMOD_10;
    assign pixd[3] = io_PMOD_1;

    wire [15:0] control;
    wire        finished;
    wire        taken;
    wire [7:0]  rega  = control[15:8];
    wire [7:0]  value = control[7:0];
    wire        send  = ~finished;

    wire [3:0] WDATA;
    wire [9:0] WADDR;
    wire       WE;

    Camera_to_ICE40 cam_capture (
        .pclk(io_PMOD_9),
        .pixd(pixd),
        .vsync(io_PMOD_3),
        .href(io_PMOD_2),
        .WDATA(WDATA),
        .WADDR(WADDR),
        .WE(WE)
    );

    wire [3:0] pixel_out;
    wire       full, empty;
    wire       r_en;

    FIFO_TOP #(.DEPTH(1024), .DATA_WIDTH(4)) fifo_inst (
        .wclk(io_PMOD_9),
        .wrst_n(1'b1),
        .rclk(i_Clk),
        .rrst_n(1'b1),
        .w_en(WE),
        .r_en(r_en),
        .data_in(WDATA),
        .data_out(pixel_out),
        .full(full),
        .empty(empty)
    );

    wire [9:0] pixel_x, pixel_y;
    wire       active_video;
    wire       raw_hs, raw_vs;

    VGA_Sync vga_sync_timing (
        .clk(i_Clk),
        .hsync(raw_hs),
        .vsync(raw_vs),
        .x(pixel_x),
        .y(pixel_y),
        .display_en(active_video)
    );

    // -------------------------------
    // Window and pixel mapping
    // -------------------------------
    wire in_win = (pixel_x >= 304 && pixel_x < 336) &&
                  (pixel_y >= 224 && pixel_y < 256);

    wire [2:0] gray3  = ~pixel_out[2:0];
    wire [2:0] red_in = in_win ? gray3 : 3'b000;
    wire [2:0] grn_in = in_win ? gray3 : 3'b000;
    wire [2:0] blu_in = in_win ? gray3 : 3'b000;

    VGA_Control #(
        .VIDEO_WIDTH(3),
        .TOTAL_COLS(800), .TOTAL_ROWS(525),
        .ACTIVE_COLS(640), .ACTIVE_ROWS(480)
    ) vga_ctrl (
        .i_Clk(i_Clk),
        .i_Red_Video(red_in),
        .i_Grn_Video(grn_in),
        .i_Blu_Video(blu_in),
        .o_HSync(o_VGA_HSync),
        .o_VSync(o_VGA_VSync),
        .o_Red_Video({o_VGA_Red_2, o_VGA_Red_1, o_VGA_Red_0}),
        .o_Grn_Video({o_VGA_Grn_2, o_VGA_Grn_1, o_VGA_Grn_0}),
        .o_Blu_Video({o_VGA_Blu_2, o_VGA_Blu_1, o_VGA_Blu_0})
    );

    /* 
    Camera_Interface_Registers config_inst (
        .clk(i_Clk),
        .resend(1'b0),
        .advance(taken),
        .control(control),
        .finished(finished)
    );

    SCCB_Module sccb_inst (
        .clk(i_Clk),
        .taken(taken),
        .SDA(io_PMOD_8),
        .SCL(io_PMOD_7),
        .send(send),
        .id(SLAVE_ADDRESS),
        .rega(rega),
        .value(value)
    ); 
    */

    // -------------------------------
    // XCLK: feed camera raw 25 MHz
    // -------------------------------
    assign io_PMOD_4 = i_Clk;

    // -------------------------------
    // Frame ready flag
    // -------------------------------
    reg frame_ready = 0;
    always @(posedge io_PMOD_9) begin
        if (io_PMOD_3) frame_ready <= 0;               // VSYNC high = new frame
        else if (WE && WADDR == 1023) frame_ready <= 1; // last pixel written
    end

    // -------------------------------
    // FIFO read enable
    // -------------------------------
    assign r_en = in_win && active_video && frame_ready && !empty;

    // -------------------------------
    // LEDs
    // -------------------------------
    assign led_vga_sync   = o_VGA_HSync;
    assign led_cam_active = WE;
    assign led_fifo_read  = r_en;
    assign led_sccb_done  = finished;

endmodule


/* `timescale 1ns / 1ps

module Top_Module_tb;

  localparam CLK_PERIOD   = 20;  // 50 MHz system clock
  localparam PCLK_PERIOD  = 42;  // ~24 MHz pixel clock

  // Clocks
  reg i_Clk = 0;
  reg io_PMOD_9 = 0;  // PCLK

  // Camera signals
  reg io_PMOD_3 = 0;  // VSYNC
  reg io_PMOD_2 = 0;  // HREF
  reg io_PMOD_1 = 0;  // D3
  reg io_PMOD_10 = 0; // D2

  // SCCB lines
  wire io_PMOD_7;     // SCL
  wire io_PMOD_8;     // SDA (inout)

  // VGA outputs
  wire o_VGA_HSync, o_VGA_VSync;
  wire o_VGA_Red_0, o_VGA_Red_1, o_VGA_Red_2;
  wire o_VGA_Grn_0, o_VGA_Grn_1, o_VGA_Grn_2;
  wire o_VGA_Blu_0, o_VGA_Blu_1, o_VGA_Blu_2;
  wire io_PMOD_4;     // XCLK

  // Instantiate DUT
  Top_Module dut (
    .i_Clk(i_Clk),
    .io_PMOD_1(io_PMOD_1),
    .io_PMOD_2(io_PMOD_2),
    .io_PMOD_3(io_PMOD_3),
    .io_PMOD_4(io_PMOD_4),
    .io_PMOD_7(io_PMOD_7),
    .io_PMOD_8(io_PMOD_8),
    .io_PMOD_9(io_PMOD_9),
    .io_PMOD_10(io_PMOD_10),
    .o_VGA_HSync(o_VGA_HSync),
    .o_VGA_VSync(o_VGA_VSync),
    .o_VGA_Red_0(o_VGA_Red_0),
    .o_VGA_Red_1(o_VGA_Red_1),
    .o_VGA_Red_2(o_VGA_Red_2),
    .o_VGA_Grn_0(o_VGA_Grn_0),
    .o_VGA_Grn_1(o_VGA_Grn_1),
    .o_VGA_Grn_2(o_VGA_Grn_2),
    .o_VGA_Blu_0(o_VGA_Blu_0),
    .o_VGA_Blu_1(o_VGA_Blu_1),
    .o_VGA_Blu_2(o_VGA_Blu_2)
  );

  // Clock generation
  always #(CLK_PERIOD / 2) i_Clk = ~i_Clk;
  always #(PCLK_PERIOD / 2) io_PMOD_9 = ~io_PMOD_9;

  // Stimulus
  initial begin
    $dumpfile("top_module_tb.vcd");
    $dumpvars(0, Top_Module_tb);
    $display("Starting Phase 1 system testbench...");

    // Simulate SCCB config phase
    #100;

    // Simulate VSYNC pulse (frame start)
    io_PMOD_3 <= 1;
    #PCLK_PERIOD;
    io_PMOD_3 <= 0;

    // Simulate 10 pixels during HREF
    repeat (10) begin
      io_PMOD_2 <= 1;  // HREF high
      io_PMOD_1 <= $random % 2;  // D3
      io_PMOD_10 <= $random % 2; // D2
      #PCLK_PERIOD;
    end
    io_PMOD_2 <= 0;

    // Wait for VGA sync to stabilize
    #1000;

    $display("Testbench complete.");
    $finish;
  end

endmodule */

