`timescale 1ns / 1ps

module butterfly10 #(
    parameter IN_WIDTH  = 11,         //input bit width 11bit
    parameter OUT_WIDTH = 12,         //output bit width 12bit
    parameter NUM       = 16,         //number of line
    parameter DATA      = 64,         //number of data
    parameter COUNT     = DATA / NUM  //input data count
) (
    input clk,
    input rstn,

    input signed [IN_WIDTH-1:0] din_i   [0:NUM-1],  //Re value
    input signed [IN_WIDTH-1:0] din_q   [0:NUM-1],  //Im value
    input                       valid_in,           //valid input

    output logic signed [OUT_WIDTH-1:0] do1_re   [0:NUM-1],  //plus Re out
    output logic signed [OUT_WIDTH-1:0] do1_im   [0:NUM-1],  //plus Im out
    output logic                        valid_out            //valid output
);

    logic [$clog2(COUNT)-1:0] count;  //
    logic shift_reg_cntl_write;
    logic shift_reg_cntl_read;
    logic signed [IN_WIDTH-1:0] shift_reg_val_re[0:NUM-1];
    logic signed [IN_WIDTH-1:0] shift_reg_val_im[0:NUM-1];
    logic bfly_en;  //0: 대기, 1: bfly계산
    integer i;

    logic signed [OUT_WIDTH-1:0]
        o_bfly10_low_re[0:NUM-1],
        o_bfly10_low_im[0:NUM-1],
        o_bfly10_high_re[0:NUM-1],
        o_bfly10_high_im[0:NUM-1];
    logic signed [OUT_WIDTH-1:0] shifted_re[0:NUM-1], shifted_im[0:NUM-1];

    assign shift_reg_cntl_write = 1;
    assign shift_reg_cntl_read = 1;
    assign bfly_en = (count >= (COUNT / 2)) ? 1 : 0;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count <= 0;
        end else begin
            if (valid_in) begin
                count <= count + 1;
            end else begin
                count <= 0;
            end
        end
    end

    logic [2:0] valid_in_buf;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            valid_in_buf <= 0;
        end else begin
            valid_in_buf[2:1] <= valid_in_buf[1:0];
            valid_in_buf[0] <= valid_in;
        end
    end

    assign valid_out = valid_in_buf[2];

    shift_reg #(
        .WIDTH(IN_WIDTH),
        .DELAY_LENGTH(2-1)
    ) U_SHIFT_REG_256 (
        .clk (clk),
        .rstn(rstn),

        .write(shift_reg_cntl_write),
        .read (shift_reg_cntl_read),

        .data_in_real(din_i),
        .data_in_imag(din_q),

        .data_out_real(shift_reg_val_re),
        .data_out_imag(shift_reg_val_im)
    );

    test_bfly10 #(
        .N(NUM),
        .IN_BIT(IN_WIDTH),
        .OUT_BIT(OUT_WIDTH)
    ) U_TEST_BFLY (
        .clk (clk),
        .rstn(rstn),

        .flag_in(valid_in_buf[0]),
        .din1_i (shift_reg_val_re),
        .din1_q (shift_reg_val_im),
        .din2_i (din_i),
        .din2_q (din_q),

        .dout1_i(o_bfly10_low_re),
        .dout1_q(o_bfly10_low_im),
        .dout2_i(o_bfly10_high_re),
        .dout2_q(o_bfly10_high_im)
    );

    shift_reg #(
        .WIDTH(OUT_WIDTH),
        .DELAY_LENGTH(1)
    ) U_SHIFT_REG_HIGH (
        .clk (clk),
        .rstn(rstn),

        .write(shift_reg_cntl_write),
        .read (shift_reg_cntl_read),

        .data_in_real(o_bfly10_high_re),
        .data_in_imag(o_bfly10_high_im),

        .data_out_real(shifted_re),
        .data_out_imag(shifted_im)
    );

    // logic mux_signal;
    // always @(posedge clk, negedge rstn) begin
    //     if (~rstn) begin
    //         mux_signal <= 0;
    //     end else begin
    //         mux_signal <= bfly_en;
    //     end
    // end

    logic signed [OUT_WIDTH-1:0] dout_reg_re[0:NUM-1], dout_reg_im[0:NUM-1];

    assign dout_reg_re = bfly_en ? o_bfly10_low_re : shifted_re;
    assign dout_reg_im = bfly_en ? o_bfly10_low_im : shifted_im;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < NUM; i = i + 1) begin
                do1_re[i] <= 0;
                do1_im[i] <= 0;
            end
        end else begin
            do1_re <= dout_reg_re;
            do1_im <= dout_reg_im;
        end
    end

endmodule
