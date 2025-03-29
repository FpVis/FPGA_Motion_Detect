`timescale 1ns / 1ps

module vga_controller (
    input  logic       clk,
    input  logic       reset,
    output logic       h_sync,
    output logic       v_sync,
    output logic [9:0] x_pixel,
    output logic [9:0] y_pixel,
    output logic       display_enable,
    output logic       left_top_enable,
    output logic       right_top_enable,
    output logic       left_bot_enable,
    output logic       right_bot_enable
);
    logic [9:0] h_counter, v_counter;


    pixel_counter U_Pxl_Counter (
        .pclk     (clk),
        .reset    (reset),
        .h_counter(h_counter),
        .v_counter(v_counter)
    );

    vga_decoder U_VGA_Decoder (
        .clk           (clk),
        .reset         (reset),
        .h_counter     (h_counter),
        .v_counter     (v_counter),
        .h_sync        (h_sync),
        .v_sync        (v_sync),
        .x_pixel       (x_pixel),
        .y_pixel       (y_pixel),
        .display_enable(display_enable),
        .left_top_enable(left_top_enable),
        .right_top_enable(right_top_enable),
        .left_bot_enable(left_bot_enable),
        .right_bot_enable(right_bot_enable)
    );
endmodule


module pixel_counter (
    input  logic       pclk,
    input  logic       reset,
    output logic [9:0] h_counter,
    output logic [9:0] v_counter
);
    localparam H_MAX = 800, V_MAX = 525;

    always_ff @(posedge pclk, posedge reset) begin : Horizontal_counter
        if (reset) begin
            h_counter <= 0;
        end else begin
            if (h_counter == H_MAX - 1) begin
                h_counter <= 0;
            end else begin
                h_counter <= h_counter + 1;
            end
        end
    end

    always_ff @(posedge pclk, posedge reset) begin : Vertical_counter
        if (reset) begin
            v_counter <= 0;
        end else begin
            if (h_counter == H_MAX - 1) begin
                if (v_counter == V_MAX - 1) begin
                    v_counter <= 0;
                end else begin
                    v_counter <= v_counter + 1;
                end
            end
        end
    end

endmodule

module vga_decoder (
    input  logic clk,
    input  logic reset,

    input  logic [9:0] h_counter,
    input  logic [9:0] v_counter,
    output logic       h_sync,
    output logic       v_sync,
    output logic [9:0] x_pixel,
    output logic [9:0] y_pixel,
    output logic       display_enable,
    output logic       left_top_enable,
    output logic       right_top_enable,
    output logic       left_bot_enable,
    output logic       right_bot_enable
);

    localparam H_Visible_area = 640;
    localparam H_Front_porch = 16;
    localparam H_Sync_pulse = 96;
    localparam H_Back_porch = 48;
    localparam H_Whole_line = 800;
    localparam V_Visible_area = 480;
    localparam V_Front_porch = 10;
    localparam V_Sync_pulse = 2;
    localparam V_Back_porch = 33;
    localparam V_Whole_frame = 525;

    assign h_sync = !((h_counter >= (H_Visible_area + H_Front_porch)) && (h_counter < (H_Visible_area + H_Front_porch + H_Sync_pulse)));
    assign v_sync = !((v_counter >= (V_Visible_area + V_Front_porch)) && (v_counter < (V_Visible_area + V_Front_porch + V_Sync_pulse)));
    assign display_enable = (h_counter < H_Visible_area) && (v_counter < V_Visible_area);
    assign x_pixel = h_counter;
    assign y_pixel = v_counter;


    assign left_top_enable = (x_pixel < 320) && (y_pixel < 240);  
    assign right_top_enable = (x_pixel >= 320 && x_pixel < 640) && (y_pixel < 240);  
    assign left_bot_enable = (x_pixel < 320) && (y_pixel >= 240 && y_pixel < 480);  
    assign right_bot_enable = (x_pixel >= 320 && x_pixel < 640) && (y_pixel >= 240 && y_pixel < 480);  

endmodule
