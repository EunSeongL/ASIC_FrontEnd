module bfly_mul #(
    parameter BFLY = 10,           // <4.6> format
    parameter TW = 9,              // <2.7> format
    parameter WIDTH = BFLY + TW,   // raw multiply width
    parameter SCALE = 7,           // fractional bits in twiddle
    parameter N = 16
)(
    input  clk,
    input  rstn,
    input  signed [BFLY-1:0] bfly_re [N-1:0],
    input  signed [BFLY-1:0] bfly_im [N-1:0],
    input  signed [TW-1:0]   tw_re,
    input  signed [TW-1:0]   tw_im,
    output logic signed [BFLY-1:0] out_re [N-1:0],
    output logic signed [BFLY-1:0] out_im [N-1:0]
);

    integer i;
    logic signed [WIDTH-1:0] mul_ac, mul_bd, mul_ad, mul_bc;
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i = 0; i < N; i = i + 1) begin
                out_re[i] <= '0;
                out_im[i] <= '0;
            end
        end else begin
            for (i = 0; i < N; i = i + 1) begin
                // 복소 곱셈: (a+jb)(c+jd) = (ac - bd) + j(ad + bc)
                mul_ac = bfly_re[i] * tw_re;
                mul_bd = bfly_im[i] * tw_im;
                mul_ad = bfly_re[i] * tw_im;
                mul_bc = bfly_im[i] * tw_re;
                // 스케일 보정 (>>7)
                out_re[i] <= (mul_ac - mul_bd) >>> SCALE;
                out_im[i] <= (mul_ad + mul_bc) >>> SCALE;
            end
        end
    end
endmodule
