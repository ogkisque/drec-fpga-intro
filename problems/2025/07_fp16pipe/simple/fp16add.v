module normal_mant (
    input [11:0] i_val,
    output reg [11:0] o_val,
    output reg [3:0]  o_lshift
);

    always @(*) begin
        if (i_val == 12'd0) begin
            o_val = 12'd0;
            o_lshift = 4'd0;
        end
        else begin
            casez (i_val)
                12'b1???????????: o_lshift = 4'd0;
                12'b01??????????: o_lshift = 4'd1;
                12'b001?????????: o_lshift = 4'd2;
                12'b0001????????: o_lshift = 4'd3;
                12'b00001???????: o_lshift = 4'd4;
                12'b000001??????: o_lshift = 4'd5;
                12'b0000001?????: o_lshift = 4'd6;
                12'b00000001????: o_lshift = 4'd7;
                12'b000000001???: o_lshift = 4'd8;
                12'b0000000001??: o_lshift = 4'd9;
                12'b00000000001?: o_lshift = 4'd10;
                12'b000000000001: o_lshift = 4'd11;
                default:          o_lshift = 4'd0;
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

    reg signed [6:0] exp_res;
    reg [4:0] shift;

    reg [11:0] m_ext_big, m_ext_sml;

    reg [12:0] m_ext_sum;
    reg [11:0] m_ext_diff;
    reg [11:0] m_ext_norm;

    wire [11:0] norm_val;
    wire [3:0]  norm_lshift;

    normal_mant normal_mant_mod (
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

            ma = (ea == 5'd0) ? 11'd0 : {1'b1, fa};
            mb = (eb == 5'd0) ? 11'd0 : {1'b1, fb};

            if ((ea > eb) || ((ea == eb) && (ma >= mb))) begin
                s_big = sa;
                e_big = ea;
                m_big = ma;
                s_sml = sb;
                e_sml = eb;
                m_sml = mb;
            end
            else begin
                s_big = sb;
                e_big = eb;
                m_big = mb;
                s_sml = sa;
                e_sml = ea;
                m_sml = ma;
            end

            exp_res = $signed({1'b0, e_big});
            shift = e_big - e_sml;

            m_ext_big = {m_big, 1'b0};
            m_ext_sml = {m_sml, 1'b0};

            if (shift >= 5'd12)
                m_ext_sml = 12'd0;
            else
                m_ext_sml = m_ext_sml >> shift;

            if (s_big == s_sml) begin
                m_ext_sum = {1'b0, m_ext_big} + {1'b0, m_ext_sml};

                if (m_ext_sum[12]) begin
                    m_ext_norm = m_ext_sum[12:1];
                    exp_res = exp_res + 7'd1;
                end
                else begin
                    m_ext_norm = m_ext_sum[11:0];
                end
            end
            else begin
                m_ext_diff = m_ext_big - m_ext_sml;

                if (m_ext_diff == 12'd0) begin
                    m_ext_norm = 12'd0;
                    exp_res = 7'd0;
                end else begin
                    m_ext_norm = norm_val;
                    exp_res = exp_res - $signed({3'b000, norm_lshift});
                end
            end

            sr = s_big;
            if (m_ext_norm == 12'd0) begin
                o_res = 16'h0000;
            end
            else if (exp_res >= 7'd31) begin
                o_res = {sr, 5'h1F, 10'd0};
            end
            else if (exp_res <= 0) begin
                o_res = {sr, 5'd0, 10'd0};
            end
            else begin
                o_res = {sr, exp_res[4:0], m_ext_norm[10:1]};
            end
        end
    end

endmodule