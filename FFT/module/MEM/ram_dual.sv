module ram_dual# (
    parameter D_WIDTH = 10,
    parameter A_WIDTH = 9
)(
    input clk,
    input rstn,
    input logic [A_WIDTH-1:0] waddr,
    input logic [D_WIDTH-1:0] wdata,
    input logic [A_WIDTH-1:0] raddr,
    input wen,
    output logic [D_WIDTH-1:0] rdata
);

localparam ARR_MAX = 2 ** A_WIDTH;
integer i;

reg [D_WIDTH-1:0] ram [0:ARR_MAX-1];

always @ (negedge rstn) begin
    for (i = 0; i < ARR_MAX; i = i + 1) begin
        ram[i] = {D_WIDTH{1'b0}};
    end
end

always @ (posedge clk) begin
    if (wen) begin
        ram[waddr] <= wdata;
    end
    rdata <= ram[raddr];
end

endmodule
