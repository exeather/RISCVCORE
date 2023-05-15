module cpu(
input clk,
input reset
);

wire [31:0] pc;
reg [31:0] instr;
reg [31:0] instrmem[127:0];
reg [31:0] regfile[31:0];
reg [31:0] datamem[127:0];
reg [31:0] data1;

wire [31:0] src1;
wire [31:0] src2;

wire [31:0] imm;
wire [4:0] rs1;			// Address of 1st register
wire [4:0] rs2;			// Address of 2nd register
wire [4:0] rd;			// Address of destination register
wire [7:0] mem_addr;
wire [3:0] alu_bits;
wire [6:0] funct7;
reg [31:0] mem_result;
wire [31:0] alu_result;
wire [31:0] result;

wire rs1_valid;
wire rs2_valid;
wire imm_valid;
wire rd_valid;
wire funct3_valid;
wire wr_en;

wire is_i_instr;
wire is_j_instr;
wire is_jr_instr;
wire is_b_instr;
wire is_s_instr;
wire is_r_instr;
wire is_l_instr;
wire is_lui;
wire is_auipc;

wire [31:0] branch_pc;
wire branch_taken;

// Reading instructions
initial
	$readmemh("testla.txt", instrmem);

always @(*)
begin
	if(reset)	instr = instrmem[pc];
	else		instr = 32'bx;
end


// Reading the Data Memory (Load Instruction)
always @(*)
begin
	if(is_l_instr)
	begin
		data1 = datamem[mem_addr];
	case(alu_bits[2:0])
		3'b000: begin						// LB
			mem_result = {{24{data1[31]}}, data1[7:0]};
		end
		3'b001: begin						// LH
			mem_result = {{16{data1[31]}}, data1[15:0]};
		end
		3'b010: begin						// LW
			mem_result = data1;
		end
		3'b100: begin						// LBU
			 mem_result = {24'b0, data1[7:0]};
		end
		3'b101: begin						// LHU
			mem_result = {16'b0, data1[15:0]};
		end
	endcase
	end
end

assign result = is_l_instr ? mem_result : alu_result;

// Writing The Data Memory (Store Instructions)   (Level sensitive)
always @(*)
begin
	if(is_s_instr & clk)
	begin
		data1 = src2;
	case(alu_bits[2:0])
		3'b000: begin						// SB
			datamem[result] = {24'b0, data1[7:0]};
		end
		3'b001: begin						// SH
			datamem[result] = {16'b0, data1[15:0]};
		end
		3'b010: begin						// SW
			datamem[result] = data1;
		end
	endcase
	end
end



//Program Counter
pc_counter pc1(
.clk(clk),
.reset(reset),
.branch_taken(branch_taken),
.is_j_instr(is_j_instr),
.is_jr_instr(is_jr_instr),
.branch_pc(branch_pc),
.pc(pc)
);


//Decoder
decoder d1(
.instr(instr),
.is_i_instr(is_i_instr),
.is_j_instr(is_j_instr),
.is_jr_instr(is_jr_instr),
.is_b_instr(is_b_instr),
.is_s_instr(is_s_instr),
.is_r_instr(is_r_instr),
.is_l_instr(is_l_instr),
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

// If to branch
branch_cond bc1(
.is_b_instr(is_b_instr),
.src1(src1),
.src2(src2),
.alu_bits(alu_bits),
.branch_taken(branch_taken)
);

// ALU
alu alu1(
.pc(pc),
.src1(src1),
.src2(src2),
.imm(imm),
.is_i_instr(is_i_instr),
.is_j_instr(is_j_instr),
.is_jr_instr(is_jr_instr),
.is_r_instr(is_r_instr),
.is_b_instr(is_b_instr),
.is_s_instr(is_s_instr),
.is_l_instr(is_l_instr),
.is_lui(is_lui),
.is_auipc(is_auipc),
.alu_bits(alu_bits),
.funct7(funct7),
.wr_en(wr_en),
.branch_pc(branch_pc),
.mem_addr(mem_addr),
.result(alu_result)
);

// Register Writeback
regfile	regfile1(
.clk(clk),
.rst(reset),
.rs1_valid(rs1_valid),
.rs2_valid(rs2_valid),
.rd_valid(rd_valid),
.rs1(rs1),
.rs2(rs2),
.rd(rd),
.rs1_data(src1),
.rs2_data(src2),
.rd_data(result)
);

endmodule
