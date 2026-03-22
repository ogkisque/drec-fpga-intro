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

wire [15:0] rnd_data;
wire [3:0]  anodes;
wire [7:0]  segments;
wire clk_1Hz;

clkdiv #(
    .F0(50_000_000),
    .F1(1)
) clkdiv_mod(.clk(CLK), .rst_n(rst_n), .out(clk_1Hz));

lfsr lfsr_mod (
    .clk   (clk_1Hz),
    .rst_n (rst_n),
    .o_data(rnd_data)
);

hex_display hex_display_mod (
    .clk       (CLK),
    .rst_n     (rst_n),
    .i_data    (rnd_data),
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

endmodule