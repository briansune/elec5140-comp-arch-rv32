`timescale 1ns / 1ps

`include "rv32_alu_op.vh"
`include "rv32_opcodes.vh"
`include "rv32_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"


module tb_rv32i_all_opcode_decode;
	
	reg								clk;
	
	reg									cmp_true;
	reg			[`INST_WIDTH-1:0]		inst_DX;
	reg			[`PRV_WIDTH-1:0]		prv;
	
	wire		[`ALU_OP_WIDTH-1:0]     alu_op;
	
	wire								illegal_instruction;
	wire								ecall;
	wire								eret_unkilled;
	wire								ebreak;
	
	wire		[`CSR_CMD_WIDTH-1:0]	csr_cmd_unkilled;
	wire								csr_imm_sel;
	
	wire								fence_i;
	wire								branch_taken_unkilled;
	
	wire								jal_unkilled;
	wire								jalr_unkilled;
	
	wire								uses_rs1;
	wire								uses_rs2;
	
	wire		[`IMM_TYPE_WIDTH-1:0]   imm_type;
	
	wire		[`SRC_A_SEL_WIDTH-1:0]  src_a_sel;
	wire		[`SRC_B_SEL_WIDTH-1:0]  src_b_sel;
	
	wire								dmem_en_unkilled;
	wire								dmem_wen_unkilled;
	
	wire								wr_reg_unkilled_DX;
	wire		[`WB_SRC_SEL_WIDTH-1:0]	wb_src_sel_DX;
	
	wire								uses_md_unkilled;
	wire								wfi_unkilled_DX;
	
	////////////////////////////////////////////////
	//	instantiate
	////////////////////////////////////////////////
	rv32i_all_opcode_decode DUT(
		
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
	
	//50MHz system clock generator
	always begin
		#10 clk = ~clk;
	end
	
	integer i;
	
	initial begin
		
		clk = 'b0;
		cmp_true = 'b0;
		prv = 'b0;
		
		inst_DX = 'b0;
		
		fork begin
			
			#100 @(posedge clk)begin
				inst_DX = 32'b0000_0000_0010_0000_1000_0000_0011_0011;
			end
			
			#100 @(posedge clk)begin
				inst_DX = 32'b0000_0010_0010_0000_1000_0000_0011_0011;
			end
			
			
			#300 $stop;
		end join
	end
	
endmodule
