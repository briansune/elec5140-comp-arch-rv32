`include "./rv32i_core/rv32i_bus_constants.vh"
`include "./rv32i_core/rv32i_ctrl_constants.vh"
`include "./rv32i_core/rv32i_csr_addr_map.vh"
`include "./rv32i_core/rv32i_platform_constants.vh"

module rv32i_top(
	
	input							sys_clk,
	input							rst,
	//signal connect to PHY//
	output							E_RESET,
	input							E_RXC,
	input							E_RXDV,
	input	[3 : 0]					E_RXD,
	input							E_RXER,
	input							E_TXC,
	output							E_TXEN,
	output	[3 : 0]					E_TXD
	
	//output	[`MEM_BUS_WIDTH-1 : 0]	dmem_rdata
);
	
	`include "./rv32i_udp/rv32i_udp_cmd.vh"
	
	//////////////////////////////////////////////////////////////
	// System signal
	//////////////////////////////////////////////////////////////
	wire								global_clk;
	wire								global_rst;
	wire								global_nrst;
	
	wire								rv32i_rst;
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// RISC_V32i signals
	//////////////////////////////////////////////////////////////
	reg									htif_pcr_req_valid;
	reg									htif_pcr_req_rw;
	reg		[`CSR_ADDR_WIDTH-1:0]		htif_pcr_req_addr;
	reg		[`HTIF_PCR_WIDTH-1:0]		htif_pcr_req_data;
	reg									htif_pcr_resp_ready;
	wire								htif_pcr_resp_valid;
	wire								htif_pcr_req_ready;
	wire	[`HTIF_PCR_WIDTH-1:0]		htif_pcr_resp_data;
	
	reg									rv32i_core_run;
	reg									rv32i_core_rst;
	reg									rv32i_core_rst_delay;
	reg									rv32i_core_hld;
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// UDP signals
	//////////////////////////////////////////////////////////////
		//added for receive test/
	reg									data_o_valid_reg1;
	reg									data_o_valid_reg2;
		//added for receive test/
	reg		[8 : 0]						icache_wr_addr;
	reg									icache_wr_en;
	wire	[31 : 0]					icache_wr_data;
	
	// 2kB FIFO with 4Byte word 32 bit line
	reg									icache_rd_end;
	wire	[8 : 0]						icache_rd_addr;
	
	wire								tx_finish_sig;
	wire								rx_finish_sig;
	
	wire	[31 : 0]					data_cmd_signal;
	wire	[15 : 0]					prg_data_len_signal;
	reg		[15 : 0]					prg_data_len_reg;
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// Instruction Cache signals
	//////////////////////////////////////////////////////////////
	wire								imem_wait;
	wire	[`MEM_ADDR_WIDTH-1:0]		imem_addr;
	wire	[`MEM_BUS_WIDTH-1:0]		imem_rdata;
	wire								imem_badmem_e;
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// Data Cache signals
	//////////////////////////////////////////////////////////////
	wire								dmem_wait;
	wire								dmem_en;
	wire								dmem_wen;
	wire	[`MEM_SIZE_WIDTH-1:0]		dmem_size;
	wire	[`MEM_ADDR_WIDTH-1:0]		dmem_addr;
	wire	[`MEM_BUS_WIDTH-1:0]		dmem_wdata_delayed;
	wire	[`MEM_BUS_WIDTH-1:0]		dmem_rdata;
	wire								dmem_badmem_e;
	
	reg									dmem_en_reg;
	reg									dmem_wen_reg;
	reg		[`MEM_ADDR_WIDTH-1:0]		dmem_waddr_reg;
	
	wire								dmem_en_signal;
	
	reg		[3 : 0]						data_mem_mask;
	reg		[3 : 0]						data_mem_mask_reg;
	
	wire	[7 : 0]						dmem_addr_sw;
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// Sytem reset high active
	//////////////////////////////////////////////////////////////
	assign global_rst = ~global_nrst;
	
	sys_pll sys_pll_inst0(
		.areset		(~rst),
		.inclk0		(sys_clk),
		.c0			(global_clk),
		.locked		(global_nrst)
	);
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// RISC-V UDP Control and communication
	//////////////////////////////////////////////////////////////
	rv32i_udp rv32i_udp_inst0(
		
		.phy_eth_rst	(E_RESET),
		
		.phy_eth_tclk	(E_TXC),
		.phy_eth_txen	(E_TXEN),
		.phy_eth_tdata	(E_TXD),
		.phy_eth_txer	(),
		
		.phy_eth_rxc	(E_RXC),
		.phy_eth_rxdv	(E_RXDV),
		.phy_eth_rxer	(E_RXER),
		.phy_eth_rdata	(E_RXD),
		
		.valid_ip_p		(),
		.data_o_valid	(data_o_valid),
		.icache_wr_data	(icache_wr_data),
		
		.tx_finish		(tx_finish_sig),
		.rx_finish		(rx_finish_sig),
		
		.data_cmd		(data_cmd_signal),
		.prg_data_len	(prg_data_len_signal),
		
		.data_result	(dmem_rdata)
	);
	
	// added for receive test
	always@(negedge E_RXC)begin
		if(!global_nrst)begin
			data_o_valid_reg1 <= 1'b0;
			data_o_valid_reg2 <= 1'b0;
			icache_wr_en <= 1'b0;
			icache_wr_addr <= 9'd0;
		end else begin
			data_o_valid_reg1 <= data_o_valid;
			data_o_valid_reg2 <= data_o_valid_reg1;
			
			// edge triggered data_o_valid (rising), fifo wr request
			if(data_o_valid_reg1 && !data_o_valid_reg2)begin
				icache_wr_en <= 1'b1;
			end else begin
				icache_wr_en <= 1'b0;
			end
			
			if(!data_o_valid_reg1 && data_o_valid_reg2)begin
				icache_wr_addr <= icache_wr_addr + 9'd1;
			end
			
			if(rx_finish_sig & !icache_wr_en)begin
				icache_wr_addr <= 9'd0;
			end
		end
	end
	
	always@(negedge E_RXC)begin
		if(!global_nrst)begin
			prg_data_len_reg <= 16'd0;
		end else begin
			if(icache_wr_en)begin
				prg_data_len_reg <= prg_data_len_signal;
			end
		end
	end	
	
	always@(negedge E_RXC)begin
		if(!global_nrst)begin
			rv32i_core_rst <= 1'b0;
			rv32i_core_rst_delay <= 1'b0;
		end else begin
			if(data_cmd_signal == udp2risc_v_rst || data_cmd_signal[31 : 16] == udp2risc_v_RROM[31 : 16])begin
				rv32i_core_rst <= 1'b1;
			end else begin
				rv32i_core_rst <= 1'b0;
			end
			
			rv32i_core_rst_delay <= rv32i_core_rst;
		end
	end
	
	always@(negedge E_RXC)begin
		if(!global_nrst)begin
			rv32i_core_run <= 1'b0;
			rv32i_core_hld <= 1'b0;
		end else begin
			if(data_cmd_signal == udp2risc_v_run)begin
				rv32i_core_run <= 1'b1;
			end
			
			if(data_cmd_signal == udp2risc_v_held)begin
				rv32i_core_hld <= 1'b1;
			end else begin
				rv32i_core_hld <= 1'd0;
			end
			
			if(rv32i_core_run & rv32i_core_hld)begin
				rv32i_core_run <= 1'b0;
			end
		end
	end
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// Instruction memory
	//////////////////////////////////////////////////////////////
	assign imem_wait = 'b0;
	assign imem_badmem_e = 'b0;
	assign icache_rd_addr = imem_addr[10 : 2];
	
	rv32i_icache rv32i_icache_inst0(
		
		.wrclock(E_RXC),				// input  wrclock_sig
		.wren(icache_wr_en),			// input  wren_sig
		.wraddress(icache_wr_addr),		// input [8:0] wraddress_sig
		.data(icache_wr_data),			// input [31:0] data_sig
		
		.rdclock(rv32i_global_clk),		// input  rdclock_sig
		.rdaddress(icache_rd_addr),		// input [8:0] rdaddress_sig
		.q(imem_rdata)					// output [31:0] q_sig
	);
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// Data memory
	//////////////////////////////////////////////////////////////
	assign dmem_wait = 'b0;
	assign dmem_badmem_e = 'b0;
	assign dmem_en_signal = dmem_en_reg | (dmem_en & !dmem_wen) | rv32i_rst;
	
	always@(*)begin
		case(dmem_size)
			`MEM_TYPE_LB: data_mem_mask = 4'b0001;
			`MEM_TYPE_LH: data_mem_mask = 4'b0011;
			`MEM_TYPE_LW: data_mem_mask = 4'b1111;
			default: data_mem_mask = 4'b1111;
		endcase
	end
	
	always@(posedge rv32i_global_clk)begin
		if(rv32i_rst)begin
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
	
	assign dmem_addr_sw = (rv32i_core_rst) ? data_cmd_signal[7 : 0] : dmem_addr[7 : 0];
	
	rv32i_dcache rv32i_dcache_inst0(
		.clock				(rv32i_global_clk),
		.byteena_a			(data_mem_mask_reg),
		.data				(dmem_wdata_delayed),
		.enable				(dmem_en_signal),
		.rdaddress			(dmem_addr_sw),
		.wraddress			(dmem_waddr_reg[7 : 0]),
		.wren				(dmem_wen_reg),
		.q					(dmem_rdata)
	);
	//////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////
	// RV32_i Core
	//////////////////////////////////////////////////////////////
	assign rv32i_rst = global_rst | rv32i_core_rst_delay;
	
	rv32i_cken rv32i_cken_inst0(
		.inclk  (global_clk),							//  altclkctrl_input.inclk
		.ena    ((rv32i_core_run | rv32i_core_rst)),	//	.ena
		.outclk (rv32i_global_clk)						// altclkctrl_output.outclk
	);
	
	always@(*)begin
		htif_pcr_req_valid = 'd1;
		htif_pcr_req_rw = 'd0;
		htif_pcr_req_addr = 'd0;
		htif_pcr_req_data = 'd0;
		htif_pcr_resp_ready = 'd1;
	end
	
	rv32i_pipeline rv32i_pipeline_inst0(
		
		.clk					(rv32i_global_clk),		//input  clk_sig
		.ext_interrupts			(ext_interrupts),		//input [23:0] ext_interrupts_sig
		.reset					(rv32i_rst),			//input  reset_sig

		.imem_wait				(imem_wait),			//input  imem_wait_sig
		.imem_addr				(imem_addr),			//output [31:0] imem_addr_sig
		.imem_rdata				(imem_rdata),			//input [31:0] imem_rdata_sig
		.imem_badmem_e			(imem_badmem_e),		//input  imem_badmem_e_sig

		.dmem_wait				(dmem_wait),			//input  dmem_wait_sig
		.dmem_en				(dmem_en),				//output  dmem_en_sig
		.dmem_wen				(dmem_wen),				//output  dmem_wen_sig
		.dmem_size				(dmem_size),			//output [2:0] dmem_size_sig
		.dmem_addr				(dmem_addr),			//output [31:0] dmem_addr_sig
		.dmem_wdata_delayed		(dmem_wdata_delayed),	//output [31:0] dmem_wdata_delayed_sig
		.dmem_rdata				(dmem_rdata),			//input [31:0] dmem_rdata_sig
		.dmem_badmem_e			(dmem_badmem_e),		//input  dmem_badmem_e_sig

		.htif_reset				(rv32i_rst),			//input  htif_reset_sig
		.htif_pcr_req_valid		(htif_pcr_req_valid),	//input  htif_pcr_req_valid_sig
		.htif_pcr_req_ready		(htif_pcr_req_ready),	//output  htif_pcr_req_ready_sig
		.htif_pcr_req_rw		(htif_pcr_req_rw),		//input  htif_pcr_req_rw_sig
		.htif_pcr_req_addr		(htif_pcr_req_addr),	//input [11:0] htif_pcr_req_addr_sig
		.htif_pcr_req_data		(htif_pcr_req_data),	//input [63:0] htif_pcr_req_data_sig
		.htif_pcr_resp_valid	(htif_pcr_resp_valid),	//output  htif_pcr_resp_valid_sig
		.htif_pcr_resp_ready	(htif_pcr_resp_ready),	//input  htif_pcr_resp_ready_sig
		.htif_pcr_resp_data		(htif_pcr_resp_data)	// output [63:0] htif_pcr_resp_data_sig
	);
	
endmodule

