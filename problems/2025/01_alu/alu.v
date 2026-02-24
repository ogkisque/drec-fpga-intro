`include "alu_ops.vh"

module alu
(
    input  [31:0] i_a,
    input  [31:0] i_b,
    input  [3:0]  i_op,
    output reg [31:0] o_res
);

    wire [4:0] shamt = i_b[4:0];

    always @(*) begin
        case (i_op)
            `ALU_ADD:  o_res = i_a + i_b;
            `ALU_SUB:  o_res = i_a - i_b;
            `ALU_SLL:  o_res = i_a << shamt;
            `ALU_SLT:  o_res = ($signed(i_a) < $signed(i_b)) ? 32'd1 : 32'd0;
            `ALU_SLTU: o_res = (i_a < i_b) ? 32'd1 : 32'd0;
            `ALU_XOR:  o_res = i_a ^ i_b;
            `ALU_SRL:  o_res = i_a >> shamt;
            `ALU_SRA:  o_res = $signed(i_a) >>> shamt;
            `ALU_OR:   o_res = i_a | i_b;
            `ALU_AND:  o_res = i_a & i_b;
            default:   o_res = 32'd0;
        endcase
    end

endmodule