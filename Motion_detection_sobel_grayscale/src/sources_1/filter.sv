// module sobel_filter_3x3 (
//     input  logic        clk,
//     input  logic        reset,
//     input  logic [ 7:0] gray_8bit,
//     input  logic [ 9:0] x_pixel,
//     input  logic [ 9:0] y_pixel,
//     input  logic        display_enable,
//     input  logic [7:0] threshold,
//     output logic [ 3:0] sobel_out
// );
//     localparam IMAGE_WIDTH = 320;

//     logic [3:0] line_buffer_1[0:IMAGE_WIDTH-1];
//     logic [3:0] line_buffer_2[0:IMAGE_WIDTH-1];

//     logic [7:0] w_0_0, w_1_0, w_2_0;
//     logic [7:0] w_0_1, w_1_1, w_2_1;
//     logic [7:0] w_0_2, w_1_2, w_2_2;

//     logic [2:0] valid_pipeline;

//     logic signed [15:0] gx_sobel, gy_sobel;
//     logic [15:0] mag_sobel;

//     integer i;

//     always @(posedge clk) begin
//         if (reset) begin
//             for (i = 0; i < IMAGE_WIDTH; i = i + 1) begin
//                 line_buffer_2[i] <= 0;
//                 line_buffer_1[i] <= 0;
//             end
//         end else if (display_enable) begin
//             line_buffer_2[x_pixel] <= line_buffer_1[x_pixel];
//             line_buffer_1[x_pixel] <= gray_8bit[7:4];
//         end
//     end

//     always @(posedge clk) begin
//         if (reset) begin
//             {w_0_0, w_1_0, w_2_0} <= 0;
//             {w_0_1, w_1_1, w_2_1} <= 0;
//             {w_0_2, w_1_2, w_2_2} <= 0;
//             valid_pipeline <= 0;
//         end else if (display_enable) begin

//             w_2_0 <= line_buffer_2[x_pixel] << 4;
//             w_2_1 <= line_buffer_1[x_pixel] << 4;
//             w_2_2 <= {gray_8bit[7:4], 4'b0};

//             w_1_0 <= w_2_0;
//             w_1_1 <= w_2_1;
//             w_1_2 <= w_2_2;

//             w_0_0 <= w_1_0;
//             w_0_1 <= w_1_1;
//             w_0_2 <= w_1_2;

//             valid_pipeline <= {
//                 valid_pipeline[1:0], (x_pixel >= 2 && y_pixel >= 2)
//             };
//         end else begin
//             valid_pipeline <= {valid_pipeline[1:0], 1'b0};
//         end
//     end

//     always @(posedge clk) begin
//         if (reset) begin
//             gx_sobel  <= 0;
//             gy_sobel  <= 0;
//             mag_sobel <= 0;
//         end else if (valid_pipeline[1]) begin

//             // GX
//             // [ -1  0  1 ]
//             // [ -2  0  2 ]
//             // [ -1  0  1 ]

//             // GY
//             // [ -1 -2 -1 ]
//             // [  0  0  0 ]
//             // [  1  2  1 ]

//             gx_sobel <=
//                 (-w_0_0 + w_2_0) +
//                 (-(w_0_1 << 1) + (w_2_1 << 1)) +
//                 (-w_0_2 + w_2_2);

//             gy_sobel <=
//                 (-w_0_0 + -(w_1_0 << 1) + -w_2_0) +
//                 (w_0_2 + (w_1_2 << 1) + w_2_2);

//             mag_sobel <= (gx_sobel[15] ? (~gx_sobel + 1) : gx_sobel) +
//                          (gy_sobel[15] ? (~gy_sobel + 1) : gy_sobel);
//         end
//     end
//     assign sobel_out = (mag_sobel[12:5] > threshold) ? 4'hF : 8'h0;

// endmodule



