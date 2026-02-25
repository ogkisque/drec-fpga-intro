module norm_lshift14 (
    input  [13:0] i_val,
    output reg [13:0] o_val,
    output reg [4:0]  o_lshift
);

    always @(*) begin
        if (i_val == 14'd0) begin
            o_val    = 14'd0;
            o_lshift = 5'd0;
        end else begin
            casez (i_val)
                14'b1?????????????: o_lshift = 5'd0;
                14'b01????????????: o_lshift = 5'd1;
                14'b001???????????: o_lshift = 5'd2;
                14'b0001??????????: o_lshift = 5'd3;
                14'b00001?????????: o_lshift = 5'd4;
                14'b000001????????: o_lshift = 5'd5;
                14'b0000001???????: o_lshift = 5'd6;
                14'b00000001??????: o_lshift = 5'd7;
                14'b000000001?????: o_lshift = 5'd8;
                14'b0000000001????: o_lshift = 5'd9;
                14'b00000000001???: o_lshift = 5'd10;
                14'b000000000001??: o_lshift = 5'd11;
                14'b0000000000001?: o_lshift = 5'd12;
                14'b00000000000001: o_lshift = 5'd13;
                default:            o_lshift = 5'd0;
            endcase

            o_val = i_val << o_lshift;
        end
    end

endmodule

module fp16add (
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

    reg        s_big, s_sml;
    reg [4:0]  e_big, e_sml;
    reg [10:0] m_big, m_sml;

    reg [5:0]  exp_res;
    reg [4:0]  shift;

    reg [13:0] m_ext_big, m_ext_sml, m_ext_sml_shifted;

    reg [14:0] m_ext_sum;
    reg [13:0] m_ext_diff;
    reg [13:0] m_ext_norm;

    wire [13:0] norm_val;
    wire [4:0]  norm_lshift;

    norm_lshift14 norm_lshift14_mod (
        .i_val   (m_ext_diff),
        .o_val   (norm_val),
        .o_lshift(norm_lshift)
    );

    always @(*) begin
        sa = i_a[15];
        ea = i_a[14:10];
        fa = i_a[9:0];

        sb = i_b[15];
        eb = i_b[14:10];
        fb = i_b[9:0];

        a_is_zero = (ea == 5'd0)  && (fa == 10'd0);
        b_is_zero = (eb == 5'd0)  && (fb == 10'd0);

        a_is_sub  = (ea == 5'd0)  && (fa != 10'd0);
        b_is_sub  = (eb == 5'd0)  && (fb != 10'd0);

        a_is_inf  = (ea == 5'h1F) && (fa == 10'd0);
        b_is_inf  = (eb == 5'h1F) && (fb == 10'd0);

        a_is_nan  = (ea == 5'h1F) && (fa != 10'd0);
        b_is_nan  = (eb == 5'h1F) && (fb != 10'd0);

        o_res               = 16'h0000;
        ma                  = 11'd0;
        mb                  = 11'd0;
        s_big               = 1'b0;
        s_sml               = 1'b0;
        e_big               = 5'd0;
        e_sml               = 5'd0;
        m_big               = 11'd0;
        m_sml               = 11'd0;
        exp_res             = 6'd0;
        shift               = 5'd0;
        m_ext_big           = 14'd0;
        m_ext_sml           = 14'd0;
        m_ext_sml_shifted   = 14'd0;
        m_ext_sum           = 15'd0;
        m_ext_diff          = 14'd0;
        m_ext_norm          = 14'd0;
        sr                  = 1'b0;

        if (a_is_nan || b_is_nan) begin
            o_res = 16'h7E00;
        end
        else if (a_is_inf && b_is_inf && (sa != sb)) begin
            o_res = 16'h7E00;
        end
        else if (a_is_inf) begin
            o_res = {sa, 5'h1F, 10'd0};
        end
        else if (b_is_inf) begin
            o_res = {sb, 5'h1F, 10'd0};
        end
        else begin
            if (a_is_sub) begin
                ea = 5'd0;
                fa = 10'd0;
            end

            if (b_is_sub) begin
                eb = 5'd0;
                fb = 10'd0;
            end

            if ((ea == 5'd0) && (fa == 10'd0) &&
                (eb == 5'd0) && (fb == 10'd0)) begin
                o_res = 16'h0000;
            end
            else if ((ea == 5'd0) && (fa == 10'd0)) begin
                o_res = {sb, eb, fb};
            end
            else if ((eb == 5'd0) && (fb == 10'd0)) begin
                o_res = {sa, ea, fa};
            end
            else begin
                ma = {1'b1, fa};
                mb = {1'b1, fb};

                if ((ea > eb) || ((ea == eb) && (ma >= mb))) begin
                    s_big = sa; e_big = ea; m_big = ma;
                    s_sml = sb; e_sml = eb; m_sml = mb;
                end else begin
                    s_big = sb; e_big = eb; m_big = mb;
                    s_sml = sa; e_sml = ea; m_sml = ma;
                end

                exp_res  = {1'b0, e_big};
                shift = e_big - e_sml;

                m_ext_big = {m_big, 3'b000};
                m_ext_sml = {m_sml, 3'b000};

                if (shift >= 5'd14)
                    m_ext_sml_shifted = 14'd0;
                else
                    m_ext_sml_shifted = m_ext_sml >> shift;

                if (s_big == s_sml) begin
                    m_ext_sum = {1'b0, m_ext_big} + {1'b0, m_ext_sml_shifted};
                    sr = s_big;

                    if (m_ext_sum[14]) begin
                        m_ext_norm = m_ext_sum[14:1];
                        exp_res = exp_res + 6'd1;
                    end else begin
                        m_ext_norm = m_ext_sum[13:0];
                    end
                end else begin
                    m_ext_diff = m_ext_big - m_ext_sml_shifted;
                    sr = s_big;

                    if (m_ext_diff == 14'd0) begin
                        m_ext_norm = 14'd0;
                        exp_res = 6'd0;
                    end else begin
                        m_ext_norm = norm_val;
                        if (exp_res > norm_lshift)
                            exp_res = exp_res - norm_lshift;
                        else
                            exp_res = 6'd0;
                    end
                end

                if (m_ext_norm == 14'd0) begin
                    o_res = 16'h0000;
                end
                else if (exp_res >= 6'd31) begin
                    o_res = {sr, 5'h1F, 10'd0};
                end
                else if (exp_res <= 6'd0) begin
                    o_res = {sr, 5'd0, 10'd0};
                end
                else begin
                    o_res    = {sr, exp_res[4:0], m_ext_norm[12:3]};
                end
            end
        end
    end

endmodule