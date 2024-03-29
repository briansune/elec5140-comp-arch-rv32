`include "rv32i_ctrl_constants.vh"
`include "rv32i_alu_op.vh"
`include "rv32i_opcodes.vh"
`include "rv32i_csr_addr_map.vh"
`include "rv32i_md_constants.vh"
`include "rv32i_platform_constants.vh"

module rv32i_pipeline(
	
	input							clk,
	input	[`N_EXT_INTS-1:0]		ext_interrupts, 
	input							reset,
	
	input							imem_wait,
	output	[`XPR_LEN-1:0]			imem_addr,
	input	[`XPR_LEN-1:0]			imem_rdata,
	input							imem_badmem_e,
	
	input							dmem_wait,
	output							dmem_en,
	output							dmem_wen,
	output	[`MEM_TYPE_WIDTH-1:0]	dmem_size,
	output	[`XPR_LEN-1:0]			dmem_addr,
	output	[`XPR_LEN-1:0]			dmem_wdata_delayed,
	input	[`XPR_LEN-1:0]			dmem_rdata,
	input							dmem_badmem_e,
	
	input							htif_reset,
	input							htif_pcr_req_valid,
	output							htif_pcr_req_ready,
	input							htif_pcr_req_rw,
	input	[`CSR_ADDR_WIDTH-1:0]	htif_pcr_req_addr,
	input	[`HTIF_PCR_WIDTH-1:0]	htif_pcr_req_data,
	output							htif_pcr_resp_valid,
	input							htif_pcr_resp_ready,
	output	[`HTIF_PCR_WIDTH-1:0]	htif_pcr_resp_data
);
	
	wire		[`PC_SRC_SEL_WIDTH-1:0]			PC_src_sel;
	wire		[`XPR_LEN-1:0]					PC_PIF;
	
	reg			[`XPR_LEN-1:0]					PC_IF;
	
	wire										kill_IF;
	wire										stall_IF;
	
	reg			[`XPR_LEN-1:0]					PC_DX;
	reg			[`INST_WIDTH-1:0]				inst_DX;
	
	wire										stall_DX;
	wire		[`IMM_TYPE_WIDTH-1:0]			imm_type;
	wire		[`XPR_LEN-1:0]					imm;
	wire		[`SRC_A_SEL_WIDTH-1:0]			src_a_sel;
	wire		[`SRC_B_SEL_WIDTH-1:0]			src_b_sel;
	wire		[`REG_ADDR_WIDTH-1:0]			rs1_addr;
	wire		[`XPR_LEN-1:0]					rs1_data;
	wire		[`XPR_LEN-1:0]					rs1_data_bypassed;
	wire		[`REG_ADDR_WIDTH-1:0]			rs2_addr;
	wire		[`XPR_LEN-1:0]					rs2_data;
	wire		[`XPR_LEN-1:0]					rs2_data_bypassed;
	wire		[`ALU_OP_WIDTH-1:0]				alu_op;
	wire		[`XPR_LEN-1:0]					alu_src_a;
	wire		[`XPR_LEN-1:0]					alu_src_b;
	wire		[`XPR_LEN-1:0]					alu_out;
	wire										cmp_true;
	wire										bypass_rs1;
	wire										bypass_rs2;
	wire		[`MEM_TYPE_WIDTH-1:0]			dmem_type;
	
	wire										md_req_valid;
	wire										md_req_ready;
	wire										md_req_in_1_signed;
	wire										md_req_in_2_signed;
	wire		[`MD_OUT_SEL_WIDTH-1:0]			md_req_out_sel;
	wire		[`MD_OP_WIDTH-1:0]				md_req_op;
	wire										md_resp_valid;
	wire		[`XPR_LEN-1:0]					md_resp_result;
	
	reg			[`XPR_LEN-1:0]					PC_WB;
	reg			[`XPR_LEN-1:0]					alu_out_WB;
	reg			[`XPR_LEN-1:0]					csr_rdata_WB;
	reg			[`XPR_LEN-1:0]					store_data_WB;
	
	wire										stall_WB;
	reg			[`XPR_LEN-1:0]					bypass_data_WB;
	wire		[`XPR_LEN-1:0]					load_data_WB;
	reg			[`XPR_LEN-1:0]					wb_data_WB;
	wire		[`REG_ADDR_WIDTH-1:0]			reg_to_wr_WB;
	wire										wr_reg_WB;
	wire		[`WB_SRC_SEL_WIDTH-1:0]			wb_src_sel_WB;
	reg			[`MEM_TYPE_WIDTH-1:0]			dmem_type_WB;
	
	// CSR management
	wire		[`CSR_ADDR_WIDTH-1:0]			csr_addr;
	wire		[`CSR_CMD_WIDTH-1:0]			csr_cmd;
	wire										csr_imm_sel;
	wire		[`PRV_WIDTH-1:0]				prv;
	wire										illegal_csr_access;
	wire										interrupt_pending;
	wire										interrupt_taken;
	wire		[`XPR_LEN-1:0]					csr_wdata;
	wire		[`XPR_LEN-1:0]					csr_rdata;
	wire										retire_WB;
	wire										exception_WB;
	wire		[`ECODE_WIDTH-1:0]				exception_code_WB;
	wire		[`XPR_LEN-1:0]					handler_PC;
	wire										eret;
	wire		[`XPR_LEN-1:0]					epc;
	
	
	`include "rv32i_store_data.vh"
	`include "rv32i_load_data.vh"
	
	assign dmem_wdata_delayed = store_data(alu_out_WB,store_data_WB,dmem_type_WB);
	assign load_data_WB = load_data(alu_out_WB,dmem_rdata,dmem_type_WB);
	
	rv32i_ctrl ctrl(
		
		.clk(clk),
		.reset(reset),
		
		.inst_DX(inst_DX),
		.imem_wait(imem_wait),
		.imem_badmem_e(imem_badmem_e),
		.dmem_wait(dmem_wait),
		.dmem_badmem_e(dmem_badmem_e),
		.cmp_true(cmp_true),
		.PC_src_sel(PC_src_sel),
		.imm_type(imm_type),
		.src_a_sel(src_a_sel),
		.src_b_sel(src_b_sel),
		.bypass_rs1(bypass_rs1),
		.bypass_rs2(bypass_rs2),
		.alu_op(alu_op),
		
		.dmem_en(dmem_en),
		.dmem_wen(dmem_wen),
		.dmem_size(dmem_size),
		.dmem_type(dmem_type),
		
		.md_req_valid(md_req_valid),
		.md_req_ready(md_req_ready),
		.md_req_op(md_req_op),
		.md_req_in_1_signed(md_req_in_1_signed),
		.md_req_in_2_signed(md_req_in_2_signed),
		.md_req_out_sel(md_req_out_sel),
		.md_resp_valid(md_resp_valid),
		
		.wr_reg_WB(wr_reg_WB),
		.reg_to_wr_WB(reg_to_wr_WB),
		.wb_src_sel_WB(wb_src_sel_WB),
		.stall_IF(stall_IF),
		.kill_IF(kill_IF),
		.stall_DX(stall_DX),
		.stall_WB(stall_WB),
		.exception_WB(exception_WB),
		.exception_code_WB(exception_code_WB),
		.retire_WB(retire_WB),
		.csr_cmd(csr_cmd),
		.csr_imm_sel(csr_imm_sel),
		.illegal_csr_access(illegal_csr_access),
		.interrupt_pending(interrupt_pending),
		.interrupt_taken(interrupt_taken),
		.prv(prv),
		.eret(eret)
	);
	
	rv32i_PC_mux PCmux(
		.PC_src_sel		(PC_src_sel),
		.inst_DX		(inst_DX),
		.rs1_data		(rs1_data_bypassed),
		.PC_IF			(PC_IF),
		.PC_DX			(PC_DX),
		.handler_PC		(handler_PC),
		.epc			(epc),
		.PC_PIF			(PC_PIF)
	);
	
	assign imem_addr = PC_PIF;
	
	always@(posedge clk or posedge reset)begin
		
		if(reset)begin
			//PC_IF <= `XPR_LEN'h200;
			PC_IF <= `XPR_LEN'h00;
		end else begin
			if(~stall_IF)begin
				PC_IF <= PC_PIF;
			end
		end
	end
	
	always@(posedge clk or posedge reset)begin
		
		if(reset)begin
			PC_DX <= 0;
			inst_DX <= `RV_NOP;
		end else begin
			if(~stall_DX)begin
				if(kill_IF)begin
					inst_DX <= `RV_NOP;
				end else begin
					PC_DX <= PC_IF;
					inst_DX <= imem_rdata;
				end
			end
		end
	end
	
	
	/////////////////////////////////////////////////////////////////
	// register convert and data load
	/////////////////////////////////////////////////////////////////
	assign rs1_addr = inst_DX[19:15];
	assign rs2_addr = inst_DX[24:20];
	
	assign rs1_data_bypassed = bypass_rs1 ? bypass_data_WB:	rs1_data;
	assign rs2_data_bypassed = bypass_rs2 ? bypass_data_WB:	rs2_data;
	
	rv32i_regfile regfile_inst0(
		.clk		(clk),
		.ra1		(rs1_addr),
		.rd1		(rs1_data),
		.ra2		(rs2_addr),
		.rd2		(rs2_data),
		.wen		(wr_reg_WB),
		.wa			(reg_to_wr_WB),
		.wd			(wb_data_WB)
	);
	
	rv32i_imm_gen imm_gen(
		.inst		(inst_DX),
		.imm_type	(imm_type),
		.imm		(imm)
	);
	
	rv32i_src_a_mux src_a_mux(
		.src_a_sel	(src_a_sel),
		.PC_DX		(PC_DX),
		.rs1_data	(rs1_data_bypassed),
		.alu_src_a	(alu_src_a)
	);
	
	rv32i_src_b_mux src_b_mux(
		.src_b_sel	(src_b_sel),
		.imm		(imm),
		.rs2_data	(rs2_data_bypassed),
		.alu_src_b	(alu_src_b)
	);
	/////////////////////////////////////////////////////////////////
	
	
	/////////////////////////////////////////////////////////////////
	// ALU op code and source A & B
	/////////////////////////////////////////////////////////////////
	rv32i_alu ALU_inst0(
		.op		(alu_op),
		.in1	(alu_src_a),
		.in2	(alu_src_b),
		.out	(alu_out)
	);
	
	/////////////////////////////////////////////////////////////////
	// RV32I_M with multiplication
	/////////////////////////////////////////////////////////////////
	rv32i_mul_div md(
		.clk				(clk),
		.reset				(reset),
		.req_valid			(md_req_valid),
		.req_ready			(md_req_ready),
		.req_in_1_signed	(md_req_in_1_signed),
		.req_in_2_signed	(md_req_in_2_signed),
		.req_out_sel		(md_req_out_sel),
		.req_op				(md_req_op),
		.req_in_1			(rs1_data_bypassed),
		.req_in_2			(rs2_data_bypassed),
		.resp_valid			(md_resp_valid),
		.resp_result		(md_resp_result)
	);
	
	assign cmp_true = alu_out[0];
	assign dmem_addr = alu_out;
	/////////////////////////////////////////////////////////////////
	
	always@(posedge clk or posedge reset)begin
		
		if(reset)begin
			
			PC_WB <= 'b0;
			store_data_WB <= 'b0;
			alu_out_WB <= 'b0;
			
		end else begin
			if(~stall_WB)begin
				PC_WB <= PC_DX;
				store_data_WB <= rs2_data_bypassed;
				alu_out_WB <= alu_out;
				csr_rdata_WB <= csr_rdata;
				dmem_type_WB <= dmem_type;
			end
		end
	end
	
	always@(*)begin
		case(wb_src_sel_WB)
			`WB_SRC_CSR:	bypass_data_WB = csr_rdata_WB;
			`WB_SRC_MD:		bypass_data_WB = md_resp_result;
			default:		bypass_data_WB = alu_out_WB;
		endcase
	end
	
	always@(*)begin
		case(wb_src_sel_WB)
			`WB_SRC_ALU:	wb_data_WB = bypass_data_WB;
			`WB_SRC_MEM:	wb_data_WB = load_data_WB;
			`WB_SRC_CSR:	wb_data_WB = bypass_data_WB;
			`WB_SRC_MD:		wb_data_WB = bypass_data_WB;
			default:		wb_data_WB = bypass_data_WB;
		endcase
	end
	
	// CSR
	assign csr_addr = inst_DX[31:20];
	assign csr_wdata = (csr_imm_sel) ? inst_DX[19:15]:	rs1_data_bypassed;
	
	rv32i_csr_file csr(
		
		.clk(clk),
		.ext_interrupts(ext_interrupts),
		.reset(reset),
		.addr(csr_addr),
		.cmd(csr_cmd),
		.wdata(csr_wdata),
		.prv(prv),
		.illegal_access(illegal_csr_access),
		.rdata(csr_rdata),
		.retire(retire_WB),
		.exception(exception_WB),
		.exception_code(exception_code_WB),
		.exception_load_addr(alu_out_WB),
		.exception_PC(PC_WB),
		.epc(epc),
		.eret(eret),
		.handler_PC(handler_PC),
		.interrupt_pending(interrupt_pending),
		.interrupt_taken(interrupt_taken),
		.htif_reset(htif_reset),
		.htif_pcr_req_valid(htif_pcr_req_valid),
		.htif_pcr_req_ready(htif_pcr_req_ready),
		.htif_pcr_req_rw(htif_pcr_req_rw),
		.htif_pcr_req_addr(htif_pcr_req_addr),
		.htif_pcr_req_data(htif_pcr_req_data),
		.htif_pcr_resp_valid(htif_pcr_resp_valid),
		.htif_pcr_resp_ready(htif_pcr_resp_ready),
		.htif_pcr_resp_data(htif_pcr_resp_data)
	);
	
endmodule
