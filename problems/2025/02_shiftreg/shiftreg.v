module shift_reg_8bit (
    input  wire       clk,
    input  wire       i_en,
    input  wire       i_load,
    input  wire [7:0] i_data,
    output wire       o_bit
);

    reg [7:0] r_shift;
    assign o_bit = r_shift[7];

    always @(posedge clk) begin
        if (i_en) begin
            if (i_load) begin
                r_shift <= i_data;
            end
            else begin
                r_shift <= {r_shift[6:0], 1'b0};
            end
        end
    end

endmodule