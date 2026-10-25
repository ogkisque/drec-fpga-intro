module sa_flow_control #(
    parameter WIDTH      = 16,
    parameter SIZE       = 4,
    parameter FIFO_ADDRW = $clog2(2 * SIZE)
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [SIZE-1:0][WIDTH-1:0]  i_a,
    input  logic                        i_a_vld,
    input  logic                        i_c_vld,
    input  logic                        i_we,
    input  logic                        i_c_rdy,

    output logic                        o_a_rdy,
    output logic [SIZE-1:0][WIDTH-1:0]  o_c,
    output logic                        o_c_vld
);
    logic a_transfer;
    logic c_transfer;
    logic fifo_empty;
    logic fifo_full;

    logic [SIZE-1:0][WIDTH-1:0] core_c;
    logic                       core_c_vld;

    assign a_transfer  = i_a_vld & o_a_rdy;
    assign c_transfer  = o_c_vld & i_c_rdy;

    assign o_c_vld = ~fifo_empty;

    sa_top #(
        .WIDTH (WIDTH),
        .SIZE  (SIZE)
    ) sa_top_mod (
        .clk     (clk),
        .rst_n   (rst_n),
        .i_a     (i_a),
        .i_a_vld (a_transfer),
        .i_c_vld (a_transfer & i_c_vld),
        .i_we    (i_we),
        .o_c     (core_c),
        .o_c_vld (core_c_vld)
    );

    fifo #(
        .DATA_WIDTH (SIZE * WIDTH),
        .ADDR_WIDTH (FIFO_ADDRW)
    ) fifo_mod (
        .clk     (clk),
        .rst_n   (rst_n),
        .i_data  (core_c),
        .i_wr_en (core_c_vld),
        .o_data  (o_c),
        .i_rd_en (i_c_rdy),
        .o_full  (fifo_full),
        .o_empty (fifo_empty)
    );

    credit_cnt #(
        .CREDITS (2**FIFO_ADDRW)
    ) credit_cnt_mod (
        .clk    (clk),
        .rst_n  (rst_n),
        .i_take (a_transfer & i_c_vld),
        .i_give (c_transfer),
        .o_rdy  (o_a_rdy)
    );

endmodule
