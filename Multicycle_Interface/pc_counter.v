module pc_counter(
input clk,
input rst_n,
input fetch_en,
input branch,
input [31:0] branch_pc,
input alu_en,
inout [31:0] pc,
input next_pc_make
);


reg [31:0] my_pc;
reg [31:0] my_next_pc;

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)	begin
		my_pc = 'b0;
		my_next_pc = 'b0;
	end
	else	begin
		my_pc = my_next_pc;
	end
end
always @(posedge clk)
begin
	if(next_pc_make)	my_next_pc = branch ? branch_pc : (my_pc + 1'b1);
	else			my_next_pc = my_next_pc;
end

/*
always @(*)
begin
	my_next_pc = branch ? branch_pc : my_pc + 1'b1;
end

*/
assign pc = my_pc;

endmodule
