module fp16mul (
    input  [15:0] i_a,
    input  [15:0] i_b,
    output reg [15:0] o_res
);

    reg        sa, sb, sr;
    reg [4:0]  ea, eb;
    reg [9:0]  fa, fb;

    reg a_is_zero, b_is_zero;
    reg a_is_sub,  b_is_sub;
    reg a_is_inf,  b_is_inf;
    reg a_is_nan,  b_is_nan;

    reg [10:0] ma, mb;
    reg [21:0] m_tmp;

    reg [5:0]  exp_res;
    reg [10:0] mant_res;

    always @(*) begin
        sa = i_a[15]; ea = i_a[14:10]; fa = i_a[9:0];
        sb = i_b[15]; eb = i_b[14:10]; fb = i_b[9:0];
        sr = sa ^ sb;

        a_is_zero = (ea == 5'd0)  && (fa == 10'd0);
        b_is_zero = (eb == 5'd0)  && (fb == 10'd0);

        a_is_sub  = (ea == 5'd0)  && (fa != 10'd0);
        b_is_sub  = (eb == 5'd0)  && (fb != 10'd0);

        a_is_inf  = (ea == 5'h1F) && (fa == 10'd0);
        b_is_inf  = (eb == 5'h1F) && (fb == 10'd0);

        a_is_nan  = (ea == 5'h1F) && (fa != 10'd0);
        b_is_nan  = (eb == 5'h1F) && (fb != 10'd0);

        o_res = 16'h0000;

        if (a_is_nan || b_is_nan) begin
            o_res = 16'h7E00;
        end else if ((a_is_inf && (b_is_zero || b_is_sub)) || (b_is_inf && (a_is_zero || a_is_sub))) begin
            o_res = 16'h7E00;
        end else if (a_is_inf || b_is_inf) begin
            o_res = {sr, 5'h1F, 10'd0};
        end else if (a_is_zero || b_is_zero || a_is_sub || b_is_sub) begin
            o_res = {sr, 5'd0, 10'd0};
        end else begin
            ma   = {1'b1, fa};
            mb   = {1'b1, fb};
            m_tmp = ma * mb;

            exp_res = ea + eb - 5'd15;

            if (m_tmp[21]) begin
                // [2.0, 4.0)
                mant_res  = m_tmp[21:11];
                exp_res = exp_res + 6'd1;
            end else begin
                // [1.0, 2.0)
                mant_res  = m_tmp[20:10];
            end

            if (exp_res >= 6'd31) begin
                o_res = {sr, 5'h1F, 10'd0};
            end else if (exp_res <= 6'd0) begin
                o_res = {sr, 5'd0, 10'd0};
            end else begin
                o_res    = {sr, exp_res[4:0], mant_res[9:0]};
            end
        end
    end

endmodule