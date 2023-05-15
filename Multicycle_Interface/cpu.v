module cpu(
input clk,
input rst_n,
input core_select,
input start,
input EOC,
output mem_en, 
output mem_write, 
output mem_read,
output [11:0] mem_addr,
output [31:0] mem_data_in, 
input [31:0] mem_data_out
);

wire fetch_en;
wire [31:0] pc;
wire [31:0] branch_pc, alu_branch_pc;
wire [11:0] alu_mem_addr;

wire [31:0] imm;
wire [4:0] rs1;			// Address of 1st register
wire [4:0] rs2;			// Address of 2nd register
wire [4:0] rd;			// Address of destination register
wire [3:0] alu_bits;
wire [6:0] funct7;
wire [31:0] mem_result;
wire [31:0] alu_result;
wire [31:0] result, rs1_data, rs2_data, rd_data;

wire rs1_valid;
wire rs2_valid;
wire imm_valid;
wire rd_valid;
wire funct3_valid;
wire wr_en, branch_taken, branch;
wire reg_read_en, reg_write_en;

wire is_i_instr;
wire is_j_instr;
wire is_jr_instr;
wire is_b_instr;
wire is_s_instr;
wire is_r_instr;
wire is_l_instr;
wire is_lui;
wire is_auipc;

reg [31:0] instr;

/*
always @(*)
begin
	instr = instrmem[pc];
end
*/
always @(posedge clk)
begin
	if(!rst_n)	instr = 'bx;
	else		instr = fetch_en ? mem_data_out : instr;
end


assign result = is_l_instr ? mem_data_out : alu_result;
assign mem_data_in = alu_result;
assign mem_addr = fetch_en ? pc : alu_mem_addr;


multi_fsm u_fsm(
.clk(clk),
.rst_n(rst_n),
.start(start),
.EOC(EOC),
.branch_taken(branch_taken),
.is_l_instr(is_l_instr),
.is_s_instr(is_s_instr),
.is_j_instr(is_j_instr),
.is_jr_instr(is_jr_instr),
.fetch_en(fetch_en),
.decode_en(decode_en),
.mem_read_en(mem_read),
.mem_write_en(mem_write),
.reg_read_en(reg_read_en),
.reg_write_en(reg_write_en),
.next_pc_make(next_pc_make),
.alu_en(alu_en),
.branch(branch),
.mem_en(mem_en)
);

pc_counter u_pc_counter(
.clk(clk),
.rst_n(rst_n),
.branch(branch),
.branch_pc(alu_branch_pc),
.pc(pc),
.alu_en(alu_en),
.fetch_en(fetch_en),
.next_pc_make(next_pc_make)
);

decoder u_decoder(
.clk(clk),
.decode_en(decode_en),
.instr(instr),
.is_i_instr(is_i_instr),
.is_j_instr(is_j_instr),
.is_jr_instr(is_jr_instr),
.is_b_instr(is_b_instr),
.is_s_instr(is_s_instr),
.is_r_instr(is_r_instr),
.is_l_instr(is_l_instr),
.is_u_instr(is_u_instr),
.is_lui(is_lui),
.is_auipc(is_auipc),
.rs1(rs1),
.rs2(rs2),
.imm(imm),
.rs1_valid(rs1_valid),
.rs2_valid(rs2_valid),
.imm_valid(imm_valid),
.rd_valid(rd_valid),
.funct3_valid(funct3_valid),
.alu_bits(alu_bits),
.funct7(funct7),
.rd(rd)
);

regfile u_regfile(
.clk(clk),
.rst(rst_n),
.reg_read_en(reg_read_en),
.reg_write_en(reg_write_en),
.rs1_valid(rs1_valid),
.rs2_valid(rs2_valid),
.rd_valid(rd_valid),
.rs1(rs1),
.rs2(rs2),
.rd(rd),
.rs1_data(rs1_data),
.rs2_data(rs2_data),
.rd_data(result)
);

alu u_alu(
.clk(clk),
.rst_n(rst_n),
.pc(pc),
.alu_en(alu_en),
.src1(rs1_data),
.src2(rs2_data),
.imm(imm),
.is_i_instr(is_i_instr),
.is_j_instr(is_j_instr),
.is_jr_instr(is_jr_instr),
.is_r_instr(is_r_instr),
.is_b_instr(is_b_instr),
.is_s_instr(is_s_instr),
.is_l_instr(is_l_instr),
.is_lui(is_lui),
.is_li(is_li),
.is_auipc(is_auipc),
.alu_bits(alu_bits),
.funct7(funct7),
.wr_en(wr_en),
.alu_branch_pc(alu_branch_pc),
.alu_mem_addr(alu_mem_addr),
.alu_result(alu_result)
);

branch_cond u_branch_cond(
.clk(clk),
.rst_n(rst_n),
.is_b_instr(is_b_instr),
.is_j_instr(is_j_instr),
.is_jr_instr(is_jr_instr),
.alu_en(alu_en),
.src1(rs1_data),
.src2(rs2_data),
.alu_bits(alu_bits),
.branch_reg(branch_taken)
);


endmodule
