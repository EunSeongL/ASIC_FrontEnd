`timescale 1ns / 1ps

module butterfly02 #(
    parameter IN_WIDTH  = 13,         //input bit width <7.6>
    parameter OUT_WIDTH = 23,         //output bit width <9.13> + 1
    parameter NUM       = 16,         //number of line
    parameter DATA      = 128,        //number of data
    parameter COUNT     = DATA / NUM  //input data count
) (
    input clk,
    input rstn,

    input signed [IN_WIDTH-1:0] din_i   [0:NUM-1],  //Re value
    input signed [IN_WIDTH-1:0] din_q   [0:NUM-1],  //Im value
    input                       valid_in,           //valid input

    output signed [OUT_WIDTH-1:0] do1_re   [0:NUM-1],  //plus Re out
    output signed [OUT_WIDTH-1:0] do1_im   [0:NUM-1],  //plus Im out
    output                        valid_out            //valid output
);

    logic signed [IN_WIDTH-1:0] shift_reg_val_re[0:NUM-1], shift_reg_val_im[0:NUM-1] ;

    logic signed [IN_WIDTH:0] o_bf02_low_re[0:NUM-1], o_bf02_low_im[0:NUM-1], o_bf02_high_re[0:NUM-1], o_bf02_high_im[0:NUM-1];
    logic signed [IN_WIDTH:0] registed_re [0:NUM-1], registed_im [0:NUM-1];
    logic signed [IN_WIDTH:0] shift_bfly02_re[0:NUM-1], shift_bfly02_im[0:NUM-1];

    integer i;
    logic bfly02_en;

    logic [4:0] bfly02_en_cnt;

    logic valid_in_buf0;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            bfly02_en_cnt <= 0;
            valid_in_buf0 <= 0;
        end
        else begin
            valid_in_buf0<= valid_in;

            if (valid_in) begin
                bfly02_en_cnt <= bfly02_en_cnt + 1;
            end
            else begin
                bfly02_en_cnt <= 0;
            end
        end
    end

    assign bfly02_en = bfly02_en_cnt[2];
  

    shift_reg #(
        .WIDTH(IN_WIDTH),
        .DELAY_LENGTH(COUNT / 2 -1)
    ) U_SHIFT_REG_64 (
        .clk (clk),
        .rstn(rstn),

        .write(1'd1),
        .read (1'd1),

        .data_in_real(din_i),
        .data_in_imag(din_q),

        .data_out_real(shift_reg_val_re),
        .data_out_imag(shift_reg_val_im)
    );

    bfly_02 #(
        .N(16),
        .IN_BIT(IN_WIDTH),
        .OUT_BIT(IN_WIDTH+1)
    ) U_BFLY02 (
        .clk (clk),
        .rstn(rstn),

        .din1_i(shift_reg_val_re),
        .din1_q(shift_reg_val_im),
        .din2_i(din_i),
        .din2_q(din_q),

        .dout1_i(o_bf02_low_re),
        .dout1_q(o_bf02_low_im),
        .dout2_i(o_bf02_high_re),
        .dout2_q(o_bf02_high_im)
    );


    shift_reg #(
        .WIDTH(IN_WIDTH+1),
        .DELAY_LENGTH(COUNT / 2 - 1)
    ) U_SHIFT_bfly02 (
        .clk (clk),
        .rstn(rstn),

        .write(1'd1),
        .read (1'd1),

        .data_in_real(o_bf02_high_re),
        .data_in_imag(o_bf02_high_im),

        .data_out_real(shift_bfly02_re),
        .data_out_imag(shift_bfly02_im)
    );

    logic signed [IN_WIDTH:0] muxed_re[0:NUM-1], muxed_im[0:NUM-1];
    logic [3:0] valid_in_buf1;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            valid_in_buf1 <= 0;
        end
        else begin
            valid_in_buf1[3:1] <= valid_in_buf1[2:0];
            valid_in_buf1[0] <= valid_in_buf0;
        end
    end

    assign muxed_re = bfly02_en ? o_bf02_low_re : shift_bfly02_re;
    assign muxed_im = bfly02_en ? o_bf02_low_im : shift_bfly02_im;

    logic signed [OUT_WIDTH-1:0] mul_re[0:NUM-1], mul_im[0:NUM-1];
    logic [$clog2(32)-1:0] mul_cnt;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            mul_cnt <= 0;
        end
        else begin
            if (valid_in_buf1[2]) begin
                mul_cnt <= mul_cnt + 1;
            end
        end
    end

    logic signed [8:0] fac_02_real[0:NUM-1], fac_02_imag[0:NUM-1];

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < NUM ; i = i + 1 ) begin
                mul_re[i] <= 0;
                mul_im[i] <= 0;
            end
        end
        else begin
            for (i = 0; i < NUM ; i = i + 1) begin
                mul_re[i] <= (muxed_re[i])*(fac_02_real[i])-(muxed_im[i])*(fac_02_imag[i]);
                mul_im[i] <= (muxed_re[i])*(fac_02_imag[i])+(muxed_im[i])*(fac_02_real[i]);
            end
        end
    end

    assign valid_out = valid_in_buf1[3];
    assign do1_re = mul_re;
    assign do1_im = mul_im;

    genvar k;
    generate //16개씩 뽑기
        for (k = 0; k < NUM; k = k + 1 ) begin
            step02_twf #(
                .INDEX_WIDTH(512),
                .BIT_WIDTH(9) //2.7format
            ) U_STEP02_FAC_LOW (
                .index(9'(k+mul_cnt*16)),
                .twf_out(fac_02_real[k])
            );

            twf_02_imag #(
                .INDEX_WIDTH(512),
                .BIT_WIDTH(9) //2.7format
            ) U_TWF_02_IMAG_HIGH (
                .index(9'(k+mul_cnt*16)),
                .twf_out(fac_02_imag[k])
            );

        end
    endgenerate    

endmodule
