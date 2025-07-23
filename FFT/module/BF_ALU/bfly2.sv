module bfly2 #(
    parameter SIG = 1,      // Sign bit
    parameter INT = 3,      // Integer bits
    parameter FLT = 6,      // Fractional bits
    parameter WIDTH = SIG + INT + FLT  // Total bit-width
)(
    input  signed [WIDTH-1:0] din1_re[15:0],
    input  signed [WIDTH-1:0] din1_im[15:0],
    
    input  signed [WIDTH-1:0] din2_re[15:0],
    input  signed [WIDTH-1:0] din2_im[15:0],
    
    output signed [WIDTH:0]   dout1_re[15:0],
    output signed [WIDTH:0]   dout1_im[15:0],
    
    output signed [WIDTH:0]   dout2_re[15:0],
    output signed [WIDTH:0]   dout2_im[15:0]
);

    genvar i;
generate
    for(i=0; i<16; i=i+1) begin : gen_bfly2
        assign dout1_re[i] = din1_re[i] + din2_re[i];
        assign dout1_im[i] = din1_im[i] + din2_im[i];
        assign dout2_re[i] = din1_re[i] - din2_re[i];
        assign dout2_im[i] = din1_im[i] - din2_im[i];
    end
endgenerate

endmodule
