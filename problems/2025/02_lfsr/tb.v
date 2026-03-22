`timescale 1ns/1ps

module tb_lfsr;

reg clk = 1'b0;
reg rst_n = 1'b0;

always begin
    #1 clk <= ~clk;
end

wire [7:0] data;

lfsr lfsr_mod(.clk(clk), .rst_n(rst_n), .o_data(data));

initial begin
    $dumpvars;      /* Open for dump of signals */
    $display("Test started...");   /* Write to console */
    #1
    rst_n = 1'b0;
    #2
    rst_n = 1'b1;

    #50 $finish;    /* Stop simulation after 50ns */
end

always begin
    #1;
    $display("[%0t] data=%b", $realtime, data);
end

endmodule