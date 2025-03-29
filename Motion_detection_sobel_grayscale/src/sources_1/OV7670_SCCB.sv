`timescale 1ns / 1ps

module OV7670_SCCB (
    input  logic clk,
    input  logic reset,
    output logic sda,
    output logic scl
);

    logic       start;
    logic       done;
    logic [7:0] reg_addr;
    logic [7:0] data;

    Control_Register U_C_Reg (.*);

    sccb_rev0 U_SCCB (
        .*,
        .ack()  // I2C Ack
    );

endmodule

// module sccb_test (
//     input  logic clk,
//     input  logic reset,
//     output logic scl,
//     output logic sda
// );
//     OV7670_SCCB U_Sccb (
//         .clk  (clk),    // 시스템 클럭
//         .reset(reset),  // 리셋 신호
//         .scl  (scl),    // I2C 클럭
//         .sda  (sda)     // I2C 데이터 라인 (양방향)
//     );
// endmodule

// module sccb (
//     input  logic       clk,       // 시스템 클럭
//     input  logic       reset,     // 리셋 신호
//     input  logic       start,     // 전송 시작 신호
//     input  logic [7:0] reg_addr,  // 레지스터 주소
//     input  logic [7:0] data,      // 레지스터 데이터
//     output logic       scl,       // I2C 클럭
//     inout  wire        sda,       // I2C 데이터 라인 (양방향)
//     output logic       done,      // I2C Done
//     output logic       ack        // I2C Ack
// );
//     logic       clk_100k;
//     logic [8:0] clk_div;
//     logic [9:0] clk_cnt_reg;
//     logic [9:0] clk_cnt_next;
//     logic       sda_out_reg;
//     logic       sda_out_next;
//     logic       sda_en_reg;
//     logic       sda_en_next;
//     logic       scl_mode_reg;
//     logic       scl_mode_next;
//     logic       done_reg;
//     logic       done_next;
//     logic [7:0] temp_reg;
//     logic [7:0] temp_next;
//     logic       ack_reg;
//     logic       ack_next;
//     logic [3:0] bit_cnt_reg;
//     logic [3:0] bit_cnt_next;

//     assign sda  = (sda_en_reg) ? sda_out_reg : 1'bz;
//     assign scl  = (scl_mode_reg) ? clk_100k : 1'b1;
//     assign done = done_reg;
//     assign ack  = ack_reg;

//     typedef enum {
//         IDLE,
//         SU_START,
//         HD_START,
//         T_LOW,
//         TRANSFER_DV,
//         WAIT_HIGH_DV,
//         ACK_DV_L,
//         ACK_DV_H,
//         TRANSFER_REG,
//         WAIT_HIGH_REG,
//         ACK_REG_L,
//         ACK_REG_H,
//         TRANSFER_DATA,
//         WAIT_HIGH_DATA,
//         ACK_DATA_L,
//         ACK_DATA_H,
//         STOP_H,
//         STOP_L,
//         DONE
//     } state_s;

//     state_s state, state_next;

//     always_ff @(posedge clk, posedge reset) begin
//         if (reset) begin
//             clk_div  <= 0;
//             clk_100k <= 0;
//         end else begin
//             clk_div <= clk_div + 1;
//             if (clk_div == 500 - 1) begin
//                 clk_div  <= 0;
//                 clk_100k <= ~clk_100k;
//             end
//         end
//     end

//     always_ff @(posedge clk, posedge reset) begin
//         if (reset) begin
//             state        <= IDLE;
//             bit_cnt_reg  <= 0;
//             clk_cnt_reg  <= 0;
//             sda_out_reg  <= 0;
//             sda_en_reg   <= 0;
//             temp_reg     <= 0;
//             scl_mode_reg <= 0;
//             done_reg     <= 0;
//             ack_reg      <= 0;
//         end else begin
//             state        <= state_next;
//             bit_cnt_reg  <= bit_cnt_next;
//             clk_cnt_reg  <= clk_cnt_next;
//             sda_out_reg  <= sda_out_next;
//             sda_en_reg   <= sda_en_next;
//             temp_reg     <= temp_next;
//             scl_mode_reg <= scl_mode_next;
//             done_reg     <= done_next;
//             ack_reg      <= ack_next;
//         end
//     end

//     always_comb begin
//         state_next    = state;
//         bit_cnt_next  = bit_cnt_reg;
//         clk_cnt_next  = clk_cnt_reg;
//         sda_out_next  = sda_out_reg;
//         sda_en_next   = sda_en_reg;
//         temp_next     = temp_reg;
//         scl_mode_next = scl_mode_reg;
//         done_next     = done_reg;
//         ack_next      = ack_reg;
//         case (state)
//             IDLE: begin
//                 bit_cnt_next  = 8;
//                 clk_cnt_next  = 0;
//                 sda_out_next  = 1'b1;
//                 sda_en_next   = 1'b1;
//                 temp_next     = 8'h42;
//                 scl_mode_next = 0;
//                 done_next     = 0;
//                 ack_next      = 0;
//                 if (start) begin
//                     sda_en_next  = 1'b1;
//                     sda_out_next = 1'b1;
//                     state_next   = SU_START;
//                 end
//             end
//             SU_START: begin
//                 if (clk_cnt_reg >= 59) begin
//                     clk_cnt_next = 0;
//                     sda_out_next = 1'b0;
//                     state_next   = HD_START;
//                 end else begin
//                     clk_cnt_next = clk_cnt_reg + 1;
//                 end
//             end
//             HD_START: begin
//                 if (clk_cnt_reg >= 59) begin
//                     if (clk_100k == 1'b0) begin
//                         clk_cnt_next = 0;
//                         scl_mode_next = 1;
//                         state_next = T_LOW;
//                     end
//                 end else begin
//                     clk_cnt_next = clk_cnt_reg + 1;
//                 end
//             end
//             T_LOW: begin
//                 if (clk_cnt_reg >= 129) begin
//                     clk_cnt_next = 0;
//                     state_next   = TRANSFER_DV;
//                 end else begin
//                     clk_cnt_next = clk_cnt_reg + 1;
//                 end
//             end
//             TRANSFER_DV: begin
//                 if (clk_cnt_reg >= 59 && clk_100k == 1'b1) begin
//                     clk_cnt_next = 0;
//                     if (bit_cnt_reg == 0) begin
//                         state_next = ACK_DV_L;
//                     end else begin
//                         sda_out_next = temp_reg[bit_cnt_reg-1];
//                         state_next   = WAIT_HIGH_DV;
//                     end
//                 end else begin
//                     clk_cnt_next = clk_cnt_reg + 1;
//                 end
//             end
//             WAIT_HIGH_DV: begin
//                 if (clk_100k == 1'b0) begin
//                     state_next   = TRANSFER_DV;
//                     bit_cnt_next = bit_cnt_reg - 1;
//                 end
//             end
//             ACK_DV_L: begin
//                 sda_en_next  = 0;
//                 sda_out_next = 0;
//                 if (clk_100k == 1'b0) state_next = ACK_DV_H;
//             end
//             ACK_DV_H: begin
//                 if (clk_100k == 1'b1) begin
//                     if (sda == 1) ack_next = 1'b1;
//                     sda_en_next = 1;
//                     state_next = TRANSFER_REG;
//                     temp_next = reg_addr;
//                     bit_cnt_next = 8;
//                 end
//             end
//             TRANSFER_REG: begin
//                 if (clk_cnt_reg >= 59 && clk_100k == 1'b1) begin
//                     clk_cnt_next = 0;
//                     if (bit_cnt_reg == 0) begin
//                         state_next = ACK_REG_L;
//                     end else begin
//                         sda_out_next = temp_reg[bit_cnt_reg-1];
//                         state_next   = WAIT_HIGH_REG;
//                     end
//                 end else begin
//                     clk_cnt_next = clk_cnt_reg + 1;
//                 end
//             end
//             WAIT_HIGH_REG: begin
//                 if (clk_100k == 1'b0) begin
//                     state_next   = TRANSFER_REG;
//                     bit_cnt_next = bit_cnt_reg - 1;
//                 end
//             end
//             ACK_REG_L: begin
//                 sda_en_next  = 0;
//                 sda_out_next = 0;
//                 if (clk_100k == 1'b0) state_next = ACK_REG_H;
//             end
//             ACK_REG_H: begin
//                 if (clk_100k == 1'b1) begin
//                     if (sda == 1) ack_next = 1'b1;
//                     sda_en_next = 1;
//                     state_next = TRANSFER_DATA;
//                     temp_next = data;
//                     bit_cnt_next = 8;
//                 end
//             end
//             TRANSFER_DATA: begin
//                 if (clk_cnt_reg >= 59 && clk_100k == 1'b1) begin
//                     clk_cnt_next = 0;
//                     if (bit_cnt_reg == 0) begin
//                         state_next = ACK_DATA_L;
//                     end else begin
//                         sda_out_next = temp_reg[bit_cnt_reg-1];
//                         state_next   = WAIT_HIGH_DATA;
//                     end
//                 end else begin
//                     clk_cnt_next = clk_cnt_reg + 1;
//                 end
//             end
//             WAIT_HIGH_DATA: begin
//                 if (clk_100k == 1'b0) begin
//                     state_next   = TRANSFER_DATA;
//                     bit_cnt_next = bit_cnt_reg - 1;
//                 end
//             end
//             ACK_DATA_L: begin
//                 sda_en_next  = 0;
//                 sda_out_next = 0;
//                 if (clk_100k == 1'b0) state_next = ACK_DATA_H;
//             end
//             ACK_DATA_H: begin
//                 if (clk_100k == 1'b1) begin
//                     if (sda == 1) ack_next = 1'b1;
//                     sda_en_next  = 1;
//                     state_next   = STOP_L;
//                     bit_cnt_next = 8;
//                 end
//             end
//             STOP_L: begin
//                 if (clk_100k == 1'b0) begin
//                     sda_out_next = 0;
//                     state_next   = STOP_H;
//                 end else scl_mode_next = 0;
//             end
//             STOP_H: begin
//                 if (clk_100k == 1'b1) begin
//                     sda_out_next = 1;
//                     state_next   = DONE;
//                 end
//             end
//             DONE: begin
//                 if (ack_reg == 1) begin
//                     done_next  = 1'b0;
//                     ack_next   = 1'b1;
//                     state_next = IDLE;
//                 end else begin
//                     done_next  = 1'b1;
//                     state_next = IDLE;
//                 end
//             end
//         endcase
//     end
// endmodule

module sccb_rev0 (
    input  logic       clk,       // 시스템 클럭
    input  logic       reset,     // 리셋 신호
    input  logic       start,     // 전송 시작 신호
    input  logic [7:0] reg_addr,  // 레지스터 주소
    input  logic [7:0] data,      // 레지스터 데이터
    output logic       scl,       // I2C 클럭
    output logic       sda,       // I2C 데이터 라인 (양방향)
    output logic       done,      // I2C Done
    output logic       ack        // I2C Ack
);
    logic       clk_100k;
    logic       clk_50k;
    logic [8:0] clk_div1;
    logic [8:0] clk_div2;
    logic [9:0] clk_cnt_reg;
    logic [9:0] clk_cnt_next;
    logic       sda_out_reg;
    logic       sda_out_next;
    logic       sda_en_reg;
    logic       sda_en_next;
    logic       scl_mode_reg;
    logic       scl_mode_next;
    logic       done_reg;
    logic       done_next;
    logic [7:0] temp_reg;
    logic [7:0] temp_next;
    logic       ack_reg;
    logic       ack_next;
    logic [3:0] bit_cnt_reg;
    logic [3:0] bit_cnt_next;

    assign sda  = (sda_en_reg) ? sda_out_reg : 1'bz;
    assign scl  = (scl_mode_reg) ? clk_100k : 1'b1;
    assign done = done_reg;
    assign ack  = ack_reg;

    typedef enum {
        IDLE,
        SU_START,
        HD_START,
        T_LOW,
        TRANSFER_DV1,
        TRANSFER_DV2,
        TRANSFER_DV3,
        TRANSFER_DV4,
        ACK_DV_L,
        ACK_DV_H,
        TRANSFER_REG1,
        TRANSFER_REG2,
        TRANSFER_REG3,
        TRANSFER_REG4,
        ACK_REG_L,
        ACK_REG_H,
        TRANSFER_DATA1,
        TRANSFER_DATA2,
        TRANSFER_DATA3,
        TRANSFER_DATA4,
        ACK_DATA_L,
        ACK_DATA_H,
        STOP_1,
        STOP_2,
        STOP_3,
        DONE
    } state_s;

    state_s state, state_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            clk_div1 <= 0;
            clk_div2 <= 0;
            clk_100k <= 0;
            clk_50k  <= 0;
        end else begin
            clk_div1 <= clk_div1 + 1;
            clk_div2 <= clk_div2 + 1;
            if (clk_div1 == 500 - 1) begin
                clk_div1 <= 0;
                clk_100k <= ~clk_100k;
            end
            if (clk_div2 == 250 - 1) begin
                clk_div2 <= 0;
                clk_50k  <= ~clk_50k;
            end
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            bit_cnt_reg  <= 0;
            clk_cnt_reg  <= 0;
            sda_out_reg  <= 0;
            sda_en_reg   <= 0;
            temp_reg     <= 0;
            scl_mode_reg <= 0;
            done_reg     <= 0;
            ack_reg      <= 0;
        end else begin
            state        <= state_next;
            bit_cnt_reg  <= bit_cnt_next;
            clk_cnt_reg  <= clk_cnt_next;
            sda_out_reg  <= sda_out_next;
            sda_en_reg   <= sda_en_next;
            temp_reg     <= temp_next;
            scl_mode_reg <= scl_mode_next;
            done_reg     <= done_next;
            ack_reg      <= ack_next;
        end
    end

    always_comb begin
        state_next    = state;
        bit_cnt_next  = bit_cnt_reg;
        clk_cnt_next  = clk_cnt_reg;
        sda_out_next  = sda_out_reg;
        sda_en_next   = sda_en_reg;
        temp_next     = temp_reg;
        scl_mode_next = scl_mode_reg;
        done_next     = done_reg;
        ack_next      = ack_reg;
        case (state)
            IDLE: begin
                bit_cnt_next  = 8;
                clk_cnt_next  = 0;
                sda_out_next  = 1'b1;
                sda_en_next   = 1'b1;
                temp_next     = 8'h42;
                scl_mode_next = 0;
                done_next     = 0;
                ack_next      = 0;
                if (start) begin
                    sda_en_next  = 1'b1;
                    sda_out_next = 1'b1;
                    state_next   = SU_START;
                end
            end
            SU_START: begin
                if (clk_cnt_reg >= 59) begin
                    clk_cnt_next = 0;
                    sda_out_next = 1'b0;
                    state_next   = HD_START;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            HD_START: begin
                if (clk_cnt_reg >= 59) begin
                    if (clk_100k == 1'b0) begin
                        clk_cnt_next = 0;
                        scl_mode_next = 1;
                        state_next = T_LOW;
                    end
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            T_LOW: begin
                if (clk_cnt_reg >= 129) begin
                    clk_cnt_next = 0;
                    state_next   = TRANSFER_DV1;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1;
                end
            end
            TRANSFER_DV1: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b1) begin
                    if (bit_cnt_reg == 0) begin
                        state_next = ACK_DV_L;
                    end else begin
                        sda_out_next = temp_reg[bit_cnt_reg-1];
                    end
                end else if (clk_100k == 1'b1 && clk_50k == 1'b0)
                    state_next = TRANSFER_DV2;
            end
            TRANSFER_DV2: begin
                if (clk_100k == 1'b1 && clk_50k == 1'b0)
                    state_next = TRANSFER_DV3;
            end
            TRANSFER_DV3: begin
                if (clk_100k == 1'b1 && clk_50k == 1'b1)
                    state_next = TRANSFER_DV4;
            end
            TRANSFER_DV4: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b0) begin
                    bit_cnt_next = bit_cnt_reg - 1;
                    state_next   = TRANSFER_DV1;
                end
            end
            ACK_DV_L: begin
                sda_en_next = 0;
                //sda_out_next = 0;
                if (clk_100k == 1'b1 && clk_50k == 1'b0) state_next = ACK_DV_H;
            end
            ACK_DV_H: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b1) begin
                    if (sda == 0) ack_next = 1'b1;
                    sda_en_next = 1;
                    temp_next = reg_addr;
                    bit_cnt_next = 8;
                    state_next = TRANSFER_REG1;
                end
            end
            TRANSFER_REG1: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b1) begin
                    if (bit_cnt_reg == 0) begin
                        state_next = ACK_REG_L;
                    end else begin
                        sda_out_next = temp_reg[bit_cnt_reg-1];
                    end
                end else if (clk_100k == 1'b1 && clk_50k == 1'b0)
                    state_next = TRANSFER_REG2;
            end
            TRANSFER_REG2: begin
                if (clk_100k == 1'b1 && clk_50k == 1'b0)
                    state_next = TRANSFER_REG3;
            end
            TRANSFER_REG3: begin
                if (clk_100k == 1'b1 && clk_50k == 1'b1)
                    state_next = TRANSFER_REG4;
            end
            TRANSFER_REG4: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b0) begin
                    bit_cnt_next = bit_cnt_reg - 1;
                    state_next   = TRANSFER_REG1;
                end
            end
            ACK_REG_L: begin
                sda_en_next = 0;
                //sda_out_next = 0;
                if (clk_100k == 1'b1 && clk_50k == 1'b0) state_next = ACK_REG_H;
            end
            ACK_REG_H: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b1) begin
                    if (sda == 0) ack_next = 1'b1;
                    sda_en_next = 1;
                    state_next = TRANSFER_DATA1;
                    temp_next = data;
                    bit_cnt_next = 8;
                end
            end
            TRANSFER_DATA1: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b1) begin
                    if (bit_cnt_reg == 0) begin
                        state_next = ACK_DATA_L;
                    end else begin
                        sda_out_next = temp_reg[bit_cnt_reg-1];
                    end
                end else if (clk_100k == 1'b1 && clk_50k == 1'b0)
                    state_next = TRANSFER_DATA2;
            end
            TRANSFER_DATA2: begin
                if (clk_100k == 1'b1 && clk_50k == 1'b0)
                    state_next = TRANSFER_DATA3;
            end
            TRANSFER_DATA3: begin
                if (clk_100k == 1'b1 && clk_50k == 1'b1)
                    state_next = TRANSFER_DATA4;
            end
            TRANSFER_DATA4: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b0) begin
                    bit_cnt_next = bit_cnt_reg - 1;
                    state_next   = TRANSFER_DATA1;
                end
            end
            ACK_DATA_L: begin
                sda_en_next = 0;
                //sda_out_next = 0;
                if (clk_100k == 1'b1 && clk_50k == 1'b0)
                    state_next = ACK_DATA_H;
            end
            ACK_DATA_H: begin
                if (clk_100k == 1'b0 && clk_50k == 1'b1) begin
                    if (sda == 0) ack_next = 1'b1;
                    state_next   = STOP_1;
                    bit_cnt_next = 8;
                end
            end
            STOP_1: begin
                sda_en_next  = 1;
                sda_out_next = 0;
                if (clk_100k == 1'b1 && clk_50k == 1'b0) state_next = STOP_2;
            end
            STOP_2: begin
                scl_mode_next = 0;
                if (clk_100k == 1'b1 && clk_50k == 1'b1) state_next = STOP_3;
            end
            STOP_3: begin
                sda_out_next = 1;
                if (clk_100k == 1'b0) begin
                    state_next = DONE;
                end
            end
            DONE: begin
                done_next  = 1'b1;
                state_next = IDLE;
            end
        endcase
    end
endmodule

module Control_Register (
    input  logic       clk,
    input  logic       reset,
    output logic       start,
    output logic [7:0] reg_addr,
    output logic [7:0] data,
    input  logic       done
);
    logic [15:0] ov7670_reg[0:75];
    logic [ 7:0] bit_count;

    initial begin
        ov7670_reg[0]  = 16'h12_80;
        ov7670_reg[1]  = 16'hFF_F0;
        ov7670_reg[2]  = 16'h12_14;
        ov7670_reg[3]  = 16'h11_80;
        ov7670_reg[4]  = 16'h0C_04;
        ov7670_reg[5]  = 16'h3E_19;
        ov7670_reg[6]  = 16'h04_00;
        ov7670_reg[7]  = 16'h40_d0;
        ov7670_reg[8]  = 16'h3a_04;
        ov7670_reg[9]  = 16'h14_18;
        ov7670_reg[10] = 16'h4F_B3;
        ov7670_reg[11] = 16'h50_B3;
        ov7670_reg[12] = 16'h51_00;
        ov7670_reg[13] = 16'h52_3d;
        ov7670_reg[14] = 16'h53_A7;
        ov7670_reg[15] = 16'h54_E4;
        ov7670_reg[16] = 16'h58_9E;
        ov7670_reg[17] = 16'h3D_C0;
        ov7670_reg[18] = 16'h17_15;
        ov7670_reg[19] = 16'h18_03;
        ov7670_reg[20] = 16'h32_00;
        ov7670_reg[21] = 16'h19_03;
        ov7670_reg[22] = 16'h1A_7B;
        ov7670_reg[23] = 16'h03_00;
        ov7670_reg[24] = 16'h0F_41;
        ov7670_reg[25] = 16'h1E_00;
        ov7670_reg[26] = 16'h33_0B;
        ov7670_reg[27] = 16'h3C_78;
        ov7670_reg[28] = 16'h69_00;
        ov7670_reg[29] = 16'h74_00;
        ov7670_reg[30] = 16'hB0_84;
        ov7670_reg[31] = 16'hB1_0c;
        ov7670_reg[32] = 16'hB2_0e;
        ov7670_reg[33] = 16'hB3_80;
        ov7670_reg[34] = 16'h70_3a;
        ov7670_reg[35] = 16'h71_35;
        ov7670_reg[36] = 16'h72_11;
        ov7670_reg[37] = 16'h73_f1;
        ov7670_reg[38] = 16'ha2_02;
        ov7670_reg[39] = 16'h7a_20;
        ov7670_reg[40] = 16'h7b_10;
        ov7670_reg[41] = 16'h7c_1e;
        ov7670_reg[42] = 16'h7d_35;
        ov7670_reg[43] = 16'h7e_5a;
        ov7670_reg[44] = 16'h7f_69;
        ov7670_reg[45] = 16'h80_76;
        ov7670_reg[46] = 16'h81_80;
        ov7670_reg[47] = 16'h82_88;
        ov7670_reg[48] = 16'h83_8f;
        ov7670_reg[49] = 16'h84_96;
        ov7670_reg[50] = 16'h85_a3;
        ov7670_reg[51] = 16'h86_af;
        ov7670_reg[52] = 16'h87_c4;
        ov7670_reg[53] = 16'h88_d7;
        ov7670_reg[54] = 16'h89_e8;
        ov7670_reg[55] = 16'h13_e0;
        ov7670_reg[56] = 16'h00_00;
        ov7670_reg[57] = 16'h10_00;
        ov7670_reg[58] = 16'h0d_40;
        ov7670_reg[59] = 16'h14_18;
        ov7670_reg[60] = 16'ha5_05;
        ov7670_reg[61] = 16'hab_07;
        ov7670_reg[62] = 16'h24_95;
        ov7670_reg[63] = 16'h25_33;
        ov7670_reg[64] = 16'h26_e3;
        ov7670_reg[65] = 16'h9f_78;
        ov7670_reg[66] = 16'ha0_68;
        ov7670_reg[67] = 16'ha1_03;
        ov7670_reg[68] = 16'ha6_d8;
        ov7670_reg[69] = 16'ha7_d8;
        ov7670_reg[70] = 16'ha8_f0;
        ov7670_reg[71] = 16'ha9_90;
        ov7670_reg[72] = 16'haa_94;
        ov7670_reg[73] = 16'h13_e7;
        ov7670_reg[74] = 16'h69_07;
        ov7670_reg[75] = 16'hFF_FF;
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            start     <= 1'b1;
            reg_addr  <= 8'h12;
            data      <= 8'h80;
            bit_count <= 0;
        end else begin
            start <= 1'b0;
            if (done == 1'b1) begin
                {reg_addr, data} <= ov7670_reg[bit_count];
                bit_count        <= bit_count + 1;
                start            <= 1'b1;
            end
            if (bit_count == 76) begin
                start <= 1'b0;
            end
        end
    end
endmodule
