 `timescale 1ns/1ps
	 module BRAM_Module( 
	  input            wclk,
	  input            wr_en,
	  input  [9:0]     wr_addr,   // 2^10 = 1024 deep
	  input  [3:0]     wr_data,   // 4-bit pixel
	  input            rclk,
	  input            rd_en,
	  input  [9:0]     rd_addr,
	  output [3:0]     rd_data
	);


	wire clk_enable = wr_en | rd_en;
		SB_RAM1024x4 ram1024x4_inst (
			.RDATA(rd_data),
			.RADDR(rd_addr),
			.RCLK(rclk),
			.RCLKE(clk_enable),     // Always enabled
			.RE(rd_en),       // Read enable
			.WADDR(wr_addr),
			.WCLK(wclk),
			.WCLKE(clk_enable),     // Always enabled
			.WDATA(wr_data),
			.WE(wr_en)        // Write enable
			);

		
		
endmodule 