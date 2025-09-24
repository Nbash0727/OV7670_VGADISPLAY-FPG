`timescale 1ns / 1ps
// Module for setting OV7670 SCCB Registers
module Camera_Interface_Registers(
    input clk,
    input resend,
    input advance,
    output [15:0] control,
    output finished
);

    reg [15:0] cont;         // control value
    wire done_itera;         // iterations are complete if high
    reg [15:0] register;     // register that is being controlled

    always @(posedge clk) begin
        if (resend)
            register <= 0;
        else if (advance)
            register <= register + 1;

        case (register)
            0:  cont <= 16'h12_80;  // COM7: reset all registers to default
            1:  cont <= 16'h12_14;  // COM7: QVGA + RGB output (used for grayscale)
            2:  cont <= 16'h15_20;  // COM10: disable PCLK toggle during HBLANK
            3:  cont <= 16'h40_D0;  // COM15: RGB565, full output range
            4:  cont <= 16'h11_80;  // CLKRC: internal PLL matches XCLK
            5:  cont <= 16'h0C_00;  // COM3: default miscellaneous settings
            6:  cont <= 16'h3E_00;  // COM14: no scaling, normal PCLK
            7:  cont <= 16'h04_00;  // COM1: disable CCIR656 interface
            8:  cont <= 16'h40_C0;  // COM15: clears RGB565 for YUV
            9:  cont <= 16'h3A_04;  // TSLB: set correct output data sequence
            10: cont <= 16'h14_18;  // COM9: max AGC value ×4

            // Color matrix coefficients
            11: cont <= 16'h4F_B3;
            12: cont <= 16'h50_B3;
            13: cont <= 16'h51_00;
            14: cont <= 16'h52_3D;
            15: cont <= 16'h53_A7;
            16: cont <= 16'h54_E4;
            17: cont <= 16'h58_9E;

            18: cont <= 16'h3D_C0;  // COM13: enable gamma, disable UV
            19: cont <= 16'h17_14;
            20: cont <= 16'h18_02;
            21: cont <= 16'h32_80;
            22: cont <= 16'h19_03;
            23: cont <= 16'h1A_7B;
            24: cont <= 16'h03_0A;
            25: cont <= 16'h0F_41;
            26: cont <= 16'h1E_00;
            27: cont <= 16'h33_0B;
            28: cont <= 16'h3C_78;
            29: cont <= 16'h69_00;
            30: cont <= 16'h74_00;
            31: cont <= 16'hB0_84;
            32: cont <= 16'hB1_0C;
            33: cont <= 16'hB2_0E;
            34: cont <= 16'hB3_80;

            // Scaling factors
            35: cont <= 16'h70_3A;
            36: cont <= 16'h71_35;
            37: cont <= 16'h72_11;
            38: cont <= 16'h73_F0;
            39: cont <= 16'hA2_02;

            // Gamma curve
            40: cont <= 16'h7A_20;
            41: cont <= 16'h7B_10;
            42: cont <= 16'h7C_1E;
            43: cont <= 16'h7D_35;
            44: cont <= 16'h7E_5A;
            45: cont <= 16'h7F_69;
            46: cont <= 16'h80_76;
            47: cont <= 16'h81_80;
            48: cont <= 16'h82_88;
            49: cont <= 16'h83_8F;
            50: cont <= 16'h84_96;
            51: cont <= 16'h85_A3;
            52: cont <= 16'h86_AF;
            53: cont <= 16'h87_C4;
            54: cont <= 16'h88_D7;
            55: cont <= 16'h89_E8;

            // AGC / AEC setup
            56: cont <= 16'h13_E0;
            57: cont <= 16'h00_00;
            58: cont <= 16'h10_00;
            59: cont <= 16'h0D_40;
            60: cont <= 16'h14_18;
            61: cont <= 16'hA5_05;
            62: cont <= 16'hAB_07;
            63: cont <= 16'h24_95;
            64: cont <= 16'h25_33;
            65: cont <= 16'h26_E3;

            // Additional AEC correction
            66: cont <= 16'h9F_78;
            67: cont <= 16'hA0_68;
            68: cont <= 16'hA1_03;
            69: cont <= 16'hA6_D8;
            70: cont <= 16'hA7_D8;
            71: cont <= 16'hA8_F0;
            72: cont <= 16'hA9_90;
            73: cont <= 16'hAA_94;

            74: cont <= 16'h13_E5;
            75: cont <= 16'h1E_23;
            76: cont <= 16'h69_06;

            default: cont <= 16'hFFFF;
        endcase
    end

    assign control = cont;
    assign done_itera = (cont == 16'hFFFF) ? 1 : 0;
    assign finished = done_itera ? 1 : 0;

endmodule

	
	// `timescale 1ns / 1ps

// module tb_Camera_Interface_Registers;

  // Inputs
  // reg clk = 0;
  // reg resend = 0;
  // reg advance = 0;

  // Outputs
  // wire [15:0] control;
  // wire finished;

  // Instantiate the Unit Under Test (UUT)
  // Camera_Interface_Registers uut (
    // .clk(clk),
    // .resend(resend),
    // .advance(advance),
    // .control(control),
    // .finished(finished)
  // );

  // Clock generation: 100MHz
  // always #5 clk = ~clk;

  // initial begin
    // $display("Starting Camera_Interface_Registers test...");
    
    // Reset sequence
    // resend = 1; #10;
    // resend = 0;

    // Advance through all register writes
    // repeat(78) begin
      // advance = 1; #10;
      // advance = 0; #10;
      // $display("Register %0d: control = %h, finished = %b", uut.register, control, finished);
    // end

    // Check final state
    // #10;
    // if (finished)
      // $display("All registers written. Finished signal is high.");
    // else
      // $display("Finished signal not high when expected.");

    // $stop;
  // end

// endmodule