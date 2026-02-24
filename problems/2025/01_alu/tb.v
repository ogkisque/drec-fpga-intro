`timescale 1ns/1ps

module tb_alu;

    reg  [31:0] i_a;
    reg  [31:0] i_b;
    reg  [3:0]  i_op;
    wire [31:0] o_res;

    reg  [31:0] exp;
    reg  [31:0] test_count;
    reg  [31:0] err_count;

    alu alu_mod (
        .i_a  (i_a),
        .i_b  (i_b),
        .i_op (i_op),
        .o_res(o_res)
    );

    initial begin
        $dumpvars;
        test_count = 32'd0;
        err_count  = 32'd0;

        i_a  = 32'd0;
        i_b  = 32'd0;
        i_op = 4'd0;
        exp  = 32'd0;

        // ADD
        i_a = 32'd10; i_b = 32'd20; i_op = `ALU_ADD;
        exp = 32'd30;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL ADD #1: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'hFFFF_FFFF; i_b = 32'd1; i_op = `ALU_ADD;
        exp = 32'h0000_0000;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL ADD #2: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // SUB
        i_a = 32'd20; i_b = 32'd10; i_op = `ALU_SUB;
        exp = 32'd10;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SUB #1: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'd0; i_b = 32'd1; i_op = `ALU_SUB;
        exp = 32'hFFFF_FFFF;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SUB #2: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // SLL
        i_a = 32'h0000_0001; i_b = 32'd4; i_op = `ALU_SLL;
        exp = 32'h0000_0010;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SLL #1: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'h0000_0001; i_b = 32'd31; i_op = `ALU_SLL;
        exp = 32'h8000_0000;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SLL #2: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'h0000_0001; i_b = 32'd36; i_op = `ALU_SLL;
        exp = 32'h0000_0010;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SLL #3: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // SLT
        i_a = 32'hFFFF_FFFF; i_b = 32'd1; i_op = `ALU_SLT;
        exp = 32'd1;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SLT #1: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'd1; i_b = 32'hFFFF_FFFF; i_op = `ALU_SLT;
        exp = 32'd0;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SLT #2: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'h8000_0000; i_b = 32'd0; i_op = `ALU_SLT;
        exp = 32'd1;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SLT #3: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // SLTU
        i_a = 32'hFFFF_FFFF; i_b = 32'd1; i_op = `ALU_SLTU;
        exp = 32'd0;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SLTU #1: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'd1; i_b = 32'hFFFF_FFFF; i_op = `ALU_SLTU;
        exp = 32'd1;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SLTU #2: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // XOR
        i_a = 32'hAA55_AA55; i_b = 32'hFFFF_0000; i_op = `ALU_XOR;
        exp = 32'h55AA_AA55;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL XOR: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // SRL
        i_a = 32'h8000_0000; i_b = 32'd4; i_op = `ALU_SRL;
        exp = 32'h0800_0000;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SRL #1: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'h8000_0000; i_b = 32'd36; i_op = `ALU_SRL;
        exp = 32'h0800_0000;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SRL #2: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // SRA
        i_a = 32'h8000_0000; i_b = 32'd4; i_op = `ALU_SRA;
        exp = 32'hF800_0000;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SRA #1: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        i_a = 32'h7FFF_FFFF; i_b = 32'd4; i_op = `ALU_SRA;
        exp = 32'h07FF_FFFF;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL SRA #2: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // OR
        i_a = 32'h1234_0000; i_b = 32'h0000_5678; i_op = `ALU_OR;
        exp = 32'h1234_5678;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL OR: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // AND
        i_a = 32'h1234_5678; i_b = 32'h00FF_0FF0; i_op = `ALU_AND;
        exp = 32'h0034_0670;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL AND: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // RND ADD
        i_a = $random; i_b = $random; i_op = `ALU_ADD;
        exp = i_a + i_b;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND ADD: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // RND SUB
        i_a = $random; i_b = $random; i_op = `ALU_SUB;
        exp = i_a - i_b;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND SUB: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // RND XOR
        i_a = $random; i_b = $random; i_op = `ALU_XOR;
        exp = i_a ^ i_b;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND XOR: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // RND SLT
        i_a = $random; i_b = $random; i_op = `ALU_SLT;
        exp = ($signed(i_a) < $signed(i_b)) ? 32'd1 : 32'd0;
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND SLT: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        // RND SRA
        i_a = $random; i_b = $random; i_op = `ALU_SRA;
        exp = $signed(i_a) >>> i_b[4:0];
        #1; test_count = test_count + 1;
        if (o_res !== exp) begin
            err_count = err_count + 1;
            $display("FAIL RND SRA: a=%h b=%h res=%h exp=%h", i_a, i_b, o_res, exp);
        end

        if (err_count == 32'd0)
            $display("ALL TESTS PASSED, total=%0d", test_count);
        else
            $display("TESTS FAILED: errors=%0d total=%0d", err_count, test_count);

        $finish;
    end

endmodule