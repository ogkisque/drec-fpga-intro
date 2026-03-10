module fifo #(
    parameter integer DATA_WIDTH = 8,
    parameter integer ADDR_WIDTH = 4
)(
    input  wire                  clk,
    input  wire                  i_wr_en,
    input  wire                  i_rd_en,
    input  wire [DATA_WIDTH-1:0] i_wr_data,
    output reg  [DATA_WIDTH-1:0] o_rd_data,
    output wire                  o_full,
    output wire                  o_empty
);

    localparam DEPTH = (1 << ADDR_WIDTH);

    reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];
    reg [ADDR_WIDTH-1:0] wr_ptr = 0;
    reg [ADDR_WIDTH-1:0] rd_ptr = 0;
    reg [ADDR_WIDTH:0] count = 0;

    assign o_empty = (count == 0);
    assign o_full  = (count == DEPTH);

    wire do_write;
    assign do_write = i_wr_en && !o_full;

    wire do_read;
    assign do_read = i_rd_en && !o_empty;

    always @(posedge clk) begin
        if (do_write) begin
            mem[wr_ptr] <= i_wr_data;
            wr_ptr <= wr_ptr + 1'b1;
        end

        if (do_read) begin
            o_rd_data <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1'b1;
        end

        case ({do_write, do_read})
            2'b10: count <= count + 1'b1;
            2'b01: count <= count - 1'b1;
            default: ;
        endcase
    end

endmodule