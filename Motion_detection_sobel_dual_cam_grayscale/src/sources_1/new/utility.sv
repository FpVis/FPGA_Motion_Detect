`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 02:59:50 PM
// Design Name: 
// Module Name: utility
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
module frame_counter (
    input logic clk,
    input logic reset,
    input logic vref,

    output logic [1:0] frame_count,
    output logic frame_done
);

    logic prev_vref;
    assign frame_done = vref != prev_vref;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            prev_vref <= 0;
        end else begin
            prev_vref <= vref;
        end
    end


    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            frame_count <= 2'b00;
        end else if (frame_done) begin
            if (frame_count == 2'b10) begin
                frame_count <= 0;
            end else begin
                frame_count <= frame_count + 1;
            end
        end
    end
endmodule


module RGB_out (
    input logic clk,
    input logic reset,
    
    input logic [9:0] x_pixel,
    input logic [9:0] y_pixel,
    input logic display_enable,
    input logic left_top_enable,
    input logic right_top_enable,
    input logic left_bot_enable,
    input logic right_bot_enable,

    input logic IMAGE1_motion_detected,
    input logic IMAGE2_motion_detected,

    input logic [3:0]  left_top_image,
    input logic [3:0]  right_top_image,
    input logic [3:0]  left_bot_image,
    input logic [11:0]  right_bot_image,

    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
);
    
    logic [3:0] r_out, g_out, b_out;
    localparam LINE_THICKNESS = 20;


    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            r_out <= 4'b0;
            g_out <= 4'b0;
            b_out <= 4'b0;
        end else if (display_enable) begin
            if (left_top_enable) begin
                if(IMAGE1_motion_detected) begin
                    if (x_pixel < LINE_THICKNESS)begin
                        r_out <= 4'hf;
                        g_out <= 4'h0;
                        b_out <= 4'h0;
                    end else begin
                        r_out <= left_top_image;
                        g_out <= left_top_image;
                        b_out <= left_top_image;
                    end
                end else begin
                    r_out <= left_top_image;
                    b_out <= left_top_image;
                    g_out <= left_top_image;
                end


            end else if (right_top_enable) begin
                r_out <= right_top_image;
                g_out <= right_top_image;
                b_out <= right_top_image;


            end else if (left_bot_enable) begin
                    if(IMAGE2_motion_detected) begin
                        if (x_pixel < LINE_THICKNESS)begin
                            r_out <= 4'hf;
                            g_out <= 4'h0;
                            b_out <= 4'h0;
                        end else begin
                            r_out <= left_bot_image;
                            g_out <= left_bot_image;
                            b_out <= left_bot_image;
                        end  
                    end else begin
                        r_out <= left_bot_image;
                        g_out <= left_bot_image;
                        b_out <= left_bot_image;
                    end

            end else if (right_bot_enable) begin
                r_out <= right_bot_image;
                g_out <= right_bot_image;
                b_out <= right_bot_image;
            end
        end else begin
            r_out <= 0;
            g_out <= 0;
            b_out <= 0;
        end
    end

    
    assign red_port = r_out;
    assign green_port = g_out;
    assign blue_port = b_out;
       
endmodule

