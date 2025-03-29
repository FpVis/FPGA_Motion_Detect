`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2025 05:36:00 PM
// Design Name: 
// Module Name: upscaler
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module upscale (
    input  logic        clk_25MHz,
    input  logic        reset,
    input  logic [ 9:0] x_pixel,
    input  logic [ 9:0] y_pixel,
    input  logic [11:0] image,
    output logic [11:0] upscaled_image
);
    logic [11:0] mem[0:319];
    logic [11:0] buffer_prev;

    logic [3:0] r_curr, g_curr, b_curr;
    logic [3:0] r_prev, g_prev, b_prev;
    logic [4:0] r_sum, b_sum, g_sum;
    logic [3:0] r_out, g_out, b_out;

    always_ff @(posedge clk_25MHz, posedge reset) begin
        if (reset) begin
            buffer_prev <= 12'd0;
        end else begin
            buffer_prev <= image;
            if (x_pixel < 320) begin
                mem[x_pixel] <= upscaled_image;
            end
        end
    end

    always_comb begin
        if (x_pixel < 640 && y_pixel < 480) begin
            if (x_pixel > 0 || y_pixel > 0) begin
                r_curr = image[11:8];
                g_curr = image[7:4];
                b_curr = image[3:0];
                if (y_pixel[0] == 0) begin
                    r_prev = mem[x_pixel][11:8];
                    g_prev = mem[x_pixel][7:4];
                    b_prev = mem[x_pixel][3:0];

                    r_sum = r_curr + r_prev;
                    g_sum = g_curr + g_prev;
                    b_sum = b_curr + b_prev;
                    r_out = r_sum >> 1;
                    g_out = g_sum >> 1;
                    b_out = b_sum >> 1;

                    upscaled_image = {r_out, g_out, b_out};
                end else begin
                    if (x_pixel[0] == 0) begin
                        r_prev = buffer_prev[11:8];
                        g_prev = buffer_prev[7:4];
                        b_prev = buffer_prev[3:0];

                        r_sum = r_curr + r_prev;
                        g_sum = g_curr + g_prev;
                        b_sum = b_curr + b_prev;
                        r_out = r_sum >> 1;
                        g_out = g_sum >> 1;
                        b_out = b_sum >> 1;

                        upscaled_image = {r_out, g_out, b_out};
                    end else upscaled_image = image;
                end
            end else upscaled_image = image;
        end else upscaled_image = 12'bz;
    end
endmodule
