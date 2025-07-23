`timescale 1ns/1ps

module bfly #(                          // <3.6> format
    parameter SIG = 1,
    parameter INT = 2,
    parameter FLT = 6,
    parameter WIDTH = SIG + INT + FLT   // 9
) (
    input clk,
    input rstn,

    input bfly_en,
    input signed [WIDTH-1:0] din1_i[0:15],  // 
    input signed [WIDTH-1:0] din1_q[0:15],  // 
    input signed [WIDTH-1:0] din2_i[0:15],  // shift reg
    input signed [WIDTH-1:0] din2_q[0:15],  // shift reg

    output logic signed [WIDTH:0] dout1_i[0:15],  // add  
    output logic signed [WIDTH:0] dout1_q[0:15],   
    output logic signed [WIDTH:0] dout2_i[0:15],  // sub
    output logic signed [WIDTH:0] dout2_q[0:15]
);
    parameter TW = 9; // <2.7>

    logic [1:0] tw_addr;
    logic [8:0] cnt;
    logic signed [8:0] tw_re, tw_im;

    logic signed [WIDTH:0] out1_i[0:15], out1_q[0:15];
    logic signed [WIDTH:0] out2_i[0:15], out2_q[0:15];

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            cnt <= 0;
        else if (bfly_en)
            cnt <= cnt + 1;
        else
            cnt <= 0;
    end

    // tw_addr 0~3 cnt 상위 두 비트로 판단
    always@(*) begin
        if (cnt < 512) begin
            tw_addr = cnt[8:7];
        end
        else begin
            tw_addr = 0;
        end
    end

    mem_tw4 u_mem_tw4 (
        .addr       (tw_addr),
        .dout_re    (tw_re),
        .dout_im    (tw_im)
    );

    bfly_add #(
        .SIG(SIG),
        .INT(INT),
        .FLT(FLT),
        .WIDTH(WIDTH)            // <4.6> format
    ) u_bfly_add (
        .clk        (clk),
        .rstn       (rstn),
        .din1_re    (din1_i),      // 9 width       
        .din1_im    (din1_q),      // 9 width
        .din2_re    (din2_i),      // 9 width
        .din2_im    (din2_q),      // 9 width
        .dout1_re   (out1_i),      // 10 width (실수 덧셈) 
        .dout1_im   (out1_q),      // 10 width (허수 덧셈)
        .dout2_re   (out2_i),      // 10 width (실수 뺄셈)
        .dout2_im   (out2_q)       // 10 width (허수 뺄셈)
    );

    bfly_mul #(                    // upper 0~256 twiddle 1,1
        .BFLY (WIDTH+1),
        .TW   (TW),
        .WIDTH(WIDTH+1),           // <4.6> format
        .N    (16)
    ) u_bfly_mul1 (
        .clk(clk),
        .rstn(rstn),
        .bfly_re(out1_i),
        .bfly_im(out1_q),
        .tw_re(tw_re),
        .tw_im(tw_im),
        .out_re(dout1_i),
        .out_im(dout1_q)
    );  

    bfly_mul #(                    // lower 257~511 twiddle 1,-j
        .BFLY (WIDTH+1),
        .TW   (TW),
        .WIDTH(WIDTH+1),           // <4.6> format
        .N    (16)
    ) bfly_mul2 (
        .clk(clk),
        .rstn(rstn),
        .bfly_re(out2_i),
        .bfly_im(out2_q),
        .tw_re(tw_re),
        .tw_im(tw_im),
        .out_re(dout2_i),
        .out_im(dout2_q)
    );

   

endmodule