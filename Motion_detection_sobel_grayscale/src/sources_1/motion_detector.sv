`timescale 1ns / 1ps

module diff_detector_pixel (
    input logic [3:0] prev_pixel,
    input logic [3:0] curr_pixel,
    output logic diff_detected
);

    assign diff_detected = (prev_pixel != curr_pixel);

endmodule


module diff_pixel_counter (
    input logic clk,
    input logic reset,
    input logic frame_done,
    input logic diff_detected,

    output logic [$clog2(320 * 240) - 1 : 0] diff_pixel_cnt
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            diff_pixel_cnt <= 0;
        end else if (frame_done) begin
            diff_pixel_cnt <= 0;
        end else if (diff_detected) begin
            diff_pixel_cnt <= diff_pixel_cnt + 1;
        end
    end
endmodule


module motion_detector (
    input logic clk,
    input logic reset,

    input logic [$clog2(320 * 240) - 1 : 0] diff_pixel_cnt,
    input logic [7:0] detection_threshold,
    output logic motion_detected
);
    typedef enum {
        IDLE,
        DETECT,
        DONE
    } state_e;
    state_e state, next_state;

    logic [$clog2(100_000_000) - 1 : 0] sec_counter;
    logic sec_tick;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            sec_counter <= 0;
            sec_tick <= 0;
        end else if (sec_counter == 100_000_000) begin
            sec_counter <= 0;
            sec_tick <= 1;
        end else if (state != next_state) begin
            sec_counter <= 0;
            sec_tick <= 0;
        end else begin
            sec_counter <= sec_counter + 1;
            sec_tick <= 0;
        end
    end


    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end


    always_comb begin
        next_state = state;
        motion_detected = 0;
        case (state)
            IDLE: begin
                motion_detected = 0;

                if((diff_pixel_cnt >> 8) > detection_threshold) begin
                    next_state = DETECT;
                end
            end

            DETECT: begin
                motion_detected = 1;

                if(sec_tick) begin
                    next_state = DONE;
                end
            end

            DONE : begin
                motion_detected = 0;

                if(sec_tick) begin
                    next_state = IDLE;
                end
            end
        endcase
    end


endmodule
