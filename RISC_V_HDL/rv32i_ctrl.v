`include "rv32i_ctrl_constants.vh"
`include "rv32i_alu_op.vh"
`include "rv32i_opcodes.vh"
`include "rv32i_csr_addr_map.vh"
`include "rv32i_md_constants.vh"

module rv32i_ctrl(
	
	input									clk,
	input									reset,
	
	input			[`INST_WIDTH-1:0]		inst_DX,
	
	input									imem_wait,
	input									imem_badmem_e,
	
	input									dmem_wait,
	input									dmem_badmem_e,
	
	input									cmp_true,
	input			[`PRV_WIDTH-1:0]		prv,
	output reg		[`PC_SRC_SEL_WIDTH-1:0]	PC_src_sel,
	
	output 			[`IMM_TYPE_WIDTH-1:0]   imm_type,
	output									bypass_rs1,
	output									bypass_rs2,
	output 			[`SRC_A_SEL_WIDTH-1:0]  src_a_sel,
	output 			[`SRC_B_SEL_WIDTH-1:0]  src_b_sel,
	output 			[`ALU_OP_WIDTH-1:0]     alu_op,
	
	output wire								dmem_en,
	output wire								dmem_wen,
	output wire		[2:0]					dmem_size,
	output wire		[`MEM_TYPE_WIDTH-1:0]	dmem_type,
	
	output									md_req_valid,
	input									md_req_ready,
	output 									md_req_in_1_signed,
	output 									md_req_in_2_signed,
	output 			[`MD_OP_WIDTH-1:0]		md_req_op,
	output 			[`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel,
	input									md_resp_valid,
	
	output wire								eret,
	output			[`CSR_CMD_WIDTH-1:0]	csr_cmd,
	output 									csr_imm_sel,
	input									illegal_csr_access,
	input									interrupt_pending,
	input									interrupt_taken,
	output wire								wr_reg_WB,
	output reg		[`REG_ADDR_WIDTH-1:0]	reg_to_wr_WB,
	output reg		[`WB_SRC_SEL_WIDTH-1:0] wb_src_sel_WB,
	output wire								stall_IF,
	output wire								kill_IF,
	output wire								stall_DX,
	output wire								stall_WB,
	
	output wire								exception_WB,
	output wire		[`ECODE_WIDTH-1:0]		exception_code_WB,
	output wire								retire_WB
);
	
	wire							kill_DX;
	wire							kill_WB;
	
	// IF stage ctrl pipeline registers
	reg								replay_IF;
	
	// IF stage ctrl signals
	wire							ex_IF;
	
	// DX stage ctrl pipeline registers
	reg								had_ex_DX;
	reg								prev_killed_DX;
	
	// DX stage ctrl signals
	wire	[2:0]					funct3 = inst_DX[14:12];
	wire	[`REG_ADDR_WIDTH-1:0]	rs1_addr = inst_DX[19:15];
	wire	[`REG_ADDR_WIDTH-1:0]	rs2_addr = inst_DX[24:20];
	wire	[`REG_ADDR_WIDTH-1:0]	reg_to_wr_DX = inst_DX[11:7];
	
	
	wire							illegal_instruction;
	wire							ebreak;
	wire							ecall;
	wire							eret_unkilled;
	wire	[`CSR_CMD_WIDTH-1:0]	csr_cmd_unkilled;
	wire							fence_i;
	wire							branch_taken_unkilled;
	wire							jal_unkilled;
	wire							jalr_unkilled;
	wire							dmem_en_unkilled;
	wire							dmem_wen_unkilled;
	wire							wr_reg_unkilled_DX;
	wire	[`WB_SRC_SEL_WIDTH-1:0]	wb_src_sel_DX;
	wire							uses_md_unkilled;
	wire							wfi_unkilled_DX;
	
	
	wire							branch_taken;
	wire							jal;
	wire							jalr;
	wire							redirect;
	wire							wr_reg_DX;
	wire							new_ex_DX;
	wire							ex_DX;
	reg		[`ECODE_WIDTH-1:0]		ex_code_DX;
	wire							killed_DX;
	wire							uses_md;
	wire							wfi_DX;
	
	
	// WB stage ctrl pipeline registers
	reg								wr_reg_unkilled_WB;
	reg								had_ex_WB;
	reg		[`ECODE_WIDTH-1:0]		prev_ex_code_WB;
	reg								store_in_WB;
	reg								dmem_en_WB;
	reg								prev_killed_WB;
	reg								uses_md_WB;
	reg								wfi_unkilled_WB;
	
	// WB stage ctrl signals
	wire							ex_WB;
	reg		[`ECODE_WIDTH-1:0]		ex_code_WB;
	wire							dmem_access_exception;
	wire							exception = ex_WB;
	wire							killed_WB;
	wire							load_in_WB;
	wire							active_wfi_WB;
	
	// Hazard signals
	wire							load_use;
	wire							uses_rs1;
	wire							uses_rs2;
	wire							raw_rs1;
	wire							raw_rs2;
	wire							raw_on_busy_md;
	
	/////////////////////////////////////////////////////////////////////////////
	// clocked - IF stage ctrl
	/////////////////////////////////////////////////////////////////////////////
	always@(posedge clk)begin
		if(reset)begin
			replay_IF <= 1'b1;
		end else begin
			replay_IF <= (redirect && imem_wait) || (fence_i && store_in_WB);
		end
	end
	
	// interrupts kill IF, DX instructions -- WB may commit
	assign kill_IF = stall_IF || ex_IF || ex_DX || ex_WB || redirect || replay_IF || interrupt_taken;
	assign stall_IF = stall_DX || ((imem_wait && !redirect) && !(ex_WB || interrupt_taken));
	assign ex_IF = imem_badmem_e && !imem_wait && !redirect && !replay_IF;
	
	// DX stage ctrl
	always@(posedge clk)begin
		if(reset)begin
			had_ex_DX <= 0;
			prev_killed_DX <= 0;
		end else if(!stall_DX)begin
			had_ex_DX <= ex_IF;
			prev_killed_DX <= kill_IF;
		end
	end
	
	// interrupts kill IF, DX instructions -- WB may commit
	// Exceptions never show up falsely due to hazards -- don't get exceptions on stall
	assign kill_DX = stall_DX || ex_DX || ex_WB || interrupt_taken;
	// internal hazards
	assign stall_DX = stall_WB || (( load_use || raw_on_busy_md || (fence_i && store_in_WB) || (uses_md_unkilled && !md_req_ready)) && !(ex_DX || ex_WB || interrupt_taken));
	
	assign new_ex_DX = ebreak || ecall || illegal_instruction || illegal_csr_access;
	assign ex_DX = had_ex_DX || new_ex_DX;
	assign killed_DX = prev_killed_DX || kill_DX;
	
	assign dmem_en = dmem_en_unkilled && !kill_DX;
	assign dmem_wen = dmem_wen_unkilled && !kill_DX;
	
	always@(*)begin
		
		ex_code_DX = `ECODE_INST_ADDR_MISALIGNED;
		
		if(had_ex_DX)begin
			ex_code_DX = `ECODE_INST_ADDR_MISALIGNED;
		end else if(illegal_instruction)begin
			ex_code_DX = `ECODE_ILLEGAL_INST;
		end else if(illegal_csr_access)begin
			ex_code_DX = `ECODE_ILLEGAL_INST;
		end else if(ebreak)begin
			ex_code_DX = `ECODE_BREAKPOINT;
		end else if(ecall)begin
			ex_code_DX = `ECODE_WIDTH'd`ECODE_ECALL_FROM_U + prv;
		end
	end
	
	assign dmem_size = {1'b0,funct3[1:0]};
	assign dmem_type = funct3;
	assign csr_cmd = (kill_DX) ? `CSR_CMD_WIDTH'd`CSR_IDLE : csr_cmd_unkilled;
	assign redirect = branch_taken || jal || jalr || eret;
	
	/////////////////////////////////////////////////////////////////////////////
	// RISC-V RV32I all opcode decoding
	/////////////////////////////////////////////////////////////////////////////
	rv32i_all_opcode_decode rv32i_aopc_deco_inst0(
		
		.cmp_true(cmp_true),
		.inst_DX(inst_DX),
		.prv(prv),
		
		.alu_op(alu_op),
		
		.illegal_instruction(illegal_instruction),
		.ecall(ecall),
		.eret_unkilled(eret_unkilled),
		.ebreak(ebreak),
		
		.csr_cmd_unkilled(csr_cmd_unkilled),
		.csr_imm_sel(csr_imm_sel),
		
		.fence_i(fence_i),
		.branch_taken_unkilled(branch_taken_unkilled),
		
		.jal_unkilled(jal_unkilled),
		.jalr_unkilled(jalr_unkilled),
		
		.uses_rs1(uses_rs1),
		.uses_rs2(uses_rs2),
		
		.imm_type(imm_type),
		
		.src_a_sel(src_a_sel),
		.src_b_sel(src_b_sel),
		
		.dmem_en_unkilled(dmem_en_unkilled),
		.dmem_wen_unkilled(dmem_wen_unkilled),
		
		.wr_reg_unkilled_DX(wr_reg_unkilled_DX),
		.wb_src_sel_DX(wb_src_sel_DX),
		
		.uses_md_unkilled(uses_md_unkilled),
		.wfi_unkilled_DX(wfi_unkilled_DX)
	);
	/////////////////////////////////////////////////////////////////////////////
	
	
	/////////////////////////////////////////////////////////////////////////////
	// M extension RISC-V RV32I_M
	/////////////////////////////////////////////////////////////////////////////
	assign uses_md = uses_md_unkilled && !kill_DX;
	
	rv32i_mul_div_ctrl rv32i_MD_ctrl_inst0(
		.funct3				(funct3),
		.uses_md			(uses_md),
		.md_req_valid		(md_req_valid),
		.md_req_op			(md_req_op),
		.md_req_in_1_signed	(md_req_in_1_signed),
		.md_req_in_2_signed	(md_req_in_2_signed),
		.md_req_out_sel		(md_req_out_sel)
	);
	/////////////////////////////////////////////////////////////////////////////
	
	
	assign eret = eret_unkilled && !kill_DX;
	assign branch_taken = branch_taken_unkilled && !kill_DX;
	assign jal = jal_unkilled && !kill_DX;
	assign jalr = jalr_unkilled && !kill_DX;
	
	always@(*)begin
		if(exception || interrupt_taken)begin
			PC_src_sel = `PC_HANDLER;
		end else if(replay_IF || (stall_IF && !imem_wait))begin
			PC_src_sel = `PC_REPLAY;
		end else if(eret)begin
			PC_src_sel = `PC_EPC;
		end else if(branch_taken)begin
			PC_src_sel = `PC_BRANCH_TARGET;
		end else if(jal)begin
			PC_src_sel = `PC_JAL_TARGET;
		end else if(jalr)begin
			PC_src_sel = `PC_JALR_TARGET;
		end else begin
			PC_src_sel = `PC_PLUS_FOUR;
		end
	end
	
	
	assign wfi_DX = wfi_unkilled_DX && !kill_DX;
	assign wr_reg_DX = wr_reg_unkilled_DX && !kill_DX;
	
	// WB stage ctrl
	always@(posedge clk)begin
		if(reset)begin
			prev_killed_WB <= 0;
			had_ex_WB <= 0;
			wr_reg_unkilled_WB <= 0;
			store_in_WB <= 0;
			dmem_en_WB <= 0;
			uses_md_WB <= 0;
			wfi_unkilled_WB <= 0;
		end else if(!stall_WB)begin
			prev_killed_WB <= killed_DX;
			had_ex_WB <= ex_DX;
			wr_reg_unkilled_WB <= wr_reg_DX;
			wb_src_sel_WB <= wb_src_sel_DX;
			prev_ex_code_WB <= ex_code_DX;
			reg_to_wr_WB <= reg_to_wr_DX;
			store_in_WB <= dmem_wen;
			dmem_en_WB <= dmem_en;
			uses_md_WB <= uses_md;
			wfi_unkilled_WB <= wfi_DX;
		end
	end
	
	// WFI handling
	// can't be killed while in WB stage
	assign active_wfi_WB = !prev_killed_WB && wfi_unkilled_WB && !(interrupt_taken || interrupt_pending);
	
	assign kill_WB = stall_WB || ex_WB;
	assign stall_WB = ((dmem_wait && dmem_en_WB) || (uses_md_WB && !md_resp_valid) || active_wfi_WB) && !exception;
	assign dmem_access_exception = dmem_badmem_e;
	assign ex_WB = had_ex_WB || dmem_access_exception;
	assign killed_WB = prev_killed_WB || kill_WB;
	
	always@(*)begin
		ex_code_WB = prev_ex_code_WB;
		if(!had_ex_WB)begin
			if(dmem_access_exception)begin
				ex_code_WB = wr_reg_unkilled_WB ? `ECODE_WIDTH'd`ECODE_LOAD_ADDR_MISALIGNED : `ECODE_WIDTH'd`ECODE_STORE_AMO_ADDR_MISALIGNED;
			end
		end
	end
	
	assign exception_WB = ex_WB;
	assign exception_code_WB = ex_code_WB;
	assign wr_reg_WB = wr_reg_unkilled_WB && !kill_WB;
	assign retire_WB = !(kill_WB || killed_WB);
	
	// Hazard logic
	assign load_in_WB = dmem_en_WB && !store_in_WB;
	
	assign raw_rs1 = wr_reg_WB && (rs1_addr == reg_to_wr_WB) && (rs1_addr != 0) && uses_rs1;
	assign bypass_rs1 = !load_in_WB && raw_rs1;
	
	assign raw_rs2 = wr_reg_WB && (rs2_addr == reg_to_wr_WB) && (rs2_addr != 0) && uses_rs2;
	assign bypass_rs2 = !load_in_WB && raw_rs2;
	
	assign raw_on_busy_md = uses_md_WB && (raw_rs1 || raw_rs2) && !md_resp_valid;
	assign load_use = load_in_WB && (raw_rs1 || raw_rs2);
	
endmodule
