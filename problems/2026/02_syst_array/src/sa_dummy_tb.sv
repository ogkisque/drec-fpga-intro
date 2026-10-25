`timescale 1ns/1ps

module sa_dummy_tb;

    localparam WIDTH = 16;
    localparam SIZE  = 4;

    logic                       clk;
    logic                       rst_n;
    logic [SIZE-1:0][WIDTH-1:0] i_a;
    logic                       i_a_vld;
    logic                       i_c_vld;
    logic                       i_we;
    logic [SIZE-1:0][WIDTH-1:0] o_c;
    logic                       o_c_vld;

    sa_top #(
        .WIDTH (WIDTH),
        .SIZE  (SIZE)
    ) sa_top_mod (
        .clk     (clk),
        .rst_n   (rst_n),
        .i_a     (i_a),
        .i_a_vld (i_a_vld),
        .i_c_vld (i_c_vld),
        .i_we    (i_we),
        .o_c     (o_c),
        .o_c_vld (o_c_vld)
    );

    initial clk = 1'b0;
    always #1 clk = ~clk;

    logic [WIDTH-1:0] mat_a [SIZE][SIZE];
    logic [WIDTH-1:0] mat_b [SIZE][SIZE];
    logic [WIDTH-1:0] mat_c [SIZE][SIZE];

    integer out_row;
    integer errors;
    integer total_errors;

    task calc_correct;
        integer r, c, k;
        logic [WIDTH-1:0] acc;
        begin
            for (r = 0; r < SIZE; r = r + 1) begin
                for (c = 0; c < SIZE; c = c + 1) begin
                    acc = 0;
                    for (k = 0; k < SIZE; k = k + 1) begin
                        acc = acc + mat_a[r][k] * mat_b[k][c];
                    end
                    mat_c[r][c] = acc;
                end
            end
        end
    endtask

    task fill_random;
        integer r, c;
        begin
            for (r = 0; r < SIZE; r = r + 1) begin
                for (c = 0; c < SIZE; c = c + 1) begin
                    mat_a[r][c] = WIDTH'($urandom());
                    mat_b[r][c] = WIDTH'($urandom());
                end
            end
        end
    endtask

    task drive_idle;
        integer i;
        begin
            @(negedge clk);
            for (i = 0; i < SIZE; i = i + 1) begin
                i_a[i] = WIDTH'($urandom());
            end
            i_a_vld = 1'b0;
            i_c_vld = 1'b0;
            i_we    = 1'($urandom());
        end
    endtask

    task load_b(input logic [SIZE-1:0] idle_mask);
        integer t, i;
        begin
            for (t = 0; t < SIZE; t = t + 1) begin
                if (idle_mask[t]) begin
                    drive_idle;
                end
                @(negedge clk);
                for (i = 0; i < SIZE; i = i + 1) begin
                    i_a[i] = mat_b[i][SIZE-1-t];
                end
                i_a_vld = 1'b1;
                i_c_vld = 1'b0;
                i_we    = 1'b1;
            end
        end
    endtask

    task load_a(input logic [SIZE-1:0] idle_mask);
        integer r, i;
        begin
            for (r = 0; r < SIZE; r = r + 1) begin
                if (idle_mask[r]) begin
                    drive_idle;
                end
                @(negedge clk);
                for (i = 0; i < SIZE; i = i + 1) begin
                    i_a[i] = mat_a[r][i];
                end
                i_a_vld = 1'b1;
                i_c_vld = 1'b1;
                i_we    = 1'b0;
            end
        end
    endtask

    always @(posedge clk) begin
        if (rst_n && o_c_vld) begin
            if (out_row >= SIZE) begin
                $display("[%0t] ERROR: extra output vector", $time);
                errors = errors + 1;
            end
            else begin
                for (int j = 0; j < SIZE; j = j + 1) begin
                    if (o_c[j] !== mat_c[out_row][j]) begin
                        $display("[%0t] ERROR: C[%0d][%0d] = %0d, expected %0d",
                                 $time, out_row, j,
                                 o_c[j], mat_c[out_row][j]);
                        errors = errors + 1;
                    end
                end
            end
            out_row = out_row + 1;
        end
    end

    task run_test(input integer num, input logic [SIZE-1:0] b_mask,
                  input logic [SIZE-1:0] a_mask);
        integer wait_cycles;
        begin
            calc_correct;
            out_row = 0;
            errors  = 0;

            load_b(b_mask);
            load_a(a_mask);
            drive_idle;
            i_we = 1'b0;

            wait_cycles = 0;
            while (out_row < SIZE && wait_cycles < 100) begin
                @(negedge clk);
                wait_cycles = wait_cycles + 1;
            end

            repeat (10) @(negedge clk);

            if (out_row != SIZE) begin
                $display("ERROR: test %0d: received %0d vectors instead of %0d",
                         num, out_row, SIZE);
                errors = errors + 1;
            end

            if (errors == 0) begin
                $display("PASS: test %0d", num);
            end
            else begin
                $display("FAIL: test %0d (%0d errors)", num, errors);
            end
            total_errors = total_errors + errors;
        end
    endtask

    integer n;

    initial begin
        total_errors = 0;
        out_row      = 0;
        errors       = 0;
        rst_n        = 1'b0;
        i_a          = 0;
        i_a_vld      = 1'b0;
        i_c_vld      = 1'b0;
        i_we         = 1'b0;

        repeat (4) @(negedge clk);
        rst_n = 1'b1;
        repeat (2) @(negedge clk);

        fill_random;
        run_test(0, 0, 0);

        fill_random;
        run_test(1, 0, 4'b0100);

        fill_random;
        run_test(2, 0, 4'b1111);

        fill_random;
        run_test(3, 4'b0001, 0);

        fill_random;
        run_test(4, 4'b1111, 0);

        fill_random;
        run_test(5, 4'b0110, 4'b1010);

        for (n = 6; n < 26; n = n + 1) begin
            fill_random;
            run_test(n, SIZE'($urandom()), SIZE'($urandom()));
        end

        if (total_errors == 0) begin
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("TESTS FAILED: %0d errors", total_errors);
        end
        $finish;
    end

    initial begin
        #1000000;
        $display("ERROR: timeout");
        $finish;
    end

endmodule