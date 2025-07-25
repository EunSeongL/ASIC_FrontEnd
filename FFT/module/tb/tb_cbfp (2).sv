`timescale 1ns / 1ps

module cbfp_stage0_tb;
    parameter BW_IN = 23;
    parameter BW_OUT = 11;
    parameter BLOCK_SIZE = 64;
    parameter BATCH_SIZE = 16;

    logic clk;
    logic rstn;
    logic in_valid;
    logic signed [BW_IN-1:0] real_in [0:BATCH_SIZE-1];
    logic signed [BW_IN-1:0] imag_in [0:BATCH_SIZE-1];

    logic signed [BW_OUT-1:0] real_out [0:BATCH_SIZE-1];
    logic signed [BW_OUT-1:0] imag_out [0:BATCH_SIZE-1];
    logic [4:0] index_out [0:BATCH_SIZE-1];
    logic valid_out;

    // DUT 인스턴스
    cbfp_stage0 dut (
        .clk(clk),
        .rstn(rstn),
        .in_valid(in_valid),
        .real_in(real_in),
        .imag_in(imag_in),
        .real_out(real_out),
        .imag_out(imag_out),
        .index_out(index_out),
        .valid_out(valid_out)
    );

    // Clock 생성
    always #5 clk = ~clk;
    int blk,b;
    // 초기화
    initial begin
        clk = 0;
        rstn = 0;
        in_valid = 0;
        for (int i = 0; i < BATCH_SIZE; i++) begin
            real_in[i] = 0;
            imag_in[i] = 0;
        end
        #20;
        rstn = 1;
        #20;

        // 두 블록 연속 입력: 각각 4번의 batch로 구성
        for (blk = 0; blk < 2; blk++) begin
            for (b = 0; b < 4; b++) begin
                in_valid = 1;
                for (int i = 0; i < BATCH_SIZE; i++) begin
                    real_in[i] = blk * 1000 + b * BATCH_SIZE + i;
                    imag_in[i] = blk * 1000 + b * BATCH_SIZE + i;
                end
                @(posedge clk);
            end
            in_valid = 0;

            // 출력 대기 및 관찰
            wait (valid_out);
            for (int t = 0; t < 4; t++) begin
                @(posedge clk);
                $display("[Time %0t] VALID_OUT: %b", $time, valid_out);
                for (int j = 0; j < BATCH_SIZE; j++) begin
                    $display("  [%2d] real=%0d imag=%0d index=%0d", j, real_out[j], imag_out[j], index_out[j]);
                end
            end
        end

        #1000;
        $finish;
    end
endmodule
