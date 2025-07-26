`timescale 1ns / 1ps

module butterfly02 #(
    parameter IN_WIDTH  = 14,         //input bit width <7.6>
    parameter OUT_WIDTH = 23,         //output bit width <9.13> + 1////////////////////////////////////////////////////////
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
    output signed [OUT_WIDTH-1:0] do2_re   [0:NUM-1],  //minus Re out
    output signed [OUT_WIDTH-1:0] do2_im   [0:NUM-1],  //minus Im out
    output                        valid_out            //valid output
);

    logic [$clog2(COUNT):0] count;  //
    logic [$clog2(512/64):0] valid_cnt;  /////////////////for fac_cnt
    logic shift_reg_cntl_write;
    logic shift_reg_cntl_read;
    logic signed [IN_WIDTH-1:0] shift_reg_val_re[0:NUM-1];
    logic signed [IN_WIDTH-1:0] shift_reg_val_im[0:NUM-1];
    logic bfly_en;  //0: 대기, 1: bfly계산

    assign shift_reg_cntl_write = (valid_in && (count <= COUNT / 2)) ? 1 : 0;
    assign shift_reg_cntl_read = (count >= (COUNT / 2)) ? 1 : 0;
    assign bfly_en = (count >= (COUNT / 2)) ? 1 : 0;
    assign valid_out = (count > (COUNT / 2)) ? 1 : 0;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            count <= 0;
        end else begin
            if (count >= (COUNT)) begin
                count <= 0;
            end else if (valid_in || (count > 0)) begin
                count <= count + 1;
            end
        end
    end
    /////////////////////////////////////////////////////////////////////
    logic bfly_en_post;
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            valid_cnt <= 0;
        end else begin
            bfly_en_post <= bfly_en;

            if (!bfly_en && bfly_en_post) begin  //valid_out falling edge
                valid_cnt <= valid_cnt + 1;
            end else if (valid_cnt > 7) begin
                valid_cnt <= 0;
            end
        end
    end
    ////////////////////////////////////////////////////////////////////////////
    logic signed [IN_WIDTH-1:0] low_reg_i[0:NUM-1];
    logic signed [IN_WIDTH-1:0] low_reg_q[0:NUM-1];
    integer i;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < NUM; i = i + 1) begin
                low_reg_i[i] <= 0;
                low_reg_q[i] <= 0;
            end
        end else begin
            for (i = 0; i < NUM; i = i + 1) begin
                low_reg_i[i] <= din_i[i];
                low_reg_q[i] <= din_q[i];
            end

        end
    end

    shift_reg #(
        .WIDTH(IN_WIDTH),
        .DELAY_LENGTH(COUNT / 2)
    ) U_SHIFT_REG_64 (
        .clk (clk),
        .rstn(rstn),

        .write(shift_reg_cntl_write),
        .read (shift_reg_cntl_read),

        .data_in_real(din_i),
        .data_in_imag(din_q),

        .data_out_real(shift_reg_val_re),
        .data_out_imag(shift_reg_val_im)
    );

    // bfly #(
    //     .SIG(1),
    //     .INT(2),
    //     .FLT(6)
    // ) U_BFLY_SUM_AND_MUL (
    //     .clk (clk),
    //     .rstn(rstn),

    //     .bfly_en(bfly_en),
    //     .din1_i (din_i),
    //     .din1_q (din_q),
    //     .din2_i (shift_reg_val_re),
    //     .din2_q (shift_reg_val_im),

    //     .dout1_i(do1_re),
    //     .dout1_q(do1_im),
    //     .dout2_i(do2_re),
    //     .dout2_q(do2_im)
    // );

    test_bfly_02 #(
        .N(16),
        .IN_BIT(IN_WIDTH),
        .OUT_BIT(OUT_WIDTH),
        .HALF(COUNT / 2),
        .TOTAL_HALF(64),
        .BLOCK_SIZE(128)
    ) U_TEST_BFLY02 (
        .clk (clk),
        .rstn(rstn),

        .bfly_en(bfly_en),
        .fac_cnt(valid_cnt), ///////////////////////////////////////////

        .din1_i(shift_reg_val_re),
        .din1_q(shift_reg_val_im),
        .din2_i(low_reg_i),
        .din2_q(low_reg_q),


        .dout1_i(do1_re),
        .dout1_q(do1_im),
        .dout2_i(do2_re),
        .dout2_q(do2_im)
    );

endmodule
