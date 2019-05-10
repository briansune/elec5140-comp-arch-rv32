`include "rv32_alu_op.vh"
`include "rv32_opcodes.vh"

module rv32i_opcode_decode(
	
	input		[2:0]					funct3,
	input		[6:0]					funct7,
	input		[6:0]					opcode,
	output reg	[`ALU_OP_WIDTH-1:0]		alu_op_arith
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
	
	
	wire	[`ALU_OP_WIDTH-1:0]		add_or_sub;
	wire	[`ALU_OP_WIDTH-1:0]		srl_or_sra;
	
	assign add_or_sub = ((opcode == `RV32_OP) && (funct7[5])) ? `ALU_OP_SUB : `ALU_OP_ADD;
	assign srl_or_sra = (funct7[5]) ? `ALU_OP_SRA : `ALU_OP_SRL;
	
	/////////////////////////////////////////////////////////////////////////////
	// OP code from funct3
	/////////////////////////////////////////////////////////////////////////////
	always@(*)begin
		case(funct3)
			`RV32_FUNCT3_ADD_SUB:	alu_op_arith = add_or_sub;
			`RV32_FUNCT3_SLL:		alu_op_arith = `ALU_OP_SLL;
			`RV32_FUNCT3_SLT:		alu_op_arith = `ALU_OP_SLT;
			`RV32_FUNCT3_SLTU:		alu_op_arith = `ALU_OP_SLTU;
			`RV32_FUNCT3_XOR:		alu_op_arith = `ALU_OP_XOR;
			`RV32_FUNCT3_SRA_SRL:	alu_op_arith = srl_or_sra;
			`RV32_FUNCT3_OR:		alu_op_arith = `ALU_OP_OR;
			`RV32_FUNCT3_AND:		alu_op_arith = `ALU_OP_AND;
			default:				alu_op_arith = `ALU_OP_ADD;
		endcase
	end
	
endmodule
