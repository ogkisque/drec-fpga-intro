`include "const.vh"

module lsu (
    input  wire        i_mem_write,
    input  wire        i_mem_read,
    input  wire [2:0]  i_funct3,
    input  wire [31:0] i_addr,
    input  wire [31:0] i_mem_data,
    output reg  [3:0]  o_mem_mask,
    output reg  [31:0] o_mem_data,
    output wire [29:0] o_mem_addr,
    input  wire [31:0] i_data,
    output reg  [31:0] o_data
);

    assign o_mem_addr = i_addr[31:2];

    always @(*) begin
        o_mem_mask = 4'd0;
        if (i_mem_write) begin
            o_mem_data = i_data;
            case (i_funct3)
                `F3_B: begin
                    case (i_addr[1:0])
                        2'b00: o_mem_mask = 4'b0001;
                        2'b01: o_mem_mask = 4'b0010;
                        2'b10: o_mem_mask = 4'b0100;
                        2'b11: o_mem_mask = 4'b1000;
                        default: o_mem_mask = 4'b0000;
                    endcase
                end
                `F3_H: begin
                    case (i_addr[1:0])
                        2'b00: o_mem_mask = 4'b0011;
                        2'b10: o_mem_mask = 4'b1100;
                        default: o_mem_mask = 4'b0000;
                    endcase
                end
                `F3_W: begin
                    case (i_addr[1:0])
                        2'b00: o_mem_mask = 4'b1111;
                        default: o_mem_mask = 4'b0000;
                    endcase
                end
                default: o_mem_mask = 4'b0000;
            endcase
        end
    end

    always @(*) begin
        o_data = 32'd0;
        if (i_mem_read) begin
            case (i_funct3)
                `F3_B: begin
                    o_data = {{24{i_mem_data[7]}}, i_mem_data[7:0]};
                end
                `F3_H: begin
                    o_data = {{16{i_mem_data[15]}}, i_mem_data[15:0]};
                end
                `F3_W: begin
                    o_data = i_mem_data;
                end
                `F3_BU: begin
                    o_data = {24'd0, i_mem_data[7:0]};
                end
                `F3_HU: begin
                    o_data = {16'd0, i_mem_data[15:0]};
                end
                default: o_data = 32'd0;
            endcase
        end
    end
endmodule