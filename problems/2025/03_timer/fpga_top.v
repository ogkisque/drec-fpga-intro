module fpga_top(
    input  wire CLK,   // CLOCK
    input  wire RSTN,  // BUTTON RST (NEGATIVE)
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n  <= RSTN_d;
    RSTN_d <= RSTN;
end

wire [3:0]  anodes;
wire [7:0]  segments;
wire [15:0] cnt;
wire        clk_10Hz;

counter600 counter600_mod (
    .clk   (clk_10Hz),
    .rst_n (rst_n),
    .o_cnt (cnt)
);

hex_display hex_display_mod (
    .clk       (CLK),
    .rst_n     (rst_n),
    .i_data    (cnt),
    .o_anodes  (anodes),
    .o_segments(segments)
);

ctrl_74hc595 ctrl(
    .clk    (CLK),
    .rst_n  (rst_n),
    .i_data ({segments, anodes}),
    .o_stcp (STCP),
    .o_shcp (SHCP),
    .o_ds   (DS),
    .o_oe   (OE)
);

clkdiv #(
    .F0(50_000_000),
    .F1(10)
) clkdiv_mod(.clk(CLK), .rst_n(rst_n), .out(clk_10Hz));

endmodule