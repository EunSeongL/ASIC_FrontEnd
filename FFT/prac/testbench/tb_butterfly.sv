`timescale 1ns / 1ps

module tb_butterfly ();
    parameter WIDTH = 9;
    parameter N = 512;
    integer file, r, i, j;
    logic signed [WIDTH-1:0] din_i_data [0:N-1];  // 3.6 포맷이면 총 9비트 필요 (부호 포함)
    logic signed [WIDTH-1:0] din_q_data [0:N-1];
    logic signed [WIDTH-1:0] din_i[0:15];
    logic signed [WIDTH-1:0] din_q[0:15];
    logic valid_in;
    logic signed [WIDTH:0] do1_re[0:15];
    logic signed [WIDTH:0] do1_im[0:15];
    logic signed [WIDTH:0] do2_re[0:15];
    logic signed [WIDTH:0] do2_im[0:15];
    logic valid_out;
    logic clk;
    logic rstn;

    always #5 clk = ~clk;

    initial begin
        file = $fopen("/home/aedu30/practice/prac/testbench/data_fixed.txt", "r");
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
        #15 rstn = 1;

        for (i = 0; i < N / 16; i = i + 1) begin
            // 16개씩 슬라이스 할당
            for (j = 0; j < 16; j = j + 1) begin
                din_i[j] = din_i_data[i*16+j];
                din_q[j] = din_q_data[i*16+j];
            end
            valid_in = 1;
            @(posedge clk);
        end
        valid_in = 0;

        #(10000*100);
        $stop;
    end


    butterfly #(
        .IN_WIDTH (9),   //input bit width
        .OUT_WIDTH(10),  //output bit width
        .NUM      (16),  //number of line
        .DATA     (512)  //number of data
    ) DUT (
        .clk (clk),
        .rstn(rstn),

        .din_i   (din_i),    //Re value
        .din_q   (din_q),    //Im value
        .valid_in(valid_in), //valid input

        .do1_re(do1_re),  //plus Re out
        .do1_im(do1_im),  //plus Im out
        .do2_re(do2_re),  //minus Re out
        .do2_im(do2_im),  //minus Im out
        .valid_out(valid_out)  //valid output
    );

endmodule