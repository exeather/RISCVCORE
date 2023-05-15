module pc_counter(
input clk,
input reset,
input branch_taken,
input is_j_instr,
input is_jr_instr,
input [31:0] branch_pc,
inout [31:0] pc
);


reg [31:0] my_pc;
reg [31:0] my_next_pc;

always @(posedge clk or negedge reset)
begin
	if(!reset)	begin
		my_pc <= -1;
	end
	else	begin
		my_pc <= my_next_pc;
	end
end
always @(*)
begin
	if(branch_taken | is_j_instr | is_jr_instr)	my_next_pc <= branch_pc;
	else						my_next_pc <= pc + 1'b1;
end
assign pc = my_pc;

endmodule
