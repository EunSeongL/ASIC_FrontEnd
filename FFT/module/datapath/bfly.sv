`timescale 1ns/1ps

module bfly #(
    parameter INT   = 3,
    parameter FLT   = 6,
    parameter WIDTH = INT + FLT   // 9
)(
    input  clk,
    input  rstn,
    input  bfly_en,

    input  signed [WIDTH-1:0] din1_i[0:15],  
    input  signed [WIDTH-1:0] din1_q[0:15],  
    input  signed [WIDTH-1:0] din2_i[0:15],  
    input  signed [WIDTH-1:0] din2_q[0:15],  

    output logic signed [WIDTH:0] dout1_i[0:15],  // add  
    output logic signed [WIDTH:0] dout1_q[0:15],   
    output logic signed [WIDTH:0] dout2_i[0:15],  // sub
    output logic signed [WIDTH:0] dout2_q[0:15]
);

    logic [4:0] cnt;

    logic signed [WIDTH:0] out1_i[0:15], out1_q[0:15];
    logic signed [WIDTH:0] out2_i[0:15], out2_q[0:15];

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn)
            cnt <= 0;
        else if (bfly_en)
            cnt <= cnt + 1;
        else
            cnt <= 0;
    end

    // 버터플라이 add/sub
    bfly_add #(
        .INT(INT),
        .FLT(FLT),
        .WIDTH(WIDTH)
    ) u_bfly_add (
        .din1_re(din1_i),
        .din1_im(din1_q),
        .din2_re(din2_i),
        .din2_im(din2_q),
        .dout1_re(out1_i),
        .dout1_im(out1_q),
        .dout2_re(out2_i),
        .dout2_im(out2_q)
    );

    // 버터플라이 TW[1,1,1,-j] 
    always_comb begin
        for (int i = 0; i < 16; i++) begin
            dout1_i[i] = out1_i[i];
            dout1_q[i] = out1_q[i];
            if (cnt > 7) begin
                dout2_i[i] =  out2_q[i];
                dout2_q[i] = -out2_i[i];
            end else begin
                dout2_i[i] = out2_i[i];
                dout2_q[i] = out2_q[i];
            end
        end
    end

endmodule
