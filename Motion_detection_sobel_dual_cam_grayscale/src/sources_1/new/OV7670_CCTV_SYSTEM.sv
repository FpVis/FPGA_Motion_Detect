`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: -
// Engineer: T.Y JANG
// 
// Create Date: 03/20/2025 10:15:08 AM
// Design Name: Dual OV7670 CCTV Motion Detection System
// Module Name: OV7670_CCTV_SYSTEM
// Project Name: Dual-Camera Real-Time Motion Detection
// Target Devices: FPGA (e.g., Xilinx Artix-7)
// Tool Versions: Vivado 2023.1 or later
// Description: 
// This module implements an advanced CCTV system utilizing two OV7670 camera modules for
// simultaneous image capture and motion detection. It processes frames from each camera,
// converts them to grayscale, applies Sobel edge detection, detects motion by comparing
// two consecutive frames per camera, and displays the results on a VGA monitor in a
// quadrant-based layout. Motion detection is indicated via LEDs and signals for each camera.
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
// - The system uses a 12 MHz clock for OV7670 cameras, 25 MHz for VGA, and 100 MHz for processing.
// - Each camera processes two frames for motion detection, reducing memory usage compared to three-frame designs.
// 
//////////////////////////////////////////////////////////////////////////////////

module OV7670_CCTV_SYSTEM(
    clk,
    reset,

    xclk1,
    pclk1,
    ov7670_data1,
    href1,
    vref1,
    sda1,
    scl1,

    xclk2,
    pclk2,
    ov7670_data2,
    href2,
    vref2,
    sda2,
    scl2,

    red_port,
    green_port,
    blue_port,
    h_sync,
    v_sync,

    detection_threshold,
    threshold,
    IMAGE1_motion_detected_led,
    IMAGE1_motion_detected_signal,
    IMAGE2_motion_detected_led,
    IMAGE2_motion_detected_signal
);

    input logic clk;                    // System clock input (typically from FPGA clock source)
    input logic reset;                  // Active-high synchronous reset

    // OV7670 Camera 1 Interface
    output logic       xclk1;           // 12 MHz clock output to OV7670 camera 1
    input logic        pclk1;           // Pixel clock from OV7670 camera 1
    input logic [7:0]  ov7670_data1;    // 8-bit pixel data from OV7670 camera 1
    input logic        href1;           // Horizontal reference signal from camera 1
    input logic        vref1;           // Vertical sync signal from camera 1
    output logic       sda1;            // SCCB data line for camera 1 configuration
    output logic       scl1;            // SCCB clock line for camera 1 configuration

    // OV7670 Camera 2 Interface
    output logic       xclk2;           // 12 MHz clock output to OV7670 camera 2
    input logic        pclk2;           // Pixel clock from OV7670 camera 2
    input logic [7:0]  ov7670_data2;    // 8-bit pixel data from OV7670 camera 2
    input logic        href2;           // Horizontal reference signal from camera 2
    input logic        vref2;           // Vertical sync signal from camera 2
    output logic       sda2;            // SCCB data line for camera 2 configuration
    output logic       scl2;            // SCCB clock line for camera 2 configuration

    // VGA Interface
    output logic [3:0] red_port;        // 4-bit red channel for VGA output
    output logic [3:0] green_port;      // 4-bit green channel for VGA output
    output logic [3:0] blue_port;       // 4-bit blue channel for VGA output
    output logic h_sync;                // Horizontal sync signal for VGA
    output logic v_sync;                // Vertical sync signal for VGA

    // Motion Detection Parameters and Outputs
    input logic [7:0] detection_threshold;  // Sensitivity threshold for motion detection
    input logic [7:0] threshold;            // Threshold for Sobel edge detection
    output logic [7:0] IMAGE1_motion_detected_led;    // 8-bit LED output for camera 1 motion
    output logic       IMAGE1_motion_detected_signal; // Single-bit motion signal for camera 1
    output logic [7:0] IMAGE2_motion_detected_led;    // 8-bit LED output for camera 2 motion
    output logic       IMAGE2_motion_detected_signal; // Single-bit motion signal for camera 2

    // Internal Signals
    logic [9:0] x_pixel, y_pixel;       // Current VGA pixel coordinates (X, Y)
    logic       display_enable;         // Active-high signal for visible VGA display area
    logic       left_top_enable;        // Enable signal for left-top quadrant (camera 1 raw)
    logic       right_top_enable;       // Enable signal for right-top quadrant (camera 1 diff)
    logic       left_bot_enable;        // Enable signal for left-bottom quadrant (camera 2 raw)
    logic       right_bot_enable;       // Enable signal for right-bottom quadrant (camera 2 diff)

    logic clk_100MHz;                   // 100 MHz clock for high-speed processing
    logic clk_25MHz;                    // 25 MHz clock for VGA and SCCB
    logic clk_12MHz;                    // 12 MHz clock for OV7670 cameras

    logic we1, we2;                     // Write enable signals for camera 1 and 2 frame buffers
    logic [16:0] wAddr1, wAddr2;        // Write addresses for camera 1 and 2 frame buffers
    logic [11:0] image1, image2;        // 12-bit RGB data from camera 1 and 2

    // Read Address Calculation for Quadrant-Based Display
    logic [16:0] rAddr = (left_top_enable)  ? 320 * y_pixel + x_pixel :             // Left-top: camera 1 raw
                         (right_top_enable) ? 320 * y_pixel + (x_pixel - 320) :     // Right-top: camera 1 diff
                         (left_bot_enable)  ? 320 * (y_pixel - 240) + x_pixel :     // Left-bottom: camera 2 raw
                         (right_bot_enable) ? 320 * (y_pixel - 240) + (x_pixel - 320) : 17'b0; // Right-bottom: camera 2 diff

    logic [3:0] gray_4bit_IMAGE1;       // 4-bit grayscale data from camera 1
    logic [3:0] gray_4bit_IMAGE2;       // 4-bit grayscale data from camera 2
    
    logic [3:0] gray_4bit_IMAGE1_read_0;// Grayscale data read from camera 1, frame 0
    logic [3:0] gray_4bit_IMAGE1_read_1;// Grayscale data read from camera 1, frame 1
    logic [3:0] gray_4bit_IMAGE2_read_0;// Grayscale data read from camera 2, frame 0
    logic [3:0] gray_4bit_IMAGE2_read_1;// Grayscale data read from camera 2, frame 1

    logic [3:0] sobel_out_IMAGE1_5x5_0; // Sobel output for camera 1, frame 0
    logic [3:0] sobel_out_IMAGE1_5x5_1; // Sobel output for camera 1, frame 1
    logic [3:0] sobel_out_IMAGE2_5x5_0; // Sobel output for camera 2, frame 0
    logic [3:0] sobel_out_IMAGE2_5x5_1; // Sobel output for camera 2, frame 1
    
    logic IMAGE1_motion_detected;       // Motion detection flag for camera 1
    logic IMAGE2_motion_detected;       // Motion detection flag for camera 2

    // Clock Assignments and Motion Detection Outputs
    assign xclk1 = clk_12MHz;           // 12 MHz clock for OV7670 camera 1
    assign xclk2 = clk_12MHz;           // 12 MHz clock for OV7670 camera 2
    
    assign IMAGE1_motion_detected_led = {8{IMAGE1_motion_detected}}; // Replicate motion signal across 8 LEDs
    assign IMAGE1_motion_detected_signal = IMAGE1_motion_detected;   // Direct motion output for camera 1
    
    assign IMAGE2_motion_detected_led = {8{IMAGE2_motion_detected}}; // Replicate motion signal across 8 LEDs
    assign IMAGE2_motion_detected_signal = IMAGE2_motion_detected;   // Direct motion output for camera 2

    // Clock Generation
    // Generates three clock domains: 12 MHz for OV7670, 25 MHz for VGA, and 100 MHz for processing.
    clk_wiz_0 instance_name (
        .clk_in1(clk),                  // Input clock from FPGA
        .reset(reset),                  // Reset signal for clock wizard
        .clk_out1(clk_25MHz),           // 25 MHz for VGA and SCCB
        .clk_out2(clk_100MHz),          // 100 MHz for internal processing
        .clk_out3(clk_12MHz)            // 12 MHz for OV7670 cameras
    );

    // OV7670 Configuration via SCCB
    // Configures both OV7670 cameras using the SCCB protocol for consistent operation.
    OV7670_SCCB U_OV7670_SCCB1 (
        .clk  (clk_25MHz),              // 25 MHz clock for SCCB timing
        .reset(reset),                  // Reset to initialize SCCB state
        .sda  (sda1),                   // SCCB data line for camera 1
        .scl  (scl1)                    // SCCB clock line for camera 1
    );
    OV7670_SCCB U_OV7670_SCCB2 (
        .clk  (clk_25MHz),              // 25 MHz clock for SCCB timing
        .reset(reset),                  // Reset to initialize SCCB state
        .sda  (sda2),                   // SCCB data line for camera 2
        .scl  (scl2)                    // SCCB clock line for camera 2
    );

    // VGA Timing Generation
    // Produces VGA timing signals and coordinates for a 640x480 display with quadrant layout.
    vga_controller U_VGA_CONTROLLER (
        .clk(clk_25MHz),                // 25 MHz clock for VGA (640x480 @ 60Hz)
        .reset(reset),                  // Reset to initialize VGA state
        .h_sync(h_sync),                // Horizontal sync output
        .v_sync(v_sync),                // Vertical sync output
        .x_pixel(x_pixel),              // X-coordinate of current pixel
        .y_pixel(y_pixel),              // Y-coordinate of current pixel
        .display_enable(display_enable),// Enable signal for active display region
        .left_top_enable(left_top_enable),   // Quadrant enable signals for split-screen
        .right_top_enable(right_top_enable),
        .left_bot_enable(left_bot_enable),
        .right_bot_enable(right_bot_enable)
    );

    // OV7670 Data Capture
    // Captures pixel data from both cameras and generates RGB outputs.
    ov7670_controller U_OV7670_Controller1 (
        .pclk       (pclk1),            // Pixel clock from camera 1
        .reset      (reset),            // Reset signal
        .href       (href1),            // Horizontal reference from camera 1
        .v_sync     (vref1),            // Vertical sync from camera 1
        .ov7670_data(ov7670_data1),     // 8-bit data from camera 1
        .pixel_we   (we1),              // Write enable for camera 1 frame buffer
        .wAddr      (wAddr1),           // Write address for camera 1
        .wData      (image1)            // 12-bit RGB output for camera 1
    );

    ov7670_controller U_OV7670_Controller2 (
        .pclk       (pclk2),            // Pixel clock from camera 2
        .reset      (reset),            // Reset signal
        .href       (href2),            // Horizontal reference from camera 2
        .v_sync     (vref2),            // Vertical sync from camera 2
        .ov7670_data(ov7670_data2),     // 8-bit data from camera 2
        .pixel_we   (we2),              // Write enable for camera 2 frame buffer
        .wAddr      (wAddr2),           // Write address for camera 2
        .wData      (image2)            // 12-bit RGB output for camera 2
    );

    // RGB to Grayscale Conversion
    // Converts 12-bit RGB data from each camera to 4-bit grayscale for processing.
    rgb2gray U_RGB2GRAY1 (
        .color_rgb(image1),             // 12-bit RGB input from camera 1
        .gray_4bit(gray_4bit_IMAGE1),   // 4-bit grayscale output for camera 1
        .gray_8bit(),                   // Unused 8-bit output
        .gray_12bit()                   // Unused 12-bit output
    );

    rgb2gray U_RGB2GRAY2 (
        .color_rgb(image2),             // 12-bit RGB input from camera 2
        .gray_4bit(gray_4bit_IMAGE2),   // 4-bit grayscale output for camera 2
        .gray_8bit(),                   // Unused 8-bit output
        .gray_12bit()                   // Unused 12-bit output
    );

    // Frame Counting for Camera 1
    // Tracks two frames per camera for motion detection using a 2-bit counter.
    logic [1:0] frame_count1;           // Frame index for camera 1 (0 or 1)
    logic frame_done1;                  // Frame completion signal for camera 1

    frame_counter U_FRAME_COUNTER1 (
        .clk(pclk1),                    // Pixel clock from camera 1
        .reset(reset),                  // Reset to initialize counter
        .vref(vref1),                   // Vertical sync to detect frame boundaries
        .frame_count(frame_count1),     // Current frame index (0 or 1)
        .frame_done(frame_done1)        // Frame completion flag
    );

    // Frame Counting for Camera 2
    logic [1:0] frame_count2;           // Frame index for camera 2 (0 or 1)
    logic frame_done2;                  // Frame completion signal for camera 2

    frame_counter U_FRAME_COUNTER (
        .clk(pclk2),                    // Pixel clock from camera 2
        .reset(reset),                  // Reset to initialize counter
        .vref(vref2),                   // Vertical sync to detect frame boundaries
        .frame_count(frame_count2),     // Current frame index (0 or 1)
        .frame_done(frame_done2)        // Frame completion flag
    );

    // Frame Buffers for Camera 1
    // Stores two frames of 4-bit grayscale data for camera 1 motion detection.
    frameBuffer_4bit U_IMAGE1_FRAME_0 (
        .wclk(pclk1),                   // Write clock (pixel clock from camera 1)
        .we(we1 && frame_count1 == 0),  // Write enable for frame 0
        .wAddr(wAddr1),                 // Write address
        .wData(gray_4bit_IMAGE1),       // 4-bit grayscale data input
        .rclk(clk_25MHz),               // Read clock (VGA clock)
        .oe(display_enable),            // Output enable for reading
        .rAddr(rAddr),                  // Read address
        .rData(gray_4bit_IMAGE1_read_0) // 4-bit grayscale data output
    );

    frameBuffer_4bit U_IMAGE1_FRAME_1 (
        .wclk(pclk1),                   // Write clock (pixel clock from camera 1)
        .we(we1 && frame_count1 == 1),  // Write enable for frame 1
        .wAddr(wAddr1),                 // Write address
        .wData(gray_4bit_IMAGE1),       // 4-bit grayscale data input
        .rclk(clk_25MHz),               // Read clock (VGA clock)
        .oe(display_enable),            // Output enable for reading
        .rAddr(rAddr),                  // Read address
        .rData(gray_4bit_IMAGE1_read_1) // 4-bit grayscale data output
    );

    // Frame Buffers for Camera 2
    // Stores two frames of 4-bit grayscale data for camera 2 motion detection.
    frameBuffer_4bit U_IMAGE2_FRAME_0 (
        .wclk(pclk2),                   // Write clock (pixel clock from camera 2)
        .we(we2 && frame_count2 == 0),  // Write enable for frame 0
        .wAddr(wAddr2),                 // Write address
        .wData(gray_4bit_IMAGE2),       // 4-bit grayscale data input
        .rclk(clk_25MHz),               // Read clock (VGA clock)
        .oe(display_enable),            // Output enable for reading
        .rAddr(rAddr),                  // Read address
        .rData(gray_4bit_IMAGE2_read_0) // 4-bit grayscale data output
    );

    frameBuffer_4bit U_IMAGE2_FRAME_1 (
        .wclk(pclk2),                   // Write clock (pixel clock from camera 2)
        .we(we2 && frame_count2 == 1),  // Write enable for frame 1
        .wAddr(wAddr2),                 // Write address
        .wData(gray_4bit_IMAGE2),       // 4-bit grayscale data input
        .rclk(clk_25MHz),               // Read clock (VGA clock)
        .oe(display_enable),            // Output enable for reading
        .rAddr(rAddr),                  // Read address
        .rData(gray_4bit_IMAGE2_read_1) // 4-bit grayscale data output
    );

    // Sobel Filter Coordinate Adjustment
    // Adjusts pixel coordinates for Sobel filter application across quadrants.
    logic [9:0] x_pixel_fliter;         // Adjusted X-coordinate for Sobel filter
    logic [9:0] y_pixel_fliter;         // Adjusted Y-coordinate for Sobel filter

    assign x_pixel_fliter = (left_top_enable)  ? x_pixel :                  // Left-top: direct mapping
                            (right_top_enable) ? (x_pixel - 320) :         // Right-top: offset by 320
                            (left_bot_enable)  ? x_pixel :                 // Left-bottom: direct mapping
                            (right_bot_enable) ? (x_pixel - 320) : 10'b0;  // Right-bottom: offset by 320

    assign y_pixel_fliter = (left_top_enable)  ? y_pixel :                  // Left-top: direct mapping
                            (right_top_enable) ? y_pixel :                 // Right-top: direct mapping
                            (left_bot_enable)  ? (y_pixel - 240) :         // Left-bottom: offset by 240
                            (right_bot_enable) ? (y_pixel - 240) : 10'b0;  // Right-bottom: offset by 240

    // Sobel Edge Detection
    // Applies a 5x5 Sobel filter to enhance edges in two frames per camera for motion detection.
    (* DONT_TOUCH = "TRUE" *)
    sobel_filter_5x5 sobel_5x5_0 (
        .clk(clk_25MHz),                // 25 MHz clock for Sobel processing
        .reset(reset),                  // Reset signal
        .gray_4bit_IMAGE1_0(gray_4bit_IMAGE1_read_0), // Camera 1, frame 0 grayscale input
        .gray_4bit_IMAGE1_1(gray_4bit_IMAGE1_read_1), // Camera 1, frame 1 grayscale input
        .gray_4bit_IMAGE2_0(gray_4bit_IMAGE2_read_0), // Camera 2, frame 0 grayscale input
        .gray_4bit_IMAGE2_1(gray_4bit_IMAGE2_read_1), // Camera 2, frame 1 grayscale input
        .x_pixel(x_pixel_fliter),       // Adjusted X-coordinate for filter window
        .y_pixel(y_pixel_fliter),       // Adjusted Y-coordinate for filter window
        .display_enable(display_enable),// Enable signal for active processing
        .threshold(threshold),          // Edge detection threshold
        .sobel_out_IMAGE1_0(sobel_out_IMAGE1_5x5_0), // Camera 1, frame 0 Sobel output
        .sobel_out_IMAGE1_1(sobel_out_IMAGE1_5x5_1), // Camera 1, frame 1 Sobel output
        .sobel_out_IMAGE2_0(sobel_out_IMAGE2_5x5_0), // Camera 2, frame 0 Sobel output
        .sobel_out_IMAGE2_1(sobel_out_IMAGE2_5x5_1)  // Camera 2, frame 1 Sobel output
    );

    // Motion Detection for Camera 1
    // Detects differences between two frames from camera 1 and determines motion.
    logic [3:0] IMAGE1_diff_pixel;      // 4-bit pixel value indicating difference
    logic IMAGE1_diff_detected;         // Difference detection flag for camera 1

    diff_detector_pixel U_IMAGE1_DIFF_DETECTOR_0 (
        .prev_pixel(sobel_out_IMAGE1_5x5_0), // Previous frame (frame 0)
        .curr_pixel(sobel_out_IMAGE1_5x5_1), // Current frame (frame 1)
        .diff_detected(IMAGE1_diff_detected) // Difference detection output
    );  

    assign IMAGE1_diff_pixel = (IMAGE1_diff_detected) ? 4'hf : 4'h0; // White if difference, black otherwise

    logic [$clog2(320 * 240) - 1 : 0] IMAGE1_diff_pixel_cnt; // Counter for differing pixels
    
    diff_pixel_counter U_DIFF_PIXEL_COUNTER (
        .clk(clk_25MHz),                // Clock for counting differences
        .reset(reset),                  // Reset signal
        .frame_done(frame_done1),       // Frame completion signal to reset counter
        .diff_detected(IMAGE1_diff_detected), // Input difference signal
        .diff_pixel_cnt(IMAGE1_diff_pixel_cnt) // Output count of differing pixels
    );

    motion_detector U_IMAGE1_MOTION_DETECTOR (
        .clk(clk_100MHz),               // 100 MHz clock for motion decision
        .reset(reset),                  // Reset signal
        .diff_pixel_cnt(IMAGE1_diff_pixel_cnt), // Count of differing pixels
        .detection_threshold(detection_threshold), // Motion sensitivity threshold
        .motion_detected(IMAGE1_motion_detected) // Motion detection output
    );

    // Motion Detection for Camera 2
    // Detects differences between two frames from camera 2 and determines motion.
    logic [3:0] IMAGE2_diff_pixel;      // 4-bit pixel value indicating difference
    logic IMAGE2_diff_detected;         // Difference detection flag for camera 2

    diff_detector_pixel U_IMAGE2_DIFF_DETECTOR (
        .prev_pixel(sobel_out_IMAGE2_5x5_0), // Previous frame (frame 0)
        .curr_pixel(sobel_out_IMAGE2_5x5_1), // Current frame (frame 1)
        .diff_detected(IMAGE2_diff_detected) // Difference detection output
    );  

    assign IMAGE2_diff_pixel = (IMAGE2_diff_detected) ? 4'hf : 4'h0; // White if difference, black otherwise

    logic [$clog2(320 * 240) - 1 : 0] IMAGE2_diff_pixel_cnt; // Counter for differing pixels
    
    diff_pixel_counter U_DIFF_PIXEL_COUNTER2 (
        .clk(clk_25MHz),                // Clock for counting differences
        .reset(reset),                  // Reset signal
        .frame_done(frame_done2),       // Frame completion signal to reset counter
        .diff_detected(IMAGE2_diff_detected), // Input difference signal
        .diff_pixel_cnt(IMAGE2_diff_pixel_cnt) // Output count of differing pixels
    );
    
    motion_detector U_IMAGE2_MOTION_DETECTOR (
        .clk(clk_100MHz),               // 100 MHz clock for motion decision
        .reset(reset),                  // Reset signal
        .diff_pixel_cnt(IMAGE2_diff_pixel_cnt), // Count of differing pixels
        .detection_threshold(detection_threshold), // Motion sensitivity threshold
        .motion_detected(IMAGE2_motion_detected) // Motion detection output
    );

    // VGA Output Generation
    // Formats processed data from both cameras into RGB signals for a split-screen VGA display.
    RGB_out U_RGB_OUT (
        .clk(clk_100MHz),               // 100 MHz clock for RGB processing
        .reset(reset),                  // Reset signal
        .x_pixel(x_pixel),              // X-coordinate for display
        .y_pixel(y_pixel),              // Y-coordinate for display
        .display_enable(display_enable),// Enable signal for active display
        .left_top_enable(left_top_enable),   // Quadrant enable signals
        .right_top_enable(right_top_enable),
        .left_bot_enable(left_bot_enable),
        .right_bot_enable(right_bot_enable),

        
        .IMAGE1_motion_detected(IMAGE1_motion_detected), // Motion flag for camera 1
        .left_top_image(gray_4bit_IMAGE1_read_0),    // Camera 1 raw image
        .right_top_image(IMAGE1_diff_pixel),         // Camera 1 difference image
        .IMAGE2_motion_detected(IMAGE2_motion_detected), // Motion flag for camera 2
        .left_bot_image(gray_4bit_IMAGE2_read_0),    // Camera 2 raw image
        .right_bot_image(IMAGE2_diff_pixel),         // Camera 2 difference image
        .red_port(red_port),            // 4-bit red channel output
        .green_port(green_port),        // 4-bit green channel output
        .blue_port(blue_port)           // 4-bit blue channel output
    );

endmodule