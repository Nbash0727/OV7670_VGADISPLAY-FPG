# OV7670_VGADISPLAY-FPG
Created by: Nathan Ash

Project Goal:
The goal of ths project was to implement a functional camera feed using a NANDLAND FPGA board and an OV7670 camera with VGA output. Due to hardware limitations there were only 10 usable PMODs on the NANDLAND board and the camera had 18 usable pins, so the design required creative workarounds.

Project Workarounds:
To make sure the feed could still be processed with limited IO the SCCB interface had to be configured. The camera output was configured to greyscale to reduce data width from 8 bits to 4 bits, enabling partial transmission. Even though this workaround allowed limited data to be transmitted there was still not enough IOs available. To account for this the synthesis was broken into two parts, the first being the SCCB configuration and the second being the actual feed.

Project Result:
After resolving synchronization issues, the final output was a 32×32 greyscale display. Functionality was validated by occluding and revealing the camera lens, confirming dynamic pixel response to light changes.


https://github.com/user-attachments/assets/4c5a32e4-5629-4df1-a7e1-97e38d9ac5d5


Procedure to Test:



