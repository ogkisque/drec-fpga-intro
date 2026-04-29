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
    input  wire         clk,
    input  [15:0]       i_a,
    input  [15:0]       i_b,
    output reg [15:0]   o_res
);
    reg        sa1, sb1;
    reg [4:0]  ea1, eb1;
    reg [9:0]  fa1, fb1;

    reg a_is_sub1,  b_is_sub1;
    reg a_is_inf1,  b_is_inf1;
    reg a_is_nan1,  b_is_nan1;

    reg [15:0] res1;
    reg res_ready1;

    reg [10:0] ma1, mb1;

    reg        s_big1, s_sml1;
    reg [4:0]  e_big1, e_sml1;
    reg [10:0] m_big1, m_sml1;

    always @(*) begin
        sa1 = i_a[15];
        ea1 = i_a[14:10];
        fa1 = i_a[9:0];

        sb1 = i_b[15];
        eb1 = i_b[14:10];
        fb1 = i_b[9:0];

        a_is_sub1  = (ea1 == 5'd0)  && (fa1 != 10'd0);
        b_is_sub1  = (eb1 == 5'd0)  && (fb1 != 10'd0);

        a_is_inf1  = (ea1 == 5'h1F) && (fa1 == 10'd0);
        b_is_inf1  = (eb1 == 5'h1F) && (fb1 == 10'd0);

        a_is_nan1  = (ea1 == 5'h1F) && (fa1 != 10'd0);
        b_is_nan1  = (eb1 == 5'h1F) && (fb1 != 10'd0);

        if (!(a_is_nan1 || b_is_nan1) &&
            !(a_is_inf1 && b_is_inf1 && (sa1 != sb1)) &&
            !a_is_inf1 && b_is_inf1) begin
            if (a_is_sub1) begin
                ea1 = 5'd0;
                fa1 = 10'd0;
            end

            if (b_is_sub1) begin
                eb1 = 5'd0;
                fb1 = 10'd0;
            end
        end
    end

    always @(*) begin
        res_ready1 = 1'b1;
        if (a_is_nan1 || b_is_nan1) begin
            res1 = 16'h7E00;
        end
        else if (a_is_inf1 && b_is_inf1 && (sa1 != sb1)) begin
            res1 = 16'h7E00;
        end
        else if (a_is_inf1) begin
            res1 = {sa1, 5'h1F, 10'd0};
        end
        else if (b_is_inf1) begin
            res1 = {sb1, 5'h1F, 10'd0};
        end
        else begin
            res_ready1 = 1'b0;

            ma1 = (ea1 == 5'd0) ? 11'd0 : {1'b1, fa1};
            mb1 = (eb1 == 5'd0) ? 11'd0 : {1'b1, fb1};

            if ((ea1 > eb1) || ((ea1 == eb1) && (ma1 >= mb1))) begin
                s_big1 = sa1;
                e_big1 = ea1;
                m_big1 = ma1;
                s_sml1 = sb1;
                e_sml1 = eb1;
                m_sml1 = mb1;
            end
            else begin
                s_big1 = sb1;
                e_big1 = eb1;
                m_big1 = mb1;
                s_sml1 = sa1;
                e_sml1 = ea1;
                m_sml1 = ma1;
            end
        end
    end
    ///////////////////////////////////////////////////
    reg signed [6:0] exp_res;
    reg [4:0] shift;

    reg [11:0] m_ext_big, m_ext_sml;

    reg [12:0] m_ext_sum;
    reg [11:0] m_ext_diff;
    reg [11:0] m_ext_norm;

    wire [11:0] norm_val;
    wire [3:0]  norm_lshift;

    reg [15:0] res2;
    reg res_ready2;

    reg        s_big2, s_sml2;
    reg [4:0]  e_big2, e_sml2;
    reg [10:0] m_big2, m_sml2;
    reg sr;

    always @(posedge clk) begin
        res2 <= res1;
        res_ready2 <= res_ready1;
        s_big2 <= s_big1;
        s_sml2 <= s_sml1;
        e_big2 <= e_big1;
        e_sml2 <= e_sml1;
        m_big2 <= m_big1;
        m_sml2 <= m_sml1;
    end

    normal_mant normal_mant_mod (
        .i_val   (m_ext_diff),
        .o_val   (norm_val),
        .o_lshift(norm_lshift)
    );

    always @(*) begin
        if (res_ready2) begin
            o_res = res2;
        end
        else begin
            exp_res = $signed({1'b0, e_big2});
            shift = e_big2 - e_sml2;

            m_ext_big = {m_big2, 1'b0};
            m_ext_sml = {m_sml2, 1'b0};

            if (shift >= 5'd12)
                m_ext_sml = 12'd0;
            else
                m_ext_sml = m_ext_sml >> shift;

            if (s_big2 == s_sml2) begin
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

            sr = s_big2;
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