module credit_cnt #(
    parameter CREDITS = 8
) (
    input  logic clk,
    input  logic rst_n,

    input  logic    i_take,
    input  logic    i_give,

    output logic    o_rdy
);
    localparam CNT_WIDTH = $clog2(CREDITS + 1);
    logic [CNT_WIDTH-1:0] cnt;

    assign o_rdy = (cnt != 0);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= CNT_WIDTH'(CREDITS);
        end
        else if (i_take & ~i_give) begin
            cnt <= cnt - 1'b1;
        end
        else if (i_give & ~i_take) begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
