`timescale 1ns / 1ps

// 16개 복소수 묶음을 처리하고, Read/Write로 제어하는 FIFO 모듈
module shift_reg #(
    parameter WIDTH = 9,
    parameter DELAY_LENGTH = 16 // 16개 묶음 데이터 블록을 128개 저장 가능
)(
    input clk,
    input rstn,

    input write, // 16개 묶음 복소수 쓰기 활성화 신호
    input read,  // 16개 묶음 복소수 읽기 활성화 신호

    // 16개 복소수의 실수부와 허수부를 각각 묶음으로 입력받는 포트
    input signed [WIDTH-1:0] data_in_real [15:0],
    input signed [WIDTH-1:0] data_in_imag [15:0],
    
    // 16개 복소수의 실수부와 허수부를 각각 묶음으로 출력하는 포트
    output logic signed [WIDTH-1:0] data_out_real [15:0],
    output logic signed [WIDTH-1:0] data_out_imag [15:0],
    
    output logic full,
    output logic empty
);

// 실수부와 허수부를 각각 저장할 2차원 배열
reg signed [WIDTH-1:0] shift_din_real [DELAY_LENGTH-1:0] [15:0];
reg signed [WIDTH-1:0] shift_din_imag [DELAY_LENGTH-1:0] [15:0];
integer i, j;

// FIFO에 저장된 데이터 블록의 개수를 세는 카운터
reg [$clog2(DELAY_LENGTH+1)-1:0] count;

// full, empty 상태 업데이트
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        full <= 1'b0;
        empty <= 1'b1;
    end
    else begin
        full <= (count == DELAY_LENGTH) ? 1'b1 : 1'b0;
        empty <= (count == 0) ? 1'b1 : 1'b0;
    end
end

// 카운터 업데이트
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        count <= 0;
    end
    else if (write && !read && !full) begin
        count <= count + 1'b1;
    end
    else if (read && !write && !empty) begin
        count <= count - 1'b1;
    end
end

// 16개 묶음 복소수 데이터 처리
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        // 리셋 시 모든 레지스터 0으로 초기화
        for(i = 0; i < DELAY_LENGTH; i=i+1) begin
            for(j = 0; j < 16; j=j+1) begin
                shift_din_real[i][j] <= 0;
                shift_din_imag[i][j] <= 0;
            end
        end
        // 출력 포트도 초기화
        for(j = 0; j < 16; j=j+1) begin
            data_out_real[j] <= 0;
            data_out_imag[j] <= 0;
        end
    end
    else begin
        // 쓰기(write)가 활성화되면 16개 묶음 복소수 데이터 입력
        if (write && !full) begin
            // 16개 묶음을 통째로 한 칸씩 시프트 (실수부/허수부 동시)
            for(i = DELAY_LENGTH-1; i > 0; i=i-1) begin
                shift_din_real[i] <= shift_din_real[i-1];
                shift_din_imag[i] <= shift_din_imag[i-1];
            end
            // 새로운 16개 묶음 데이터를 0번 칸에 저장
            shift_din_real[0] <= data_in_real;
            shift_din_imag[0] <= data_in_imag;
        end

        // 읽기(read)가 활성화되면 16개 묶음 복소수 데이터 출력
        if (read && !empty) begin
            // 가장 오래된 16개 묶음 데이터를 출력
            data_out_real <= shift_din_real[DELAY_LENGTH-1];
            data_out_imag <= shift_din_imag[DELAY_LENGTH-1];
            
            // 데이터를 한 칸씩 앞으로 당김 (FIFO 동작)
            for(i = DELAY_LENGTH-1; i > 0; i=i-1) begin
                shift_din_real[i] <= shift_din_real[i-1];
                shift_din_imag[i] <= shift_din_imag[i-1];
            end
            // 맨 앞 칸을 비움
            for(j = 0; j < 16; j=j+1) begin
                shift_din_real[0][j] <= 0;
                shift_din_imag[0][j] <= 0;
            end
        end
        else begin
            // 읽기가 비활성화되면 출력은 0
            for(j = 0; j < 16; j=j+1) begin
                data_out_real[j] <= 0;
                data_out_imag[j] <= 0;
            end
        end
    end
end

endmodule
