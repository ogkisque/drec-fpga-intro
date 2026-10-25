module fifo #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 3
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [DATA_WIDTH-1:0]   i_data,
    input  logic                    i_wr_en,
    input  logic                    i_rd_en,

    output logic [DATA_WIDTH-1:0]   o_data,
    output logic                    o_full,
    output logic                    o_empty
);
    localparam DEPTH = (1 << ADDR_WIDTH);
    logic [ADDR_WIDTH-1:0] rd_ptr;
    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH:0] count;
    logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];

    assign o_full  = (count == DEPTH);
    assign o_empty = (count == 0);

    logic do_write;
    assign do_write = i_wr_en && !o_full;

    logic do_read;
    assign do_read = i_rd_en && !o_empty;

    assign o_data = mem[rd_ptr];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            count <= 0;
        end
        else begin
            if (do_read) begin
                rd_ptr <= rd_ptr + 1;
            end
            if (do_write) begin
                mem[wr_ptr] <= i_data;
                wr_ptr <= wr_ptr + 1;
            end

            case ({do_write, do_read})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: ;
            endcase
        end
    end
endmodule
