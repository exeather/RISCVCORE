module decoder(
input clk,
input decode_en,
input [31:0]instr,
output reg is_i_instr,
output reg is_j_instr,
output reg is_jr_instr,
output reg is_b_instr,
output reg is_s_instr,
output reg is_r_instr,
output reg is_l_instr,
output reg is_u_instr,
output reg is_lui,
output reg is_auipc,
output reg [4:0]rs1,
output reg [4:0]rs2,
output reg [31:0]imm,
output reg rs1_valid,
output reg rs2_valid,
output reg imm_valid,
output reg rd_valid,
output reg funct3_valid,
output reg [3:0] alu_bits,
output reg [6:0] funct7,
output reg [4:0] rd
);

wire [4:0] opcode;
assign opcode = instr[6:2];

wire [31:0] imm_i = {{21{instr[31]}}, instr[30:20]};
wire [31:0] imm_s = {{21{instr[31]}}, instr[30:25], instr[11:7]};
wire [31:0] imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], {1'b0}};
wire [31:0] imm_u = { {12'b0}, instr[31:12]};
wire [31:0] imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], {1'b0}};
wire [31:0] imm_auipc = {instr[31:12], {12'b0}};
wire [31:0] imm_lui = {instr[31:12], {12'b0}};


always @(*)
begin
	rs1 = instr[19:15];
	rs2 = instr[24:20];
	rd = instr[11:7];
	alu_bits = {instr[30], instr[14:12]};
	funct7 = instr[19:15];
	
	
	// Determining Type of Instruction 
	is_i_instr = ((opcode == 5'b00001) || (opcode == 5'b00100)|| (opcode == 5'b00110)|| (opcode == 5'b11001) );
	is_u_instr = ((opcode == 5'b00101));
	is_r_instr = ((opcode == 5'b01011) || (opcode == 5'b01100)|| (opcode == 5'b01110)|| (opcode == 5'b10100));
	is_b_instr = ((opcode == 5'b11000));
	is_j_instr = ((opcode == 5'b11011));
	is_jr_instr = ((opcode == 5'b11001));
	is_s_instr = ((opcode == 5'b01000) || (opcode == 5'b01001));
	is_l_instr = ((opcode == 5'b00000));
	is_lui = ((opcode == 5'b01101));
	is_auipc = ((opcode == 5'b00101));
	
	// Determine if SRC1, SRC2, IMM, RD is valid or not.
	rs1_valid = is_r_instr || is_i_instr || is_s_instr || is_b_instr || is_jr_instr || is_l_instr;
	rs2_valid = is_r_instr || is_s_instr || is_b_instr;
	imm_valid = is_i_instr || is_s_instr || is_b_instr || is_j_instr;
	rd_valid = is_r_instr || is_i_instr || is_j_instr || is_jr_instr || is_l_instr || is_auipc || is_u_instr || is_lui;
	funct3_valid = is_r_instr || is_i_instr || is_s_instr || is_b_instr;


	// Immediate Forming
	imm = 	(is_i_instr | is_l_instr) ? imm_i :
	     	(is_j_instr | is_jr_instr) ? imm_j :
		is_b_instr ? imm_b :
		is_s_instr ? imm_s :
		is_u_instr ? imm_u :
		is_auipc ? imm_auipc:
		is_lui ? imm_lui:
			  32'b0;	

end

endmodule
