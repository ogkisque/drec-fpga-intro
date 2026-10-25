module sa_core #(
    parameter WIDTH = 16,
    parameter SIZE  = 4
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [SIZE-1:0][WIDTH-1:0]  i_a,
    input  logic [SIZE-1:0]             i_a_vld,
    input  logic [SIZE-1:0]             i_we,
    input  logic [SIZE-1:0]             i_c_vld,

    output logic [SIZE-1:0][WIDTH-1:0]  o_c,
    output logic [SIZE-1:0]             o_c_vld
);
    logic [SIZE:0][SIZE-1:0][WIDTH-1:0] a_net;
    logic [SIZE:0][SIZE-1:0]            a_vld_net;
    logic [SIZE:0][SIZE-1:0]            we_net;

    logic [SIZE:0][SIZE-1:0][WIDTH-1:0] c_net;
    logic [SIZE:0][SIZE-1:0]            c_vld_net;

    assign a_net[0]     = i_a;
    assign a_vld_net[0] = i_a_vld;
    assign we_net[0]    = i_we;

    assign c_net[0]     = 0;
    assign c_vld_net[0] = i_c_vld;

    assign o_c          = c_net[SIZE];
    assign o_c_vld      = c_vld_net[SIZE];

    generate
        for (genvar i = 0; i < SIZE; i = i + 1) begin : row
            for (genvar j = 0; j < SIZE; j = j + 1) begin : col
                pe #(
                    .WIDTH (WIDTH)
                ) pe_mod (
                    .clk     (clk),
                    .rst_n   (rst_n),

                    .i_a     (a_net[j][i]),
                    .i_a_vld (a_vld_net[j][i]),
                    .i_we    (we_net[j][i]),
                    .i_c     (c_net[i][j]),
                    .i_c_vld (c_vld_net[i][j]),

                    .o_a     (a_net[j+1][i]),
                    .o_a_vld (a_vld_net[j+1][i]),
                    .o_we    (we_net[j+1][i]),
                    .o_c     (c_net[i+1][j]),
                    .o_c_vld (c_vld_net[i+1][j])
                );
            end
        end
    endgenerate
endmodule
