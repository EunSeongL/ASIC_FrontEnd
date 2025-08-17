`timescale 1ns / 1ps

module bfly_02 #(
    parameter N          = 16,  // 데이터 개수
    parameter IN_BIT     = 14,  // 입력 비트수
    parameter OUT_BIT    = 23   // 출력 비트수 (미사용 중)
) (
    input clk,
    input rstn,

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
    
    always @(*) begin
        for (i = 0; i < N; i = i + 1) begin
            dout1_i[i] <= din1_i[i] + din2_i[i];
            dout1_q[i] <= din1_q[i] + din2_q[i];
            
            dout2_i[i] <= din1_i[i] - din2_i[i];
            dout2_q[i] <= din1_q[i] - din2_q[i];
        end
    end

endmodule
