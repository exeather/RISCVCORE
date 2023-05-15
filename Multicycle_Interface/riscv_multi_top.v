//`include "module.v"

module riscv_multi_top #(parameter DATA_LENGTH = 32, parameter ADDRESS_LENGTH = 12) (
input clk,
input rst_n,
input core_select,
input [31:0] addr_in,
input [31:0] data_in,
input pselect,
input pwrite,
input pready,
input instruction_load_start,
output wire [31:0] data_out,
output wire run_complete
);

wire core_mem_en; 
wire core_mem_write_en; 
wire core_mem_read_en; 
 
wire [11:0] core_mem_addr; 
wire [31:0] core_mem_data_in; 
wire [31:0] core_mem_data_out;
wire from_apb_mem_wr_en_wire,from_apb_mem_rd_en_wire,from_core_to_imem_en_wire,from_core_to_imem_wr_en_wire,from_core_to_imem_rd_en_wire,from_core_to_dmem_en_wire,from_core_to_dmem_wr_en_wire,from_core_to_dmem_rd_en_wire,from_top_to_spi_mosi_in,from_top_to_spi_miso_out,to_inst_mem_en_wire,to_inst_mem_wr_en_wire,to_inst_mem_rd_en_wire,to_data_mem_en_wire,to_data_mem_wr_en_wire,to_data_mem_rd_en_wire,from_spi_mem_en_wire,from_apb_mem_en_wire,from_spi_mem_wr_en_wire,from_spi_mem_rd_en_wire,to_apb_pwrite,to_apb_pready,to_apb_psel;

wire [DATA_LENGTH-1 : 0] from_apb_mem_data_in_wire, from_apb_mem_data_out_wire, from_top_to_apb_out, from_core_to_imem_data_in_wire, from_core_to_dmem_data_in_wire, from_imem_to_core_data_wire, from_spi_mem_data_in_wire, from_spi_mem_data_out_wire, from_dmem_to_core_data_wire, to_data_mem_data_in_wire, to_inst_mem_data_in_wire, from_top_to_apb_data_in;
wire [1:0] from_apb_mem_data_length_wire,from_spi_mem_data_length_wire,from_core_to_dmem_data_length_wire,from_core_to_imem_data_length_wire,to_inst_mem_data_length_wire,to_data_mem_data_length_wire;

wire [ADDRESS_LENGTH-1 : 0] from_top_to_apb_addr_in, from_apb_mem_address_wire, from_core_to_imem_address_wire, from_core_to_dmem_address_wire,from_spi_mem_address_wire, to_data_mem_address_wire, to_inst_mem_address_wire;

assign from_top_to_apb_addr_in = addr_in;
assign from_top_to_apb_data_in = data_in;
assign data_out = from_top_to_apb_out;

assign to_apb_pready = pready;
assign to_apb_pwrite = pwrite;
assign to_apb_psel = pselect;


assign to_inst_mem_en_wire = (instruction_load_start) ? from_apb_mem_en_wire : 1'b0;
assign to_inst_mem_wr_en_wire = (instruction_load_start) ? from_apb_mem_wr_en_wire : 1'b0;
assign to_inst_mem_rd_en_wire = (instruction_load_start) ? from_apb_mem_rd_en_wire : 1'b0;
assign to_inst_mem_address_wire = (instruction_load_start) ? from_apb_mem_address_wire : {{DATA_LENGTH-1}{1'b0}};
assign to_inst_mem_data_in_wire = (instruction_load_start) ? from_apb_mem_data_in_wire : {{DATA_LENGTH-1}{1'b0}};
assign to_inst_mem_data_length_wire = (instruction_load_start) ? from_apb_mem_data_length_wire : 2'b0;  


// Core reset pin creation when memory is taking instruction from the apb interface


wire core_reset_n;

assign core_reset_n = core_select & rst_n;
assign from_core_to_imem_rd_en_wire = !from_core_to_imem_wr_en_wire;



cpu Core (
.clk(clk),
.rst_n(core_reset_n),
.core_select(core_select),
.start(1'b1),
.EOC(1'b0),
.mem_en(core_mem_en), 
.mem_write(core_mem_write_en), 
.mem_read(core_mem_read_en),
.mem_addr(core_mem_addr),
.mem_data_in(core_mem_data_in), 
.mem_data_out(core_mem_data_out)
);



data_memory_wrapper #(DATA_LENGTH,ADDRESS_LENGTH) imem_wrapper (
    .clk(clk),
    .core_select(core_select),
    .from_core_mem_en(core_mem_en),
    .from_core_mem_wr_en(core_mem_write_en),
    .from_core_mem_rd_en(core_mem_read_en),
    .from_core_mem_address(core_mem_addr),
    .from_core_mem_data_in(core_mem_data_in),
    .from_core_mem_data_length(2'b00),

    .from_intf_mem_ctrl_mem_en(to_inst_mem_en_wire),
    .from_intf_mem_ctrl_mem_wr_en(to_inst_mem_wr_en_wire),
    .from_intf_mem_ctrl_mem_rd_en(to_inst_mem_rd_en_wire),
    .from_intf_mem_ctrl_mem_address(to_inst_mem_address_wire),
    .from_intf_mem_ctrl_mem_data_in(to_inst_mem_data_in_wire),
    .from_intf_mem_ctrl_mem_data_length(to_inst_mem_data_length_wire),

    .to_core_mem_data_out(core_mem_data_out),
    .to_intf_mem_ctrl_mem_data_out(from_apb_mem_data_out_wire)
);


apb #(DATA_LENGTH,ADDRESS_LENGTH) apb_mem(
    .from_top_clk(clk),
    .preset_n(rst_n),
    .pwrite(to_apb_pwrite),
    .psel(to_apb_psel),
    .pready(to_apb_pready),

    .from_top_apb_paddr(from_top_to_apb_addr_in),
    .from_top_apb_pwdata(from_top_to_apb_data_in),
    
    .prdata(from_top_to_apb_out),

    .to_mem_en(from_apb_mem_en_wire),
    .to_mem_wr_en(from_apb_mem_wr_en_wire),
    .to_mem_rd_en(from_apb_mem_rd_en_wire),
    .to_mem_address(from_apb_mem_address_wire),
    .to_mem_data_in(from_apb_mem_data_in_wire),
    .to_mem_data_length(from_apb_mem_data_length_wire),

    .from_mem_data_out(from_apb_mem_data_out_wire)

);


endmodule

