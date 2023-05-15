module testbench();

reg clk, reset;
initial
begin
clk = 1'b0;
reset = 1'b1;
#8;
reset = 1'b0;
#6;
reset = 1'b1;
end

always
begin
	clk = !clk;
	#5;
end
cpu c1(
.clk(clk),
.reset(reset)
);

endmodule
