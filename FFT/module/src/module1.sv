`timescale 1ns / 1ps

module module1 #(
    parameter IN_BIT_WIDTH = 11,  //11bit input
    parameter OUT_BIT_WIDTH = 12,  //12bit output
    parameter N = 16,  //묶음
    parameter BF10_BIT = 12,  //12bit
    parameter BF11_BIT = 15,  //
    parameter BF12_BIT = 25  //
) (
    input clk,
    input rstn,

    input                           valid_in,
    input signed [IN_BIT_WIDTH-1:0] din_i   [0:N-1],  //re input
    input signed [IN_BIT_WIDTH-1:0] din_q   [0:N-1],  //im input

    output logic                            valid_out,
    output logic signed [OUT_BIT_WIDTH-1:0] dout_i   [0:N-1],  //re output
    output logic signed [OUT_BIT_WIDTH-1:0] dout_q   [0:N-1],  //im output

    output logic [4:0] cbfp_index[0:N-1]
);

    logic signed [BF10_BIT-1:0] o_bf10_re[0:N-1], o_bf10_im[0:N-1];
    logic valid_out_bf10;

    logic signed [BF11_BIT-1:0] o_bf11_re[0:N-1], o_bf11_im[0:N-1];
    logic valid_out_bf11;

    logic signed [BF12_BIT-1:0] o_bf12_re[0:N-1], o_bf12_im[0:N-1];
    logic valid_out_bf12;

    logic signed [OUT_BIT_WIDTH-1:0] o_cbfp1_re[0:N-1], o_cbfp1_im[0:N-1];
    logic valid_out_cbfp1;

    butterfly10 #() U_BF10 (
        .clk (clk),
        .rstn(rstn),

        .din_i   (din_i),    //Re value
        .din_q   (din_q),    //Im value
        .valid_in(valid_in), //valid input

        .do1_re   (o_bf10_re),      //plus Re out
        .do1_im   (o_bf10_im),      //plus Im out
        .valid_out(valid_out_bf10)  //valid output
    );

    butterfly11 #() U_BF11 (
        .clk (clk),
        .rstn(rstn),

        .din_i   (o_bf10_re),      //Re value
        .din_q   (o_bf10_im),      //Im value
        .valid_in(valid_out_bf10), //valid input

        .do1_re(o_bf11_re),  //Re out
        .do1_im(o_bf11_im),  //Im out
        .valid_out(valid_out_bf11)
    );

    butterfly12 #() U_BF12 (
        .clk (clk),
        .rstn(rstn),

        .din_i   (o_bf11_re),      //Re value
        .din_q   (o_bf11_im),      //Im value
        .valid_in(valid_out_bf11), //valid input

        .do1_re   (o_bf12_re),      //plus Re out
        .do1_im   (o_bf12_im),      //plus Im out
        .valid_out(valid_out_bf12)  //valid output
    );

    cbfp_stage1 #() U_CBFP1 (
        .clk(clk),
        .rstn(rstn),
        .real_in(o_bf12_re),
        .imag_in(o_bf12_im),
        .in_valid(valid_out_bf12),

        .real_out (o_cbfp1_re),
        .imag_out (o_cbfp1_im),
        .index_out(cbfp_index),
        .valid_out(valid_out_cbfp1)
    );

    // assign dout_i = o_bf11_re;
    // assign dout_q = o_bf11_im;
    // assign valid_out = valid_out_bf11;

    // assign dout_i = o_bf12_re;
    // assign dout_q = o_bf12_im;
    // assign valid_out = valid_out_bf12;

    assign dout_i = o_cbfp1_re;
    assign dout_q = o_cbfp1_im;
    assign valid_out = valid_out_cbfp1;



endmodule
