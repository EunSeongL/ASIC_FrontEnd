module mem_tw4 (
    input  logic [1:0] addr,        
    output logic signed[8:0] dout_re,     
    output logic signed[8:0] dout_im      
);

    logic [17:0] dout;
    
    always @(*) begin
        case (addr)
            2'b00: dout = 18'b0_1_0000000_0_0_0000000;
            2'b01: dout = 18'b0_1_0000000_0_0_0000000;
            2'b10: dout = 18'b0_1_0000000_0_0_0000000;
            2'b11: dout = 18'b0_0_0000000_1_1_0000000;
            default: dout = 18'b0;
        endcase
    end
    
    assign dout_re = dout[17:9];
    assign dout_im = dout[8:0];

endmodule
