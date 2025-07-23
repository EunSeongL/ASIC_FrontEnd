`timescale 1ns/1ps

module bfly #(
    parameter SIG = 1,
    parameter INT = 2,
    parameter FLT = 6,
    parameter WIDTH = SIG + INT + FLT
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
    logic signed [9:0] tw_re, tw_im;

    logic signed [WIDTH:0] out1_i[0:15], out1_q[0:15];
    logic signed [WIDTH:0] out2_i[0:15], out2_q[0:15];

    logic [8:0] cnt;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            cnt <= 0;
        else if (bfly_en)
            cnt <= cnt + 1;
        else
            cnt <= 0;
    end

    always @(*) begin
        if(cnt < 128) begin
            tw_addr = 0;
        end
        else if(cnt < 256) begin
            tw_addr = 1;
        end
        else if(cnt < 384) begin
            tw_addr = 2;
        end
        else if(cnt < 512) begin
            tw_addr = 3;
        end
        else begin
            tw_addr = 0;
        end
    end

    bfly2 #(
        .SIG(SIG),
        .INT(INT),
        .FLT(FLT),
        .WIDTH(WIDTH+1)
    ) u_bfly2 (
        .din1_re(din1_i),
        .din1_im(din1_q),
        .din2_re(din2_i),
        .din2_im(din2_q),
        .dout1_re(out1_i),      // 실수 덧셈 
        .dout1_im(out1_q),      // 허수 덧셈
        .dout2_re(out2_i),      // 실수 뺄셈
        .dout2_im(out2_q)       // 허수 뺄셈
    );

    mem_tw4 u_mem_tw4 (
        .addr(tw_addr),
        .dout_re(tw_re),
        .dout_im(tw_im)
    );

    cmul #(
        .BFLY (WIDTH+1),    
        .TW   (TW),       
        .WIDTH(WIDTH+1)   
    ) u_cmul1 (
        .bfly_re(out1_i),
        .bfly_im(out1_q),
        .tw_re(tw_re),
        .tw_im(tw_im),
        .out_re(dout1_re),
        .out_im(dout1_im)
    );

    cmul #(
        .BFLY (WIDTH+1),
        .TW   (TW),
        .WIDTH(WIDTH+1)
    ) u_cmul2 (
        .bfly_re(out2_i),
        .bfly_im(out2_q),
        .tw_re(tw_re),
        .tw_im(tw_im),
        .out_re(dout2_re),
        .out_im(dout2_im)
    );
   

endmodule