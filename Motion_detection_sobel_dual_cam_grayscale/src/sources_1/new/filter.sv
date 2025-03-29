
module sobel_filter_5x5 (
    input  logic        clk,
    input  logic        reset,
    input  logic [3:0]  gray_4bit_IMAGE1_0,
    input  logic [3:0]  gray_4bit_IMAGE1_1,

    input  logic [3:0]  gray_4bit_IMAGE2_0,
    input  logic [3:0]  gray_4bit_IMAGE2_1,


    input  logic [ 9:0] x_pixel,
    input  logic [ 9:0] y_pixel,
    input  logic        display_enable,
    input  logic [7:0]  threshold,

    output logic [ 3:0] sobel_out_IMAGE1_0,
    output logic [ 3:0] sobel_out_IMAGE1_1,

    output logic [ 3:0] sobel_out_IMAGE2_0,
    output logic [ 3:0] sobel_out_IMAGE2_1
);
    localparam IMAGE_WIDTH = 320;

    logic [3:0] line_buffer_IMAGE1_1_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE1_2_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE1_3_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE1_4_0[0:IMAGE_WIDTH-1];

    logic [3:0] line_buffer_IMAGE1_1_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE1_2_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE1_3_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE1_4_1[0:IMAGE_WIDTH-1];



    logic [7:0] w_IMAGE1_0_0_0, w_IMAGE1_1_0_0, w_IMAGE1_2_0_0, w_IMAGE1_3_0_0, w_IMAGE1_4_0_0;
    logic [7:0] w_IMAGE1_0_1_0, w_IMAGE1_1_1_0, w_IMAGE1_2_1_0, w_IMAGE1_3_1_0, w_IMAGE1_4_1_0;
    logic [7:0] w_IMAGE1_0_2_0, w_IMAGE1_1_2_0, w_IMAGE1_2_2_0, w_IMAGE1_3_2_0, w_IMAGE1_4_2_0;
    logic [7:0] w_IMAGE1_0_3_0, w_IMAGE1_1_3_0, w_IMAGE1_2_3_0, w_IMAGE1_3_3_0, w_IMAGE1_4_3_0;
    logic [7:0] w_IMAGE1_0_4_0, w_IMAGE1_1_4_0, w_IMAGE1_2_4_0, w_IMAGE1_3_4_0, w_IMAGE1_4_4_0;

    logic [7:0] w_IMAGE1_0_0_1, w_IMAGE1_1_0_1, w_IMAGE1_2_0_1, w_IMAGE1_3_0_1, w_IMAGE1_4_0_1;
    logic [7:0] w_IMAGE1_0_1_1, w_IMAGE1_1_1_1, w_IMAGE1_2_1_1, w_IMAGE1_3_1_1, w_IMAGE1_4_1_1;
    logic [7:0] w_IMAGE1_0_2_1, w_IMAGE1_1_2_1, w_IMAGE1_2_2_1, w_IMAGE1_3_2_1, w_IMAGE1_4_2_1;
    logic [7:0] w_IMAGE1_0_3_1, w_IMAGE1_1_3_1, w_IMAGE1_2_3_1, w_IMAGE1_3_3_1, w_IMAGE1_4_3_1;
    logic [7:0] w_IMAGE1_0_4_1, w_IMAGE1_1_4_1, w_IMAGE1_2_4_1, w_IMAGE1_3_4_1, w_IMAGE1_4_4_1;



    logic [3:0] line_buffer_IMAGE2_1_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE2_2_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE2_3_0[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE2_4_0[0:IMAGE_WIDTH-1];

    logic [3:0] line_buffer_IMAGE2_1_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE2_2_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE2_3_1[0:IMAGE_WIDTH-1];
    logic [3:0] line_buffer_IMAGE2_4_1[0:IMAGE_WIDTH-1];



    logic [7:0] w_IMAGE2_0_0_0, w_IMAGE2_1_0_0, w_IMAGE2_2_0_0, w_IMAGE2_3_0_0, w_IMAGE2_4_0_0;
    logic [7:0] w_IMAGE2_0_1_0, w_IMAGE2_1_1_0, w_IMAGE2_2_1_0, w_IMAGE2_3_1_0, w_IMAGE2_4_1_0;
    logic [7:0] w_IMAGE2_0_2_0, w_IMAGE2_1_2_0, w_IMAGE2_2_2_0, w_IMAGE2_3_2_0, w_IMAGE2_4_2_0;
    logic [7:0] w_IMAGE2_0_3_0, w_IMAGE2_1_3_0, w_IMAGE2_2_3_0, w_IMAGE2_3_3_0, w_IMAGE2_4_3_0;
    logic [7:0] w_IMAGE2_0_4_0, w_IMAGE2_1_4_0, w_IMAGE2_2_4_0, w_IMAGE2_3_4_0, w_IMAGE2_4_4_0;

    logic [7:0] w_IMAGE2_0_0_1, w_IMAGE2_1_0_1, w_IMAGE2_2_0_1, w_IMAGE2_3_0_1, w_IMAGE2_4_0_1;
    logic [7:0] w_IMAGE2_0_1_1, w_IMAGE2_1_1_1, w_IMAGE2_2_1_1, w_IMAGE2_3_1_1, w_IMAGE2_4_1_1;
    logic [7:0] w_IMAGE2_0_2_1, w_IMAGE2_1_2_1, w_IMAGE2_2_2_1, w_IMAGE2_3_2_1, w_IMAGE2_4_2_1;
    logic [7:0] w_IMAGE2_0_3_1, w_IMAGE2_1_3_1, w_IMAGE2_2_3_1, w_IMAGE2_3_3_1, w_IMAGE2_4_3_1;
    logic [7:0] w_IMAGE2_0_4_1, w_IMAGE2_1_4_1, w_IMAGE2_2_4_1, w_IMAGE2_3_4_1, w_IMAGE2_4_4_1;


    logic [2:0] valid_pipeline;

    logic signed [15:0] IMAGE1_gx_sobel_0, IMAGE1_gy_sobel_0;
    logic signed [15:0] IMAGE1_gx_sobel_1, IMAGE1_gy_sobel_1;
    logic [15:0] IMAGE1_mag_sobel_0, IMAGE1_mag_sobel_1;

    logic signed [15:0] IMAGE2_gx_sobel_0, IMAGE2_gy_sobel_0;
    logic signed [15:0] IMAGE2_gx_sobel_1, IMAGE2_gy_sobel_1;
    logic [15:0] IMAGE2_mag_sobel_0, IMAGE2_mag_sobel_1;

    logic sobel_en;

    integer i;

   
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for (i = 0; i < IMAGE_WIDTH; i = i + 1) begin
                line_buffer_IMAGE1_4_0[i] <= 0;
                line_buffer_IMAGE1_3_0[i] <= 0;
                line_buffer_IMAGE1_2_0[i] <= 0;
                line_buffer_IMAGE1_1_0[i] <= 0;

                line_buffer_IMAGE1_4_1[i] <= 0;
                line_buffer_IMAGE1_3_1[i] <= 0;
                line_buffer_IMAGE1_2_1[i] <= 0;
                line_buffer_IMAGE1_1_1[i] <= 0;



                line_buffer_IMAGE2_4_0[i] <= 0;
                line_buffer_IMAGE2_3_0[i] <= 0;
                line_buffer_IMAGE2_2_0[i] <= 0;
                line_buffer_IMAGE2_1_0[i] <= 0;

                line_buffer_IMAGE2_4_1[i] <= 0;
                line_buffer_IMAGE2_3_1[i] <= 0;
                line_buffer_IMAGE2_2_1[i] <= 0;
                line_buffer_IMAGE2_1_1[i] <= 0;



            end
        end else if (display_enable) begin
            line_buffer_IMAGE1_4_0[x_pixel] <= line_buffer_IMAGE1_3_0[x_pixel];
            line_buffer_IMAGE1_3_0[x_pixel] <= line_buffer_IMAGE1_2_0[x_pixel];
            line_buffer_IMAGE1_2_0[x_pixel] <= line_buffer_IMAGE1_1_0[x_pixel];
            line_buffer_IMAGE1_1_0[x_pixel] <= gray_4bit_IMAGE1_0;

            line_buffer_IMAGE1_4_1[x_pixel] <= line_buffer_IMAGE1_3_1[x_pixel];
            line_buffer_IMAGE1_3_1[x_pixel] <= line_buffer_IMAGE1_2_1[x_pixel];
            line_buffer_IMAGE1_2_1[x_pixel] <= line_buffer_IMAGE1_1_1[x_pixel];
            line_buffer_IMAGE1_1_1[x_pixel] <= gray_4bit_IMAGE1_1;



            line_buffer_IMAGE2_4_0[x_pixel] <= line_buffer_IMAGE2_3_0[x_pixel];
            line_buffer_IMAGE2_3_0[x_pixel] <= line_buffer_IMAGE2_2_0[x_pixel];
            line_buffer_IMAGE2_2_0[x_pixel] <= line_buffer_IMAGE2_1_0[x_pixel];
            line_buffer_IMAGE2_1_0[x_pixel] <= gray_4bit_IMAGE2_0;

            line_buffer_IMAGE2_4_1[x_pixel] <= line_buffer_IMAGE2_3_1[x_pixel];
            line_buffer_IMAGE2_3_1[x_pixel] <= line_buffer_IMAGE2_2_1[x_pixel];
            line_buffer_IMAGE2_2_1[x_pixel] <= line_buffer_IMAGE2_1_1[x_pixel];
            line_buffer_IMAGE2_1_1[x_pixel] <= gray_4bit_IMAGE2_1;
        end
    end

    // Window Shift Logic for 4 Frames
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            // Reset window values for all 4 frames
            {w_IMAGE1_0_0_0, w_IMAGE1_1_0_0, w_IMAGE1_2_0_0, w_IMAGE1_3_0_0, w_IMAGE1_4_0_0} <= 0;
            {w_IMAGE1_0_1_0, w_IMAGE1_1_1_0, w_IMAGE1_2_1_0, w_IMAGE1_3_1_0, w_IMAGE1_4_1_0} <= 0;
            {w_IMAGE1_0_2_0, w_IMAGE1_1_2_0, w_IMAGE1_2_2_0, w_IMAGE1_3_2_0, w_IMAGE1_4_2_0} <= 0;
            {w_IMAGE1_0_3_0, w_IMAGE1_1_3_0, w_IMAGE1_2_3_0, w_IMAGE1_3_3_0, w_IMAGE1_4_3_0} <= 0;
            {w_IMAGE1_0_4_0, w_IMAGE1_1_4_0, w_IMAGE1_2_4_0, w_IMAGE1_3_4_0, w_IMAGE1_4_4_0} <= 0;

            {w_IMAGE1_0_0_1, w_IMAGE1_1_0_1, w_IMAGE1_2_0_1, w_IMAGE1_3_0_1, w_IMAGE1_4_0_1} <= 0;
            {w_IMAGE1_0_1_1, w_IMAGE1_1_1_1, w_IMAGE1_2_1_1, w_IMAGE1_3_1_1, w_IMAGE1_4_1_1} <= 0;
            {w_IMAGE1_0_2_1, w_IMAGE1_1_2_1, w_IMAGE1_2_2_1, w_IMAGE1_3_2_1, w_IMAGE1_4_2_1} <= 0;
            {w_IMAGE1_0_3_1, w_IMAGE1_1_3_1, w_IMAGE1_2_3_1, w_IMAGE1_3_3_1, w_IMAGE1_4_3_1} <= 0;
            {w_IMAGE1_0_4_1, w_IMAGE1_1_4_1, w_IMAGE1_2_4_1, w_IMAGE1_3_4_1, w_IMAGE1_4_4_1} <= 0;



            {w_IMAGE2_0_0_0, w_IMAGE2_1_0_0, w_IMAGE2_2_0_0, w_IMAGE2_3_0_0, w_IMAGE2_4_0_0} <= 0;
            {w_IMAGE2_0_1_0, w_IMAGE2_1_1_0, w_IMAGE2_2_1_0, w_IMAGE2_3_1_0, w_IMAGE2_4_1_0} <= 0;
            {w_IMAGE2_0_2_0, w_IMAGE2_1_2_0, w_IMAGE2_2_2_0, w_IMAGE2_3_2_0, w_IMAGE2_4_2_0} <= 0;
            {w_IMAGE2_0_3_0, w_IMAGE2_1_3_0, w_IMAGE2_2_3_0, w_IMAGE2_3_3_0, w_IMAGE2_4_3_0} <= 0;
            {w_IMAGE2_0_4_0, w_IMAGE2_1_4_0, w_IMAGE2_2_4_0, w_IMAGE2_3_4_0, w_IMAGE2_4_4_0} <= 0;

            {w_IMAGE2_0_0_1, w_IMAGE2_1_0_1, w_IMAGE2_2_0_1, w_IMAGE2_3_0_1, w_IMAGE2_4_0_1} <= 0;
            {w_IMAGE2_0_1_1, w_IMAGE2_1_1_1, w_IMAGE2_2_1_1, w_IMAGE2_3_1_1, w_IMAGE2_4_1_1} <= 0;
            {w_IMAGE2_0_2_1, w_IMAGE2_1_2_1, w_IMAGE2_2_2_1, w_IMAGE2_3_2_1, w_IMAGE2_4_2_1} <= 0;
            {w_IMAGE2_0_3_1, w_IMAGE2_1_3_1, w_IMAGE2_2_3_1, w_IMAGE2_3_3_1, w_IMAGE2_4_3_1} <= 0;
            {w_IMAGE2_0_4_1, w_IMAGE2_1_4_1, w_IMAGE2_2_4_1, w_IMAGE2_3_4_1, w_IMAGE2_4_4_1} <= 0;


            valid_pipeline <= 0;

        end else if (display_enable) begin
            // Frame 0
            w_IMAGE1_4_0_0 <= line_buffer_IMAGE1_4_0[x_pixel] << 4;
            w_IMAGE1_4_1_0 <= line_buffer_IMAGE1_3_0[x_pixel] << 4;
            w_IMAGE1_4_2_0 <= line_buffer_IMAGE1_2_0[x_pixel] << 4;
            w_IMAGE1_4_3_0 <= line_buffer_IMAGE1_1_0[x_pixel] << 4;
            w_IMAGE1_4_4_0 <= {gray_4bit_IMAGE1_0, 4'b0};

            // Frame 1
            w_IMAGE1_4_0_1 <= line_buffer_IMAGE1_4_1[x_pixel] << 4;
            w_IMAGE1_4_1_1 <= line_buffer_IMAGE1_3_1[x_pixel] << 4;
            w_IMAGE1_4_2_1 <= line_buffer_IMAGE1_2_1[x_pixel] << 4;
            w_IMAGE1_4_3_1 <= line_buffer_IMAGE1_1_1[x_pixel] << 4;
            w_IMAGE1_4_4_1 <= {gray_4bit_IMAGE1_1, 4'b0};

            // Frame 0
            w_IMAGE2_4_0_0 <= line_buffer_IMAGE2_4_0[x_pixel] << 4;
            w_IMAGE2_4_1_0 <= line_buffer_IMAGE2_3_0[x_pixel] << 4;
            w_IMAGE2_4_2_0 <= line_buffer_IMAGE2_2_0[x_pixel] << 4;
            w_IMAGE2_4_3_0 <= line_buffer_IMAGE2_1_0[x_pixel] << 4;
            w_IMAGE2_4_4_0 <= {gray_4bit_IMAGE2_0, 4'b0};

            // Frame 1
            w_IMAGE2_4_0_1 <= line_buffer_IMAGE2_4_1[x_pixel] << 4;
            w_IMAGE2_4_1_1 <= line_buffer_IMAGE2_3_1[x_pixel] << 4;
            w_IMAGE2_4_2_1 <= line_buffer_IMAGE2_2_1[x_pixel] << 4;
            w_IMAGE2_4_3_1 <= line_buffer_IMAGE2_1_1[x_pixel] << 4;
            w_IMAGE2_4_4_1 <= {gray_4bit_IMAGE2_1, 4'b0};


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
            IMAGE1_gx_sobel_0 <= 0; IMAGE1_gy_sobel_0 <= 0; IMAGE1_mag_sobel_0 <= 0;
            IMAGE1_gx_sobel_1 <= 0; IMAGE1_gy_sobel_1 <= 0; IMAGE1_mag_sobel_1 <= 0;

            IMAGE2_gx_sobel_0 <= 0; IMAGE2_gy_sobel_0 <= 0; IMAGE2_mag_sobel_0 <= 0;
            IMAGE2_gx_sobel_1 <= 0; IMAGE2_gy_sobel_1 <= 0; IMAGE2_mag_sobel_1 <= 0;
        end else if (valid_pipeline[1]) begin
            // Frame 0 Sobel Calculation
            IMAGE1_gx_sobel_0 <=
                (-w_IMAGE1_0_0_0 - (w_IMAGE1_1_0_0 << 1) + (w_IMAGE1_3_0_0 << 1) + w_IMAGE1_4_0_0) +
                (-(w_IMAGE1_0_1_0 << 2) - (w_IMAGE1_1_1_0 << 3) + (w_IMAGE1_3_1_0 << 3) + (w_IMAGE1_4_1_0 << 2)) +
                (-(w_IMAGE1_0_2_0 * 6) - (w_IMAGE1_1_2_0 * 12) + (w_IMAGE1_3_2_0 * 12) + (w_IMAGE1_4_2_0 * 6)) +
                (-(w_IMAGE1_0_3_0 << 2) - (w_IMAGE1_1_3_0 << 3) + (w_IMAGE1_3_3_0 << 3) + (w_IMAGE1_4_3_0 << 2)) +
                (-w_IMAGE1_0_4_0 - (w_IMAGE1_1_4_0 << 1) + (w_IMAGE1_3_4_0 << 1) + w_IMAGE1_4_4_0);

            IMAGE1_gy_sobel_0 <=
                (-w_IMAGE1_0_0_0 + -(w_IMAGE1_1_0_0 << 2) + -(w_IMAGE1_2_0_0 * 6) + -(w_IMAGE1_3_0_0 << 2) + -w_IMAGE1_4_0_0) +
                (-(w_IMAGE1_0_1_0 << 1) + -(w_IMAGE1_1_1_0 << 3) + -(w_IMAGE1_2_1_0 * 12) + -(w_IMAGE1_3_1_0 << 3) + -(w_IMAGE1_4_1_0 << 1)) +
                ((w_IMAGE1_0_3_0 << 1) + (w_IMAGE1_1_3_0 << 3) + (w_IMAGE1_2_3_0 * 12) + (w_IMAGE1_3_3_0 << 3) + (w_IMAGE1_4_3_0 << 1)) +
                (w_IMAGE1_0_4_0 + (w_IMAGE1_1_4_0 << 2) + (w_IMAGE1_2_4_0 * 6) + (w_IMAGE1_3_4_0 << 2) + w_IMAGE1_4_4_0);

            IMAGE1_mag_sobel_0 <= (IMAGE1_gx_sobel_0[15] ? (~IMAGE1_gx_sobel_0 + 1) : IMAGE1_gx_sobel_0) +
                         (IMAGE1_gy_sobel_0[15] ? (~IMAGE1_gy_sobel_0 + 1) : IMAGE1_gy_sobel_0);

            // Frame 1 Sobel Calculation
            IMAGE1_gx_sobel_1 <=
                (-w_IMAGE1_0_0_1 - (w_IMAGE1_1_0_1 << 1) + (w_IMAGE1_3_0_1 << 1) + w_IMAGE1_4_0_1) +
                (-(w_IMAGE1_0_1_1 << 2) - (w_IMAGE1_1_1_1 << 3) + (w_IMAGE1_3_1_1 << 3) + (w_IMAGE1_4_1_1 << 2)) +
                (-(w_IMAGE1_0_2_1 * 6) - (w_IMAGE1_1_2_1 * 12) + (w_IMAGE1_3_2_1 * 12) + (w_IMAGE1_4_2_1 * 6)) +
                (-(w_IMAGE1_0_3_1 << 2) - (w_IMAGE1_1_3_1 << 3) + (w_IMAGE1_3_3_1 << 3) + (w_IMAGE1_4_3_1 << 2)) +
                (-w_IMAGE1_0_4_1 - (w_IMAGE1_1_4_1 << 1) + (w_IMAGE1_3_4_1 << 1) + w_IMAGE1_4_4_1);

            IMAGE1_gy_sobel_1 <=
                (-w_IMAGE1_0_0_1 + -(w_IMAGE1_1_0_1 << 2) + -(w_IMAGE1_2_0_1 * 6) + -(w_IMAGE1_3_0_1 << 2) + -w_IMAGE1_4_0_1) +
                (-(w_IMAGE1_0_1_1 << 1) + -(w_IMAGE1_1_1_1 << 3) + -(w_IMAGE1_2_1_1 * 12) + -(w_IMAGE1_3_1_1 << 3) + -(w_IMAGE1_4_1_1 << 1)) +
                ((w_IMAGE1_0_3_1 << 1) + (w_IMAGE1_1_3_1 << 3) + (w_IMAGE1_2_3_1 * 12) + (w_IMAGE1_3_3_1 << 3) + (w_IMAGE1_4_3_1 << 1)) +
                (w_IMAGE1_0_4_1 + (w_IMAGE1_1_4_1 << 2) + (w_IMAGE1_2_4_1 * 6) + (w_IMAGE1_3_4_1 << 2) + w_IMAGE1_4_4_1);

            IMAGE1_mag_sobel_1 <= (IMAGE1_gx_sobel_1[15] ? (~IMAGE1_gx_sobel_1 + 1) : IMAGE1_gx_sobel_1) +
                         (IMAGE1_gy_sobel_1[15] ? (~IMAGE1_gy_sobel_1 + 1) : IMAGE1_gy_sobel_1);

    




            // Frame 0 Sobel Calculation
            IMAGE2_gx_sobel_0 <=
            (-w_IMAGE2_0_0_0 - (w_IMAGE2_1_0_0 << 1) + (w_IMAGE2_3_0_0 << 1) + w_IMAGE2_4_0_0) +
            (-(w_IMAGE2_0_1_0 << 2) - (w_IMAGE2_1_1_0 << 3) + (w_IMAGE2_3_1_0 << 3) + (w_IMAGE2_4_1_0 << 2)) +
            (-(w_IMAGE2_0_2_0 * 6) - (w_IMAGE2_1_2_0 * 12) + (w_IMAGE2_3_2_0 * 12) + (w_IMAGE2_4_2_0 * 6)) +
            (-(w_IMAGE2_0_3_0 << 2) - (w_IMAGE2_1_3_0 << 3) + (w_IMAGE2_3_3_0 << 3) + (w_IMAGE2_4_3_0 << 2)) +
            (-w_IMAGE2_0_4_0 - (w_IMAGE2_1_4_0 << 1) + (w_IMAGE2_3_4_0 << 1) + w_IMAGE2_4_4_0);

            IMAGE2_gy_sobel_0 <=
            (-w_IMAGE2_0_0_0 + -(w_IMAGE2_1_0_0 << 2) + -(w_IMAGE2_2_0_0 * 6) + -(w_IMAGE2_3_0_0 << 2) + -w_IMAGE2_4_0_0) +
            (-(w_IMAGE2_0_1_0 << 1) + -(w_IMAGE2_1_1_0 << 3) + -(w_IMAGE2_2_1_0 * 12) + -(w_IMAGE2_3_1_0 << 3) + -(w_IMAGE2_4_1_0 << 1)) +
            ((w_IMAGE2_0_3_0 << 1) + (w_IMAGE2_1_3_0 << 3) + (w_IMAGE2_2_3_0 * 12) + (w_IMAGE2_3_3_0 << 3) + (w_IMAGE2_4_3_0 << 1)) +
            (w_IMAGE2_0_4_0 + (w_IMAGE2_1_4_0 << 2) + (w_IMAGE2_2_4_0 * 6) + (w_IMAGE2_3_4_0 << 2) + w_IMAGE2_4_4_0);

            IMAGE2_mag_sobel_0 <= (IMAGE2_gx_sobel_0[15] ? (~IMAGE2_gx_sobel_0 + 1) : IMAGE2_gx_sobel_0) +
                    (IMAGE2_gy_sobel_0[15] ? (~IMAGE2_gy_sobel_0 + 1) : IMAGE2_gy_sobel_0);

            // Frame 1 Sobel Calculation
            IMAGE2_gx_sobel_1 <=
            (-w_IMAGE2_0_0_1 - (w_IMAGE2_1_0_1 << 1) + (w_IMAGE2_3_0_1 << 1) + w_IMAGE2_4_0_1) +
            (-(w_IMAGE2_0_1_1 << 2) - (w_IMAGE2_1_1_1 << 3) + (w_IMAGE2_3_1_1 << 3) + (w_IMAGE2_4_1_1 << 2)) +
            (-(w_IMAGE2_0_2_1 * 6) - (w_IMAGE2_1_2_1 * 12) + (w_IMAGE2_3_2_1 * 12) + (w_IMAGE2_4_2_1 * 6)) +
            (-(w_IMAGE2_0_3_1 << 2) - (w_IMAGE2_1_3_1 << 3) + (w_IMAGE2_3_3_1 << 3) + (w_IMAGE2_4_3_1 << 2)) +
            (-w_IMAGE2_0_4_1 - (w_IMAGE2_1_4_1 << 1) + (w_IMAGE2_3_4_1 << 1) + w_IMAGE2_4_4_1);

            IMAGE2_gy_sobel_1 <=
            (-w_IMAGE2_0_0_1 + -(w_IMAGE2_1_0_1 << 2) + -(w_IMAGE2_2_0_1 * 6) + -(w_IMAGE2_3_0_1 << 2) + -w_IMAGE2_4_0_1) +
            (-(w_IMAGE2_0_1_1 << 1) + -(w_IMAGE2_1_1_1 << 3) + -(w_IMAGE2_2_1_1 * 12) + -(w_IMAGE2_3_1_1 << 3) + -(w_IMAGE2_4_1_1 << 1)) +
            ((w_IMAGE2_0_3_1 << 1) + (w_IMAGE2_1_3_1 << 3) + (w_IMAGE2_2_3_1 * 12) + (w_IMAGE2_3_3_1 << 3) + (w_IMAGE2_4_3_1 << 1)) +
            (w_IMAGE2_0_4_1 + (w_IMAGE2_1_4_1 << 2) + (w_IMAGE2_2_4_1 * 6) + (w_IMAGE2_3_4_1 << 2) + w_IMAGE2_4_4_1);

            IMAGE2_mag_sobel_1 <= (IMAGE2_gx_sobel_1[15] ? (~IMAGE2_gx_sobel_1 + 1) : IMAGE2_gx_sobel_1) +
                    (IMAGE2_gy_sobel_1[15] ? (~IMAGE2_gy_sobel_1 + 1) : IMAGE2_gy_sobel_1);

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
    assign sobel_out_IMAGE1_0 = ((IMAGE1_mag_sobel_0[12:5] > threshold) && sobel_en) ? 4'hF : 4'h0;
    assign sobel_out_IMAGE1_1 = ((IMAGE1_mag_sobel_1[12:5] > threshold) && sobel_en) ? 4'hF : 4'h0;

    assign sobel_out_IMAGE2_0 = ((IMAGE2_mag_sobel_0[12:5] > threshold) && sobel_en) ? 4'hF : 4'h0;
    assign sobel_out_IMAGE2_1 = ((IMAGE2_mag_sobel_1[12:5] > threshold) && sobel_en) ? 4'hF : 4'h0;

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