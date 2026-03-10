`timescale 1ns/1ps

module tb_shift_reg;

    reg clk = 1'b0;
    reg i_en;
    reg i_load;
    reg [7:0] i_data;
    reg i_bit;
    wire o_bit;

    shift_reg shift_reg_mod (
        .clk   (clk),
        .i_en  (i_en),
        .i_load(i_load),
        .i_data(i_data),
        .i_bit (i_bit),
        .o_bit (o_bit)
    );

    always begin
        #1 clk <= ~clk;
    end

    initial begin
        $dumpvars;      /* Open for dump of signals */
        $display("Test started...");   /* Write to console */

        i_en   = 1'b0;
        i_load = 1'b0;
        i_data = 8'b00000000;
        i_bit  = 1'b0;
        #1

        i_en   = 1'b1;
        i_load = 1'b1;
        i_data = 8'b10110011;
        #1

        i_load = 1'b0;
        i_data = 8'b0;
        #2

        i_en = 1'b0;
        #4

        i_en = 1'b1;

        #20 $finish;
    end

    always begin
        #1;
        @(posedge clk);
        $display("[%0t] en=%b load=%b i_data=%b i_bit=%b | o_bit=%b",
                 $realtime, i_en, i_load, i_data, i_bit, o_bit);
    end

endmodule