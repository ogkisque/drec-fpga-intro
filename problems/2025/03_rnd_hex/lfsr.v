module lfsr (
    input  wire        clk,
    input  wire        rst_n,
    output wire [15:0] o_data
);

    reg [15:0] data;

    wire new_bit;
    assign new_bit = data[15] ^ data[13] ^ data[12] ^ data[10];

    assign o_data = data;

    always @(posedge clk or negedge rst_n) begin
        data <= !rst_n ? 16'h0001 : {data[14:0], new_bit};
    end

endmodule