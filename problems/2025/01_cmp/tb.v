`timescale 1ns/1ps
`include "branch_ops.vh"

module tb_branch_unit;

    reg  [31:0] i_a;
    reg  [31:0] i_b;
    reg  [2:0]  cmp_op;
    wire        taken;

    reg         exp;
    reg  [31:0] test_count;
    reg  [31:0] err_count;

    branch_unit branch_unit_mod (
        .i_a   (i_a),
        .i_b   (i_b),
        .cmp_op(cmp_op),
        .taken (taken)
    );

    initial begin
        $dumpvars;
        test_count = 32'd0;
        err_count  = 32'd0;

        i_a    = 32'd0;
        i_b    = 32'd0;
        cmp_op = 3'd0;
        exp    = 1'b0;

        // BEQ
        i_a = 32'd5; i_b = 32'd5; cmp_op = `BR_BEQ;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BEQ #1: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'd5; i_b = 32'd6; cmp_op = `BR_BEQ;
        exp = 1'b0;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BEQ #2: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // BNE
        i_a = 32'd5; i_b = 32'd6; cmp_op = `BR_BNE;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BNE #1: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'd7; i_b = 32'd7; cmp_op = `BR_BNE;
        exp = 1'b0;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BNE #2: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // BLT
        i_a = 32'hFFFF_FFFF; i_b = 32'd1; cmp_op = `BR_BLT;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BLT #1: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'd1; i_b = 32'hFFFF_FFFF; cmp_op = `BR_BLT;
        exp = 1'b0;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BLT #2: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'h8000_0000; i_b = 32'd0; cmp_op = `BR_BLT;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BLT #3: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // BGE
        i_a = 32'd10; i_b = 32'd10; cmp_op = `BR_BGE;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BGE #1: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'd2; i_b = 32'd1; cmp_op = `BR_BGE;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BGE #2: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'hFFFF_FFFF; i_b = 32'd1; cmp_op = `BR_BGE;
        exp = 1'b0;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BGE #3: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // BLTU
        i_a = 32'd1; i_b = 32'hFFFF_FFFF; cmp_op = `BR_BLTU;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BLTU #1: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'hFFFF_FFFF; i_b = 32'd1; cmp_op = `BR_BLTU;
        exp = 1'b0;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BLTU #2: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // BGEU
        i_a = 32'd5; i_b = 32'd5; cmp_op = `BR_BGEU;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BGEU #1: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'hFFFF_FFFF; i_b = 32'd1; cmp_op = `BR_BGEU;
        exp = 1'b1;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BGEU #2: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        i_a = 32'd1; i_b = 32'hFFFF_FFFF; cmp_op = `BR_BGEU;
        exp = 1'b0;
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL BGEU #3: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // RND BEQ
        i_a = $random; i_b = $random; cmp_op = `BR_BEQ;
        exp = (i_a == i_b);
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND BEQ: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // RND BNE
        i_a = $random; i_b = $random; cmp_op = `BR_BNE;
        exp = (i_a != i_b);
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND BNE: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // RND BLT
        i_a = $random; i_b = $random; cmp_op = `BR_BLT;
        exp = ($signed(i_a) < $signed(i_b));
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND BLT: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // RND BGE
        i_a = $random; i_b = $random; cmp_op = `BR_BGE;
        exp = ($signed(i_a) >= $signed(i_b));
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND BGE: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // RND BLTU
        i_a = $random; i_b = $random; cmp_op = `BR_BLTU;
        exp = (i_a < i_b);
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND BLTU: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        // RND BGEU
        i_a = $random; i_b = $random; cmp_op = `BR_BGEU;
        exp = (i_a >= i_b);
        #1; test_count = test_count + 1;
        if (taken !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND BGEU: a=%h b=%h taken=%b exp=%b", i_a, i_b, taken, exp);
        end

        if (err_count == 32'd0)
            $display("ALL TESTS PASSED, total=%0d", test_count);
        else
            $display("TESTS FAILED: errors=%0d total=%0d", err_count, test_count);

        $finish;
    end

endmodule