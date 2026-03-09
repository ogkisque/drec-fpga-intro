module shift_reg (
    input  wire       clk,
    input  wire       i_en,
    input  wire       i_load,
    input  wire [7:0] i_data,
    output wire       o_bit
);

    reg [7:0] data;
    assign o_bit = data[7];

    always @(posedge clk) begin
        if (i_en) begin
            if (i_load) begin
                data <= i_data;
            end
            else begin
                data <= {data[6:0], 1'b0};
            end
        end
    end

endmodule