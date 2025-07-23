module mag_detect #(
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] in_dat,
    output logic [$clog2(WIDTH):0] cnt
);

    logic msb;
    logic [$clog2(WIDTH):0] n;

    always_comb begin
        msb = in_dat[WIDTH-1];
        n = 0;

        for (int i = WIDTH-2; i >= 0; i--) begin
            if (in_dat[i] == msb)
                n++;
            else
                break;
        end
        cnt = n;
    end

endmodule
