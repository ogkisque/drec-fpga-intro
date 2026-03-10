module lfsr (
    input wire clk,
    output wire [7:0] o_data
);

    reg [7:0] data = 8'b00000001;

    wire new_bit;
    assign new_bit = data[7] ^ data[5] ^ data[4] ^ data[3];
    assign o_data = data;

    always @(posedge clk) begin
        data <= {data[6:0], new_bit};
    end

endmodule