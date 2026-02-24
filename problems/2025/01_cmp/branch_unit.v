`include "branch_ops.vh"

module branch_unit
(
    input  [31:0] i_a,
    input  [31:0] i_b,
    input  [2:0]  cmp_op,
    output reg    taken
);

    always @(*) begin
        case (cmp_op)
            `BR_BEQ:   taken = (i_a == i_b);
            `BR_BNE:   taken = (i_a != i_b);
            `BR_BLT:   taken = ($signed(i_a) <  $signed(i_b));
            `BR_BGE:   taken = ($signed(i_a) >= $signed(i_b));
            `BR_BLTU:  taken = (i_a <  i_b);
            `BR_BGEU:  taken = (i_a >= i_b);
            default:   taken = 1'b0;
        endcase
    end

endmodule