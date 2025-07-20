module rom_512(
    clk,
    rstn,
    addr0,
    data0,
);

parameter D_WIDTH = 10;
parameter A_WIDTH = 9;

input clk;
input rstn;
input [A_WIDTH-1:0] addr0;

output reg [D_WIDTH-1:0] data0;

reg [D_WIDTH-1:0] rom_512 [2**A_WIDTH-1:0];

initial  begin
    $readmemh("module/MEM/cos_fixed.txt", rom_512);
end

always @ (posedge clk or negedge rstn)
    if(!rstn) begin
        data0 <= {(D_WIDTH){1'b0}};
    end
    else begin
        data0 <= rom_512[addr0];
    end
endmodule