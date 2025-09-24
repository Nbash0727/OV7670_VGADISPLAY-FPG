	`timescale 1ns / 1ps
// controls the camera_interace_register module and the SCCB module
	module Camera_Interface(input clk, input resend, output Camera_Configured , output XCLK, output SCL, inout SDA);
		
		wire start, finished, taken;
		wire [15:0] control;
		reg [7:0] slave_address = 8'h42; // write to the camera's internal registers
		reg t_XCLK;
		
		always@(posedge clk)
		begin
			t_XCLK <= ~t_XCLK; // generate the clock for the OV7670 Camera
			
		end
		
		assign start = (finished)?0:1;// the register file has finished compiling
		assign Camera_Configured = finished;
		assign XCLK = t_XCLK;
		// Control other camera modules 
		 Camera_Interace_Registers inst1(.clk(clk),.advance(taken), .control(control), .finished(finished), .resend(resend));
         SCCB_Module inst2(.clk(clk), .taken(taken), .SDA(SDA), .SCL(SCL), .send(start), .id(slave_address), .rega(command[15:8]), .value(command[7:0]));
	endmodule