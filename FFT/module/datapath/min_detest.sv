module min_detect #(
    parameter int WIDTH = 8  // cnt, temp, min_val 비트 수
)(
    input  logic [WIDTH-1:0] cnt,
    input  logic [WIDTH-1:0] temp,
    input  logic [$clog2(WIDTH):0] index,
    output logic [WIDTH-1:0] min_val
);

    always_comb begin
        if (index == 1)
            min_val = cnt;
        else
            min_val = (cnt < temp) ? cnt : temp;
    end

endmodule