module sobel_filter_5x5 (
    input  logic        clk,
    input  logic        reset,
    input  logic [3:0]  gray_4bit_0,
    input  logic [3:0]  gray_4bit_1,
    input  logic [3:0]  gray_4bit_2,

    input  logic [ 9:0] x_pixel,
    input  logic [ 9:0] y_pixel,
    input  logic        display_enable,
    input  logic [7:0]  threshold,

    output logic [ 3:0] sobel_out_0,
    output logic [ 3:0] sobel_out_1,
    output logic [ 3:0] sobel_out_2
);
    localparam IMAGE_WIDTH = 320;

    logic [3:0] line_buffer_1_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_2_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_3_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_4_0[0:IMAGE_WIDTH-1];

    logic [3:0] line_buffer_1_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_2_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_3_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_4_1[0:IMAGE_WIDTH-1];

    logic [3:0] line_buffer_1_2[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_2_2[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_3_2[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_4_2[0:IMAGE_WIDTH-1];


    logic [7:0] w_0_0_0, w_1_0_0, w_2_0_0, w_3_0_0, w_4_0_0;
    logic [7:0] w_0_1_0, w_1_1_0, w_2_1_0, w_3_1_0, w_4_1_0;
    logic [7:0] w_0_2_0, w_1_2_0, w_2_2_0, w_3_2_0, w_4_2_0;
    logic [7:0] w_0_3_0, w_1_3_0, w_2_3_0, w_3_3_0, w_4_3_0;
    logic [7:0] w_0_4_0, w_1_4_0, w_2_4_0, w_3_4_0, w_4_4_0;

    logic [7:0] w_0_0_1, w_1_0_1, w_2_0_1, w_3_0_1, w_4_0_1;
    logic [7:0] w_0_1_1, w_1_1_1, w_2_1_1, w_3_1_1, w_4_1_1;
    logic [7:0] w_0_2_1, w_1_2_1, w_2_2_1, w_3_2_1, w_4_2_1;
    logic [7:0] w_0_3_1, w_1_3_1, w_2_3_1, w_3_3_1, w_4_3_1;
    logic [7:0] w_0_4_1, w_1_4_1, w_2_4_1, w_3_4_1, w_4_4_1;

    logic [7:0] w_0_0_2, w_1_0_2, w_2_0_2, w_3_0_2, w_4_0_2;
    logic [7:0] w_0_1_2, w_1_1_2, w_2_1_2, w_3_1_2, w_4_1_2;
    logic [7:0] w_0_2_2, w_1_2_2, w_2_2_2, w_3_2_2, w_4_2_2;
    logic [7:0] w_0_3_2, w_1_3_2, w_2_3_2, w_3_3_2, w_4_3_2;
    logic [7:0] w_0_4_2, w_1_4_2, w_2_4_2, w_3_4_2, w_4_4_2;


    logic [2:0] valid_pipeline;

    logic signed [15:0] gx_sobel_0, gy_sobel_0, gx_sobel_1, gy_sobel_1;
    logic signed [15:0] gx_sobel_2, gy_sobel_2;
    logic [15:0] mag_sobel_0, mag_sobel_1, mag_sobel_2;

    logic sobel_en;

    integer i;

   
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for (i = 0; i < IMAGE_WIDTH; i = i + 1) begin
                line_buffer_4_0[i] <= 0;
                line_buffer_3_0[i] <= 0;
                line_buffer_2_0[i] <= 0;
                line_buffer_1_0[i] <= 0;

                line_buffer_4_1[i] <= 0;
                line_buffer_3_1[i] <= 0;
                line_buffer_2_1[i] <= 0;
                line_buffer_1_1[i] <= 0;

                line_buffer_4_2[i] <= 0;
                line_buffer_3_2[i] <= 0;
                line_buffer_2_2[i] <= 0;
                line_buffer_1_2[i] <= 0;

            end
        end else if (display_enable) begin
            line_buffer_4_0[x_pixel] <= line_buffer_3_0[x_pixel];
            line_buffer_3_0[x_pixel] <= line_buffer_2_0[x_pixel];
            line_buffer_2_0[x_pixel] <= line_buffer_1_0[x_pixel];
            line_buffer_1_0[x_pixel] <= gray_4bit_0;

            line_buffer_4_1[x_pixel] <= line_buffer_3_1[x_pixel];
            line_buffer_3_1[x_pixel] <= line_buffer_2_1[x_pixel];
            line_buffer_2_1[x_pixel] <= line_buffer_1_1[x_pixel];
            line_buffer_1_1[x_pixel] <= gray_4bit_1;

            line_buffer_4_2[x_pixel] <= line_buffer_3_2[x_pixel];
            line_buffer_3_2[x_pixel] <= line_buffer_2_2[x_pixel];
            line_buffer_2_2[x_pixel] <= line_buffer_1_2[x_pixel];
            line_buffer_1_2[x_pixel] <= gray_4bit_2;
        end
    end

    // Window Shift Logic for 4 Frames
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            // Reset window values for all 4 frames
            {w_0_0_0, w_1_0_0, w_2_0_0, w_3_0_0, w_4_0_0} <= 0;
            {w_0_1_0, w_1_1_0, w_2_1_0, w_3_1_0, w_4_1_0} <= 0;
            {w_0_2_0, w_1_2_0, w_2_2_0, w_3_2_0, w_4_2_0} <= 0;
            {w_0_3_0, w_1_3_0, w_2_3_0, w_3_3_0, w_4_3_0} <= 0;
            {w_0_4_0, w_1_4_0, w_2_4_0, w_3_4_0, w_4_4_0} <= 0;

            {w_0_0_1, w_1_0_1, w_2_0_1, w_3_0_1, w_4_0_1} <= 0;
            {w_0_1_1, w_1_1_1, w_2_1_1, w_3_1_1, w_4_1_1} <= 0;
            {w_0_2_1, w_1_2_1, w_2_2_1, w_3_2_1, w_4_2_1} <= 0;
            {w_0_3_1, w_1_3_1, w_2_3_1, w_3_3_1, w_4_3_1} <= 0;
            {w_0_4_1, w_1_4_1, w_2_4_1, w_3_4_1, w_4_4_1} <= 0;

            {w_0_0_2, w_1_0_2, w_2_0_2, w_3_0_2, w_4_0_2} <= 0;
            {w_0_1_2, w_1_1_2, w_2_1_2, w_3_1_2, w_4_1_2} <= 0;
            {w_0_2_2, w_1_2_2, w_2_2_2, w_3_2_2, w_4_2_2} <= 0;
            {w_0_3_2, w_1_3_2, w_2_3_2, w_3_3_2, w_4_3_2} <= 0;
            {w_0_4_2, w_1_4_2, w_2_4_2, w_3_4_2, w_4_4_2} <= 0;

            valid_pipeline <= 0;

        end else if (display_enable) begin
            // Frame 0
            w_4_0_0 <= line_buffer_4_0[x_pixel] << 4;
            w_4_1_0 <= line_buffer_3_0[x_pixel] << 4;
            w_4_2_0 <= line_buffer_2_0[x_pixel] << 4;
            w_4_3_0 <= line_buffer_1_0[x_pixel] << 4;
            w_4_4_0 <= {gray_4bit_0, 4'b0};

            // Frame 1
            w_4_0_1 <= line_buffer_4_1[x_pixel] << 4;
            w_4_1_1 <= line_buffer_3_1[x_pixel] << 4;
            w_4_2_1 <= line_buffer_2_1[x_pixel] << 4;
            w_4_3_1 <= line_buffer_1_1[x_pixel] << 4;
            w_4_4_1 <= {gray_4bit_1, 4'b0};

            // Frame 2
            w_4_0_2 <= line_buffer_4_2[x_pixel] << 4;
            w_4_1_2 <= line_buffer_3_2[x_pixel] << 4;
            w_4_2_2 <= line_buffer_2_2[x_pixel] << 4;
            w_4_3_2 <= line_buffer_1_2[x_pixel] << 4;
            w_4_4_2 <= {gray_4bit_2, 4'b0};


            // Update valid pipeline for each frame
            valid_pipeline <= {
                valid_pipeline[1:0], 
                (x_pixel >= 4 && y_pixel >= 4 && x_pixel < 320 && y_pixel < 240)
            };
        end else begin
            valid_pipeline <= {valid_pipeline[2:0], 1'b0};
        end
    end

    // Sobel Calculation for 4 Frames
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            gx_sobel_0 <= 0; gy_sobel_0 <= 0; mag_sobel_0 <= 0;
            gx_sobel_1 <= 0; gy_sobel_1 <= 0; mag_sobel_1 <= 0;
            gx_sobel_2 <= 0; gy_sobel_2 <= 0; mag_sobel_2 <= 0;
        end else if (valid_pipeline[1]) begin
            // Frame 0 Sobel Calculation
            gx_sobel_0 <=
                (-w_0_0_0 - (w_1_0_0 << 1) + (w_3_0_0 << 1) + w_4_0_0) +
                (-(w_0_1_0 << 2) - (w_1_1_0 << 3) + (w_3_1_0 << 3) + (w_4_1_0 << 2)) +
                (-(w_0_2_0 * 6) - (w_1_2_0 * 12) + (w_3_2_0 * 12) + (w_4_2_0 * 6)) +
                (-(w_0_3_0 << 2) - (w_1_3_0 << 3) + (w_3_3_0 << 3) + (w_4_3_0 << 2)) +
                (-w_0_4_0 - (w_1_4_0 << 1) + (w_3_4_0 << 1) + w_4_4_0);

            gy_sobel_0 <=
                (-w_0_0_0 + -(w_1_0_0 << 2) + -(w_2_0_0 * 6) + -(w_3_0_0 << 2) + -w_4_0_0) +
                (-(w_0_1_0 << 1) + -(w_1_1_0 << 3) + -(w_2_1_0 * 12) + -(w_3_1_0 << 3) + -(w_4_1_0 << 1)) +
                ((w_0_3_0 << 1) + (w_1_3_0 << 3) + (w_2_3_0 * 12) + (w_3_3_0 << 3) + (w_4_3_0 << 1)) +
                (w_0_4_0 + (w_1_4_0 << 2) + (w_2_4_0 * 6) + (w_3_4_0 << 2) + w_4_4_0);

            mag_sobel_0 <= (gx_sobel_0[15] ? (~gx_sobel_0 + 1) : gx_sobel_0) +
                         (gy_sobel_0[15] ? (~gy_sobel_0 + 1) : gy_sobel_0);


            gx_sobel_1 <=
                (-w_0_0_1 - (w_1_0_1 << 1) + (w_3_0_1 << 1) + w_4_0_1) +
                (-(w_0_1_1 << 2) - (w_1_1_1 << 3) + (w_3_1_1 << 3) + (w_4_1_1 << 2)) +
                (-(w_0_2_1 * 6) - (w_1_2_1 * 12) + (w_3_2_1 * 12) + (w_4_2_1 * 6)) +
                (-(w_0_3_1 << 2) - (w_1_3_1 << 3) + (w_3_3_1 << 3) + (w_4_3_1 << 2)) +
                (-w_0_4_1 - (w_1_4_1 << 1) + (w_3_4_1 << 1) + w_4_4_1);

            gy_sobel_1 <=
                (-w_0_0_1 + -(w_1_0_1 << 2) + -(w_2_0_1 * 6) + -(w_3_0_1 << 2) + -w_4_0_1) +
                (-(w_0_1_1 << 1) + -(w_1_1_1 << 3) + -(w_2_1_1 * 12) + -(w_3_1_1 << 3) + -(w_4_1_1 << 1)) +
                ((w_0_3_1 << 1) + (w_1_3_1 << 3) + (w_2_3_1 * 12) + (w_3_3_1 << 3) + (w_4_3_1 << 1)) +
                (w_0_4_1 + (w_1_4_1 << 2) + (w_2_4_1 * 6) + (w_3_4_1 << 2) + w_4_4_1);

            mag_sobel_1 <= (gx_sobel_1[15] ? (~gx_sobel_1 + 1) : gx_sobel_1) +
                         (gy_sobel_1[15] ? (~gy_sobel_1 + 1) : gy_sobel_1);

    
            gx_sobel_2 <=
                (-w_0_0_2 - (w_1_0_2 << 1) + (w_3_0_2 << 1) + w_4_0_2) +
                (-(w_0_1_2 << 2) - (w_1_1_2 << 3) + (w_3_1_2 << 3) + (w_4_1_2 << 2)) +
                (-(w_0_2_2 * 6) - (w_1_2_2 * 12) + (w_3_2_2 * 12) + (w_4_2_2 * 6)) +
                (-(w_0_3_2 << 2) - (w_1_3_2 << 3) + (w_3_3_2 << 3) + (w_4_3_2 << 2)) +
                (-w_0_4_2 - (w_1_4_2 << 1) + (w_3_4_2 << 1) + w_4_4_2);

            gy_sobel_2 <=
                (-w_0_0_2 + -(w_1_0_2 << 2) + -(w_2_0_2 * 6) + -(w_3_0_2 << 2) + -w_4_0_2) +
                (-(w_0_1_2 << 1) + -(w_1_1_2 << 3) + -(w_2_1_2 * 12) + -(w_3_1_2 << 3) + -(w_4_1_2 << 1)) +
                ((w_0_3_2 << 1) + (w_1_3_2 << 3) + (w_2_3_2 * 12) + (w_3_3_2 << 3) + (w_4_3_2 << 1)) +
                (w_0_4_2 + (w_1_4_2 << 2) + (w_2_4_2 * 6) + (w_3_4_2 << 2) + w_4_4_2);

            mag_sobel_2 <= (gx_sobel_2[15] ? (~gx_sobel_2 + 1) : gx_sobel_2) +
                         (gy_sobel_2[15] ? (~gy_sobel_2 + 1) : gy_sobel_2);

        end
    end

    // Sobel Enable and Output Logic
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            sobel_en <= 0;
        end else begin
            sobel_en <= valid_pipeline[2];
        end
    end

    // Output Assignment
    assign sobel_out_0 = ((mag_sobel_0[12:5] > threshold) && sobel_en) ? 4'hF : 4'h0;
    assign sobel_out_1 = ((mag_sobel_1[12:5] > threshold) && sobel_en) ? 4'hF : 4'h0;
    assign sobel_out_2 = ((mag_sobel_2[12:5] > threshold) && sobel_en) ? 4'hF : 4'h0;

endmodule



module rgb2gray (
    input  logic [11:0] color_rgb,
    output logic [3:0]  gray_4bit,
    output logic [7:0]  gray_8bit,
    output logic [11:0] gray_12bit
);
    localparam RW = 8'h47;  
    localparam GW = 8'h96;  
    localparam BW = 8'h1D;  

    logic [3:0] r, g, b;

    assign r = color_rgb[11:8];
    assign g = color_rgb[7:4];
    assign b = color_rgb[3:0];
    assign gray_12bit = r * RW + g * GW + b * BW;
    assign gray_8bit = gray_12bit[11:4];
    assign gray_4bit = gray_12bit[11:8];

endmodule