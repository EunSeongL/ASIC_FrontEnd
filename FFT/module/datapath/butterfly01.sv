`timescale 1ns / 1ps

module butterfly01 #(
    parameter IN_WIDTH  = 10,          //input bit width
    parameter OUT_WIDTH = 11,         //output bit width
    parameter NUM       = 16,         //number of line
    parameter DATA      = 512,        //number of data
    parameter COUNT     = DATA / NUM  //input data count
) (
    input clk,
    input rstn,

    input  signed [IN_WIDTH-1:0]  din_i    [0:NUM-1],  //Re value
    input  signed [IN_WIDTH-1:0]  din_q    [0:NUM-1],  //Im value
    input                         valid_in,           //valid input

    output signed [OUT_WIDTH-1:0] do1_re_bfly01   [0:NUM-1],  //plus Re out
    output signed [OUT_WIDTH-1:0] do1_im_bfly01   [0:NUM-1],  //plus Im out
    output signed [OUT_WIDTH-1:0] do2_re_bfly01   [0:NUM-1],  //minus Re out
    output signed [OUT_WIDTH-1:0] do2_im_bfly01   [0:NUM-1],  //minus Im out
    output                        valid_out            //valid output
);

    logic [$clog2(COUNT):0] count;  //0~32
    logic shift_reg_cntl_write;
    logic shift_reg_cntl_read;
    logic signed [IN_WIDTH-1:0] shift_reg_val_re[0:NUM-1];
    logic signed [IN_WIDTH-1:0] shift_reg_val_im[0:NUM-1];
    logic bfly_en;  //0: 대기, 1: bfly계산

    assign shift_reg_cntl_write = (valid_in && (count<=COUNT/2)) ? 1 : 0;
    assign shift_reg_cntl_read = (count >= (COUNT/2)) ? 1 : 0;
    assign bfly_en = (count >= (COUNT / 2)) ? 1 : 0;
    assign valid_out = (count > (COUNT / 2)) ? 1 : 0;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count <= 0;
        end else begin
            if (count >= (COUNT)) begin
                count <= 0;
            end else if (valid_in || (count > 0)) begin
                count <= count + 1;
            end
        end
    end

    logic signed [IN_WIDTH-1:0] low_reg_i [0:NUM-1];
    logic signed [IN_WIDTH-1:0] low_reg_q [0:NUM-1];
    integer i;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < NUM ; i=i+1) begin
                low_reg_i[i] <= 0;
                low_reg_q[i] <= 0;    
            end
        end
        else begin
            for (i = 0; i < NUM ; i=i+1) begin
                low_reg_i[i] <= din_i[i];
                low_reg_q[i] <= din_q[i];    
            end
            
        end
    end

    shift_reg #(
        .WIDTH(10),
        .DELAY_LENGTH(8)
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

    bfly_add #(
        .INT(4),
        .FLT(6)
    ) u_bfly_add (
        .din1_re(din_i),
        .din1_im(din_q),
        .din2_re(shift_reg_val_re),
        .din2_im(shift_reg_val_im),
        .dout1_re(do1_re_bfly01),
        .dout1_im(do1_im_bfly01),
        .dout2_re(do2_re_bfly01),
        .dout2_im(do2_im_bfly01)
    );

endmodule
