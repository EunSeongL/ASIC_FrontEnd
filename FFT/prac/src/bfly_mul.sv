module bfly_mul #(
    parameter BFLY = 10,           // <4.6> format
    parameter TW = 9,              // <2.7> format
    parameter WIDTH = BFLY + TW,    
    parameter N = 16
)(
    input  clk,
    input  rstn,
    input  signed [BFLY-1:0] bfly_re [N-1:0],
    input  signed [BFLY-1:0] bfly_im [N-1:0],
    input  signed [TW-1:0]   tw_re,
    input  signed [TW-1:0]   tw_im,
    output logic signed [WIDTH-1:0] out_re [N-1:0],
    output logic signed [WIDTH-1:0] out_im [N-1:0]
);

    integer i;
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i < N; i = i + 1) begin
                out_re[i] <= '0;
                out_im[i] <= '0;
            end
        end else begin
            for (i = 0; i < N; i = i + 1) begin
                out_re[i] <= (bfly_re[i] * tw_re) - (bfly_im[i] * tw_im);
                out_im[i] <= (bfly_im[i] * tw_re) + (bfly_re[i] * tw_im);
            end
        end
    end

/*
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : bfly_mul
            assign out_re[i] = (bfly_re[i] * tw_re) - (bfly_im[i] * tw_im);
            assign out_im[i] = (bfly_im[i] * tw_re) + (bfly_re[i] * tw_im);
        end
    endgenerate
*/
endmodule
