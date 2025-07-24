`timescale 1ns/1ps

module cbfp_stage0 #(
    parameter N = 512,              // 전체 샘플 수
    parameter BW_IN = 23,           // 입력 데이터 비트 수 <9.13>
    parameter BW_OUT = 11,          // 출력 데이터 비트 수
    parameter BLOCK_SIZE = 64,      // 각 블록 당 데이터 수
    parameter TARGET_INT_BITS = 12, // 목표 정수부 비트 수
    parameter NUM_BLOCKS = 8        // 블록 개수
)(
    input wire clk,
    input wire rstn,
    input wire signed [BW_IN-1:0] real_in [0:N-1],
    input wire signed [BW_IN-1:0] imag_in [0:N-1],

    output reg signed [BW_OUT-1:0] real_out [0:N-1],
    output reg signed [BW_OUT-1:0] imag_out [0:N-1],
    output reg [4:0] index_out [0:N-1],  // shift amount 기록
    output reg valid_out
);

  integer blk, samp;
  reg [4:0] cnt1_re [0:NUM_BLOCKS-1];
  reg [4:0] cnt1_im [0:NUM_BLOCKS-1];
  reg [4:0] cnt_blk  [0:NUM_BLOCKS-1]; // 공통 shift amount
  reg [2:0] valid_cnt;
  reg signed [BW_OUT-1:0] real_out_reg [0:N-1];
  reg signed [BW_OUT-1:0] imag_out_reg [0:N-1];
  reg [4:0] index_out_reg [0:N-1];

  function [4:0] mag_detect;
    input signed [BW_IN-1:0] val;
    integer i;
    reg found;
    begin
      mag_detect = 0;
      found = 1'b0;
      for (i = BW_IN-2; i >= 0; i = i - 1) begin
        if (!found && (val[i] !== val[BW_IN-1])) begin
          mag_detect = BW_IN - 1 - i;
          found = 1'b1;
        end
      end
    end
  endfunction

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (blk = 0; blk < NUM_BLOCKS; blk = blk + 1) begin
        cnt1_re[blk] <= 5'd31;
        cnt1_im[blk] <= 5'd31;
        cnt_blk[blk] <= 5'd0;
      end
    end else begin
      // 1단계: 최대 정수부 비트 위치 측정
      for (blk = 0; blk < NUM_BLOCKS; blk = blk + 1) begin
        for (samp = 0; samp < BLOCK_SIZE; samp = samp + 1) begin
          integer idx;
          reg [4:0] msb_re, msb_im;
          idx = blk * BLOCK_SIZE + samp;
          msb_re = mag_detect(real_in[idx]);
          msb_im = mag_detect(imag_in[idx]);
          if (msb_re < cnt1_re[blk]) cnt1_re[blk] <= msb_re;
          if (msb_im < cnt1_im[blk]) cnt1_im[blk] <= msb_im;
        end
      end

      // 2단계: 공통 shift amount 선택
      for (blk = 0; blk < NUM_BLOCKS; blk = blk + 1) begin
        cnt_blk[blk] <= (cnt1_re[blk] < cnt1_im[blk]) ? cnt1_re[blk] : cnt1_im[blk];
      end

      // 3단계: 정규화 적용 (MUX style)
      for (blk = 0; blk < NUM_BLOCKS; blk = blk + 1) begin
        for (samp = 0; samp < BLOCK_SIZE; samp = samp + 1) begin
          integer idx;
          reg signed [BW_IN+7:0] shifted_re_hi, shifted_re_lo;
          reg signed [BW_IN+7:0] shifted_im_hi, shifted_im_lo;
          reg signed [BW_IN+7:0] temp_re, temp_im;
          reg [4:0] shift_amt;
          idx = blk * BLOCK_SIZE + samp;
          shift_amt = cnt_blk[blk];
          index_out_reg[idx] <= shift_amt;
      
          // real part
          shifted_re_hi = real_in[idx] <<< shift_amt;
          shifted_re_lo = real_in[idx] >>> (TARGET_INT_BITS - shift_amt);
          temp_re = (shift_amt > TARGET_INT_BITS) ? (shifted_re_hi >>> TARGET_INT_BITS) : shifted_re_lo;
          real_out_reg[idx] <= $signed(temp_re[BW_OUT-1:0]);
      
          // imag part
          shifted_im_hi = imag_in[idx] <<< shift_amt;
          shifted_im_lo = imag_in[idx] >>> (TARGET_INT_BITS - shift_amt);
          temp_im = (shift_amt > TARGET_INT_BITS) ? (shifted_im_hi >>> TARGET_INT_BITS) : shifted_im_lo;
          imag_out_reg[idx] <= $signed(temp_im[BW_OUT-1:0]);
        end
      end
    end
  end
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      valid_cnt  <= 3'd0;
      valid_out  <= 1'b0;
    end else begin
      if (valid_cnt < 3) begin
        valid_cnt <= valid_cnt + 1;
        valid_out <= 1'b0;
      end else begin
        valid_cnt <= 1'b0;
        valid_out <= 1'b1;
      end
    end
  end

  integer k;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (k = 0; k < N; k = k + 1) begin
        real_out[k] <= 0;
        imag_out[k] <= 0;
        index_out[k] <= 0;
      end
    end else if (valid_out) begin
      for (k = 0; k < N; k = k + 1) begin
        real_out[k] <= real_out_reg[k];
        imag_out[k] <= imag_out_reg[k];
        index_out[k] <= index_out_reg[k];
      end
    end
  end
endmodule
