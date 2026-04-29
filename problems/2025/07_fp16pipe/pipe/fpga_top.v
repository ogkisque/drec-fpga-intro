module fpga_top(
    input  wire CLK,   // CLOCK
    input  wire RSTN,  // BUTTON RST (NEGATIVE)
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output reg  [15:0] o_res
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

reg [15:0] a, b;
wire [15:0] c;

always @(posedge CLK) begin
    a <= i_a;
    b <= i_b;
    o_res <= c;
end

fp16add fp16add (
    .clk      (CLK),
    .i_a      (a),
    .i_b      (b),
    .o_res    (c)
);

endmodule
