module counter600 (
    input         clk,
    input         rst_n,
    output [15:0] o_cnt
);

reg [15:0] cnt;

assign o_cnt = cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= 15'd600;
    else
        if (cnt == 15'd0)
            cnt <= 15'd600;
        else
            cnt <= cnt - 15'd1;
end

endmodule