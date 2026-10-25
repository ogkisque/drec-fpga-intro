module sr #(
    parameter WIDTH = 16
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [WIDTH-1:0]    i_data,
    input  logic                i_vld,

    output logic [WIDTH-1:0]    o_data,
    output logic                o_vld
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_data <= 0;
            o_vld  <= 1'b0;
        end
        else begin
            o_vld <= i_vld;
            if (i_vld) begin
                o_data <= i_data;
            end
        end
    end
endmodule