module lfsr_8bit (
    input  wire       clk,
    input  wire       i_en,
    output wire [7:0] o_data
);

    reg [7:0] r_lfsr = 8'b00000001;

    wire new_bit;
    assign new_bit = r_lfsr[7] ^ r_lfsr[5] ^ r_lfsr[4] ^ r_lfsr[3];
    assign o_data = r_lfsr;

    always @(posedge clk) begin
        if (i_en) begin
            r_lfsr <= {r_lfsr[6:0], new_bit};
        end
    end

endmodule