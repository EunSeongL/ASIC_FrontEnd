module mem_tw8 (
    input  logic [2:0] addr,        
    output logic [9:0] dout_re,     
    output logic [9:0] dout_im      
);

    logic [19:0] dout;
    
    always @(*) begin
        case (addr)
            3'b000: dout = 20'b0_1_0000000_0_0_0000000;
            3'b001: dout = 20'b0_1_0000000_0_0_0000000;
            3'b010: dout = 20'b0_1_0000000_0_0_0000000;
            3'b011: dout = 20'b0_0_0000000_1_1_0000000;
            3'b100: dout = 20'b0_1_0000000_0_0_0000000;
            3'b101: dout = 20'b0_0_1011010_1_1_0100110;
            3'b110: dout = 20'b0_1_0000000_0_0_0000000;
            3'b111: dout = 20'b1_1_0100110_1_1_0100110;
            default: dout = 20'b0;
        endcase
    end
    
    assign dout_re = dout[19:10];
    assign dout_im = dout[9:0];

endmodule
