module apb #(parameter DATA_LENGTH = 32,ADDRESS_LENGTH = 12) (
input from_top_clk, 
input preset_n, 
input [ADDRESS_LENGTH-1:0] from_top_apb_paddr, 
input pwrite, 
input psel, 
input pready, 
input [DATA_LENGTH-1:0] from_top_apb_pwdata, 
output to_mem_en, 
output to_mem_wr_en, 
output to_mem_rd_en, 
output [ADDRESS_LENGTH-1:0] to_mem_address, 
output [DATA_LENGTH-1:0] to_mem_data_in, 
output [1:0] to_mem_data_length, 
input [DATA_LENGTH-1:0] from_mem_data_out,
output reg [DATA_LENGTH-1:0] prdata
);

    // input                        from_top_clk, preset_n, pwrite, psel, pready;
    // input [ADDRESS_LENGTH-1:0]   from_top_apb_paddr; //paddr
    // input [DATA_LENGTH-1:0]      from_top_apb_pwdata; //pwdata

    // mem_wrapper_signals
    // input [DATA_LENGTH-1:0]      from_mem_data_out;
    // output                       to_mem_en, to_mem_wr_en, to_mem_rd_en;
    // output [ADDRESS_LENGTH-1:0]  to_mem_address;
    // output [DATA_LENGTH-1:0]     to_mem_data_in;
    // output [1:0]                 to_mem_data_length;
    
    //output reg [DATA_LENGTH-1:0]     prdata;

    reg [2:0] apb_state;
    reg penable;

    reg [DATA_LENGTH-1:0]           apb_data_in;
    reg [ADDRESS_LENGTH-1:0]        apb_address_in;

    parameter IDLE            = 3'b000;
    parameter SETUP           = 3'b001;
    //parameter WRITE_DATA = 2'b10;
    parameter WRITE_EN        = 3'b010;
    parameter READ_EN         = 3'b011;
    parameter DONE            = 3'b100;
    
    assign to_mem_wr_en       = (apb_state == DONE) ? 1'b1 : 1'b0;
    assign to_mem_rd_en       = (to_mem_wr_en) ? 1'b0 : 1'b1;
    assign to_mem_en          = (apb_state == DONE) ? 1'b1 : (1'b0 | to_mem_rd_en);
    assign to_mem_address     = (apb_state == DONE) ? apb_address_in : to_mem_address;
    assign to_mem_data_length = 2'b11;
    assign to_mem_data_in     =  (apb_state == DONE) ? apb_data_in : to_mem_data_in;

always @(posedge from_top_clk) begin
    if (~preset_n) begin
        apb_address_in     <= {DATA_LENGTH{1'b0}};
        apb_data_in        <= {DATA_LENGTH{1'b0}};
        apb_state          <= IDLE;
    end

    else begin
        case (apb_state)
            IDLE: begin
                if (psel && !penable) begin
                    apb_state <= SETUP;
                end
            end
            
            SETUP : begin
                if (psel && !penable) begin
                    if (pwrite) begin
                        penable = 1'b1;
                        apb_state <= WRITE_EN;
                    end
                    else begin
                        penable = 1'b1;
                        apb_state <= READ_EN;
                    end
                end
            end

            WRITE_EN : begin
                if (psel && penable && pwrite && pready) begin
                    apb_address_in <= from_top_apb_paddr;
                    apb_data_in <= from_top_apb_pwdata;
                    apb_state <= DONE;
                end
            end

            READ_EN : begin
                if (psel && penable && !pwrite && pready) begin
                    apb_address_in <= from_top_apb_paddr;
                    prdata <= from_mem_data_out;
                    apb_state <= DONE;
                end
            end

            DONE : begin
                penable <= 1'b0;
                apb_state <= IDLE;
            end

            default: begin
                penable <= 1'b0;
                apb_state <= IDLE;
            end

        endcase
    end
end 

endmodule