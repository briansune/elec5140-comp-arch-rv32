`include "rv32i_bus_constants.vh"
`include "rv32i_ctrl_constants.vh"
`include "rv32i_csr_addr_map.vh"
`include "rv32i_platform_constants.vh"

module rv32i_core(
	
	input										clk,
	input										reset,
	
	input		[`N_EXT_INTS-1:0]				ext_interrupts,
	
	input										htif_pcr_req_valid,
	output										htif_pcr_req_ready,
	input										htif_pcr_req_rw,
	input		[`CSR_ADDR_WIDTH-1:0]			htif_pcr_req_addr,
	input		[`HTIF_PCR_WIDTH-1:0]			htif_pcr_req_data,
	output										htif_pcr_resp_valid,
	input										htif_pcr_resp_ready,
	output		[`HTIF_PCR_WIDTH-1:0]			htif_pcr_resp_data
);
	
	wire										imem_wait;
	wire		[`MEM_ADDR_WIDTH-1:0]			imem_addr;
	wire		[`MEM_BUS_WIDTH-1:0]			imem_rdata;
	wire										imem_badmem_e;
	
	wire										dmem_wait;
	wire										dmem_en;
	wire										dmem_wen;
	wire		[`MEM_SIZE_WIDTH-1:0]			dmem_size;
	wire		[`MEM_ADDR_WIDTH-1:0]			dmem_addr;
	wire		[`MEM_BUS_WIDTH-1:0]			dmem_wdata_delayed;
	wire		[`MEM_BUS_WIDTH-1:0]			dmem_rdata;
	wire										dmem_badmem_e;
	
	//////////////////////////////////////////////////////////////
	// Instruction memory
	//////////////////////////////////////////////////////////////
	assign imem_wait = 'b0;
	assign imem_badmem_e = 'b0;
	
	rv32i_instr_mem rv32i_instr_mem_inst0(
		.clock		(clk),
		.address	(imem_addr[9 : 2]),
		.q			(imem_rdata)
	);
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// Data memory
	//////////////////////////////////////////////////////////////
	assign dmem_wait = 'b0;
	assign dmem_badmem_e = 'b0;
	
	reg							dmem_en_reg;
	reg							dmem_wen_reg;
	reg	[`MEM_ADDR_WIDTH-1:0]	dmem_waddr_reg;
	
	wire						dmem_en_signal;
	
	reg	[3 : 0]					data_mem_mask;
	reg	[3 : 0]					data_mem_mask_reg;
	
	always@(*)begin
		case(dmem_size)
			`MEM_TYPE_LB: data_mem_mask = 4'b0001;
			`MEM_TYPE_LH: data_mem_mask = 4'b0011;
			`MEM_TYPE_LW: data_mem_mask = 4'b1111;
			default: data_mem_mask = 4'b1111;
		endcase
	end
	
	always@(posedge clk)begin
		if(reset)begin
			dmem_en_reg <= 'd0;
			dmem_wen_reg <= 'd0;
			dmem_waddr_reg <= 'd0;
			data_mem_mask_reg <= 'd0;
		end else begin
			if(dmem_en & dmem_wen)begin
				dmem_en_reg <= dmem_en;
				dmem_wen_reg <= dmem_wen;
				data_mem_mask_reg <= data_mem_mask;
			end
			
			if(dmem_wen_reg)begin
				dmem_en_reg <= dmem_en;
				dmem_wen_reg <= dmem_wen;
				data_mem_mask_reg <= data_mem_mask;
			end
			
			dmem_waddr_reg <= dmem_addr;
		end
	end
	
	assign dmem_en_signal = dmem_en_reg | (dmem_en & !dmem_wen);
	
	rv32i_data_mem rv32i_data_mem_inst0(
		.clock				(clk),
		.byteena_a			(data_mem_mask_reg),
		.data				(dmem_wdata_delayed),
		.enable				(dmem_en_signal),
		.rdaddress			(dmem_addr[7 : 0]),
		.wraddress			(dmem_waddr_reg[7 : 0]),
		.wren				(dmem_wen_reg),
		.q					(dmem_rdata)
	);
	//////////////////////////////////////////////////////////////
	
	
	rv32i_pipeline pipeline_inst0(
		
		.clk					(clk),
		.ext_interrupts			(ext_interrupts),
		.reset					(reset),
		
		.imem_wait				(imem_wait),
		.imem_addr				(imem_addr),
		.imem_rdata				(imem_rdata),
		.imem_badmem_e			(imem_badmem_e),
		
		.dmem_wait				(dmem_wait),
		.dmem_en				(dmem_en),
		.dmem_wen				(dmem_wen),
		.dmem_size				(dmem_size),
		.dmem_addr				(dmem_addr),
		.dmem_wdata_delayed		(dmem_wdata_delayed),
		.dmem_rdata				(dmem_rdata),
		.dmem_badmem_e			(dmem_badmem_e),
		
		.htif_reset				(reset),
		.htif_pcr_req_valid		(htif_pcr_req_valid),
		.htif_pcr_req_ready		(htif_pcr_req_ready),
		.htif_pcr_req_rw		(htif_pcr_req_rw),
		.htif_pcr_req_addr		(htif_pcr_req_addr),
		.htif_pcr_req_data		(htif_pcr_req_data),
		.htif_pcr_resp_valid	(htif_pcr_resp_valid),
		.htif_pcr_resp_ready	(htif_pcr_resp_ready),
		.htif_pcr_resp_data		(htif_pcr_resp_data)
	);

endmodule

