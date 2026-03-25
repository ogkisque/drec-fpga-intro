`define OP_LOAD   7'b0000011
`define OP_STORE  7'b0100011
`define OP_IMM    7'b0010011
`define OP_OP     7'b0110011
`define OP_LUI    7'b0110111
`define OP_AUIPC  7'b0010111
`define OP_JAL    7'b1101111
`define OP_JALR   7'b1100111
`define OP_BRANCH 7'b1100011

`define F3_ADD  3'b000
`define F3_SLL  3'b001
`define F3_SLT  3'b010
`define F3_SLTU 3'b011
`define F3_XOR  3'b100
`define F3_SRL  3'b101
`define F3_OR   3'b110
`define F3_AND  3'b111

`define F3_BEQ  3'b000
`define F3_BNE  3'b001
`define F3_BLT  3'b100
`define F3_BGE  3'b101
`define F3_BLTU 3'b110
`define F3_BGEU 3'b111

`define F3_B    3'b000
`define F3_H    3'b001
`define F3_W    3'b010

`define F7_ADD  7'b0000000
`define F7_SUB  7'b0100000
`define F7_SRL  7'b0000000
`define F7_SRA  7'b0100000