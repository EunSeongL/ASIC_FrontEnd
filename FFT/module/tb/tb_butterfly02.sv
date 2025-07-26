`timescale 1ns / 1ps

module tb_butterfly ();
    parameter IN_WIDTH = 14; //<7.6>
    parameter OUT_WIDTH = (23); //<9.13>+1
    parameter N = 256;

    integer file, r, i, j, i_blk, j_blk;
    integer out_file;
    integer clk_count;

    logic signed [IN_WIDTH-1:0] din_i_data [0:N-1];
    logic signed [IN_WIDTH-1:0] din_q_data [0:N-1];
    logic signed [IN_WIDTH-1:0] din_i[0:15];
    logic signed [IN_WIDTH-1:0] din_q[0:15];
    logic valid_in;
    logic signed [OUT_WIDTH-1:0] do1_re[0:15];
    logic signed [OUT_WIDTH-1:0] do1_im[0:15];
    logic signed [OUT_WIDTH-1:0] do2_re[0:15];
    logic signed [OUT_WIDTH-1:0] do2_im[0:15];
    logic valid_out;
    logic clk;
    logic rstn;

    logic prev_valid_out;
    logic falling_edge_detected;

    always #5 clk = ~clk;

    initial begin
        file = $fopen("bfly01_1.txt", "r");
        if (file == 0) begin
            $display("파일 열기 실패");
            $finish;
        end

        for (i = 0; i < N; i = i + 1) begin
            r = $fscanf(file, "%d %d\n", din_i_data[i], din_q_data[i]);
            if (r != 2) begin
                $display("파일 읽기 오류 at line %0d", i + 1);
                $finish;
            end
        end
        $fclose(file);

        clk = 0;
        rstn = 0;
        valid_in = 0;
        clk_count = 0;
        prev_valid_out = 0;
        falling_edge_detected = 0;

        out_file = $fopen("butterfly02_output.txt", "w");
        if (out_file == 0) begin
            $display("출력 파일 열기 실패");
            $finish;
        end

        #15 rstn = 1;

        // 🔹 1차 데이터 입력 (0~127)
        for (i_blk = 0; i_blk < 128 / 16; i_blk = i_blk + 1) begin
            @(posedge clk);
            for (j_blk = 0; j_blk < 16; j_blk = j_blk + 1) begin
                din_i[j_blk] = din_i_data[(i_blk * 16) + j_blk];
                din_q[j_blk] = din_q_data[(i_blk * 16) + j_blk];
            end
            valid_in = 1;
            #1;
        end

        @(posedge clk);
        valid_in = 0;

        // 🔹 wait for falling edge of valid_out
        wait (falling_edge_detected == 1);

        // 🔹 1클럭 쉬고 다음 데이터
        @(posedge clk);
        @(posedge clk);

        // 🔹 2차 데이터 입력 (128~255)
        for (i_blk = 8; i_blk < 16; i_blk = i_blk + 1) begin
            @(posedge clk);
            for (j_blk = 0; j_blk < 16; j_blk = j_blk + 1) begin
                din_i[j_blk] = din_i_data[(i_blk * 16) + j_blk];
                din_q[j_blk] = din_q_data[(i_blk * 16) + j_blk];
            end
            valid_in = 1;
            #1;
        end

        @(posedge clk);
        valid_in = 0;

        #10000;
        $fclose(out_file);
        $stop;
    end

    // 🔸 valid_out falling edge 감지
    always @(posedge clk) begin
        prev_valid_out <= valid_out;
        if (prev_valid_out == 1 && valid_out == 0 && !falling_edge_detected) begin
            falling_edge_detected <= 1;
        end
    end

    // clk count 및 출력 저장
    always @(posedge clk) begin
        clk_count <= clk_count + 1;

        if (valid_out) begin
            for (j = 0; j < 16; j = j + 1) begin
                $fwrite(out_file, "%0d %0d %0d %0d\n",
                    do1_re[j], do1_im[j], do2_re[j], do2_im[j]);
            end
        end
    end

    butterfly02 #(
        .IN_WIDTH(14),
        .OUT_WIDTH(23),
        .NUM(16),
        .DATA(128)
    ) DUT (
        .clk       (clk),
        .rstn      (rstn),
        .din_i     (din_i),
        .din_q     (din_q),
        .valid_in  (valid_in),
        .do1_re    (do1_re),
        .do1_im    (do1_im),
        .do2_re    (do2_re),
        .do2_im    (do2_im),
        .valid_out (valid_out)
    );

endmodule
