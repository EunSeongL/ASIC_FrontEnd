module cmul #(
    parameter BFLY = 10;
    parameter TW = 9;
)(
    input signed [BFLY-1:0] bfly_re,
    input signed [BFLY-1:0] bfly_im,
    input signed [TW-1:0] tw_re,
    input signed [TW-1:0] tw_im,
    output signed [WIDTH-1:0] out_re,
    output signed [WIDTH-1:0] out_im
);

    localparam WIDTH = BFLY + TW;

    assign out_re = (bfly_re * tw_re) - (bfly_im * tw_im);
    assign out_im = (bfly_im * tw_re) + (bfly_re * tw_im);

endmodule