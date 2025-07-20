module mem_tw8(
    input [2:0] addr,     
    output [9:0] dout_re,   
    output [9:0] dout_im    
);

reg [19:0] dout;

always @(*) begin
    case (addr)
        3'b000: begin
            dout = 20'b0_1_0000000_0_0_0000000; 
        end
        3'b001: begin
            dout = 20'b0_1_0000000_0_0_0000000; 
        end
        3'b010: begin
            dout = 20'b0_1_0000000_0_0_0000000;
        end
        3'b011: begin
            dout = 20'b0_0_0000000_1_1_0000000;
        end
        3'b100: begin
            dout = 20'b0_1_0000000_0_0_0000000;
        end
        3'b101: begin
            dout = 20'b0_0_1011010_1_1_0100110;
        end
        3'b110: begin
            dout = 20'b0_1_0000000_0_0_0000000;
        end
        3'b111: begin
            dout = 20'b1_1_0100110_1_1_0100110;
        end
        default: begin
            dout = 20'b0;
        end
    endcase
end

assign dout_re = dout[19:10];
assign dout_im = dout[9:0];

endmodule
