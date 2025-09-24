 `timescale 1ns/1ps
 // Module that captures the pixel data from the camera and sends it to other parts of the system
 module Camera_to_ICE40(input pclk, input [3:0] pixd, input vsync, input href, output [3:0] WDATA, output [9:0] WADDR, output WE); // configure WRITE_MODE and READ_MODE to '2'
 
 
	reg [9:0] t_WADDR; // this register will increase until the row is reset
	reg [3:0] t_WDATA; // temp. value for the input data
	reg t_WE; // write enable placeholder
 
	reg [3:0] pixd_reg;

	always @(negedge pclk) begin
		pixd_reg <= pixd;

		if (vsync) begin
			t_WADDR <= 0;
			t_WE <= 0;
		end else if (href && t_WADDR < 1023) begin
			t_WDATA <= pixd_reg;
			t_WADDR <= t_WADDR + 1;
			t_WE <= 1;
		end else begin
			t_WE <= 0;
		end
	end

	
	
	//assign all the outputs with the reg variables
	assign WDATA = t_WDATA; 
	assign WE  = t_WE;
	assign WADDR = t_WADDR;   
 endmodule
 
/*  `timescale 1ns / 1ps

module Camera_to_ICE40_tb;

    // Pixel Clock
   localparam PCLK_PERIOD = 42;  // 24 MHz

   // DUT signals
    reg pclk = 0; // reg must be driven by TB
    reg vsync = 0;
    reg href = 0;
    reg [3:0] pixd = 0;
  wire [3:0] WDATA; // Wires are driven internally
    wire [9:0] WADDR;
    wire WE;

    // Instantiate DUT
    Camera_to_ICE40 dut (
      .pclk(pclk),
      .pixd(pixd),
      .vsync(vsync),
      .href(href),
      .WDATA(WDATA),
      .WADDR(WADDR),
      .WE(WE)
    );

    // Clock generation
    always #(PCLK_PERIOD / 2) pclk = ~pclk;

    // Stimulus
    initial begin
      $dumpfile("camera_tb.vcd");
      $dumpvars(0, Camera_to_ICE40_tb);
      $display("Starting Camera_to_ICE40 testbench...");

      // Frame start
      vsync <= 1;
      #PCLK_PERIOD;
      vsync <= 0;

      // Simulate a row of 10 pixels
      repeat (10) begin
        href <= 1;
        pixd <= $random % 16;
        #PCLK_PERIOD;
      end

      // End row
      href <= 0;
      #PCLK_PERIOD;

      // Trigger another vsync to reset address
      vsync <= 1;
      #PCLK_PERIOD;
      vsync <= 0;

      // Simulate another row of 5 pixels
      repeat (5) begin
        href <= 1;
        pixd <= $random % 16;
        #PCLK_PERIOD;
      end

      href <= 0;
      #PCLK_PERIOD;

      $display("Testbench complete.");
      $finish;
  end
endmodule */
