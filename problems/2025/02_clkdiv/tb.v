`timescale 1ns/1ps

module testbench;

reg clk   = 1'b0;
reg rst_n = 1'b0;

always begin
    #1 clk <= ~clk;
end

initial begin
    repeat (3) @(posedge clk);
    rst_n <= 1'b1;
end

wire clkdiv_out_9600;
wire clkdiv_out_38400;
wire clkdiv_out_115200;

clkdiv #(
    .F0(50_000_000),
    .F1(9_600)
) clkdiv_9600(.clk(clk), .rst_n(rst_n), .out(clkdiv_out_9600));

clkdiv #(
    .F0(50_000_000),
    .F1(38_400)
) clkdiv_38400(.clk(clk), .rst_n(rst_n), .out(clkdiv_out_38400));

clkdiv #(
    .F0(50_000_000),
    .F1(115_200)
) clkdiv_115200(.clk(clk), .rst_n(rst_n), .out(clkdiv_out_115200));

initial begin
    $dumpvars;      /* Open for dump of signals */
    $display("Test started...");   /* Write to console */
    #1000000 $finish;    /* Stop simulation after 50ns */
end

endmodule

