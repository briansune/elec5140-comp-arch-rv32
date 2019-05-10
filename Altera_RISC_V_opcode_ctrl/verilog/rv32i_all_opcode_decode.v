`include "rv32_alu_op.vh"
`include "rv32_opcodes.vh"
`include "rv32_ctrl_constants.vh"
`include "vscale_csr_addr_map.vh"

module rv32i_all_opcode_decode(
	
	input									cmp_true,
	input			[`INST_WIDTH-1:0]		inst_DX,
	input			[`PRV_WIDTH-1:0]		prv,
	
	output reg		[`ALU_OP_WIDTH-1:0]     alu_op,
	
	output reg								illegal_instruction,
	output reg								ecall,
	output reg								eret_unkilled,
	output reg								ebreak,
	
	output reg		[`CSR_CMD_WIDTH-1:0]	csr_cmd_unkilled,
	output reg								csr_imm_sel,
	
	output reg								fence_i,
	output reg								branch_taken_unkilled,
	
	output reg								jal_unkilled,
	output reg								jalr_unkilled,
	
	output reg								uses_rs1,
	output reg								uses_rs2,
	
	output reg		[`IMM_TYPE_WIDTH-1:0]   imm_type,
	
	output reg		[`SRC_A_SEL_WIDTH-1:0]  src_a_sel,
	output reg		[`SRC_B_SEL_WIDTH-1:0]  src_b_sel,
	
	output reg								dmem_en_unkilled,
	output reg								dmem_wen_unkilled,
	
	output reg								wr_reg_unkilled_DX,
	output reg		[`WB_SRC_SEL_WIDTH-1:0]	wb_src_sel_DX,
	
	output reg								uses_md_unkilled,
	output reg								wfi_unkilled_DX
);
	
	/////////////////////////////////////////////////////////////////////////////
	//  31    27    23    19    15    11     7     3     0
	//  ||    ||    ||    ||    ||    ||    ||    ||    ||
	//    iiii  iiii  iiii  _rs1  fun3  -rd-  -opc  opc_       I-type
	//    iiii  iii_  _rs2  _rs1  fun3  iiii  iopc  opc_       S-type
	//    iiii  iiii  iiii  iiii  iiii  -rd-  -opc  opc_       U-type
	//
	//    12 10:5                       4:1  11
	//    iiii  iii_  _rs2  _rs1  fun3  iiii  iopc  opc_       B-type
	//
	//    20      10:1   11      19:12
	//    iiii  iiii  iiii  iiii  iiii  -rd-  -opc  opc_       J-type
	/////////////////////////////////////////////////////////////////////////////
	
	wire	[`REG_ADDR_WIDTH-1:0]	rs1_addr = inst_DX[19:15];
	wire	[`REG_ADDR_WIDTH-1:0]	reg_to_wr_DX = inst_DX[11:7];
	
	wire	[6:0]					opcode = inst_DX[6:0];
	wire	[2:0]					funct3 = inst_DX[14:12];
	wire	[6:0]					funct7 = inst_DX[31:25];
	wire	[11:0]					funct12 = inst_DX[31:20];
	
	wire	[`ALU_OP_WIDTH-1:0]		alu_op_arith;
	
	/////////////////////////////////////////////////////////////////////////////
	// OP code from funct3
	/////////////////////////////////////////////////////////////////////////////
	rv32i_opcode_decode rv32i_opcde_inst0(
		.funct3			(funct3),
		.funct7			(funct7),
		.opcode			(opcode),
		.alu_op_arith	(alu_op_arith)
	);
	/////////////////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////////////////
	// OP code from funct3
	/////////////////////////////////////////////////////////////////////////////
	always@(*)begin
		
		illegal_instruction = 1'b0;
		
		csr_cmd_unkilled = `CSR_IDLE;
		csr_imm_sel = funct3[2];
		
		ecall = 1'b0;
		ebreak = 1'b0;
		eret_unkilled = 1'b0;
		
		fence_i = 1'b0;
		branch_taken_unkilled = 1'b0;
		
		jal_unkilled = 1'b0;
		jalr_unkilled = 1'b0;
		
		uses_rs1 = 1'b1;
		uses_rs2 = 1'b0;
		
		imm_type = `IMM_I;
		
		src_a_sel = `SRC_A_RS1;
		src_b_sel = `SRC_B_IMM;
		
		alu_op = `ALU_OP_ADD;
		
		dmem_en_unkilled = 1'b0;
		dmem_wen_unkilled = 1'b0;
		
		wr_reg_unkilled_DX = 1'b0;
		wb_src_sel_DX = `WB_SRC_ALU;
		uses_md_unkilled = 1'b0;
		wfi_unkilled_DX = 1'b0;
		
		case(opcode)
			
			`RV32_LOAD: begin
				dmem_en_unkilled = 1'b1;
				wr_reg_unkilled_DX = 1'b1;
				wb_src_sel_DX = `WB_SRC_MEM;
			end
			
			`RV32_STORE: begin
				uses_rs2 = 1'b1;
				imm_type = `IMM_S;
				dmem_en_unkilled = 1'b1;
				dmem_wen_unkilled = 1'b1;
			end
			
			/////////////////////////////////////////////////////////////
			// RISC V branch op-code
			/////////////////////////////////////////////////////////////
			`RV32_BRANCH: begin
				
				uses_rs2 = 1'b1;
				branch_taken_unkilled = cmp_true;
				src_b_sel = `SRC_B_RS2;
				
				case(funct3)
					`RV32_FUNCT3_BEQ:	alu_op = `ALU_OP_SEQ;
					`RV32_FUNCT3_BNE:	alu_op = `ALU_OP_SNE;
					`RV32_FUNCT3_BLT:	alu_op = `ALU_OP_SLT;
					`RV32_FUNCT3_BLTU:	alu_op = `ALU_OP_SLTU;
					`RV32_FUNCT3_BGE:	alu_op = `ALU_OP_SGE;
					`RV32_FUNCT3_BGEU:	alu_op = `ALU_OP_SGEU;
					default:			illegal_instruction = 1'b1;
				endcase
			end
			/////////////////////////////////////////////////////////////
			
			/////////////////////////////////////////////////////////////
			// RISC V branch op-code
			/////////////////////////////////////////////////////////////
			`RV32_JAL: begin
				jal_unkilled = 1'b1;
				uses_rs1 = 1'b0;
				src_a_sel = `SRC_A_PC;
				src_b_sel = `SRC_B_FOUR;
				wr_reg_unkilled_DX = 1'b1;
			end
			`RV32_JALR: begin
				illegal_instruction = (funct3 != 0);
				jalr_unkilled = 1'b1;
				src_a_sel = `SRC_A_PC;
				src_b_sel = `SRC_B_FOUR;
				wr_reg_unkilled_DX = 1'b1;
			end
			/////////////////////////////////////////////////////////////
			
			`RV32_MISC_MEM: begin
				case(funct3)
					`RV32_FUNCT3_FENCE: begin
						if ((inst_DX[31:28] == 0) && (rs1_addr == 0) && (reg_to_wr_DX == 0))
							;// most fences are no-ops
						else
							illegal_instruction = 1'b1;
					end
					
					`RV32_FUNCT3_FENCE_I: begin
						if((inst_DX[31:20] == 0) && (rs1_addr == 0) && (reg_to_wr_DX == 0))
							fence_i = 1'b1;
						else
							illegal_instruction = 1'b1;
					end
					default: illegal_instruction = 1'b1;
				endcase // case (funct3)
			end
			
			`RV32_OP_IMM: begin
				alu_op = alu_op_arith;
				wr_reg_unkilled_DX = 1'b1;
			end
			
			`RV32_OP: begin
				uses_rs2 = 1'b1;
				src_b_sel = `SRC_B_RS2;
				alu_op = alu_op_arith;
				wr_reg_unkilled_DX = 1'b1;
				
				if(funct7 == `RV32_FUNCT7_MUL_DIV)begin
					uses_md_unkilled = 1'b1;
					wb_src_sel_DX = `WB_SRC_MD;
				end
			end
			
			`RV32_SYSTEM: begin
				wb_src_sel_DX = `WB_SRC_CSR;
				wr_reg_unkilled_DX = (funct3 != `RV32_FUNCT3_PRIV);
				
				case(funct3)
					`RV32_FUNCT3_PRIV: begin
						if ((rs1_addr == 0) && (reg_to_wr_DX == 0)) begin
							
							/////////////////////////////////////////////////////
							// funct12 => bit 31 to 20 of instruction
							/////////////////////////////////////////////////////
							case(funct12)
								`RV32_FUNCT12_ECALL: ecall = 1'b1;
								`RV32_FUNCT12_EBREAK: ebreak = 1'b1;
								`RV32_FUNCT12_ERET: begin
									if (prv == 0)
										illegal_instruction = 1'b1;
									else
										eret_unkilled = 1'b1;
								end
								
								`RV32_FUNCT12_WFI: wfi_unkilled_DX = 1'b1;
								default: illegal_instruction = 1'b1;
							endcase
						end
					end
					
					`RV32_FUNCT3_CSRRW:		csr_cmd_unkilled = (rs1_addr == 0) ? `CSR_READ : `CSR_WRITE;
					`RV32_FUNCT3_CSRRS:		csr_cmd_unkilled = (rs1_addr == 0) ? `CSR_READ : `CSR_SET;
					`RV32_FUNCT3_CSRRC:		csr_cmd_unkilled = (rs1_addr == 0) ? `CSR_READ : `CSR_CLEAR;
					`RV32_FUNCT3_CSRRWI:	csr_cmd_unkilled = (rs1_addr == 0) ? `CSR_READ : `CSR_WRITE;
					`RV32_FUNCT3_CSRRSI:	csr_cmd_unkilled = (rs1_addr == 0) ? `CSR_READ : `CSR_SET;
					`RV32_FUNCT3_CSRRCI:	csr_cmd_unkilled = (rs1_addr == 0) ? `CSR_READ : `CSR_CLEAR;
					default:				illegal_instruction = 1'b1;
				endcase
			end
			
			/////////////////////////////////////////////////////
			// add upper immediate to PC
			/////////////////////////////////////////////////////
			`RV32_AUIPC: begin
				uses_rs1 = 1'b0;
				src_a_sel = `SRC_A_PC;
				imm_type = `IMM_U;
				wr_reg_unkilled_DX = 1'b1;
			end
			
			/////////////////////////////////////////////////////
			// load upper immediate
			/////////////////////////////////////////////////////
			`RV32_LUI: begin
				uses_rs1 = 1'b0;
				src_a_sel = `SRC_A_ZERO;
				imm_type = `IMM_U;
				wr_reg_unkilled_DX = 1'b1;
			end
			
			default: begin
				illegal_instruction = 1'b1;
			end
		endcase
	end
	
endmodule
