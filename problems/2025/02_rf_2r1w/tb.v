`timescale 1ns/1ps

module tb_reg_file;

    reg clk = 1'b0;

    reg [4:0] i_rd_addr0;
    wire [31:0] o_rd_data0;

    reg [4:0] i_rd_addr1;
    wire [31:0] o_rd_data1;

    reg [4:0] i_wr_addr;
    reg [31:0] i_wr_data;
    reg i_wr_en;

    reg_file reg_file_mod (
        .clk       (clk),
        .i_rd_addr0(i_rd_addr0),
        .o_rd_data0(o_rd_data0),
        .i_rd_addr1(i_rd_addr1),
        .o_rd_data1(o_rd_data1),
        .i_wr_addr (i_wr_addr),
        .i_wr_data (i_wr_data),
        .i_wr_en   (i_wr_en)
    );

    always begin
        #1 clk = ~clk;
    end

    initial begin
        $dumpvars;      /* Open for dump of signals */
        $display("Test started...");   /* Write to console */
        i_rd_addr0 = 5'd0;
        i_rd_addr1 = 5'd0;
        i_wr_en   = 1'b1;
        i_wr_addr = 5'd1;
        i_wr_data = 32'd111;
        #2

        i_wr_addr = 5'd2;
        i_wr_data = 32'd666;
        #2

        i_wr_addr = 5'd10;
        i_wr_data = 32'd999;
        #2

        i_wr_en = 1'b0;

        i_rd_addr0 = 5'd1;
        i_rd_addr1 = 5'd2;
        #2;
        $display("reg[1]  = %d, reg[2]  = %d", o_rd_data0, o_rd_data1);

        i_rd_addr0 = 5'd10;
        i_rd_addr1 = 5'd1;
        #2;
        $display("reg[10] = %d, reg[1]  = %d", o_rd_data0, o_rd_data1);

        $finish;
    end

endmodule