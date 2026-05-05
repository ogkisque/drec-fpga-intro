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

    reg [31:0] rd_data0;
    reg [31:0] rd_data1;

    assign o_rd_data0 = rd_data0;
    assign o_rd_data1 = rd_data1;

    always @(*) begin
        if (i_rd_addr0 == 0)
            rd_data0 = 32'd0;
        else if (i_wr_en && i_rd_addr0 == i_wr_addr)
            rd_data0 = i_wr_data;
        else
            rd_data0 = data[i_rd_addr0];
        
        if (i_rd_addr1 == 0)
            rd_data1 = 32'd0;
        else if (i_wr_en && i_rd_addr1 == i_wr_addr)
            rd_data1 = i_wr_data;
        else
            rd_data1 = data[i_rd_addr1];
    end

    always @(posedge clk) begin
        if (i_wr_en) begin
            data[i_wr_addr] <= i_wr_data;
        end
    end

endmodule