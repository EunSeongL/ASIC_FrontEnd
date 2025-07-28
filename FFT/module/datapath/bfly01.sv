`timescale 1ns/1ps

module bfly01 #(
    parameter INT   = 4,
    parameter FLT   = 6,
    parameter WIDTH = INT + FLT   // 10
)(
    input  clk,
    input  rstn,
    input  bfly_en,

    input  signed [WIDTH-1:0] din1_i[0:15],  
    input  signed [WIDTH-1:0] din1_q[0:15],  
    input  signed [WIDTH-1:0] din2_i[0:15],  
    input  signed [WIDTH-1:0] din2_q[0:15],  

    output logic signed [WIDTH:0] dout1_i[0:15],  // add  
    output logic signed [WIDTH:0] dout1_q[0:15],   
    output logic signed [WIDTH:0] dout2_i[0:15],  // sub
    output logic signed [WIDTH:0] dout2_q[0:15]
);

    int i;
    logic [4:0] cnt, cnt1;
    logic [2:0] tw_idx;   // twiddle index

    // 중간 add/sub 결과
    logic signed [WIDTH:0] out1_i[0:15], out1_q[0:15];
    logic signed [WIDTH:0] out2_i[0:15], out2_q[0:15];
    logic signed [WIDTH+10:0] mul1_re, mul1_im, mul2_re, mul2_im;

    // Twiddle factors
    logic signed [9:0] tw_re[0:3];
    logic signed [9:0] tw_im[0:3];
    logic signed [9:0] tw_re1[0:3];
    logic signed [9:0] tw_im1[0:3];

    // 카운터
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            cnt <= 0;
        else if (bfly_en)
            cnt <= cnt + 1;
        else
            cnt <= 0;
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            cnt1 <= 0;
        else
            cnt1 <= cnt;
    end

    assign tw_idx = cnt1[2:1];

    always_comb begin
        for (int k = 0; k < 4; k++) begin
            tw_re[k]  = 0;
            tw_im[k]  = 0;
            tw_re1[k] = 0;
            tw_im1[k] = 0;
        end
        case (tw_idx)
            2'd0: begin 
                tw_re[0]=256; tw_im[0]=0; 
                tw_re1[0]=256; tw_im1[0]=0;
            end
            2'd1: begin 
                tw_re[1]=256; tw_im[1]=0; 
                tw_re1[1]=181; tw_im1[1]=-181;
            end
            2'd2: begin 
                tw_re[2]=256; tw_im[2]=0; 
                tw_re1[2]=256; tw_im1[2]=0;
            end
            2'd3: begin 
                tw_re[3]=0; tw_im[3]=-256; 
                tw_re1[3]=-181; tw_im1[3]=-181;
            end
        endcase
    end

    // 버터플라이 add/sub
    bfly_add #(
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

    // Twiddle 곱
    always @(*) begin
        if(cnt) begin
            for (i = 0; i < 16; i = i + 1) begin
                mul1_re = (out1_i[i]) * tw_re[tw_idx] - (out1_q[i]) * tw_im[tw_idx];
                mul1_im = (out1_i[i]) * tw_im[tw_idx] + (out1_q[i]) * tw_re[tw_idx];
                dout1_i[i] = mul1_re >>> 8;
                dout1_q[i] = mul1_im >>> 8;

                mul2_re = (out2_i[i]) * tw_re1[tw_idx] - (out2_q[i]) * tw_im1[tw_idx];
                mul2_im = (out2_i[i]) * tw_im1[tw_idx] + (out2_q[i]) * tw_re1[tw_idx];
                dout2_i[i] = mul2_re >>> 8;
                dout2_q[i] = mul2_im >>> 8;
            end
        end
    end

endmodule
