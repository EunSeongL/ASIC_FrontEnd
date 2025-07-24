`timescale 1ns/1ps

module bfly #(
    parameter SIG = 1,
    parameter INT = 2,
    parameter FLT = 6,
    parameter WIDTH = SIG + INT + FLT   // 9
)(
    input clk,
    input rstn,
    input bfly_en,

    input signed [WIDTH-1:0] din1_i[0:15],  
    input signed [WIDTH-1:0] din1_q[0:15],  
    input signed [WIDTH-1:0] din2_i[0:15],  
    input signed [WIDTH-1:0] din2_q[0:15],  

    output logic signed [WIDTH:0] dout1_i[0:15],  // add  
    output logic signed [WIDTH:0] dout1_q[0:15],   
    output logic signed [WIDTH:0] dout2_i[0:15],  // sub
    output logic signed [WIDTH:0] dout2_q[0:15]
);

    logic [3:0] cnt;
    logic [3:0] cnt_d;
    logic signed [WIDTH:0] out1_i[0:15], out1_q[0:15];
    logic signed [WIDTH:0] out2_i[0:15], out2_q[0:15];

    // 카운터: 입력 블록 진행
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            cnt_d <= 0;
        else if (bfly_en)
            cnt_d <= cnt + 1;
        else
            cnt_d <= 0;
    end

    always_ff @(posedge clk or negedge rstn) begin : blockName
        if(!rstn) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt_d;
        end
    end

    // 버터플라이 add/sub
    bfly_add #(
        .SIG(SIG),
        .INT(INT),
        .FLT(FLT),
        .WIDTH(WIDTH)
    ) u_bfly_add (
        .din1_re(din1_i),
        .din1_im(din1_q),
        .din2_re(din2_i),
        .din2_im(din2_q),
        .dout1_re(out1_i),
        .dout1_im(out1_q),
        .dout2_re(out2_i),
        .dout2_im(out2_q)
    );

   
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            // upper: twiddle = 1 → 그대로
            dout1_i[i] = out1_i[i];
            dout1_q[i] = out1_q[i];
            // lower: 조건에 따라 1 또는 -j
            if (cnt >= 8 && cnt < 16) begin
                // -j 곱: 실수/허수 swap + 부호 반전
                dout2_i[i] =  out2_q[i];
                dout2_q[i] = -out2_i[i];
            end else begin
                // 그대로 (twiddle = 1)
                dout2_i[i] = out2_i[i];
                dout2_q[i] = out2_q[i];
            end
        end
    end

endmodule
