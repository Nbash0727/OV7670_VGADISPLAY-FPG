# OV7670_VGADISPLAY-FPG
Created by: Nathan Ash

Project Goal:<br/>
The goal of this project was to implement a functional camera feed using a NANDLAND FPGA board and an OV7670 camera with VGA output. Due to hardware limitations, there were only 10 usable PMODs on the NANDLAND board and the camera had 18 usable pins, so the design required creative workarounds.

Project Workarounds:<br/>
To make sure the feed could still be processed with limited I/O the SCCB interface had to be configured. The camera output was configured to grayscale to reduce data width from 8 bits to 4 bits, enabling partial transmission. Even though this workaround allowed limited data to be transmitted there still weren't enough I/Os available. To account for this, the synthesis was broken into two parts, the first being the SCCB configuration and the second being the actual feed.

Project Result:<br/>
After resolving synchronization issues, the final output was a 32×32 greyscale display. Functionality was validated by occluding and revealing the camera lens, confirming dynamic pixel response to light changes.


https://github.com/user-attachments/assets/4c5a32e4-5629-4df1-a7e1-97e38d9ac5d5

Verilog File Descriptions:<br/>
Top Module:<br/>
The top module integrates camera capture, FIFO buffering, and VGA display into a grayscale imaging system using the OV7670 and a NANDLAND ICE40 FPGA. It reads pixel data from PMOD inputs, buffers it across clock domains, and maps a 32×32 grayscale window onto a 640×480 VGA frame. Sync signals, pixel coordinates, and frame readiness are managed internally, with LED indicators showing system status. SCCB configuration logic is included but optional, allowing flexible synthesis and testing.<br/>
<br/>
BRAM Module:<br/>
 This module wraps a Lattice-specific SB_RAM1024x4 block to provide dual-clock read/write access to a 1024-depth, 4-bit wide memory array. It supports asynchronous operation between camera and system clock domains, enabling pixel data to be written during wclk and read when rclk. Read and write enables are gated through a shared clk_enable signal to ensure consistent access.<br/>
 <br/>
