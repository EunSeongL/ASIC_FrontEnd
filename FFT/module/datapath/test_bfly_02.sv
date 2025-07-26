`timescale 1ns / 1ps

module test_bfly_02 #(
    parameter N          = 16,  // 데이터 개수
    parameter IN_BIT     = 14,   // 입력 비트수
    parameter OUT_BIT    = 23,  // 출력 비트수 (미사용 중)
    parameter HALF       = 4,   // 들어오는 묶음중 절반  
    parameter TOTAL_HALF = 64,
    parameter BLOCK_SIZE = 128
) (
    input clk,
    input rstn,

    input      bfly_en,
    input [$clog2(HALF*2):0] fac_cnt,

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
    logic signed [9-1:0] fac_02_real_low  [0:(N)-1]; //for + 2.7format
    logic signed [9-1:0] fac_02_real_high [0:(N)-1]; //for - 2.7format
    logic signed [9-1:0] fac_02_real_low_reg  [0:(N)-1]; //1clk delay
    logic signed [9-1:0] fac_02_real_high_reg  [0:(N)-1]; //1clk delay

    logic signed [9-1:0] fac_02_imag_low  [0:(N)-1]; //for + 2.7format
    logic signed [9-1:0] fac_02_imag_high [0:(N)-1]; //for - 2.7format
    logic signed [9-1:0] fac_02_imag_low_reg  [0:(N)-1]; //1clk delay
    logic signed [9-1:0] fac_02_imag_high_reg  [0:(N)-1]; //1clk delay

    logic [$clog2(HALF):0] inner_blk_cnt; //128범위에서 움직이는

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i< N ; i=i+1 ) begin
                fac_02_real_low_reg[i]  <= 0;
                fac_02_real_high_reg[i] <= 0;
                fac_02_imag_low_reg[i]  <= 0;
                fac_02_imag_high_reg[i] <= 0;    
            end
        end
        else begin
            fac_02_real_low_reg   <= fac_02_real_low;
            fac_02_real_high_reg  <= fac_02_real_high;
            fac_02_imag_low_reg   <= fac_02_imag_low;
            fac_02_imag_high_reg  <= fac_02_imag_high;    
        end
    end

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            inner_blk_cnt <= 1;
        end
        else begin
            if (bfly_en) begin
                inner_blk_cnt <= inner_blk_cnt + 1;
            end
            else begin
                inner_blk_cnt <= 1;
            end
        end
    end

    always @(*) begin
        for (i = 0; i < N; i = i + 1) begin
            dout1_i[i] = (din1_i[i] + din2_i[i])*(fac_02_real_low_reg[i])-(din1_q[i] + din2_q[i])*(fac_02_imag_low_reg[i]);
            dout1_q[i] = (din1_i[i] + din2_i[i])*(fac_02_imag_low_reg[i])+(din1_q[i] + din2_q[i])*(fac_02_real_low_reg[i]);
            
            dout2_i[i] = (din1_i[i] - din2_i[i])*(fac_02_real_high_reg[i])-(din1_q[i] - din2_q[i])*(fac_02_imag_high_reg[i]);
            dout2_q[i] = (din1_i[i] - din2_i[i])*(fac_02_imag_high_reg[i])+(din1_q[i] - din2_q[i])*(fac_02_real_high_reg[i]);
        end
    end

    genvar k;
    generate //16개씩 뽑기
        for (k = 0; k < N; k = k + 1 ) begin
            step02_twf #(
                .INDEX_WIDTH(512),
                .BIT_WIDTH(9) //2.7format
            ) U_STEP02_FAC_LOW (
                .index(9'(BLOCK_SIZE*fac_cnt+((inner_blk_cnt-1)*N)+k)),
                .twf_out(fac_02_real_low[k])
            );

            step02_twf #(
                .INDEX_WIDTH(512),
                .BIT_WIDTH(9) //2.7format
            ) U_STEP02_FAC_HIGH (
                .index(9'(BLOCK_SIZE*fac_cnt+((inner_blk_cnt-1)*N)+k+TOTAL_HALF)),
                .twf_out(fac_02_real_high[k])
            );

            twf_02_imag #(
                .INDEX_WIDTH(512),
                .BIT_WIDTH(9) //2.7format
            ) U_TWF_02_IMAG_HIGH (
                .index(9'(BLOCK_SIZE*fac_cnt+((inner_blk_cnt-1)*N)+k)),
                .twf_out(fac_02_imag_low[k])
            );

            twf_02_imag #(
                .INDEX_WIDTH(512),
                .BIT_WIDTH(9) //2.7format
            ) U_TWF_02_IMAG_LOW (
                .index(9'(BLOCK_SIZE*fac_cnt+((inner_blk_cnt-1)*N)+k+TOTAL_HALF)),
                .twf_out(fac_02_imag_high[k])
            );

        end
    endgenerate    

endmodule
