`timescale 1ps / 1ps

module test_bfly10 #(
    parameter N       = 16,  // 데이터 개수
    parameter IN_BIT  = 9,   // 입력 비트수
    parameter OUT_BIT = 10   // 출력 비트수 (미사용 중)
) (
    input clk,
    input rstn,

    input flag_in,
    input signed [IN_BIT-1:0] din1_i[0:N-1],
    input signed [IN_BIT-1:0] din1_q[0:N-1],
    input signed [IN_BIT-1:0] din2_i[0:N-1],
    input signed [IN_BIT-1:0] din2_q[0:N-1],

    output logic signed [OUT_BIT-1:0] dout1_i[0:N-1],
    output logic signed [OUT_BIT-1:0] dout1_q[0:N-1],
    output logic signed [OUT_BIT-1:0] dout2_i[0:N-1],
    output logic signed [OUT_BIT-1:0] dout2_q[0:N-1]
);

    integer i;
    logic flag;
    logic signed [IN_BIT-1:0] din1_i_reg[0:N-1], din1_q_reg[0:N-1];

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            flag <= 0;
        end
        else begin
            if (flag_in) begin
                flag <= ~flag;
            end
            else begin
                flag <= 0;
            end
        end
    end

    always @(*) begin
        if (flag) begin
            // twiddle factor = 1 (즉, W=1)
            for (i = 0; i < N; i = i + 1) begin
                dout1_i[i] = din1_i[i] + din2_i[i];
                dout1_q[i] = din1_q[i] + din2_q[i];
                dout2_i[i] = din1_i[i] - din2_i[i];
                dout2_q[i] = din1_q[i] - din2_q[i];
            end
        end else begin
            // twiddle factor = -j (즉, W=-j)
            // (a + bj) * (-j) = b - aj
            for (i = 0; i < N; i = i + 1) begin
                dout1_i[i] = din1_i[i] + din2_i[i];  // 그대로 합
                dout1_q[i] = din1_q[i] + din2_q[i];
                // (a - b) * (-j) = (b - a*j)
                dout2_i[i] = din1_q[i] - din2_q[i];  // b part
                dout2_q[i] = (-din1_i[i] + din2_i[i]);  // -a part
            end
        end
    end


endmodule
