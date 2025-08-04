`timescale 1ns/1ps

module mag_detect_0 #(
    parameter int WIDTH = 23
) ( 
    input logic clk,
    input logic rstn,
    input logic valid,
    input logic signed [WIDTH - 1:0] di_re [0:15],
    input logic signed [WIDTH - 1:0] di_im [0:15],
    output logic [4:0] min_chain,
    output logic out_valid
);
    logic [WIDTH-1:0] mag_cnt_re[0:15];
    logic [WIDTH-1:0] mag_cnt_im[0:15];
    genvar i,j;

    for(i=0; i<16; i = i + 1) begin: gen_all
        // === Real Part ===
        assign mag_cnt_re[i] =
                (di_re[i][21:0] == 'h0) && ~di_re[i][22] ? 5'd22 :
                (di_re[i][21:1] == 'h0) && ~di_re[i][22] ? 5'd21 :
                (di_re[i][21:2] == 'h0) && ~di_re[i][22] ? 5'd20 :
                (di_re[i][21:3] == 'h0) && ~di_re[i][22] ? 5'd19 :
                (di_re[i][21:4] == 'h0) && ~di_re[i][22] ? 5'd18 :
                (di_re[i][21:5] == 'h0) && ~di_re[i][22] ? 5'd17 :
                (di_re[i][21:6] == 'h0) && ~di_re[i][22] ? 5'd16 :
                (di_re[i][21:7] == 'h0) && ~di_re[i][22] ? 5'd15 :
                (di_re[i][21:8] == 'h0) && ~di_re[i][22] ? 5'd14 :
                (di_re[i][21:9] == 'h0) && ~di_re[i][22] ? 5'd13 :
                (di_re[i][21:10] == 'h0) && ~di_re[i][22] ? 5'd12 :
                (di_re[i][21:11] == 'h0) && ~di_re[i][22] ? 5'd11 :
                (di_re[i][21:12] == 'h0) && ~di_re[i][22] ? 5'd10 :
                (di_re[i][21:13] == 'h0) && ~di_re[i][22] ? 5'd9 :
                (di_re[i][21:14] == 'h0)  && ~di_re[i][22] ? 5'd8  :
                (di_re[i][21:15] == 'h0)  && ~di_re[i][22] ? 5'd7  :
                (di_re[i][21:16] == 'h0)  && ~di_re[i][22] ? 5'd6  :
                (di_re[i][21:17] == 'h0)  && ~di_re[i][22] ? 5'd5  :
                (di_re[i][21:18] == 'h0)  && ~di_re[i][22] ? 5'd4  :
                (di_re[i][21:19] == 'h0)  && ~di_re[i][22] ? 5'd3  :
                (di_re[i][21:20] == 'h0)  && ~di_re[i][22] ? 5'd2  :
                (di_re[i][21:21] == 'h0)  && ~di_re[i][22] ? 5'd1  :
                (di_re[i][21:0] == 22'h3FFFFF) && di_re[i][22] ? 5'd22 :
                (di_re[i][21:1] == 21'h1FFFFF) && di_re[i][22] ? 5'd21 :
                (di_re[i][21:2] == 20'hFFFFF) && di_re[i][22] ? 5'd20 :
                (di_re[i][21:3] == 19'h7FFFF) && di_re[i][22] ? 5'd19 :
                (di_re[i][21:4] == 18'h3FFFF) && di_re[i][22] ? 5'd18 :
                (di_re[i][21:5] == 17'h1FFFF) && di_re[i][22] ? 5'd17 :
                (di_re[i][21:6] == 16'hFFFF) && di_re[i][22] ? 5'd16 :
                (di_re[i][21:7] == 15'h7FFF) && di_re[i][22] ? 5'd15 :
                (di_re[i][21:8] == 14'h3FFF) && di_re[i][22] ? 5'd14 :
                (di_re[i][21:9] == 13'h1FFF) && di_re[i][22] ? 5'd13 :
                (di_re[i][21:10] == 12'hFFF) && di_re[i][22] ? 5'd12 :
                (di_re[i][21:11] == 11'h7FF) && di_re[i][22] ? 5'd11 :
                (di_re[i][21:12] == 10'h3FF) && di_re[i][22] ? 5'd10 :
                (di_re[i][21:13] == 9'h1FF) && di_re[i][22] ? 5'd9 :
                (di_re[i][21:14] == 8'hFF)  && di_re[i][22] ? 5'd8  :
                (di_re[i][21:15] == 7'h7F)  && di_re[i][22] ? 5'd7  :
                (di_re[i][21:16] == 6'h3F)  && di_re[i][22] ? 5'd6  :
                (di_re[i][21:17] == 5'h1F)  && di_re[i][22] ? 5'd5  :
                (di_re[i][21:18] == 4'hF)  && di_re[i][22] ? 5'd4  :
                (di_re[i][21:19] == 3'h7)  && di_re[i][22] ? 5'd3  :
                (di_re[i][21:20] == 2'h3)  && di_re[i][22] ? 5'd2  :
                (di_re[i][21:21] == 1'h1)  && di_re[i][22] ? 5'd1  :
                5'd0;

        // === Imag Part ===
        assign mag_cnt_im[i] =
                (di_im[i][21:0] == 'h0)  && ~di_im[i][22] ? 5'd22 :
                (di_im[i][21:1] == 'h0)  && ~di_im[i][22] ? 5'd21 :
                (di_im[i][21:2] == 'h0)  && ~di_im[i][22] ? 5'd20 :
                (di_im[i][21:3] == 'h0)  && ~di_im[i][22] ? 5'd19 :
                (di_im[i][21:4] == 'h0)  && ~di_im[i][22] ? 5'd18 :
                (di_im[i][21:5] == 'h0)  && ~di_im[i][22] ? 5'd17 :
                (di_im[i][21:6] == 'h0)  && ~di_im[i][22] ? 5'd16 :
                (di_im[i][21:7] == 'h0)  && ~di_im[i][22] ? 5'd15 :
                (di_im[i][21:8] == 'h0)  && ~di_im[i][22] ? 5'd14 :
                (di_im[i][21:9] == 'h0)  && ~di_im[i][22] ? 5'd13 :
                (di_im[i][21:10] == 'h0) && ~di_im[i][22] ? 5'd12 :
                (di_im[i][21:11] == 'h0) && ~di_im[i][22] ? 5'd11 :
                (di_im[i][21:12] == 'h0) && ~di_im[i][22] ? 5'd10 :
                (di_im[i][21:13] == 'h0) && ~di_im[i][22] ? 5'd9  :
                (di_im[i][21:14] == 'h0) && ~di_im[i][22] ? 5'd8  :
                (di_im[i][21:15] == 'h0) && ~di_im[i][22] ? 5'd7  :
                (di_im[i][21:16] == 'h0) && ~di_im[i][22] ? 5'd6  :
                (di_im[i][21:17] == 'h0) && ~di_im[i][22] ? 5'd5  :
                (di_im[i][21:18] == 'h0) && ~di_im[i][22] ? 5'd4  :
                (di_im[i][21:19] == 'h0) && ~di_im[i][22] ? 5'd3  :
                (di_im[i][21:20] == 'h0) && ~di_im[i][22] ? 5'd2  :
                (di_im[i][21:21] == 'h0) && ~di_im[i][22] ? 5'd1  :
                (di_im[i][21:0] == 22'h3FFFFF) && di_im[i][22] ? 5'd22 :
                (di_im[i][21:1] == 21'h1FFFFF) && di_im[i][22] ? 5'd21 :
                (di_im[i][21:2] == 20'hFFFFF)  && di_im[i][22] ? 5'd20 :
                (di_im[i][21:3] == 19'h7FFFF)  && di_im[i][22] ? 5'd19 :
                (di_im[i][21:4] == 18'h3FFFF)  && di_im[i][22] ? 5'd18 :
                (di_im[i][21:5] == 17'h1FFFF)  && di_im[i][22] ? 5'd17 :
                (di_im[i][21:6] == 16'hFFFF)   && di_im[i][22] ? 5'd16 :
                (di_im[i][21:7] == 15'h7FFF)   && di_im[i][22] ? 5'd15 :
                (di_im[i][21:8] == 14'h3FFF)   && di_im[i][22] ? 5'd14 :
                (di_im[i][21:9] == 13'h1FFF)   && di_im[i][22] ? 5'd13 :
                (di_im[i][21:10] == 12'hFFF)   && di_im[i][22] ? 5'd12 :
                (di_im[i][21:11] == 11'h7FF)   && di_im[i][22] ? 5'd11 :
                (di_im[i][21:12] == 10'h3FF)   && di_im[i][22] ? 5'd10 :
                (di_im[i][21:13] == 9'h1FF)    && di_im[i][22] ? 5'd9  :
                (di_im[i][21:14] == 8'hFF)     && di_im[i][22] ? 5'd8  :
                (di_im[i][21:15] == 7'h7F)     && di_im[i][22] ? 5'd7  :
                (di_im[i][21:16] == 6'h3F)     && di_im[i][22] ? 5'd6  :
                (di_im[i][21:17] == 5'h1F)     && di_im[i][22] ? 5'd5  :
                (di_im[i][21:18] == 4'hF)      && di_im[i][22] ? 5'd4  :
                (di_im[i][21:19] == 3'h7)      && di_im[i][22] ? 5'd3  :
                (di_im[i][21:20] == 2'h3)      && di_im[i][22] ? 5'd2  :
                (di_im[i][21:21] == 1'h1)      && di_im[i][22] ? 5'd1  :
                5'd0;
        
    end

    logic [4:0] local_min;
    logic [4:0] global_min;
    logic [2:0] out_cnt;

    // 16개 비교해서 제일 작은 값 도출
    always_comb begin
        local_min = 5'd31;
        for (int i = 0; i < 16; i++) begin
            automatic logic [4:0] cmp_val = (mag_cnt_re[i] < mag_cnt_im[i]) ? mag_cnt_re[i] : mag_cnt_im[i];
            if (cmp_val < local_min)
                local_min = cmp_val;
        end
    end
    
    // 제일 작은 값 저장 및 새로운 min과 비교 후 저장
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            global_min <= 5'd31;
            out_cnt    <= 3'd0;
            min_chain  <= 5'd0;
            out_valid <= 0;
        end else begin
            out_valid <= 0;
            if (local_min < global_min )
                global_min <= local_min;
                
            if (out_cnt == 3'd4) begin
                if (local_min < global_min )
                    min_chain <= local_min;
                else
                    min_chain <= global_min;
                out_valid <= 1;
                global_min <= 5'd31;  // 초기화
                out_cnt <= 3'd1;
            end else if(valid) begin
                out_cnt <= out_cnt + 1;
            end
        end
    end

endmodule
