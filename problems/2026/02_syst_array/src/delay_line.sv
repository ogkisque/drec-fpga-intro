module delay_line #(
    parameter WIDTH = 16,
    parameter DEPTH = 1
) (
    input logic clk,
    input logic rst_n,

    input logic [WIDTH-1:0] i_data,
    input logic             i_vld,

    output logic [WIDTH-1:0]    o_data,
    output logic                o_vld
);
    logic [DEPTH:0][WIDTH-1:0]  data;
    logic [DEPTH:0]             vld;

    assign data[0] = i_data;
    assign vld[0]  = i_vld;

    assign o_data  = data[DEPTH];
    assign o_vld   = vld[DEPTH];

    generate
        for (genvar k = 0; k < DEPTH; k = k + 1) begin : sr_mod
            sr #(
                .WIDTH (WIDTH)
            ) sr_mod (
                .clk    (clk),
                .rst_n  (rst_n),
                .i_data (data[k]),
                .i_vld  (vld[k]),
                .o_data (data[k+1]),
                .o_vld  (vld[k+1])
            );
        end
    endgenerate
endmodule
