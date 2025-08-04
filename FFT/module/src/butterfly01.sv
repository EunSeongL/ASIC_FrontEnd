`timescale 1ns / 1ps

module butterfly01 #(
    parameter IN_WIDTH  = 10,         //input bit width <7.6>
    parameter OUT_WIDTH = 13,         //output bit width <7.6>
    parameter NUM       = 16,         //number of line
    parameter DATA      = 256,        //number of data
    parameter COUNT     = DATA / NUM  //input data count
) (
    input clk,
    input rstn,

    input signed [IN_WIDTH-1:0] din_i   [0:NUM-1],  //Re value
    input signed [IN_WIDTH-1:0] din_q   [0:NUM-1],  //Im value
    input                       valid_in,           //valid input

    output signed [OUT_WIDTH-1:0] do1_re   [0:NUM-1],  //Re out
    output signed [OUT_WIDTH-1:0] do1_im   [0:NUM-1],  //Im out
    output                        valid_out
);

    // 내부 고정 파라미터
    localparam TMP_WIDTH = IN_WIDTH + 1;  // 버터플라이 add/sub 결과 <5.6>
    localparam TW_WIDTH  = 10;            // twiddle factor <2.8>
    localparam integer SHIFT      = 8;
    localparam signed [TW_WIDTH+TMP_WIDTH:0] HALF = 1 << (SHIFT-1); // 256/2 = 128


    logic signed [IN_WIDTH-1:0] shift_reg_val_re[0:NUM-1], shift_reg_val_im[0:NUM-1];
    logic signed [TMP_WIDTH-1:0] o_bf01_low_re[0:NUM-1], o_bf01_low_im[0:NUM-1];
    logic signed [TMP_WIDTH-1:0] o_bf01_high_re[0:NUM-1], o_bf01_high_im[0:NUM-1];
    logic signed [TMP_WIDTH-1:0] shift_bfly01_re[0:NUM-1], shift_bfly01_im[0:NUM-1];

    integer i;
    logic bfly01_en;
    logic [4:0] bfly01_en_cnt;
    logic [1:0]valid_in_buf0;
    logic [7:0] valid_in_buf1;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            bfly01_en_cnt <= 0;
            valid_in_buf0[1:0] <= 0;
        end
        else begin
            valid_in_buf0[1] <= valid_in_buf0[0];
            valid_in_buf0[0]<= valid_in;
            if (valid_in) bfly01_en_cnt <= bfly01_en_cnt + 1;
            else bfly01_en_cnt <= 0;
        end
    end
    assign bfly01_en = bfly01_en_cnt[3];
  
    // 입력 데이터 절반 지연
    shift_reg #(
        .WIDTH(IN_WIDTH),
        .DELAY_LENGTH(COUNT / 2 -1)
    ) U_SHIFT_REG_128 (
        .clk (clk),
        .rstn(rstn),
        .write(1'd1),
        .read (1'd1),
        .data_in_real(din_i),
        .data_in_imag(din_q),
        .data_out_real(shift_reg_val_re),
        .data_out_imag(shift_reg_val_im)
    );

    // 1단계 버터플라이 (덧셈/뺄셈)
    bfly_add #(
        .N(NUM),
        .IN_BIT(IN_WIDTH),
        .OUT_BIT(TMP_WIDTH)
    ) U_BFLY01 (
        .clk (clk),
        .rstn(rstn),
        .din1_i(shift_reg_val_re),
        .din1_q(shift_reg_val_im),
        .din2_i(din_i),
        .din2_q(din_q),
        .dout1_i(o_bf01_low_re),
        .dout1_q(o_bf01_low_im),
        .dout2_i(o_bf01_high_re),
        .dout2_q(o_bf01_high_im)
    );

    // High path 지연
    shift_reg #(
        .WIDTH(TMP_WIDTH),
        .DELAY_LENGTH(COUNT / 2 - 1)
    ) U_SHIFT_bfly01 (
        .clk (clk),
        .rstn(rstn),
        .write(1'd1),
        .read (1'd1),
        .data_in_real(o_bf01_high_re),
        .data_in_imag(o_bf01_high_im),
        .data_out_real(shift_bfly01_re),
        .data_out_imag(shift_bfly01_im)
    );

    // MUX (even/odd 구간 스위칭)
    logic signed [TMP_WIDTH-1:0] muxed_re[0:NUM-1], muxed_im[0:NUM-1];
    assign muxed_re = bfly01_en ? o_bf01_low_re : shift_bfly01_re;
    assign muxed_im = bfly01_en ? o_bf01_low_im : shift_bfly01_im;

    // Twiddle Factor LUT (8개)
    logic signed [TW_WIDTH-1:0] tw_re[0:7], tw_im[0:7];
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < 8 ; i = i + 1 ) begin
                tw_re[i] <= 0;
                tw_im[i] <= 0;
            end
        end
        else begin
            tw_re[0] <=  256; tw_im[0] <=    0;
            tw_re[1] <=  256; tw_im[1] <=    0;
            tw_re[2] <=  256; tw_im[2] <=    0;
            tw_re[3] <=    0; tw_im[3] <= -256;
            tw_re[4] <=  256; tw_im[4] <=    0;
            tw_re[5] <=  181; tw_im[5] <= -181;
            tw_re[6] <=  256; tw_im[6] <=    0;
            tw_re[7] <= -181; tw_im[7] <= -181;
        end
    end

    // index 계산 (64씩 그룹핑)
    logic [2:0] tw_idx;
    logic [$clog2(DATA)-1:0] sample_cnt;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) sample_cnt <= 0;
        else if (valid_in_buf1[6]) sample_cnt <= sample_cnt + 1;
    end

    assign tw_idx = (sample_cnt>15) ? sample_cnt[3:2] + 4 : sample_cnt[3:2]; 

    // 곱셈 (복소수 곱)
    logic signed [TW_WIDTH+TMP_WIDTH:0] mul_re[0:NUM-1], mul_im[0:NUM-1];
    always @(posedge clk or negedge rstn) begin
        integer i;  // 여기 선언
        if (!rstn) begin
            for (i = 0; i < NUM; i = i + 1) begin
                mul_re[i] <= 0;
                mul_im[i] <= 0;
            end
        end else begin
            case (tw_idx)
                0: begin
                    for (i = 0; i < NUM; i = i + 1) begin
                        mul_re[i] <= ((muxed_re[i]) * (256));
                        mul_im[i] <= ((muxed_im[i]) * (256));
                    end
                end
                1: begin
                    for (i = 0; i < NUM; i = i + 1) begin
                        mul_re[i] <= ((muxed_re[i]) * (256));
                        mul_im[i] <= ((muxed_im[i]) * (256));
                    end
                end
                2: begin
                    for (i = 0; i < NUM; i = i + 1) begin
                        mul_re[i] <= -((muxed_re[i]) * (256));
                        mul_im[i] <= -((muxed_im[i]) * (256));
                    end
                end
                3: begin
                    for (i = 0; i < NUM; i = i + 1) begin
                        // mul_re[i] <= (muxed_im[i]) * (-256);
                        // mul_im[i] <= (muxed_re[i]) * (256);
                        mul_re[i] <= (muxed_im[i]) * (-256);
                        mul_im[i] <= (muxed_re[i]) * (256);
                    end
                end
                4: begin
                    for (i = 0; i < NUM; i = i + 1) begin
                        mul_re[i] <= ((muxed_re[i]) * (256));
                        mul_im[i] <= ((muxed_im[i]) * (256));
                    end
                end
                5: begin
                    for (i = 0; i < NUM; i = i + 1) begin
                        mul_re[i] <= -((muxed_re[i] + muxed_im[i]) * (-181));
                        mul_im[i] <= -((muxed_im[i] - muxed_re[i]) * (-181));
                    end
                end
                6: begin
                    for (i = 0; i < NUM; i = i + 1) begin
                        mul_re[i] <= ((muxed_re[i]) * (-256));
                        mul_im[i] <= ((muxed_im[i]) * (-256));
                    end
                end
                7: begin
                    for (i = 0; i < NUM; i = i + 1) begin
                        mul_re[i] <= (muxed_im[i] - muxed_re[i]) * (-181);
                        mul_im[i] <= (muxed_re[i] + muxed_im[i]) * (181);
                    end
                end 
            endcase
        end
    end

    // Shift & Rounding (>>8)
    logic signed [OUT_WIDTH-1:0] out_re[0:NUM-1], out_im[0:NUM-1];
    //integer i;  // 여기 선언
    always @(*) begin
        for (i = 0; i < NUM; i = i + 1) begin
            out_re[i] = (mul_re[i]+128) >>> 8;
            out_im[i] = (mul_im[i]+128) >>> 8;
        end
    end

    // Valid 신호 딜레이
   
    always @(posedge clk, negedge rstn) begin
        if (~rstn) valid_in_buf1 <= 0;
        else begin
            valid_in_buf1[7:1] <= valid_in_buf1[6:0];
            valid_in_buf1[0] <= valid_in_buf0[0];
        end
    end
    assign valid_out = valid_in_buf1[7];

    // 최종 출력
    assign do1_re = out_re;
    assign do1_im = out_im;

endmodule
