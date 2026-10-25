module pe #(
    parameter WIDTH = 16
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [WIDTH-1:0]    i_a,
    input  logic                i_a_vld,
    input  logic                i_we,
    input  logic [WIDTH-1:0]    i_c,
    input  logic                i_c_vld,

    output logic [WIDTH-1:0]    o_a,
    output logic                o_a_vld,
    output logic                o_we,
    output logic [WIDTH-1:0]    o_c,
    output logic                o_c_vld
);
    logic [WIDTH-1:0] b;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_a_vld <= 1'b0;
            o_we    <= 1'b0;
        end
        else begin
            o_a_vld <= i_a_vld;
            o_we    <= i_we;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            b   <= 0;
            o_a <= 0;
        end
        else if (i_a_vld) begin
            if (i_we) begin
                b   <= i_a;
                o_a <= b;
            end
            else begin
                o_a <= i_a;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_c     <= 0;
            o_c_vld <= 1'b0;
        end
        else begin
            o_c_vld <= i_a_vld & i_c_vld;
            if (i_a_vld & i_c_vld) begin
                o_c <= i_c + i_a * b;
            end
        end
    end
endmodule