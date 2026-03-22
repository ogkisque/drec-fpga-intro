module lfsr (
    input wire clk,
    input wire rst_n,
    output wire [7:0] o_data
);

    reg [7:0] data;

    wire new_bit;
    assign new_bit = data[7] ^ data[5] ^ data[4] ^ data[3];
    assign o_data = data;

    always @(posedge clk or negedge rst_n) begin
        data <= !rst_n ? 8'b00000001 : {data[6:0], new_bit};
    end

endmodule