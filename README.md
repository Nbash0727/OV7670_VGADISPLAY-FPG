# OV7670_VGADISPLAY-FPG
Created by: Nathan Ash

Project Goal:<br/>
The goal of ths project was to implement a functional camera feed using a NANDLAND FPGA board and an OV7670 camera with VGA output. Due to hardware limitations there were only 10 usable PMODs on the NANDLAND board and the camera had 18 usable pins, so the design required creative workarounds.

Project Workarounds:<br/>
To make sure the feed could still be processed with limited IO the SCCB interface had to be configured. The camera output was configured to greyscale to reduce data width from 8 bits to 4 bits, enabling partial transmission. Even though this workaround allowed limited data to be transmitted there was still not enough IOs available. To account for this the synthesis was broken into two parts, the first being the SCCB configuration and the second being the actual feed.

Project Result:<br/>
After resolving synchronization issues, the final output was a 32×32 greyscale display. Functionality was validated by occluding and revealing the camera lens, confirming dynamic pixel response to light changes.


https://github.com/user-attachments/assets/4c5a32e4-5629-4df1-a7e1-97e38d9ac5d5

Verilog File Description's:<br/>
Top Module:<br/>
The top module integrates camera capture, FIFO buffering, and VGA display into a grayscale imaging system using the OV7670 and a NANDLAND ICE40 FPGA. It reads pixel data from PMOD inputs, buffers it across clock domains, and maps a 32×32 grayscale window onto a 640×480 VGA frame. Sync signals, pixel coordinates, and frame readiness are managed internally, with LED indicators showing system status. SCCB configuration logic is included but optional, allowing flexible synthesis and testing.<br/>
BRAM Module:<br/>
 This module wraps a Lattice-specific SB_RAM1024x4 block to provide dual-clock read/write access to a 1024-depth, 4-bit wide memory array. It supports asynchronous operation between camera and system clock domains, enabling pixel data to be written during wclk and read when rclk. Read and write enables are gated through a shared clk_enable signal to ensure consistent access.<br/>
FIFO_Top Module:<br/>
The FIFO_TOP module implements a FIFO for transferring 4-bit pixel data between unsynchronized write (wclk) and read (rclk) domains. It uses Gray-coded pointers and synchronization modules to safely pass write and read addresses across clock boundaries, minimizing metastability. The FIFO depth is 1024, and data is stored using a BRAM_Module wrapper around Lattice’s SB_RAM1024x4. This design enables reliable buffering of camera data for real-time VGA display, with full and empty flags for flow control.

Procedure to Test:



