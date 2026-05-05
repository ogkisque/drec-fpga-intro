module core(
    input  wire  clk,
    input  wire  rst_n,
    input  wire [31:0] i_instr_data,
    output wire [29:0] o_instr_addr,
    output wire o_instr_stall,
    output wire [29:0] o_mem_addr,
    output wire [31:0] o_mem_data,
    output wire o_mem_we,
    output wire [3:0] o_mem_mask,
    input  wire [31:0] i_mem_data
);

reg [29:0] pc;
reg [29:0] pc_next;
assign o_instr_addr = pc_next;
assign o_instr_stall = 1'd0;

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
wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [31:0] wr_data;
wire wr_en;

wire [1:0] wb_sel;
wire [1:0] alu_sel1;
wire [1:0] alu_sel2;
wire [3:0] alu_op;
wire [2:0] cmp_op;
wire branch;
wire jump;
wire branch_res;
wire [31:0] alu_a;
wire [31:0] alu_b;
wire [31:0] alu_res;
wire mem_write;
wire mem_read;
wire need_reg_write;
wire [31:0] lsu_data;

assign o_mem_we = mem_write;
assign wr_en = need_reg_write && (rd_addr != 5'b0);

reg_file reg_file (
    .clk        (clk),
    .i_rd_addr0 (rs1_addr),
    .o_rd_data0 (rs1_data),
    .i_rd_addr1 (rs2_addr),
    .o_rd_data1 (rs2_data),
    .i_wr_addr  (f1_rd_addr),
    .i_wr_data  (wr_data),
    .i_wr_en    (f1_wr_en)
);

control_unit control_unit(
    .i_instr            (i_instr_data),
    .o_alu_op           (alu_op),
    .o_alu_sel1         (alu_sel1),
    .o_alu_sel2         (alu_sel2),
    .o_need_reg_write   (need_reg_write),
    .o_wb_sel           (wb_sel),
    .o_cmp_op           (cmp_op),
    .o_branch           (branch),
    .o_jump             (jump),
    .o_mem_write        (mem_write),
    .o_mem_read         (mem_read)
);

branch_unit branch_unit (
    .i_a    (rs1_data),
    .i_b    (rs2_data),
    .cmp_op (cmp_op),
    .taken  (branch_res)
);

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
    .i3     ({pc, 2'b00}),
    .i_sel  (alu_sel2),
    .o_y    (alu_b)
);

alu alu (
    .i_a   (alu_a),
    .i_b   (alu_b),
    .i_op  (alu_op),
    .o_res (alu_res)
);

lsu lsu (
    .i_mem_write (mem_write),
    .i_mem_read (mem_read),
    .i_funct3 (i_instr_data[14:12]),
    .i_addr (alu_res),
    .i_mem_data (i_mem_data),
    .o_mem_mask (o_mem_mask),
    .o_mem_data (o_mem_data),
    .o_mem_addr (o_mem_addr),
    .i_data     (rs2_data),
    .o_data     (lsu_data)
);

wire [29:0] pc_inc;
assign pc_inc = pc + 30'd1;

wire taken = jump | (branch && branch_res);
always @(*) begin
    if (taken) begin
        pc_next = alu_res >> 2;
    end
    else begin
        pc_next = pc_inc;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= 30'd0;
    end
    else begin
        pc <= pc_next;
    end
end

reg [31:0] f1_alu_res;
reg [1:0] f1_wb_sel;
reg [31:0] f1_u_imm;
reg [31:0] f1_rd_addr;
reg [29:0] f1_pc_inc;
reg f1_wr_en;

always @(posedge clk) begin
    f1_alu_res <= alu_res;
    f1_wb_sel <= wb_sel;
    f1_u_imm <= u_imm;
    f1_rd_addr <= rd_addr;
    f1_pc_inc <= pc_inc;
    f1_wr_en <= wr_en;
end

mux4 mux4_sel_wb (
    .i0     (f1_alu_res),
    .i1     (lsu_data),
    .i2     ({f1_pc_inc, 2'b00}),
    .i3     (f1_u_imm),
    .i_sel  (f1_wb_sel),
    .o_y    (wr_data)
);

endmodule