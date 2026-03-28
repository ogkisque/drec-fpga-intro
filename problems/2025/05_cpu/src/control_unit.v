`include "const.vh"
`include "alu_ops.vh"
`include "branch_ops.vh"

module control_unit(
    input  wire [31:0]  i_instr,
    output reg  [3:0]   o_alu_op,
    output reg  [1:0]   o_alu_sel1,
    output reg  [1:0]   o_alu_sel2,
    output reg          o_need_reg_write,
    output reg  [1:0]   o_wb_sel,
    output reg  [2:0]   o_cmp_op,
    output reg          o_branch,
    output reg          o_jump,
    output reg          o_mem_write,
    output reg          o_mem_read
);

wire [6:0] opcode;
assign opcode = i_instr[6:0];
wire [3:0] funct3;
assign funct3 = i_instr[14:12];
wire [6:0] funct7;
assign funct7 = i_instr[31:25];

always @(*) begin

    case (opcode)
        `OP_OP: begin
            o_alu_sel1       <= 2'b00;
            o_alu_sel2       <= 2'b00;
            o_wb_sel         <= 2'b00;
            o_need_reg_write <= 1'b1;
            case (funct3)
                `F3_ADD:  o_alu_op <= (funct7 == `F7_ADD) ? `ALU_ADD : `ALU_SUB;
                `F3_SLL:  o_alu_op <= `ALU_SLL;
                `F3_SLT:  o_alu_op <= `ALU_SLT;
                `F3_SLTU: o_alu_op <= `ALU_SLTU;
                `F3_XOR:  o_alu_op <= `ALU_XOR;
                `F3_SRL:  o_alu_op <= (funct7 == `F7_SRL) ? `ALU_SRL : `ALU_SRA;
                `F3_OR:   o_alu_op <= `ALU_OR;
                `F3_AND:  o_alu_op <= `ALU_AND;
            endcase
            o_branch         <= 1'b0;
            o_jump           <= 1'b0;
            o_mem_write      <= 1'b0;
            o_mem_read       <= 1'b0;
        end

        `OP_IMM: begin
            o_alu_sel1       <= 2'b00;
            o_alu_sel2       <= 2'b01;
            o_wb_sel         <= 2'b00;
            o_need_reg_write <= 1'b1;
            case (funct3)
                `F3_ADD:  o_alu_op = `ALU_ADD;
                `F3_SLL:  o_alu_op = `ALU_SLL;
                `F3_SLT:  o_alu_op = `ALU_SLT;
                `F3_SLTU: o_alu_op = `ALU_SLTU;
                `F3_XOR:  o_alu_op = `ALU_XOR;
                `F3_SRL:  o_alu_op = (funct7 == `F7_SRL) ? `ALU_SRL : `ALU_SRA;
                `F3_OR:   o_alu_op = `ALU_OR;
                `F3_AND:  o_alu_op = `ALU_AND;
            endcase
            o_branch         <= 1'b0;
            o_jump           <= 1'b0;
            o_mem_write      <= 1'b0;
            o_mem_read       <= 1'b0;
        end

        `OP_LOAD: begin
            o_alu_sel1       <= 2'b00;
            o_alu_sel2       <= 2'b01;
            o_wb_sel         <= 2'b01;
            o_need_reg_write <= 1'b1;
            o_alu_op         <= `ALU_ADD;
            o_branch         <= 1'b0;
            o_jump           <= 1'b0;
            o_mem_write      <= 1'b0;
            o_mem_read       <= 1'b1;
        end

        `OP_STORE: begin
            o_alu_sel1       <= 2'b00;
            o_alu_sel2       <= 2'b10;
            o_need_reg_write <= 1'b0;
            o_alu_op         <= `ALU_ADD;
            o_branch         <= 1'b0;
            o_jump           <= 1'b0;
            o_mem_write      <= 1'b1;
            o_mem_read       <= 1'b0;
        end

        `OP_BRANCH: begin
            o_alu_sel1       <= 2'b10;
            o_alu_sel2       <= 2'b11;
            o_need_reg_write <= 1'b0;
            o_alu_op         <= `ALU_ADD;
            o_branch         <= 1'b1;
            case (funct3)
                `F3_BEQ:  o_cmp_op <= `BR_BEQ;
                `F3_BNE:  o_cmp_op <= `BR_BNE;
                `F3_BLT:  o_cmp_op <= `BR_BLT;
                `F3_BGE:  o_cmp_op <= `BR_BGE;
                `F3_BLTU: o_cmp_op <= `BR_BLTU;
                `F3_BGEU: o_cmp_op <= `BR_BGEU;
            endcase
            o_jump           <= 1'b0;
            o_mem_write      <= 1'b0;
            o_mem_read       <= 1'b0;
        end

        `OP_JALR: begin
            o_alu_sel1       <= 2'b00;
            o_alu_sel2       <= 2'b01;
            o_need_reg_write <= 1'b1;
            o_wb_sel         <= 2'b10;
            o_alu_op         <= `ALU_ADD;
            o_branch         <= 1'b0;
            o_jump           <= 1'b1;
            o_mem_write      <= 1'b0;
            o_mem_read       <= 1'b0;
        end

        `OP_JAL: begin
            o_alu_sel1       <= 2'b01;
            o_alu_sel2       <= 2'b11;
            o_need_reg_write <= 1'b1;
            o_wb_sel         <= 2'b10;
            o_alu_op         <= `ALU_ADD;
            o_branch         <= 1'b0;
            o_jump           <= 1'b1;
            o_mem_write      <= 1'b0;
            o_mem_read       <= 1'b0;
        end

        `OP_LUI: begin
            o_need_reg_write <= 1'b1;
            o_wb_sel         <= 2'b11;
            o_branch         <= 1'b0;
            o_jump           <= 1'b0;
            o_mem_write      <= 1'b0;
            o_mem_read       <= 1'b0;
        end

        `OP_AUIPC: begin
            o_alu_sel1       <= 2'b11;
            o_alu_sel2       <= 2'b11;
            o_alu_op         <= `ALU_ADD;
            o_need_reg_write <= 1'b1;
            o_wb_sel         <= 2'b00;
            o_branch         <= 1'b0;
            o_jump           <= 1'b0;
            o_mem_write      <= 1'b0;
            o_mem_read       <= 1'b0;
        end
    endcase

end

endmodule