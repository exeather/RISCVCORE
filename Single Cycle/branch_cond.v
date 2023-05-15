module branch_cond(
input is_b_instr,
input [31:0] src1,
input [31:0] src2,
input [3:0] alu_bits,
output branch_taken
);


wire [3:0] cond = {is_b_instr, alu_bits[2:0]};

assign branch_taken = 	(cond == 5'b1000) ? (src1 == src2) :
			(cond == 5'b1001) ? (src1 != src2) :
			(cond == 5'b1100) ? ((src1 < src2)^ (src1[31] != src2[31])) :
			(cond == 5'b1101) ? ((src1 >= src2)^ (src1[31] != src2[31])) :
			(cond == 5'b1110) ? (src1 < src2) :
			(cond == 5'b1111) ? (src1 >= src2) :
			(cond[3] == 1'b0) ? 32'b0 :
						32'b0;
endmodule
