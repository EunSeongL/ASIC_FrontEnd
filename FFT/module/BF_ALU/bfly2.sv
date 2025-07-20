module bfly2 #(
    parameter SIG = 1; // Sign bit
    parameter INT = 3; // Integer bits
    parameter FLT = 6; // Fractional bits
)(
    input signed [WIDTH-1:0] din1_re,
    input signed [WIDTH-1:0] din1_im,
    
    input signed [WIDTH-1:0] din2_re,
    input signed [WIDTH-1:0] din2_im,
    
    output signed [WIDTH:0] dout1_re,
    output signed [WIDTH:0] dout1_im,
    
    output signed [WIDTH:0] dout2_re,
    output signed [WIDTH:0] dout2_im
);

    localparam WIDTH = SIG + INT + FLT; 

    assign dout1_re = din1_re + din2_re;
    assign dout1_im = din1_im + din2_im;

    assign dout2_re = din1_re - din2_re;
    assign dout2_im = din1_im - din2_im;

endmodule