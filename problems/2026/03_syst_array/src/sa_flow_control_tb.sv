`timescale 1ns/1ps

module sa_flow_control_tb;

    localparam WIDTH    = 16;
    localparam SIZE     = 4;
    localparam MATRICES = 20;

    logic                       clk;
    logic                       rst_n;
    logic [SIZE-1:0][WIDTH-1:0] i_a;
    logic                       i_a_vld;
    logic                       i_c_vld;
    logic                       i_we;
    logic                       o_a_rdy;
    logic [SIZE-1:0][WIDTH-1:0] o_c;
    logic                       o_c_vld;
    logic                       i_c_rdy;

    sa_flow_control #(
        .WIDTH (WIDTH),
        .SIZE  (SIZE)
    ) sa_flow_control_mod (
        .clk     (clk),
        .rst_n   (rst_n),
        .i_a     (i_a),
        .i_a_vld (i_a_vld),
        .i_c_vld (i_c_vld),
        .i_we    (i_we),
        .i_c_rdy (i_c_rdy),
        .o_a_rdy (o_a_rdy),
        .o_c     (o_c),
        .o_c_vld (o_c_vld)
    );

    initial clk = 1'b0;
    always #1 clk = ~clk;

    localparam BEATS = MATRICES * 2 * SIZE;
    localparam ROWS  = MATRICES * SIZE;

    logic [SIZE*WIDTH+1:0] in_mem  [BEATS];
    logic [SIZE*WIDTH-1:0] exp_mem [ROWS];

    integer in_wr;
    integer in_rd;
    integer exp_wr;
    integer exp_rd;

    logic [WIDTH-1:0] mat_a [SIZE][SIZE];
    logic [WIDTH-1:0] mat_b [SIZE][SIZE];

    integer idle_pct;
    integer stall_pct;
    integer errors;
    integer total_errors;
    integer out_rows;
    integer src_stalls;

    logic                       a_accepted;
    logic                       c_hold;
    logic [SIZE-1:0][WIDTH-1:0] c_prev;

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

    task push_matrix;
        integer t, r, c, k;
        logic [SIZE-1:0][WIDTH-1:0] row;
        logic [WIDTH-1:0]           acc;
        begin
            fill_random;

            for (t = 0; t < SIZE; t = t + 1) begin
                for (k = 0; k < SIZE; k = k + 1) begin
                    row[k] = mat_b[k][SIZE-1-t];
                end
                in_mem[in_wr] = {1'b1, 1'b0, row};
                in_wr = in_wr + 1;
            end

            for (r = 0; r < SIZE; r = r + 1) begin
                for (k = 0; k < SIZE; k = k + 1) begin
                    row[k] = mat_a[r][k];
                end
                in_mem[in_wr] = {1'b0, 1'b1, row};
                in_wr = in_wr + 1;
            end

            for (r = 0; r < SIZE; r = r + 1) begin
                for (c = 0; c < SIZE; c = c + 1) begin
                    acc = 0;
                    for (k = 0; k < SIZE; k = k + 1) begin
                        acc = acc + mat_a[r][k] * mat_b[k][c];
                    end
                    row[c] = acc;
                end
                exp_mem[exp_wr] = row;
                exp_wr = exp_wr + 1;
            end
        end
    endtask

    always @(negedge clk) begin
        if (rst_n) begin
            if (!i_a_vld || a_accepted) begin
                if (in_rd < in_wr && $urandom_range(99) >= idle_pct) begin
                    {i_we, i_c_vld, i_a} = in_mem[in_rd];
                    i_a_vld = 1'b1;
                end
                else begin
                    for (int i = 0; i < SIZE; i = i + 1) begin
                        i_a[i] = WIDTH'($urandom());
                    end
                    i_a_vld = 1'b0;
                    i_c_vld = 1'($urandom());
                    i_we    = 1'($urandom());
                end
            end
            i_c_rdy = ($urandom_range(99) >= stall_pct);
        end
    end

    always @(posedge clk) begin
        a_accepted = 1'b0;
        if (rst_n && i_a_vld) begin
            if (o_a_rdy) begin
                in_rd = in_rd + 1;
                a_accepted = 1'b1;
            end
            else begin
                src_stalls = src_stalls + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n) begin
            if (c_hold && (!o_c_vld || o_c !== c_prev)) begin
                $display("[%0t] ERROR: o_c/o_c_vld changed while stalled", $time);
                errors = errors + 1;
            end
            c_hold = o_c_vld && !i_c_rdy;
            c_prev = o_c;

            if (o_c_vld && i_c_rdy) begin
                if (exp_rd >= exp_wr) begin
                    $display("[%0t] ERROR: extra output vector", $time);
                    errors = errors + 1;
                end
                else begin
                    for (int j = 0; j < SIZE; j = j + 1) begin
                        if (o_c[j] !== exp_mem[exp_rd][j*WIDTH +: WIDTH]) begin
                            $display("[%0t] ERROR: row %0d C[%0d] = %0d, expected %0d",
                                     $time, out_rows, j,
                                     o_c[j], exp_mem[exp_rd][j*WIDTH +: WIDTH]);
                            errors = errors + 1;
                        end
                    end
                    exp_rd = exp_rd + 1;
                end
                out_rows = out_rows + 1;
            end
        end
    end

    task run_test(input integer num, input integer idle, input integer stall);
        integer cycles;
        integer m;
        begin
            idle_pct   = idle;
            stall_pct  = stall;
            errors     = 0;
            out_rows   = 0;
            src_stalls = 0;
            in_wr      = 0;
            in_rd      = 0;
            exp_wr     = 0;
            exp_rd     = 0;

            for (m = 0; m < MATRICES; m = m + 1) begin
                push_matrix;
            end

            cycles = 0;
            while ((in_rd < in_wr || exp_rd < exp_wr) && cycles < 10000) begin
                @(negedge clk);
                cycles = cycles + 1;
            end
            idle_pct = 100;
            repeat (20) @(negedge clk);

            if (in_rd < in_wr || exp_rd < exp_wr) begin
                $display("ERROR: test %0d: stuck, %0d beats not sent, %0d rows not received",
                         num, in_wr - in_rd, exp_wr - exp_rd);
                errors = errors + 1;
            end

            if (errors == 0) begin
                $display("PASS: test %0d (idle %0d%%, stall %0d%%): %0d rows in %0d cycles, %0d src stalls",
                         num, idle, stall, out_rows, cycles, src_stalls);
            end
            else begin
                $display("FAIL: test %0d (idle %0d%%, stall %0d%%): %0d errors",
                         num, idle, stall, errors);
            end
            total_errors = total_errors + errors;
        end
    endtask

    initial begin
        total_errors = 0;
        errors       = 0;
        out_rows     = 0;
        src_stalls   = 0;
        in_wr        = 0;
        in_rd        = 0;
        exp_wr       = 0;
        exp_rd       = 0;
        idle_pct     = 100;
        stall_pct    = 0;
        a_accepted   = 1'b0;
        c_hold       = 1'b0;
        c_prev       = 0;
        rst_n        = 1'b0;
        i_a          = 0;
        i_a_vld      = 1'b0;
        i_c_vld      = 1'b0;
        i_we         = 1'b0;
        i_c_rdy      = 1'b0;

        repeat (4) @(negedge clk);
        rst_n = 1'b1;
        repeat (2) @(negedge clk);

        run_test(0,  0,  0);
        run_test(1, 50,  0);
        run_test(2,  0, 50);
        run_test(3, 50, 50);
        run_test(4, 20, 80);
        run_test(5, 80, 20);
        run_test(6,  0, 95);
        run_test(7, 90, 90);

        if (total_errors == 0) begin
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("TESTS FAILED: %0d errors", total_errors);
        end
        $finish;
    end

    initial begin
        #10000000;
        $display("ERROR: timeout");
        $finish;
    end

endmodule