FIFO_Top Module:<br/>
The FIFO_TOP module implements a FIFO for transferring 4-bit pixel data between unsynchronized write (wclk) and read (rclk) domains. It uses Gray-coded pointers and synchronization modules to safely pass write and read addresses across clock boundaries, minimizing metastability. The FIFO depth is 1024, and data is stored using a BRAM_Module wrapper around Lattice’s SB_RAM1024x4. This design enables reliable buffering of camera data for real-time VGA display, with full and empty flags for flow control.<br/>
<br/>
XCLK_Divider Module:<br/>
The xclk_divider module generates a stable ~25 MHz clock signal (o_XCLK) for the OV7670 camera by instancing the Lattice-specific SB_PLL40_CORE. It multiplies and divides the input clock (i_Clk) through configured PLL parameters to match the camera’s timing requirements. The locked output indicates PLL stability, ensuring reliable synchronization for downstream modules. This divider is essential for feeding the OV7670 a consistent clock source directly from the FPGA.<br/>
<br/>
Camera_Interface_Register Module:<br/>
The Camera_Interface_Registers module sequentially outputs SCCB register configuration commands for the OV7670 camera. It cycles through a predefined set of 77 register-value pairs to initialize grayscale output, clock settings, color matrix coefficients, gamma curve, and AGC/AEC parameters. The advance signal steps through the configuration sequence, while resend resets it. Once all registers are sent, the finished flag is asserted to indicate completion. This module simplifies camera setup for embedded imaging pipelines.<br/>
<br/>
VGA_Sync Module:<br/>
The VGA_Sync module generates timing signals and pixel coordinates for a 640×480 VGA display at 60Hz using a 25 MHz pixel clock. It produces active-low horizontal and vertical sync pulses (hsync, vsync), tracks pixel positions (x, y), and asserts display_en during the visible region. Internal counters manage VGA timing based on front porch, sync pulse, and back porch parameters, enabling precise raster scanning and pixel mapping for real-time video output.<br/>
<br/>
Sync_To_Count Module:<br/>
The Sync_To_Count module generates VGA-compatible horizontal and vertical sync signals along with pixel coordinate counters for a 640×480 display at 60Hz. It uses a 25 MHz input clock to drive timing logic based on VGA porch and pulse parameters. The module outputs o_HSync, o_VSync, and real-time pixel positions (o_Col_Count, o_Row_Count), making it ideal for raster-based video systems and display alignment.<br/>
<br/>
VGA_Control Module:<br/>
The VGA_Control module manages VGA signal generation and pixel gating for a 640×480 display using a 25 MHz clock. It instantiates Sync_To_Count to produce horizontal and vertical sync pulses along with pixel coordinates, then conditionally drives RGB outputs only during the active video region. Sync signals are passed directly to output, and video data is masked outside the visible frame, ensuring clean raster display and proper timing alignment.<br/>
<br/>
FIFO_READ Module:<br/>
The FIFO_READ module handles the read-side logic of an asynchronous FIFO, operating in its own clock domain (rclk). It maintains binary and Gray-coded read pointers, incrementing them only when r_en is asserted and the FIFO is not empty. The module compares the synchronized Gray-coded write pointer (g_wptr_sync) to its own next read pointer to determine the empty status. This design ensures safe data retrieval across clock domains using Gray code for metastability mitigation.<br/>
<br/>
FIFO_WRITE Module:<br/>
The FIFO_WRITE module manages the write-side logic of an asynchronous FIFO, operating in its own clock domain (wclk). It maintains both binary and Gray-coded write pointers, incrementing them only when w_en is asserted and the FIFO is not full. The full flag is computed by comparing the next Gray-coded write pointer to the synchronized read pointer (g_rptr_sync) using a standard wraparound detection method. This design ensures safe data writes across clock domains while minimizing metastability risks.<br/>
<br/>
FIFO_Synch Module:<br/>
The FIFO_Synch module implements a two-stage synchronizer for safely transferring multi-bit signals across asynchronous clock domains. It uses double flip-flop sampling to mitigate metastability, ensuring reliable synchronization of Gray-coded FIFO pointers. This module is essential for robust asynchronous FIFO designs where clock domain crossing is required.<br/>
<br/>
Camera_to_ICE40 Module:<br/>
The Camera_to_ICE40 module captures pixel data from the OV7670 camera and prepares it for downstream buffering and display. It samples 4-bit grayscale pixel input (pixd) on the falling edge of the pixel clock (pclk), incrementing a write address (WADDR) during active HREF periods. VSYNC resets the address counter at the start of each frame, and WE is asserted only when valid pixel data is captured. This module enables real-time pixel acquisition within tight I/O constraints.<br/>
<br/>
SCCB_Module:<br/>
The SCCB_Module implements a finite state machine to configure the OV7670 camera via its Serial Camera Control Bus (SCCB), a protocol similar to I²C. It sends a sequence of register writes—device ID, register address, and value—paced by a ~100 kHz tick generator. The module handles bit-level transmission, acknowledgment phases, and generates bidirectional SDA and SCL signals. Once a transaction completes, the taken flag is asserted to signal readiness for the next command.<br/>
<br/>
<br/>
Testing Procedure:<br/>
1.) For this project the required design tools are ICECUBE2 and Diamond Programmer, which are free through Lattice Semiconductors personal project plan. The method to get free access and to properly setup the board are shown on NANDLANDS youtube channel.
<br/>
https://www.youtube.com/@Nandland
<br/>
2.) The first step in this project is to properly connect all the pins for camera and board interface. To properly connect the PMOD you must first look at the data sheet and determine which pins accept IO's. The proper setup is to use pins 5/6 for Vcc/GND and then use pins 1-4/7-10 for the digital IO's.
<br/>
<img width="577" height="253" alt="image" src="https://github.com/user-attachments/assets/d8ff4a50-a6af-42f8-a11b-488fe68ed38f" />
<img width="467" height="334" alt="image" src="https://github.com/user-attachments/assets/0d16ebd8-2ec1-4421-a576-a8e95dbb9d85" /><br/>
3.) After properly assigning the pins you need to complete Part 1, which is the SCCB configuration that's controlled through the Top_Module.v. The first step is to make sure the SDA assignment is set to "inout" and that the SCL is set to "output". Also, you must have "pixd[0]" and "pixd[1]" set to some constant. Then you must make sure the instances for Camera_Interface_Registers and SCCB_Module are uncommented. The final step is just synthesizing the RTL with ICECUBE and programming the FPGA with Diamond Programmer. <br/>
<br/>
4.) The final part is basically the inverse of Part 1; so you need to comment the instances, set the SDA/SCL PMOD's to input, and then have the "pixd[0/1]" set to the SDA/SCL PMOD. This obviously means that you replace the wires that are currently connected, but make sure to keep the power on since the SCCB configuration will reset if the camera turns off. Another thing to keep in mind is that a breadboard may be very useful since the SDA/SCL wires each need to be in parallel with a 4.7Kohm resistor that is connected to Vcc. 




