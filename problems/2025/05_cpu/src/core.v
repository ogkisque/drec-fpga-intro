module core(
    input wire  clk,
    input wire  rst_n,
    input wire  [31:0] i_instr_data,
    output wire [29:0] o_instr_addr,
    output wire [29:0] o_mem_addr,
    output wire [31:0] o_mem_data,
    output wire o_mem_we,
    output wire [3:0] o_mem_mask,
    input wire  [31:0] i_mem_data
);

reg [31:0] pc;

wire [31:0] u_imm;
wire [31:0] b_imm;
wire [31:0] j_imm;
wire [31:0] i_imm;
wire [31:0] s_imm;

assign i_imm = {{20{i_instr_data[31]}}, i_instr_data[31:20]};
assign s_imm = {{20{i_instr_data[31]}}, i_instr_data[31:25], i_instr_data[11:7]};
assign b_imm = {{19{i_instr_data[31]}}, i_instr_data[31], i_instr_data[7],
                i_instr_data[30:25], i_instr_data[11:8], 1'b0};
assign u_imm = {i_instr_data[31:12], 12'b0};
assign j_imm = {{11{i_instr_data[31]}}, i_instr_data[31], i_instr_data[19:12],
                i_instr_data[20], i_instr_data[30:21], 1'b0};

wire [4:0] rs1_addr;
assign rs1_addr = i_instr_data[19:15];
wire [4:0] rs2_addr;
assign rs2_addr = i_instr_data[24:20];
wire [4:0] rd_addr;
assign rd_addr = i_instr_data[11:7];
wire [31:0] rs1_data
wire [31:0] rs2_data;
wire [31:0] wr_data;
wire wr_en;

wire [1:0] wb_sel;
wire [1:0] alu_sel1;
wire [1:0] alu_sel2;

reg_file reg_file (
    .clk        (clk),
    .i_rd_addr0 (rs1_addr),
    .o_rd_data0 (rs1_data),
    .i_rd_addr1 (rs2_addr),
    .o_rd_data1 (rs2_data),
    .i_wr_addr  (rd_addr),
    .i_wr_data  (wr_data),
    .i_wr_en    (wr_en)
);

wire branch_res;

branch_unit branch_unit (
    .i_a    (rs1_data),
    .i_b    (rs1_data),
    .cmp_op (cmp_op),
    .taken  (branch_res)
);

wire [31:0] alu_a;
wire [31:0] alu_b;
wire [31:0] alu_res;

mux4 mux4_sel_alu_a (
    .i0     (rs1_data),
    .i1     (j_imm),
    .i2     (b_imm),
    .i3     (u_imm),
    .i_sel  (alu_sel1),
    .o_y    (alu_a)
);

mux4 mux4_sel_alu_b (
    .i0     (rs2_data),
    .i1     (i_imm),
    .i2     (s_imm),
    .i3     (pc),
    .i_sel  (alu_sel2),
    .o_y    (alu_b)
);

alu alu (
    .i_a   (alu_a),
    .i_b   (alu_b),
    .i_op  (alu_op),
    .o_res (alu_res)
);

endmodule