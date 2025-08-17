`timescale 1ns / 1ps

module module0 #(
    parameter IN_BIT_WIDTH = 9,  //<3.6> format 
    parameter OUT_BIT_WIDTH = 11,  //11bit
    parameter N = 16,  //묶음
    parameter BF00_BIT = 10,  //<4.6> format
    parameter BF01_BIT = 13,  //<7.6> foramt
    parameter BF02_BIT = 23,  //<9.13>+1
    parameter TOTAL_BLOCK_CNT = 32  //total block cnt 32
) (
    input clk,
    input rstn,

    input                           valid_in,
    input signed [IN_BIT_WIDTH-1:0] din_i   [0:N-1],  //re input
    input signed [IN_BIT_WIDTH-1:0] din_q   [0:N-1],  //im input

    output                             valid_out,
    output  signed [OUT_BIT_WIDTH-1:0] dout_i   [0:N-1],  //re output
    output  signed [OUT_BIT_WIDTH-1:0] dout_q   [0:N-1],  //im output

    output  logic[4:0] cbfp_index[0:N-1]
);

    logic signed [BF00_BIT-1:0] o_bf00_re[0:N-1], o_bf00_im[0:N-1];
    logic valid_out_bf00;

    logic signed [BF01_BIT-1:0] o_bf01_re[0:N-1], o_bf01_im[0:N-1];
    logic valid_out_bf01;

    logic signed [BF02_BIT-1:0] o_bf02_re[0:N-1], o_bf02_im[0:N-1];
    logic valid_out_bf02;

    //logic signed [OUT_BIT_WIDTH-1:0] o_cbfp0_re[0:N-1], o_cbfp0_im[0:N-1];
    //logic valid_out_cbfp0;

    //logic [4:0] o_cbfp_index[0:N-1];



    butterfly #() U_BF00 (
        .clk (clk),
        .rstn(rstn),

        .din_i   (din_i),    //Re value
        .din_q   (din_q),    //Im value
        .valid_in(valid_in), //valid input

        .do1_re   (o_bf00_re),      //plus Re out
        .do1_im   (o_bf00_im),      //plus Im out
        .valid_out(valid_out_bf00)  //valid output
    );

    butterfly01 #() U_BF01 (
        .clk (clk),
        .rstn(rstn),

        .din_i   (o_bf00_re),      //Re value
        .din_q   (o_bf00_im),      //Im value
        .valid_in(valid_out_bf00), //valid input

        .do1_re(o_bf01_re),  //Re out
        .do1_im(o_bf01_im),  //Im out
        .valid_out(valid_out_bf01)
    );


    butterfly02 #() U_BF02 (
        .clk (clk),
        .rstn(rstn),

        .din_i   (o_bf01_re),  //Re value
        .din_q   (o_bf01_im),  //Im value
        .valid_in(valid_out_bf01),  //valid input

        .do1_re   (o_bf02_re),      //plus Re out
        .do1_im   (o_bf02_im),      //plus Im out
        .valid_out(valid_out_bf02)  //valid output
    );

    cbfp_stage0 #() U_CBFP0 (
        .clk(clk),
        .rstn(rstn),
        .real_in(o_bf02_re),
        .imag_in(o_bf02_im),
        .in_valid(valid_out_bf02),

        .real_out (dout_i),
        .imag_out (dout_q),
        .index_out(cbfp_index),
        .valid_out(valid_out)
    );

    // cbfp #() U_CBFP0 (
    //     .clk (clk),
    //     .rstn(rstn),

    //     .din_i(o_bf02_re),
    //     .din_q(o_bf02_im),
    //     .valid_in(valid_out_bf02),

    //     .dout_i(dout_i),
    //     .dout_q(dout_q),
    //     .index_out(cbfp_index),
    //     .valid_out(valid_out)
    // );


    //assign dout_i = o_cbfp0_re;
    //assign dout_q = o_cbfp0_im;
    //assign valid_out = valid_out_cbfp0;
    //assign cbfp_index = o_cbfp_index;






    // shift_reg_with_valid_out #(
    //     .WIDTH(OUT_BIT_WIDTH),
    //     .DELAY_LENGTH(TOTAL_BLOCK_CNT)
    // ) U_SHIFT_REG_OUTPUT (
    //     .clk (clk),
    //     .rstn(rstn),

    //     .write(valid_out_cbfp),  // 16개 묶음 복소수 쓰기
    //     .read(full_cnt),  // 16개 묶음 복소수 읽기

    //     .data_in_real(o_cbfp_re),
    //     .data_in_imag(o_cbfp_im),

    //     .data_out_real(dout_i),
    //     .data_out_imag(dout_q),

    //     .valid_out(valid_out)  //값이 나올때 같이 high
    // );

    // //index buffer
    // logic [4:0] index_out_buffer[0:TOTAL_BLOCK_CNT-1][0:N-1];
    // integer i, j;
    // always @(posedge clk, negedge rstn) begin
    //     if (~rstn) begin
    //         for (i = 0; i < TOTAL_BLOCK_CNT; i = i + 1) begin
    //             for (j = 0; j < N; j = j + 1) begin
    //                 index_out_buffer[i][j] <= 0;
    //             end
    //         end
    //     end else begin
    //         if (full_cnt) begin
    //             cbfp_index <= index_out_buffer[TOTAL_BLOCK_CNT-1];
    //             index_out_buffer[1:TOTAL_BLOCK_CNT-1] <= index_out_buffer[0:TOTAL_BLOCK_CNT-2];
    //             for (i = 0; i < N; i = i + 1) begin
    //                 index_out_buffer[0][i] <= 0;
    //             end
    //         end else if (valid_out_cbfp) begin
    //             index_out_buffer[1:TOTAL_BLOCK_CNT-1] <= index_out_buffer[0:TOTAL_BLOCK_CNT-2];
    //             index_out_buffer[0] <= cbfp_index_out;
    //         end
    //     end
    // end

endmodule
