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

    input signed [IN_WIDTH-1:0] din_i   [NUM-1:0],  //Re value
    input signed [IN_WIDTH-1:0] din_q   [NUM-1:0],  //Im value
    input                       valid_in,           //valid input

    output signed [OUT_WIDTH-1:0] do1_re,    //plus Re out
    output signed [OUT_WIDTH-1:0] do1_im,    //plus Im out
    output signed [OUT_WIDTH-1:0] do2_re,    //minus Re out
    output signed [OUT_WIDTH-1:0] do2_im,    //minus Im out
    output                        valid_out  //valid output
);

    logic [$clog2(COUNT)-1:0] count;  //0~511
    logic [1:0] shift_reg_cntl;  //00: 대기, 01: reg write, 10:reg_read
    logic signed [IN_WIDTH-1:0] shift_reg_val_re, shift_reg_val_im;
    logic bfly_en;  //0: 대기, 1: bfly계산

    assign shift_reg_cntl = (count >= (COUNT/2)) ? 2'b10 : ( valid_in ? 2'b01 : 2'b00);
    assign bfly_en = (count >= (COUNT / 2)) ? 1 : 0;
    assign valid_out = (count >= (COUNT / 2)) ? 1 : 0;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            count <= 0;
        end else begin
            if (valid_in) begin
                if (count >= COUNT) begin
                    count <= 0;
                end else begin
                    count <= count + 1;
                end
            end
        end
    end

    shift_reg #(
        .WIDTH(9),
        .DELAY_LENGTH(256)
    ) U_SHIFT_REG_256 (
        .clk (clk),
        .rstn(rstn),

        .write(shift_reg_cntl[1]),
        .read (shift_reg_cntl[0]),

        .data_in_real(din_i),
        .data_in_imag(din_q),

        .data_out_real(shift_reg_val_re),
        .data_out_imag(shift_reg_val_im)
    );

    bfly #(
        .SIG(1),
        .INT(2),
        .FLT(6)
    ) U_BFLY_SUM_AND_MUL (
        .clk (clk),
        .rstn(rstn),

        .bfly_en(bfly_en),
        .din1_i (din_i),
        .din1_q (din_q),
        .din2_i (shift_reg_val_re),
        .din2_q (shift_reg_val_im),

        .dout1_i(do1_re),
        .dout1_q(do1_im),
        .dout2_i(do2_re),
        .dout2_q(do2_im)
    );

endmodule
