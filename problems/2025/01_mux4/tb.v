`timescale 1ns/1ps

module tb_mux4;

    reg  [31:0] i_d0;
    reg  [31:0] i_d1;
    reg  [31:0] i_d2;
    reg  [31:0] i_d3;
    reg  [1:0]  i_sel;
    wire [31:0] o_y;

    reg  [31:0] exp;
    reg  [31:0] test_count;
    reg  [31:0] err_count;

    mux4 #(.WIDTH(32))
    mux4_mod (
        .i0 (i_d0),
        .i1 (i_d1),
        .i2 (i_d2),
        .i3 (i_d3),
        .i_sel(i_sel),
        .o_y  (o_y)
    );

    initial begin
        $dumpvars;
        test_count = 32'd0;
        err_count  = 32'd0;

        i_d0 = 32'd0;
        i_d1 = 32'd0;
        i_d2 = 32'd0;
        i_d3 = 32'd0;
        i_sel = 2'b00;
        exp = 32'd0;

        i_d0 = 32'h1111_1111;
        i_d1 = 32'h2222_2222;
        i_d2 = 32'h3333_3333;
        i_d3 = 32'h4444_4444;

        i_sel = 2'b00;
        exp   = 32'h1111_1111;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SEL00: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_sel = 2'b01;
        exp   = 32'h2222_2222;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SEL01: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_sel = 2'b10;
        exp   = 32'h3333_3333;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SEL10: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_sel = 2'b11;
        exp   = 32'h4444_4444;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SEL11: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_d0 = 32'h0000_0000;
        i_d1 = 32'hFFFF_FFFF;
        i_d2 = 32'hA5A5_A5A5;
        i_d3 = 32'h5A5A_5A5A;

        i_sel = 2'b00; exp = 32'h0000_0000;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL PAT #1: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_sel = 2'b01; exp = 32'hFFFF_FFFF;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL PAT #2: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_sel = 2'b10; exp = 32'hA5A5_A5A5;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL PAT #3: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_sel = 2'b11; exp = 32'h5A5A_5A5A;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL PAT #4: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_d0 = $random;
        i_d1 = $random;
        i_d2 = $random;
        i_d3 = $random;
        i_sel = 2'b00;
        exp   = i_d0;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND #1: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_d0 = $random;
        i_d1 = $random;
        i_d2 = $random;
        i_d3 = $random;
        i_sel = 2'b01;
        exp   = i_d1;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND #2: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_d0 = $random;
        i_d1 = $random;
        i_d2 = $random;
        i_d3 = $random;
        i_sel = 2'b10;
        exp   = i_d2;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND #3: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        i_d0 = $random;
        i_d1 = $random;
        i_d2 = $random;
        i_d3 = $random;
        i_sel = 2'b11;
        exp   = i_d3;
        #1; test_count = test_count + 1;
        if (o_y !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND #4: sel=%b y=%h exp=%h", i_sel, o_y, exp);
        end

        if (err_count == 32'd0)
            $display("ALL TESTS PASSED, total=%0d", test_count);
        else
            $display("TESTS FAILED: errors=%0d total=%0d", err_count, test_count);

        $finish;
    end

endmodule