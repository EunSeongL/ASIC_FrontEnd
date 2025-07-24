`timescale 1ns / 1ps

module cbfp_stage0 #(
    parameter int BW_IN = 23,
    parameter int BW_OUT = 11,
    parameter int TARGET_INT_BITS = 12,
    parameter int BLOCK_SIZE = 64,
    parameter int BATCH_SIZE = 16
) (
    input logic                    clk,
    input logic                    rstn,
    input logic signed [BW_IN-1:0] real_in [0:BATCH_SIZE-1],
    input logic signed [BW_IN-1:0] imag_in [0:BATCH_SIZE-1],
    input logic                    in_valid,

    output logic signed [BW_OUT-1:0] real_out [0:BATCH_SIZE-1],
    output logic signed [BW_OUT-1:0] imag_out [0:BATCH_SIZE-1],
    output logic        [       4:0] index_out[0:BATCH_SIZE-1],
    output logic                     valid_out
);
    // 입출력 및 shift 카운터
    logic [2:0] input_cnt;
    logic [2:0] output_cnt;
    int i,j,k;

    // 값 저장 버퍼
    logic signed [BW_IN-1:0] real_buf [0:BLOCK_SIZE-1];
    logic signed [BW_IN-1:0] imag_buf [0:BLOCK_SIZE-1];

    // 정규화에 사용되는 MSB, 최소값 탐색
    logic [5:0] msb_re [0:BLOCK_SIZE-1];
    logic [5:0] msb_im [0:BLOCK_SIZE-1];

    // 전체 64포인트 중 가장 작은 MSB가 저장
    logic [5:0] min_chain [0:BLOCK_SIZE-1];

    // 정규화 shift 관련 제어
    logic shift_val_loaded;
    logic [4:0] shift_val;

    // 정규화 결과 저장
    logic signed [BW_OUT-1:0] norm_real [0:BLOCK_SIZE-1];
    logic signed [BW_OUT-1:0] norm_imag [0:BLOCK_SIZE-1];
    logic [4:0] norm_index [0:BLOCK_SIZE-1];

    
    generate
        for (genvar g = 0; g < BLOCK_SIZE; g++) begin
            mag_detect #(
                .WIDTH(BW_IN)
            ) u_mag_re (
                .in_dat(real_buf[g]),
                .cnt(msb_re[g])
            );
            mag_detect #(
                .WIDTH(BW_IN)
            ) u_mag_im (
                .in_dat(imag_buf[g]),
                .cnt(msb_im[g])
            );
        end
    endgenerate

    generate
        for (genvar q = 0; q < BLOCK_SIZE; q++) begin
            if (q == 0) begin
                assign min_chain[0] = (msb_re[0] < msb_im[0]) ? msb_re[0] : msb_im[0];
            end else begin
                min_detect #(
                    .WIDTH(6)
                ) u_min (
                    .cnt((msb_re[q] < msb_im[q]) ? msb_re[q] : msb_im[q]),
                    .temp(min_chain[q-1]),
                    .index(4'd0),
                    .min_val(min_chain[q])
                );
            end
        end
    endgenerate

    parameter IDLE = 0, COLLECT = 1, PROCESS = 2, OUTPUT = 3;
    logic [1:0] c_state, n_state;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (c_state)
            IDLE: begin
                n_state = COLLECT;
            end
            COLLECT: begin
                n_state = (input_cnt == 2'b11) ? PROCESS : COLLECT;
            end
            PROCESS: begin
                if(shift_val_loaded) begin
                    n_state = OUTPUT;
                end
            end
            OUTPUT: begin
                n_state = (output_cnt == 2'b11) ? IDLE : OUTPUT;
            end
            default: n_state = c_state;
        endcase
    end


    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            input_cnt <= 0;
        end else if (c_state == COLLECT && in_valid) begin
            for (i = 0; i < BATCH_SIZE; i++) begin
                automatic int idx = input_cnt * BATCH_SIZE + i;
                real_buf[idx] <= real_in[i];
                imag_buf[idx] <= imag_in[i];
            end
            input_cnt <= input_cnt + 1;
        end else if(c_state == PROCESS) input_cnt <= 0;
    end


    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            shift_val <= 0;
            shift_val_loaded <= 0;
        end else if (c_state == PROCESS && !shift_val_loaded) begin
            shift_val <= min_chain[BLOCK_SIZE-1];
            shift_val_loaded <= 1; 
        end else if (c_state != PROCESS) begin
            shift_val_loaded <= 0;
        end
    end

    logic signed [BW_IN+7:0] temp_r;
    logic signed [BW_IN+7:0] temp_i;
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            temp_r <= 0;
            temp_i <= 0;
         
        end
        if (c_state == PROCESS && shift_val_loaded) begin
            for (j = 0; j < BLOCK_SIZE; j = j + 1) begin
                temp_r = (shift_val > 12) ? (real_buf[j]  <<<  shift_val) : (real_buf[j] >>> (-12+shift_val));
                temp_i = (shift_val > 12) ? (imag_buf[j]  <<<  shift_val) : (imag_buf[j] >>> (-12+shift_val));

                norm_real[j]  <= temp_r[BW_OUT-1:0];
                norm_imag[j]  <= temp_i[BW_OUT-1:0];
                norm_index[j] <= shift_val[4:0];
               
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            output_cnt <= 0;
            valid_out  <= 0;
        end else if (c_state == OUTPUT) begin
            valid_out <= 1;
            for (k = 0; k < BATCH_SIZE; k = k + 1) begin
                automatic int idx_o = output_cnt * BATCH_SIZE + k;
                real_out[k]  <= norm_real[idx_o];
                imag_out[k]  <= norm_imag[idx_o];
                index_out[k] <= norm_index[idx_o];
            end
            output_cnt <= output_cnt + 1;
        end else if (c_state == (IDLE || COLLECT)) begin
            valid_out <= 0;
            output_cnt <= 0;
        end
    end

endmodule

