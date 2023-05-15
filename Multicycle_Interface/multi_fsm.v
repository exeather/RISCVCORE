module multi_fsm(
input clk,
input rst_n,
input start,
input EOC,
input branch_taken,
input is_l_instr,
input is_s_instr,
input is_j_instr,
input is_jr_instr,
output reg fetch_en,
output reg decode_en,
output reg mem_read_en,
output reg mem_write_en,
output reg reg_read_en,
output reg reg_write_en,
output reg next_pc_make,
output reg alu_en,
output reg branch,
output reg mem_en
);

parameter [3:0] IDLE 		= 4'b0000,
		FETCH	 	= 4'b0001,
		FETCH_WAIT	= 4'b0010,
		DECODE 		= 4'b0011,
		REG_READ 	= 4'b0100,
		ALU		= 4'b0101,
		BRANCH_WRITE	= 4'b0111,
		BRANCH_WAIT	= 4'b0110,
		MEMORY_WRITE	= 4'b1000,
		STORE_WAIT	= 4'b1001;
		
reg [3:0] pstate;
reg [3:0] nstate;

//NSL Next State Logic
always @(*)
begin
casez(pstate)
	IDLE:		nstate = start ? FETCH : IDLE;
	FETCH:		nstate = FETCH_WAIT;
	FETCH_WAIT:	nstate = DECODE;
	DECODE:		nstate = REG_READ;
	REG_READ: 	nstate = ALU;
	ALU:		nstate = BRANCH_WAIT;
	BRANCH_WAIT:	nstate = (branch_taken & (!is_l_instr) & ( !is_s_instr) )? BRANCH_WRITE : MEMORY_WRITE;
	BRANCH_WRITE:	nstate = FETCH;
	MEMORY_WRITE:	nstate = FETCH;
	STORE_WAIT:	nstate = FETCH;			
	default: 	nstate = 3'bxxx;
endcase
end

// OL
always @(*)
begin
	case(pstate)
		IDLE: 		begin
			fetch_en = 1'b0;
			decode_en = 1'b0;
			mem_read_en = 1'b0;
			alu_en = 1'b0;
			branch = 1'b0;
			reg_read_en = 1'b0;
			reg_write_en = 1'b0;
			mem_read_en = 1'b0;
			mem_write_en = 1'b0;
			mem_en = 1'b0;
			next_pc_make = 1'b0;
		end

		FETCH: 		begin
			fetch_en = 1'b1;
			decode_en = 1'b0;
			alu_en = 1'b0;
			next_pc_make = 1'b0;
			reg_read_en = 1'b0;
			reg_write_en = !(is_j_instr || is_jr_instr);
			mem_read_en = 1'b1;
			mem_write_en = 1'b0;
			mem_en = 1'b1;
		end
		
		FETCH_WAIT:	begin
			fetch_en = 1'b1;
			decode_en = 1'b0;
			alu_en = 1'b0;
			
			reg_read_en = 1'b0;
			reg_write_en = 1'b0;
			mem_read_en = 1'b0;
			mem_write_en = 1'b0;
			mem_en = 1'b0;
		end

		DECODE: 	begin
			mem_en = 1'b0;
			mem_read_en = 1'b0;
			fetch_en = 1'b0;
			decode_en = 1'b1;
			branch = 1'b0;
		end

		REG_READ: 	begin
			fetch_en = 1'b0;	
			reg_read_en = 1'b1;		
		end
		
		ALU:		begin
			fetch_en = 1'b0;
			alu_en = 1'b1;
			branch = branch_taken ? 1'b1 : 1'b0;
			reg_read_en = 1'b1;
		end
		
		BRANCH_WAIT:	begin
			next_pc_make = 1'b1;
		end
		
		BRANCH_WRITE:	begin
			reg_write_en = 1'b1;
			reg_read_en = 1'b0;
			alu_en = 1'b1;
			next_pc_make = 1'b0;
		end
		
		MEMORY_WRITE:	begin
			fetch_en = 1'b0;
			alu_en = 1'b0;
			reg_write_en = 1'b1;
			reg_read_en = 1'b0;
			next_pc_make = 1'b0;
			if(is_s_instr)	begin
				mem_write_en = 1'b1;
				reg_write_en = 1'b0;
			end
			else		begin
				mem_write_en = 1'b0;
			end

			if(is_l_instr)	begin
				mem_read_en = 1'b1;
			end
			else		begin
				mem_read_en = 1'b0;
			end
			mem_en = is_s_instr || is_l_instr;
		end
		STORE_WAIT:	begin
			mem_en = 1'b0;
			mem_write_en = 1'b0;
		end
		/*
		LOAD_WAIT:		begin
			reg_write_en = 1'b1;
			mem_read_en = 1'b1;
			mem_en = 1'b0;	
		end
		RD_CHECK:		begin
			reg_write_en = 1'b0;
			mem_read_en = 1'b0;
		end
		*/
	endcase
end

//PSR
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n) pstate <= IDLE;
	else pstate <= nstate;

end

endmodule
