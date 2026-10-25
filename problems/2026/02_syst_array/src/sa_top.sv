module sa_top #(
    parameter WIDTH = 16,
    parameter SIZE  = 4
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [SIZE-1:0][WIDTH-1:0]  i_a,
    input  logic                        i_a_vld,
    input  logic                        i_c_vld,
    input  logic                        i_we,

    output logic [SIZE-1:0][WIDTH-1:0]  o_c,
    output logic                        o_c_vld
);
    logic [SIZE-1:0][WIDTH-1:0] core_a;
    logic [SIZE-1:0]            core_a_vld;
    logic [SIZE-1:0]            core_we;
    logic [SIZE-1:0]            core_c_vld_in;

    logic [SIZE-1:0][WIDTH-1:0] core_c;
    logic [SIZE-1:0]            core_c_vld_out;

    logic [SIZE-1:0]            delay_vld;

    assign o_c_vld = delay_vld[0];

    generate
        for (genvar i = 0; i < SIZE; i = i + 1) begin : delay_row
            delay_line #(
                .WIDTH (WIDTH + 1),
                .DEPTH (i)
            ) delay_row_mod (
                .clk    (clk),
                .rst_n  (rst_n),
                .i_data ({i_we, i_a[i]}),
                .i_vld  (i_a_vld),
                .o_data ({core_we[i], core_a[i]}),
                .o_vld  (core_a_vld[i])
            );
        end

        for (genvar j = 0; j < SIZE; j = j + 1) begin : delay_col
            delay_line #(
                .WIDTH (1),
                .DEPTH (j)
            ) delay_col_mod (
                .clk    (clk),
                .rst_n  (rst_n),
                .i_data (1'b0),
                .i_vld  (i_c_vld),
                .o_data (),
                .o_vld  (core_c_vld_in[j])
            );
        end

        for (genvar j = 0; j < SIZE; j = j + 1) begin : delay_out
            delay_line #(
                .WIDTH (WIDTH),
                .DEPTH (SIZE - 1 - j)
            ) delay_out_mod (
                .clk    (clk),
                .rst_n  (rst_n),
                .i_data (core_c[j]),
                .i_vld  (core_c_vld_out[j]),
                .o_data (o_c[j]),
                .o_vld  (delay_vld[j])
            );
        end
    endgenerate

    sa_core #(
        .WIDTH (WIDTH),
        .SIZE  (SIZE)
    ) sa_core_mod (
        .clk     (clk),
        .rst_n   (rst_n),
        .i_a     (core_a),
        .i_a_vld (core_a_vld),
        .i_we    (core_we),
        .i_c_vld (core_c_vld_in),
        .o_c     (core_c),
        .o_c_vld (core_c_vld_out)
    );

endmodule
