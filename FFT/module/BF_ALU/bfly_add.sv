module bfly_add #(
    parameter SIG = 1,      // Sign bit
    parameter INT = 3,      // Integer bits
    parameter FLT = 6,      // Fractional bits
    parameter WIDTH = SIG + INT + FLT // Total bit-width
)(
    input  clk,
    input  rstn,
    input  signed [WIDTH-1:0] din1_re[15:0],
    input  signed [WIDTH-1:0] din1_im[15:0],
    
    input  signed [WIDTH-1:0] din2_re[15:0],
    input  signed [WIDTH-1:0] din2_im[15:0],
    
    output logic signed [WIDTH:0]   dout1_re[15:0],
    output logic signed [WIDTH:0]   dout1_im[15:0],
    
    output logic signed [WIDTH:0]   dout2_re[15:0],
    output logic signed [WIDTH:0]   dout2_im[15:0]
);

    integer i;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0; i<16; i=i+1) begin
                dout1_re[i] <= 0;
                dout1_im[i] <= 0;
                dout2_re[i] <= 0;
                dout2_im[i] <= 0;
            end
        end else begin
            for (i=0; i<16; i=i+1) begin
                dout1_re[i] <= din1_re[i] + din2_re[i];
                dout1_im[i] <= din1_im[i] + din2_im[i];
                dout2_re[i] <= din1_re[i] - din2_re[i];
                dout2_im[i] <= din1_im[i] - din2_im[i];
            end
        end
    end

endmodule
