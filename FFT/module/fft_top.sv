`timescale 1ns / 1ps

module fft_top #(
    parameter WIDTH=9
)(
    input clk,
    input rstn,
    input fft_mode, // 0: ifft, 1: fft
    input signed [WIDTH-1:0] din_i[0:15],
    input signed [WIDTH-1:0] din_q[0:15],
    input din_valid,

    output logic signed [WIDTH+3:0] do_re[0:511],
    output logic signed [WIDTH+3:0] do_im[0:511],
    output logic do_en
);

    logic signed [WIDTH-1:0] conj_din_re[0:15];
    logic signed [WIDTH-1:0] conj_din_im[0:15];

    logic signed [WIDTH-1:0] sdf1_do_re[0:15];
    logic signed [WIDTH+1:0] sdf1_do_im[0:15];
    logic sdf1_do_en;
    logic [4:0] sdf1_do_index[0:15];
    logic signed [WIDTH+2:0] sdf2_do_re[0:15];
    logic signed [WIDTH+2:0] sdf2_do_im[0:15];
    logic sdf2_do_en;
    logic [4:0] sdf2_do_index[0:15];
    logic signed [WIDTH+3:0] sdf3_do_re[0:15];
    logic signed [WIDTH+3:0] sdf3_do_im[0:15];
    logic sdf3_do_en;

    logic [4:0] sdf1_index_do[0:15];
    logic [5:0] index_sum[0:15];



endmodule