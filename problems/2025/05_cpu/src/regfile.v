module reg_file (
    input  wire        clk,

    input  wire [4:0]  i_rd_addr0,
    output wire [31:0] o_rd_data0,

    input  wire [4:0]  i_rd_addr1,
    output wire [31:0] o_rd_data1,

    input  wire [4:0]  i_wr_addr,
    input  wire [31:0] i_wr_data,
    input  wire        i_wr_en
);

    reg [31:0] data [31:0];

    assign o_rd_data0 = data[i_rd_addr0];
    assign o_rd_data1 = data[i_rd_addr1];

    always @(posedge clk) begin
        if (i_wr_en) begin
            data[i_wr_addr] <= i_wr_data;
        end
    end

endmodule