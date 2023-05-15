module decoder(
input [31:0]instr,
output is_i_instr,
output is_j_instr,
output is_jr_instr,
output is_b_instr,
output is_s_instr,
output is_r_instr,
output is_l_instr,
output is_lui,
output is_auipc,
output [4:0]rs1,
output [4:0]rs2,
output [31:0]imm,
output rs1_valid,
output rs2_valid,
output imm_valid,
output rd_valid,
output funct3_valid,
output [3:0] alu_bits,
output [6:0] funct7,
output [4:0] rd
);

wire [4:0] opcode;

assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd = instr[11:7];

assign opcode = instr[6:2];
assign alu_bits = {instr[30], instr[14:12]};
assign funct7 = instr[31:25];

// Determining Type of Instruction 
assign is_i_instr = (opcode == 5'b00001) || (opcode == 5'b00100)|| (opcode == 5'b00110)|| (opcode == 5'b11001);
assign is_u_instr = (opcode == 5'b00101) || (opcode == 5'b01101);
assign is_r_instr = (opcode == 5'b01011) || (opcode == 5'b01100)|| (opcode == 5'b01110)|| (opcode == 5'b10100);
assign is_b_instr = (opcode == 5'b11000);
assign is_j_instr = (opcode == 5'b11011);
assign is_jr_instr = (opcode == 5'b11001);
assign is_s_instr = (opcode == 5'b01000) || (opcode == 5'b01001);
assign is_l_instr = (opcode == 5'b00000);
assign is_lui = (opcode == 5'b01101);
assign is_auipc = (opcode == 5'b00101);

// Determine if SRC1, SRC2, IMM, RD is valid or not.
assign rs1_valid = is_r_instr || is_i_instr || is_s_instr || is_b_instr || is_jr_instr || is_l_instr;
assign rs2_valid = is_r_instr || is_s_instr || is_b_instr;
assign imm_valid = is_i_instr || is_s_instr || is_b_instr || is_j_instr;
assign rd_valid = is_r_instr || is_i_instr || is_j_instr || is_jr_instr || is_l_instr;
assign funct3_valid = is_r_instr || is_i_instr || is_s_instr || is_b_instr;

// Immediate Forming
wire [31:0] imm_i = {{21{instr[31]}}, instr[30:20]};
wire [31:0] imm_s = {{21{instr[31]}}, instr[30:25], instr[11:7]};
wire [31:0] imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], {1'b0}};
wire [31:0] imm_u = {instr[31:12], {12'b0}};
wire [31:0] imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], {1'b0}};

assign imm = 	(is_i_instr | is_l_instr) ? imm_i :
	     	(is_j_instr | is_jr_instr) ? imm_j :
		is_b_instr ? imm_b :
		is_s_instr ? imm_s :
		is_u_instr ? imm_u :
			  32'b0;	

endmodule
