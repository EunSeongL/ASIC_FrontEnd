module ctrl (
    input clk,
    input rstn,
    
    output logic cnt_256,
    output logic cnt_128,
    output logic cnt_64
);
    
    always_ff @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            cnt_64 <= 0;
            cnt_128 <= 0;
            cnt_256 <= 0;
        end
    end

endmodule