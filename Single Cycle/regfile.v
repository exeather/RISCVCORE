module regfile(
input clk,
input rst,
input rs1_valid,
input rs2_valid,
input rd_valid,
input [4:0] rs1,
input [4:0] rs2,
input [4:0] rd,
output [31:0] rs1_data,
output [31:0] rs2_data,
input [31:0] rd_data
);

reg [31:0] regs [31:0];
reg [31:0] src1;
reg [31:0] src2;
always @(negedge rst)
begin
	regs[0] = 32'b0;
end


// Reading Data Level Sensitive
always @(*)
begin
	src1 = rs1_valid ? regs[rs1] : 32'bx;	
	src2 = rs2_valid ? regs[rs2] : 32'bx;	
end
assign rs1_data = src1;
assign rs2_data = src2;

// Writing Data at Negedge clock
always @(negedge clk)
begin
	regs[rd] = rd_valid ? rd_data : regs[rd];	
	
end


endmodule