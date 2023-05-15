module branch_cond(
input clk,
input rst_n,
input is_b_instr,
input is_j_instr,
input is_jr_instr,
input alu_en,
input [31:0] src1,
input [31:0] src2,
input [3:0] alu_bits,
output reg branch_reg
);


wire [3:0] cond = {is_b_instr, alu_bits[2:0]};
wire branch_taken, branch_taken1;
assign branch_taken1 = 	(cond == 4'b1000) ? (src1 == src2) :
			(cond == 4'b1001) ? (src1 != src2) :
			(cond == 4'b1100) ? ((src1 < src2)^ (src1[31] != src2[31])) :
			(cond == 4'b1101) ? ((src1 >= src2)^ (src1[31] != src2[31])) :
			(cond == 4'b1110) ? (src1 < src2) :
			(cond == 4'b1111) ? (src1 >= src2) :
			(cond[3] == 1'b0) ? 32'b0 :
						32'b0;
assign branch_taken = branch_taken1 || is_j_instr || is_jr_instr;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)	branch_reg = 1'b0;
	else		branch_reg = alu_en ? branch_taken : branch_reg;
end

endmodule
