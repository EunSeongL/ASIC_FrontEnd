module mem_tw4(
    input [1:0] addr,     
    output [9:0] dout_re,   
    output [9:0] dout_im    
);

reg [19:0] dout;

always @(*) begin
    case (addr)
        2'b00: begin
            dout = 20'b0_1_0000000_0_0_0000000; 
        end
        2'b01: begin
            dout = 20'b0_1_0000000_0_0_0000000; 
        end
        2'b10: begin
            dout = 20'b0_1_0000000_0_0_0000000;
        end
        2'b11: begin
            dout = 20'b0_0_0000000_1_1_0000000;
        end
        default: begin
            dout = 20'b0;
        end
    endcase
end

assign dout_re = dout[19:10];
assign dout_im = dout[9:0];

endmodule
