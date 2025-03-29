`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: -
// Engineer: T.Y JANG
// 
// Create Date: 03/20/2025 10:15:08 AM
// Design Name: OV7670-Based CCTV Motion Detection System
// Module Name: OV7670_CCTV_SYSTEM
// Project Name: Real-Time Motion Detection CCTV
// Target Devices: BASYS-3
// Tool Versions: Vivado 2020.2
// Description: 
// This module implements a sophisticated CCTV system leveraging the OV7670 camera module.
// It integrates image capture, processing, motion detection, and VGA display output. The system
// captures frames from the OV7670, converts them to grayscale, applies Sobel edge detection,
// detects motion by comparing consecutive frames, and outputs the processed data to a VGA
// display with real-time motion indication via LEDs.
//
// ************************************************
// ** Captured Data From OV7670 is QVGA, RGB 555 **
// ************************************************
//
// Dependencies: 
// - clk_wiz_0 (Clock Wizard IP)
// - OV7670_SCCB (SCCB configuration module)
// - vga_controller (VGA timing generator)
// - ov7670_controller (OV7670 data interface)
// - rgb2gray (RGB to grayscale converter)
// - frameBuffer_4bit (Frame buffer memory)
// - sobel_filter_5x5 (Sobel edge detection filter)
// - diff_detector_pixel (Pixel difference detector)
// - diff_pixel_counter (Difference pixel counter)
// - motion_detector (Motion detection logic)
// - RGB_out (VGA RGB output driver)
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// - The system operates with a 25 MHz clock for VGA, 12 MHz clock for OV7670 and a 100 MHz clock for internal processing.
// - Motion detection sensitivity is adjustable via detection_threshold and threshold parameters.
// 
//////////////////////////////////////////////////////////////////////////////////

module OV7670_CCTV_SYSTEM (
    clk,
    reset,
    xclk,
    pclk,
    ov7670_data,
    href,
    vref,
    h_sync,
    v_sync,
    detection_threshold,
    threshold,
    motion_detected_led,
    motion_detected_signal,
    red_port,
    green_port,
    blue_port,
    sda,
    scl
);

    input logic clk;                    // System clock input (typically from FPGA clock source)
    input logic reset;                  // Active-high synchronous reset
    // OV7670 INTERFACE
    output logic xclk;                  // Clock output to OV7670 camera (25 MHz)
    input logic pclk;                   // Pixel clock from OV7670
    input logic [7:0] ov7670_data;      // 8-bit pixel data from OV7670 (RGB555 format)
    input logic href;                   // Horizontal reference signal from OV7670
    input logic vref;                   // Vertical sync signal from OV7670
    output logic sda;                   // SCCB data line for OV7670 configuration
    output logic scl;                   // SCCB clock line for OV7670 configuration
    
    // VGA INTERFACE
    output logic [3:0] red_port;        // 4-bit red channel for VGA output
    output logic [3:0] green_port;      // 4-bit green channel for VGA output
    output logic [3:0] blue_port;       // 4-bit blue channel for VGA output
    output logic h_sync;                // Horizontal sync signal for VGA
    output logic v_sync;                // Vertical sync signal for VGA

    // MOTION DETECTING PARAMETERS
    input logic [7:0] detection_threshold;  // Threshold for motion detection sensitivity
    input logic [7:0] threshold;            // Threshold for Sobel edge detection
    output logic motion_detected_signal;    // Single-bit motion detection output
    output logic [15:0] motion_detected_led;// 16-bit LED output for motion indication

    // STEP 1: Clock Generation for OV7670 and VGA
    // Generates two clock domains: 12MHz for OV7670, 25 MHz for VGA and 100 MHz for internal processing.
    logic clk_100MHz;                   // 100 MHz clock for high-speed internal operations
    logic clk_25MHz;                    // 25 MHz clock for VGA timing
    logic clk_12MHz;                    // 12 MHz clock for OV7670
    assign xclk = clk_12MHz;            // Assign 12 MHz clock to OV7670's external clock input

    clk_wiz_0 U_CLK_WIZ (
        .clk_in1(clk),                  // Input clock from FPGA
        .reset  (reset),                // Reset signal for clock wizard
        .clk_out1(clk_25MHz),           // 25 MHz output for VGA
        .clk_out2(clk_100MHz),          // 100 MHz output for processing
        .clk_out3(clk_12MHz)            // 12 MHz output for OV7670
    );

    // STEP 2: OV7670 Configuration via SCCB Protocol
    // Configures the OV7670 camera registers using the SCCB (I2C-like) interface.
    OV7670_SCCB U_SCCB (
        .clk  (clk_100MHz),             // High-speed clock for SCCB timing
        .reset(reset),                  // Reset signal to initialize SCCB state
        .sda  (sda),                    // Bidirectional data line for SCCB
        .scl  (scl)                     // Clock line for SCCB communication
    );

    // STEP 3: VGA Timing and Coordinate Generation
    // Generates VGA timing signals and pixel coordinates for a 640x480 display.
    logic [9:0] x_pixel, y_pixel;       // Current pixel coordinates (X, Y)
    logic display_enable;               // Active-high signal indicating visible display area
    logic left_top_enable;              // Enable signal for left-top quadrant
    logic right_top_enable;             // Enable signal for right-top quadrant
    logic left_bot_enable;              // Enable signal for left-bottom quadrant
    logic right_bot_enable;             // Enable signal for right-bottom quadrant

    vga_controller U_VGA_CONTROLLER (
        .clk(clk_25MHz),                // 25 MHz clock for VGA timing (640x480 @ 60Hz)
        .reset(reset),                  // Reset to initialize VGA state
        .h_sync(h_sync),                // Horizontal sync output
        .v_sync(v_sync),                // Vertical sync output
        .x_pixel(x_pixel),              // X-coordinate of current pixel
        .y_pixel(y_pixel),              // Y-coordinate of current pixel
        .display_enable(display_enable),// Enable signal for active display region
        .left_top_enable(left_top_enable),   // Quadrant enable signals for split-screen display
        .right_top_enable(right_top_enable),
        .left_bot_enable(left_bot_enable),
        .right_bot_enable(right_bot_enable)
    );

    // STEP 4: Capture and Process Image Data from OV7670 (QVGA, RGB 555)
    // Reads pixel data from the OV7670 and converts it to grayscale.
    logic pixel_we;                     // Write enable for pixel data
    logic [16:0] wAddr;                 // Write address for frame buffer
    logic [16:0] rAddr = (left_top_enable) ? 320 * y_pixel + x_pixel :              // Read address calculation for quadrant-based display
                         (right_top_enable) ? 320 * (y_pixel) + (x_pixel - 320) :   
                         (left_bot_enable) ? 320 * (y_pixel - 240) + x_pixel : 
                         (right_bot_enable) ? 320 * (y_pixel - 240) + (x_pixel - 320) : 17'b0;

    logic [11:0] rgb_444;               // 12-bit RGB data (4:4:4 format)
    logic [3:0] gray_4bit;              // 4-bit grayscale output

    ov7670_controller U_OV7670_CONTROLLER (
        .pclk(pclk),                    // Pixel clock from OV7670
        .reset(reset),                  // Reset signal for controller
        .href(href),                    // Horizontal reference input
        .v_sync(vref),                  // Vertical sync input
        .ov7670_data(ov7670_data),      // 8-bit data input from OV7670
        .pixel_we(pixel_we),            // Write enable output for frame buffer
        .wAddr(wAddr),                  // Write address output
        .wData(rgb_444)                 // 12-bit RGB data output
    );

    rgb2gray U_RGB2GRAY (
        .color_rgb (rgb_444),           // Input 12-bit RGB data
        .gray_4bit (gray_4bit),         // Output 4-bit grayscale data
        .gray_8bit (),                  // Unused 8-bit grayscale output
        .gray_12bit()                   // Unused 12-bit grayscale output
    );

    logic [3:0] gray_4bit_read_realtime;       // Grayscale data

    frameBuffer_4bit U_FRAME (
        .wclk(pclk),                    // Write clock (pixel clock)
        .we(pixel_we), // Write enable for frame 0
        .wAddr(wAddr),                  // Write address
        .wData(gray_4bit),              // 4-bit grayscale data to write
        .rclk(clk_25MHz),               // Read clock (VGA clock)
        .oe(display_enable),            // Output enable for reading
        .rAddr(rAddr),                  // Read address
        .rData(gray_4bit_read_realtime)        // 4-bit grayscale data output
    );

    // STEP 5: Frame Buffering for Motion Detection
    // Stores three consecutive frames to enable frame differencing.
    logic [1:0] frame_count;            // 2-bit counter for tracking frame sequence
    logic frame_done;                   // Signal indicating completion of a frame

    frame_counter U_FRAME_COUNTER(
        .clk(pclk),                     // Pixel clock for frame counting
        .reset(reset),                  // Reset to initialize frame counter
        .vref(vref),                    // Vertical sync to detect frame boundaries
        .frame_count(frame_count),      // Current frame index (0, 1, 2)
        .frame_done(frame_done)         // Frame completion flag
    );

    logic [3:0] gray_4bit_read_0;       // Grayscale data read from frame 0
    logic [3:0] gray_4bit_read_1;       // Grayscale data read from frame 1
    logic [3:0] gray_4bit_read_2;       // Grayscale data read from frame 2

    frameBuffer_4bit U_FRAME_0 (
        .wclk(pclk),                    // Write clock (pixel clock)
        .we(pixel_we && frame_count == 0), // Write enable for frame 0
        .wAddr(wAddr),                  // Write address
        .wData(gray_4bit),              // 4-bit grayscale data to write
        .rclk(clk_25MHz),               // Read clock (VGA clock)
        .oe(display_enable),            // Output enable for reading
        .rAddr(rAddr),                  // Read address
        .rData(gray_4bit_read_0)        // 4-bit grayscale data output
    );

    frameBuffer_4bit U_FRAME_1 (
        .wclk(pclk),                    // Write clock (pixel clock)
        .we(pixel_we && frame_count == 1), // Write enable for frame 1
        .wAddr(wAddr),                  // Write address
        .wData(gray_4bit),              // 4-bit grayscale data to write
        .rclk(clk_25MHz),               // Read clock (VGA clock)
        .oe(display_enable),            // Output enable for reading
        .rAddr(rAddr),                  // Read address
        .rData(gray_4bit_read_1)        // 4-bit grayscale data output
    );

    frameBuffer_4bit U_FRAME_2 (
        .wclk(pclk),                    // Write clock (pixel clock)
        .we(pixel_we && frame_count == 2), // Write enable for frame 2
        .wAddr(wAddr),                  // Write address
        .wData(gray_4bit),              // 4-bit grayscale data to write
        .rclk(clk_25MHz),               // Read clock (VGA clock)
        .oe(display_enable),            // Output enable for reading
        .rAddr(rAddr),                  // Read address
        .rData(gray_4bit_read_2)        // 4-bit grayscale data output
    );

    // STEP 6: Sobel Edge Detection on Buffered Frames
    // Implements a 5x5 Sobel filter to perform edge enhancement across three consecutive frames,
    // The filter operates on a sliding window, leveraging the quadrant-adjusted pixel coordinates
    // to ensure accurate edge detection within the 640x480 VGA display framework.
    logic [3:0] sobel_out_5x5_0;        // 4-bit Sobel-filtered output for frame 0, representing edge intensity
    logic [3:0] sobel_out_5x5_1;        // 4-bit Sobel-filtered output for frame 1, representing edge intensity
    logic [3:0] sobel_out_5x5_2;        // 4-bit Sobel-filtered output for frame 2, representing edge intensity

    logic [9:0] x_pixel_filter;         // Adjusted X-coordinate for Sobel filter window, quadrant-specific
    logic [9:0] y_pixel_filter;         // Adjusted Y-coordinate for Sobel filter window, quadrant-specific

    // Coordinate adjustment logic to map VGA pixel coordinates to the appropriate quadrant
    // for consistent filter application across the split-screen display (320x240 per quadrant).
    assign x_pixel_filter = (left_top_enable)  ? x_pixel :                   // Left-top quadrant: direct mapping
                            (right_top_enable) ? (x_pixel - 320) :          // Right-top: offset by 320 pixels
                            (left_bot_enable)  ? x_pixel :                  // Left-bottom: direct mapping
                            (right_bot_enable) ? (x_pixel - 320) : 10'b0;   // Right-bottom: offset by 320 pixels

    assign y_pixel_filter = (left_top_enable)  ? y_pixel :                   // Left-top: direct mapping
                            (right_top_enable) ? y_pixel :                  // Right-top: direct mapping
                            (left_bot_enable)  ? (y_pixel - 240) :          // Left-bottom: offset by 240 lines
                            (right_bot_enable) ? (y_pixel - 240) : 10'b0;   // Right-bottom: offset by 240 lines

    (* DONT_TOUCH = "TRUE" *)
    sobel_filter_5x5 sobel_5x5_0 (
        .clk(clk_25MHz),                // Clock for Sobel processing
        .reset(reset),                  // Reset signal
        .gray_4bit_0(gray_4bit_read_0), // Input grayscale data from frame 0
        .gray_4bit_1(gray_4bit_read_1), // Input grayscale data from frame 1
        .gray_4bit_2(gray_4bit_read_2), // Input grayscale data from frame 2
        .x_pixel(x_pixel_filter),       // X-coordinate for filter window
        .y_pixel(y_pixel_filter),       // Y-coordinate for filter window
        .display_enable(display_enable),// Enable signal for active processing
        .threshold(threshold),          // Edge detection threshold
        .sobel_out_0(sobel_out_5x5_0),  // Filtered output for frame 0
        .sobel_out_1(sobel_out_5x5_1),  // Filtered output for frame 1
        .sobel_out_2(sobel_out_5x5_2)   // Filtered output for frame 2
    );

    // STEP 7: Frame-to-Frame Difference Detection
    // Compares consecutive Sobel-filtered frames to detect changes.
    logic diff_detected_0;              // Difference detected between frames 0 and 1
    logic diff_detected_1;              // Difference detected between frames 1 and 2

    diff_detector_pixel U_DIFF_DETECTOR_0 (
        .prev_pixel(sobel_out_5x5_0),   // Previous frame pixel (frame 0)
        .curr_pixel(sobel_out_5x5_1),   // Current frame pixel (frame 1)
        .diff_detected(diff_detected_0) // Difference detection output
    );

    diff_detector_pixel U_DIFF_DETECTOR_1 (
        .prev_pixel(sobel_out_5x5_1),   // Previous frame pixel (frame 1)
        .curr_pixel(sobel_out_5x5_2),   // Current frame pixel (frame 2)
        .diff_detected(diff_detected_1) // Difference detection output
    );

    // STEP 8: Aggregate Frame Differences for Robust Motion Detection
    // Combines difference signals and counts differing pixels across frames.
    logic [3:0] diff_pixel;             // 4-bit pixel value indicating difference
    logic [$clog2(320 * 240) - 1 : 0] diff_pixel_cnt; // Counter for differing pixels
    
    assign diff_pixel = (diff_detected) ? 4'hf : 4'h0; // Set to max (white) if difference detected, else black
    assign diff_detected = (diff_detected_0 && diff_detected_1); // Require both comparisons to confirm difference

    diff_pixel_counter U_DIFF_PIXEL_COUNTER(
        .clk(clk_25MHz),                // Clock for counting differences
        .reset(reset),                  // Reset signal
        .frame_done(frame_done),        // Frame completion signal to reset counter
        .diff_detected(diff_detected),  // Input difference signal
        .diff_pixel_cnt(diff_pixel_cnt) // Output count of differing pixels
    );

    // STEP 9: Motion Detection Decision Logic
    // Determines if motion is present based on the number of differing pixels.
    motion_detector U_MOTION_DETECTOR (
        .clk  (clk_100MHz),             // High-speed clock for motion decision
        .reset(reset),                  // Reset signal
        .diff_pixel_cnt(diff_pixel_cnt),// Count of differing pixels
        .detection_threshold(detection_threshold), // Sensitivity threshold for motion
        .motion_detected(motion_detected) // Motion detection output
    );

    assign motion_detected_led = {16{motion_detected}}; // Replicate motion signal across 16 LEDs
    assign motion_detected_signal = motion_detected;    // Direct motion detection output

    // STEP 10: VGA Output Generation
    // Formats processed data into RGB signals for VGA display in a split-screen layout.
    RGB_out U_RGB_OUT (
        .clk  (clk_100MHz),             // High-speed clock for RGB processing
        .reset(reset),                  // Reset signal
        .x_pixel(x_pixel),              // X-coordinate for display
        .y_pixel(y_pixel),              // Y-coordinate for display
        .display_enable(display_enable),// Enable signal for active display
        .left_top_enable(left_top_enable),   // Quadrant enable signals
        .right_top_enable(right_top_enable),
        .left_bot_enable(left_bot_enable),
        .right_bot_enable(right_bot_enable),

        .motion_detected(motion_detected),
        .left_top_image (gray_4bit_read_realtime),  // Grayscale image for left-top quadrant
        .right_top_image(diff_pixel),        // Difference image for right-top quadrant
        .left_bot_image (gray_4bit_read_realtime),  // Grayscale image for left-bottom quadrant
        .right_bot_image(diff_pixel),        // Difference image for right-bottom quadrant
        .red_port  (red_port),          // 4-bit red channel output
        .green_port(green_port),        // 4-bit green channel output
        .blue_port (blue_port)          // 4-bit blue channel output
    );

endmodule