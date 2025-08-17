`timescale 1ns / 1ps

module butterfly20 #(
    parameter IN_WIDTH  = 12,  //input bit width 12bit
    parameter OUT_WIDTH = 13,  //output bit width 13bit
    parameter NUM       = 16   //number of line
) (
    input clk,
    input rstn,

    input signed [IN_WIDTH-1:0] din_i   [0:NUM-1],  //Re value
    input signed [IN_WIDTH-1:0] din_q   [0:NUM-1],  //Im value
    input                       valid_in,           //valid input

    output logic signed [OUT_WIDTH-1:0] do_re    [0:NUM-1],  //Re out
    output logic signed [OUT_WIDTH-1:0] do_im    [0:NUM-1],  //Im out
    output logic                        valid_out            //valid output
);

    integer i;

    //8개 low index
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < NUM / 2; i = i + 1) begin
                do_re[i] <= 0;
                do_im[i] <= 0;
            end
        end else begin
            do_re[0] <= din_i[0] + din_i[4];
            do_im[0] <= din_q[0] + din_q[4];

            do_re[1] <= din_i[1] + din_i[5];
            do_im[1] <= din_q[1] + din_q[5];

            do_re[2] <= din_i[2] + din_i[6];
            do_im[2] <= din_q[2] + din_q[6];

            do_re[3] <= din_i[3] + din_i[7];
            do_im[3] <= din_q[3] + din_q[7];

            do_re[4] <= din_i[0] - din_i[4];
            do_im[4] <= din_q[0] - din_q[4];

            do_re[5] <= din_i[1] - din_i[5];
            do_im[5] <= din_q[1] - din_q[5];

            //(a+bj)(-j) = -aj+b
            do_re[6] <= din_q[2] - din_q[6];
            do_im[6] <= -din_i[2] + din_i[6];

            do_re[7] <= din_q[3] - din_q[7];
            do_im[7] <= -din_i[3] + din_i[7];
        end
    end

    //8개 high index
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = NUM / 2; i < NUM; i = i + 1) begin
                do_re[i] <= 0;
                do_im[i] <= 0;
            end
        end else begin
            do_re[8]  <= din_i[8] + din_i[12];
            do_im[8]  <= din_q[8] + din_q[12];

            do_re[9]  <= din_i[9] + din_i[13];
            do_im[9]  <= din_q[9] + din_q[13];

            do_re[10] <= din_i[10] + din_i[14];
            do_im[10] <= din_q[10] + din_q[14];

            do_re[11] <= din_i[11] + din_i[15];
            do_im[11] <= din_q[11] + din_q[15];

            do_re[12] <= din_i[8] - din_i[12];
            do_im[12] <= din_q[8] - din_q[12];

            do_re[13] <= din_i[9] - din_i[13];
            do_im[13] <= din_q[9] - din_q[13];

            //(a+bj)(-j) = -aj+b
            do_re[14] <= din_q[10] - din_q[14];
            do_im[14] <= -din_i[10] + din_i[14];

            do_re[15] <= din_q[11] - din_q[15];
            do_im[15] <= -din_i[11] + din_i[15];
        end
    end

    //valid_out
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            valid_out <= 0;
        end else begin
            valid_out <= valid_in;
        end
    end


endmodule
