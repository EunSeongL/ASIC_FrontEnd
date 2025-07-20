module rom_512 #(
    parameter int D_WIDTH = 10,
    parameter int A_WIDTH = 9
) (
    input  logic                  clk,
    input  logic                  rstn,
    input  logic [A_WIDTH-1:0]    addr0,
    output logic [D_WIDTH-1:0]    data0
);

    logic [D_WIDTH-1:0] rom_512 [2**A_WIDTH];

    initial begin
        $readmemh("module/MEM/cos_fixed.txt", rom_512);
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            data0 <= 0;
        end else begin
            data0 <= rom_512[addr0];
        end
    end

endmodule
