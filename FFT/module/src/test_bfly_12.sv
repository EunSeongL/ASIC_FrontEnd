`timescale 1ns / 1ps

module test_bfly_12 #(
    parameter N          = 8,  // 데이터 개수
    parameter IN_BIT     = 13,   // 입력 비트수
    parameter OUT_BIT    = 25,  // 출력 비트수 (미사용 중)
    parameter HALF       = 4,   // 들어오는 묶음중 절반  
    parameter TOTAL_HALF = 64,
    parameter BLOCK_SIZE = 128
) (
    input clk,
    input rstn,

    input      bfly_en,

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
    logic signed [8:0] fac_02_real_low  [0:N-1]; //for + 2.7format
    logic signed [8:0] fac_02_real_high [0:N-1]; //for - 2.7format

    logic signed [8:0] fac_02_imag_low  [0:N-1]; //for + 2.7format
    logic signed [8:0] fac_02_imag_high [0:N-1]; //for - 2.7format

    logic signed [IN_BIT:0] bfly12_low_re[0:N-1], bfly12_low_im[0:N-1], bfly12_high_re[0:N-1], bfly12_high_im[0:N-1];


    logic [$clog2(512):0] inner_blk_cnt; //128범위에서 움직이는

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            inner_blk_cnt <= 0;
        end
        else begin
            if (bfly_en) begin
                inner_blk_cnt <= inner_blk_cnt + 1;
            end
            else begin
                inner_blk_cnt <= 0;
            end
        end
    end

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < N ; i = i + 1 ) begin
                bfly12_low_re[i]  <= 0;
                bfly12_low_im[i]  <= 0;
                bfly12_high_re[i] <= 0;
                bfly12_high_im[i] <= 0;
            end
        end
        else begin
            for (i = 0; i < N ; i = i + 1 ) begin
                bfly12_low_re[i]  <= din1_i[i] + din2_i[i];
                bfly12_low_im[i]  <= din1_q[i] + din2_q[i];
                bfly12_high_re[i] <= din1_i[i] - din2_i[i];
                bfly12_high_im[i] <= din1_q[i] - din2_q[i];
            end    
        end
    end

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < N ; i = i + 1 ) begin
                dout1_i[i] <= 0;
                dout1_q[i] <= 0;
                dout2_i[i] <= 0;
                dout2_q[i] <= 0;
            end
        end
        else begin
           for (i = 0; i < N; i = i + 1) begin
                dout1_i[i] <= (bfly12_low_re[i])*(fac_02_real_low[i])-(bfly12_low_im[i])*(fac_02_imag_low[i]);
                dout1_q[i] <= (bfly12_low_re[i])*(fac_02_imag_low[i])+(bfly12_low_im[i])*(fac_02_real_low[i]);

                dout2_i[i] <= (bfly12_high_re[i])*(fac_02_real_high[i])-(bfly12_high_im[i])*(fac_02_imag_high[i]);
                dout2_q[i] <= (bfly12_high_re[i])*(fac_02_imag_high[i])+(bfly12_high_im[i])*(fac_02_real_high[i]);
            end 
        end
    end

    logic [8:0] twf_index_low [0:N-1];
    logic [8:0] twf_index_high [0:N-1];
    
    always_comb begin
        for (int ii = 0; ii < N; ii++) begin
            twf_index_low[ii]  = ii + inner_blk_cnt*16;
            twf_index_high[ii] = ii + inner_blk_cnt*16 + N;
        end
    end
    
    genvar k;
    generate
        for (k = 0; k < N; k++) begin
            twf_12_real #(.INDEX_WIDTH(512), .BIT_WIDTH(9))
            U_STEP02_FAC_LOW (
                .index(twf_index_low[k]),
                .twf_out(fac_02_real_low[k])
            );
    
            twf_12_real #(.INDEX_WIDTH(512), .BIT_WIDTH(9))
            U_STEP02_FAC_HIGH (
                .index(twf_index_high[k]),
                .twf_out(fac_02_real_high[k])
            );
    
            twf_12_imag #(.INDEX_WIDTH(512), .BIT_WIDTH(9))
            U_TWF_02_IMAG_LOW (
                .index(twf_index_low[k]),
                .twf_out(fac_02_imag_low[k])
            );
    
            twf_12_imag #(.INDEX_WIDTH(512), .BIT_WIDTH(9))
            U_TWF_02_IMAG_HIGH (
                .index(twf_index_high[k]),
                .twf_out(fac_02_imag_high[k])
            );
        end
    endgenerate
   

endmodule
