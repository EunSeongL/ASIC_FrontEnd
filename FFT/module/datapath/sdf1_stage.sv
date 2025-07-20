module stage1# (
    parameter SIGN_BIT = 1,
    parameter INT_BIT = 3,
    parameter FR_BIT = 6
)(
    input clk,     
    input rstn,
    input start,
    input din_vld,
    input [DW-1:0] din_re,
    input [DW-1:0] din_im,
    output [DW-1:0] dout1_re,
    output [DW-1:0] dout1_im,
    output [DW-1:0] dout2_re,
    output [DW-1:0] dout2_im,
    output dout_vld,
    output stop
);


localparam DW = SIGN_BIT + INT_BIT + FR_BIT;

endmodule