`timescale 1ns / 1ps

module cbfp_stage0 #(
    parameter int WIDTH     = 23,     // 입력 데이터 비트 수
    parameter int N_BLOCK   = 8,      // 블록 개수
    parameter int BLOCK_LEN = 64,     // 각 블록 당 데이터 수
    parameter int N         = 512     // 전체 샘플 수
)(
    input  logic signed [WIDTH-1:0] pre_bfly02_re [0:N-1],
    input  logic signed [WIDTH-1:0] pre_bfly02_im [0:N-1],
    output logic [5:0] index1_re    [0:N-1],  // shift index
    output logic [5:0] index1_im    [0:N-1],
    output logic signed [WIDTH-1:0] re_bfly02 [0:N-1],
    output logic signed [WIDTH-1:0] im_bfly02 [0:N-1]
);

    // 블록 최소 cnt 저장용
    logic [5:0] cnt1_re [0:N_BLOCK-1];
    logic [5:0] cnt1_im [0:N_BLOCK-1];

    // 임시 저장용
    logic [5:0] tmp1_re, tmp1_im;
    logic [5:0] temp1_re, temp1_im;

    int idx;
    logic [5:0] min_cnt;

    // 각 블록마다 leading zero 탐색
    always_comb begin
        for (int ii = 0; ii < N_BLOCK; ii++) begin
            cnt1_re[ii] = 6'd63;
            cnt1_im[ii] = 6'd63;
            for (int jj = 0; jj < BLOCK_LEN; jj++) begin
                idx = ii * BLOCK_LEN + jj;
                tmp1_re = mag_detect(pre_bfly02_re[idx]);
                tmp1_im = mag_detect(pre_bfly02_im[idx]);

                cnt1_re[ii] = (tmp1_re < cnt1_re[ii]) ? tmp1_re : cnt1_re[ii];
                cnt1_im[ii] = (tmp1_im < cnt1_im[ii]) ? tmp1_im : cnt1_im[ii];
            end
        end

        // 최종적으로 두 개 중 작은 값을 선택
        for (int ii = 0; ii < N_BLOCK; ii++) begin
            min_cnt = (cnt1_re[ii] < cnt1_im[ii]) ? cnt1_re[ii] : cnt1_im[ii];
            cnt1_re[ii] = min_cnt;
            cnt1_im[ii] = min_cnt;
        end

        // 인덱스 매핑
        for (int ii = 0; ii < N_BLOCK; ii++) begin
            for (int jj = 0; jj < BLOCK_LEN; jj++) begin
                idx = ii * BLOCK_LEN + jj;
                index1_re[idx] = cnt1_re[ii];
                index1_im[idx] = cnt1_im[ii];
            end
        end

        // shift 연산 수행 (scale to 12-bit)
        for (int ii = 0; ii < N_BLOCK; ii++) begin
            for (int jj = 0; jj < BLOCK_LEN; jj++) begin
                idx = ii * BLOCK_LEN + jj;
                if (cnt1_re[ii] > 6'd12)
                    re_bfly02[idx] = (pre_bfly02_re[idx] <<< cnt1_re[ii]) >>> 12;
                else
                    re_bfly02[idx] = pre_bfly02_re[idx] >>> (12 - cnt1_re[ii]);

                if (cnt1_im[ii] > 6'd12)
                    im_bfly02[idx] = (pre_bfly02_im[idx] <<< cnt1_im[ii]) >>> 12;
                else
                    im_bfly02[idx] = pre_bfly02_im[idx] >>> (12 - cnt1_im[ii]);
            end
        end
    end

endmodule

