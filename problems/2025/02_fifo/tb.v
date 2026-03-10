`timescale 1ns/1ps

module tb_fifo;

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;

    reg clk = 1'b0;
    reg i_wr_en;
    reg i_rd_en;
    reg [DATA_WIDTH-1:0] i_wr_data;
    wire [DATA_WIDTH-1:0] o_rd_data;
    wire o_full;
    wire o_empty;

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) fifo_mod (
        .clk     (clk),
        .i_wr_en (i_wr_en),
        .i_rd_en (i_rd_en),
        .i_wr_data(i_wr_data),
        .o_rd_data(o_rd_data),
        .o_full  (o_full),
        .o_empty (o_empty)
    );

    always begin
        #1 clk = ~clk;
    end

    initial begin
        $dumpvars;      /* Open for dump of signals */
        $display("Test started...");   /* Write to console */
        i_wr_en   = 1'b0;
        i_rd_en   = 1'b0;
        i_wr_data = 8'h00;

        #4;
        i_wr_en   = 1'b1;
        i_wr_data = 8'h11;
        #2;
        $display("write 11 | empty=%b full=%b", o_empty, o_full);

        i_wr_data = 8'h22;
        #2;
        $display("write 22 | empty=%b full=%b", o_empty, o_full);

        i_wr_data = 8'h33;
        #2;
        $display("write 33 | empty=%b full=%b", o_empty, o_full);

        i_wr_en = 1'b0;
        i_rd_en = 1'b1;
        #2;
        $display("read -> %h | empty=%b full=%b", o_rd_data, o_empty, o_full);

        #2;
        $display("read -> %h | empty=%b full=%b", o_rd_data, o_empty, o_full);

        i_rd_en = 1'b0;
        i_wr_en   = 1'b1;
        i_wr_data = 8'h44;
        #2;
        $display("write 44 | empty=%b full=%b", o_empty, o_full);

        i_wr_data = 8'h55;
        #2;
        $display("write 55 | empty=%b full=%b", o_empty, o_full);

        i_wr_en = 1'b0;
        i_rd_en = 1'b1;
        #2;
        $display("read -> %h | empty=%b full=%b", o_rd_data, o_empty, o_full);

        #2;
        $display("read -> %h | empty=%b full=%b", o_rd_data, o_empty, o_full);

        #2;
        $display("read -> %h | empty=%b full=%b", o_rd_data, o_empty, o_full);

        i_rd_en = 1'b0;
        i_wr_en   = 1'b1;
        i_wr_data = 8'h44;

        #32
        $display("empty=%b full=%b", o_empty, o_full);

        $finish;
    end

endmodule