`timescale 1ns / 1ps

module butterfly12 #(
    parameter IN_WIDTH  = 15,         //input bit width 15bit
    parameter OUT_WIDTH = 25,         //output bit width 25bit
    parameter NUM       = 16,         //number of line
    parameter DATA      = 16,        //number of data
    parameter COUNT     = DATA / NUM  //input data count
) (
    input clk,
    input rstn,

    input signed [IN_WIDTH-1:0] din_i   [0:NUM-1],  //Re value
    input signed [IN_WIDTH-1:0] din_q   [0:NUM-1],  //Im value
    input                       valid_in,           //valid input

    output logic signed [OUT_WIDTH-1:0] do1_re   [0:NUM-1],  //plus Re out
    output logic signed [OUT_WIDTH-1:0] do1_im   [0:NUM-1],  //plus Im out
    output                              valid_out            //valid output
);

    // logic [$clog2(COUNT)-1:0] count;  
    // logic [$clog2(512/64):0] valid_cnt;  /////////////////for fac_cnt
    logic bfly_en;  //0: 대기, 1: bfly계산
    integer i;

    logic signed [OUT_WIDTH-1:0] bfly_out_re1 [0:7], bfly_out_re2 [0:7];
    logic signed [OUT_WIDTH-1:0] bfly_out_im1 [0:7], bfly_out_im2 [0:7];

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < NUM ; i = i + 1 ) begin
                do1_re[i] <= 0;
                do1_im[i] <= 0;
            end
        end
        else begin
            do1_re <= {bfly_out_re1,bfly_out_re2};
            do1_im <= {bfly_out_im1,bfly_out_im2};
        end
    end

    //assign bfly_en = (count >= (COUNT / 2)) ? 1 : 0;

    logic [2:0] valid_in_buf;

    assign valid_out = valid_in_buf[2];
   
   always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            valid_in_buf <= 0;
            bfly_en <= 0;
        end else begin
            valid_in_buf[2:1] <= valid_in_buf[1:0];
            // bfly_en <= valid_in_buf[0];
            bfly_en <= valid_in;
            valid_in_buf[0] <= valid_in;
        end
    end

    // always @(posedge clk or negedge rstn) begin
    //     if (!rstn) begin
    //         count <= 0;
    //     end else begin
    //         if (valid_in) begin
    //             count <= count + 1;
    //         end else begin
    //             count <= 0;
    //         end
    //     end
    // end
   
    // always @(posedge clk, negedge rstn) begin
    //     if (~rstn) begin
    //         valid_cnt <= 0;
    //     end else begin
    //        if (valid_in) begin
    //             valid_cnt <= valid_cnt + 1;
    //        end
    //        else begin
    //             valid_cnt <= 0;
    //        end
    //     end
    // end

    test_bfly_12 #(
        .N(8),
        .IN_BIT(IN_WIDTH),
        .OUT_BIT(OUT_WIDTH),
        .HALF(COUNT / 2),
        .TOTAL_HALF(1),
        .BLOCK_SIZE(16)
    ) U_TEST_BFLY02 (
        .clk (clk),
        .rstn(rstn),

        .bfly_en(bfly_en),

        .din1_i(din_i[0:7]),
        .din1_q(din_q[0:7]),
        .din2_i(din_i[8:15]),
        .din2_q(din_q[8:15]),


        .dout1_i(bfly_out_re1),
        .dout1_q(bfly_out_im1),
        .dout2_i(bfly_out_re2),
        .dout2_q(bfly_out_im2)
    );

endmodule
