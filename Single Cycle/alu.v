module alu(
input [31:0] pc,
input [31:0] src1,
input [31:0] src2,
input [31:0] imm,
input is_i_instr,
input is_j_instr,
input is_jr_instr,
input is_r_instr,
input is_b_instr,
input is_s_instr,
input is_l_instr,
input is_lui,
input is_auipc,
input [3:0]alu_bits,
input [6:0] funct7,
output wr_en,
output reg [31:0] branch_pc,
output reg [7:0] mem_addr,
output reg [31:0] result
);



wire [31:0]sltu_result = {31'b0, src1 < src2};
wire [31:0]sltiu_result = {31'b0, src1 < imm};

wire [63:0] sext_src1 = {{32{src1[31]}}, src1};
wire [63:0] sra_result = sext_src1 >>> src2[4:0];
wire [63:0] srai_result = sext_src1 >>> imm[4:0];

wire [63:0] muls_result = $signed(src1) * $signed(src2);
wire [63:0] mulu_result = $signed(src1) * src2;
wire [63:0] muluu_result = src1 * src2;


always @(*) 		// Signed Immediate Instruction
begin
if (is_i_instr)	begin
case (alu_bits[2:0])				// For the instructions that needs 3 ALU bits
	3'b000 : begin				// ADDI
		result = $signed(src1)+$signed(imm);
	end
	3'b100 : begin				// XORI
		result = src1 ^ imm;
	end
	3'b110 : begin				// ORI
		result = src1 | imm;
	end
	3'b111 : begin				// ANDI
		result = src1 & imm;
	end
	3'b010	: begin				// SLTI
		result = (src1[31] == imm[31]) ? sltiu_result : {31'b0, src1[31]};
	end
	3'b011 : begin				// SLTIU
		result = sltiu_result;
	end
	default
		result = 32'bx;
endcase

case (alu_bits)
	4'b0001: begin				// SLLI
		result = src1 <<< imm[5:0];
	end
	4'b0101: begin				// SRLI
		result = src1 >>> imm[5:0];
	end
	4'b1101: begin				// SRAI
		result = srai_result[31:0];
	end
endcase

end
end

always @(*) 		// Signed Register Instruction
begin
if (is_r_instr)	
begin
case (alu_bits)
	4'b0000: begin 					// ADD
	result = $signed(src1)+$signed(src2);
	end
	4'b1000: begin 					// SUB
	result = $signed(src1) - $signed(src2);
	end
	4'b0001: begin 					// SLL
	result = src1 << src2[4:0];
	end
	4'b0010: begin 					// SLT
	result = (src1[31] == src2[31]) ? sltu_result : {31'b0, src1[31]};
	end
	4'b0011: begin 					// SLTU
	result = sltu_result;
	end
	4'b0100: begin 					// XOR
	result = src1 ^ src2;
	end
	4'b0101: begin 					// SRL
	result = src1 >>> src2[4:0];
	end
	4'b1101: begin 					// SRA
	result = sra_result[31:0];
	end
	4'b0110: begin 					// OR
	result = src1 | src2;
	end
	4'b0111: begin 					// AND
	result = src1 & src2;
	end
endcase
end
if(funct7 == 7'b1)
begin
case (alu_bits[2:0])				// For the instructions that needs 3 ALU bits
	3'b000 : begin				// MUL
	result = muls_result[31:0];
	end
	3'b001 : begin				// MULH
	result = muls_result[63:32];
	end
	3'b010 : begin				// MULHSU
	result = mulu_result[63:32];
	end
	3'b011 : begin				// MULHU
	result = muluu_result[63:32];
	end
endcase
end

end

always @(*) 		// Conditional Branch Instruction
begin	
if (is_b_instr)	begin
	branch_pc = pc + {{2{imm[31]}}, imm[31:2]};
	
end
end

always @(*) 		// Jump instruction Instruction
begin
if (is_j_instr)	begin
	result = pc + 1'b1;
	branch_pc = pc + {{2{imm[31]}}, imm[31:2]};
end
if(is_jr_instr) begin
	result = pc+1'b1;
	branch_pc = src1+{{2{imm[31]}}, imm[31:2]};
end
end

always @(*) 		// Store Instruction
begin
if(is_s_instr) begin
	result = src1+{{2{imm[31]}}, imm[31:2]};
end
end

always @(*) 		// Load Instruction
begin
if (is_l_instr)	begin
	mem_addr = src1+{{2{imm[31]}}, imm[31:2]};
end
end

always @(*)		// LUI or AUIPC
begin
if(is_lui) begin
	result = {imm[31:12], 12'b0};
end
if(is_auipc) begin
	result = pc + $signed(imm);
end

end



assign wr_en = is_i_instr || is_r_instr || is_j_instr || is_jr_instr;

endmodule
