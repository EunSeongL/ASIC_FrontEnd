`timescale 1ns / 1ps

module butterfly #(
    parameter IN_WIDTH  = 9,          //input bit width
    parameter OUT_WIDTH = 10,         //output bit width
    parameter NUM       = 16,         //number of line
    parameter DATA      = 512,        //number of data
    parameter COUNT     = DATA / NUM  //input data count
) (
    input clk,
    input rstn,

    input signed [IN_WIDTH-1:0] din_i   [0:NUM-1],  //Re value
    input signed [IN_WIDTH-1:0] din_q   [0:NUM-1],  //Im value
    input                       valid_in,           //valid input

    output logic signed [OUT_WIDTH-1:0] do1_re   [0:NUM-1],  //plus Re out
    output logic signed [OUT_WIDTH-1:0] do1_im   [0:NUM-1],  //plus Im out
    output                        valid_out            //valid output
);

    logic [$clog2(COUNT)-1:0] count;  //0~32
    logic signed [IN_WIDTH-1:0] shift_reg_val_re[0:NUM-1];
    logic signed [IN_WIDTH-1:0] shift_reg_val_im[0:NUM-1];
    logic bfly_en;  //0: 대기, 1: bfly계산
    integer i;

    logic signed [OUT_WIDTH-1:0] o_bfly_low_re[0:NUM-1], o_bfly_low_im[0:NUM-1], o_bfly_high_re[0:NUM-1], o_bfly_high_im[0:NUM-1];
    logic signed [OUT_WIDTH-1:0] reg_high_re[0:NUM-1], reg_high_im[0:NUM-1]; 

    assign bfly_en = (count >= (COUNT / 2)) ? 1 : 0;
    //assign bfly_en = (count > 16) ? 1 : 0;

    // always @(posedge clk or negedge rstn) begin
    //     if (!rstn) begin
    //         count <= 0;
    //     end else begin
    //         if (count >= (COUNT)) begin
    //             count <= 0;
    //         end else if (valid_in || (count > 0)) begin
    //             count <= count + 1;
    //         end
    //     end
    // end

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

    shift_reg #(
        .WIDTH(9),
        .DELAY_LENGTH(NUM-1)
    ) U_SHIFT_REG_256 (
        .clk (clk),
        .rstn(rstn),

        .write(1'd1),
        .read (1'd1),

        .data_in_real(din_i),
        .data_in_imag(din_q),

        .data_out_real(shift_reg_val_re),
        .data_out_imag(shift_reg_val_im)
    );

    test_bfly #(
        .N(16),
        .IN_BIT(9),
        .OUT_BIT(10)
    ) U_TEST_BFLY (
        .clk(clk),
        .rstn(rstn),

        .bfly_en(bfly_en),
        .din1_i(shift_reg_val_re),
        .din1_q(shift_reg_val_im),
        .din2_i(din_i),
        .din2_q(din_q),
        

        .dout1_i(o_bfly_low_re),
        .dout1_q(o_bfly_low_im),
        .dout2_i(o_bfly_high_re),
        .dout2_q(o_bfly_high_im)
    );

    shift_reg #(
        .WIDTH(10),
        .DELAY_LENGTH(NUM-1)
    ) U_SHIFT_REG_HIGH (
        .clk (clk),
        .rstn(rstn),

        .write(1'd1),
        .read (1'd1),

        .data_in_real(o_bfly_high_re),
        .data_in_imag(o_bfly_high_im),

        .data_out_real(reg_high_re),
        .data_out_imag(reg_high_im)
    );
    // logic bfly_en_reg;

    // always @(posedge clk, negedge rstn) begin
    //     if (~rstn) begin
    //         bfly_en_reg <= 0;
    //     end
    //     else begin
    //         bfly_en_reg <= bfly_en;
    //     end
    // end

    logic signed [OUT_WIDTH-1:0] muxed_re[0:NUM-1], muxed_im[0:NUM-1];

    assign muxed_re = bfly_en ? o_bfly_low_re : reg_high_re;
    assign muxed_im = bfly_en ? o_bfly_low_im : reg_high_im;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < NUM ; i = i + 1 ) begin
                do1_re[i] <= 0;
                do1_im[i] <= 0;
            end
        end
        else begin
            do1_re <= muxed_re;
            do1_im <= muxed_im;
        end
    end

    logic [17:0] valid_in_reg;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            valid_in_reg <= 0;
        end
        else begin
            valid_in_reg[17:1] <= valid_in_reg[16:0];
            valid_in_reg[0] <= valid_in;
        end
    end

    assign valid_out = valid_in_reg[16];

endmodule
