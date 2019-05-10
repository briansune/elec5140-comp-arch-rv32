`include "rv32i_ctrl_constants.vh"
`include "rv32i_opcodes.vh"

module rv32i_imm_gen(
	
	input		[`XPR_LEN-1:0]			inst,
	input		[`IMM_TYPE_WIDTH-1:0]	imm_type,
	output reg	[`XPR_LEN-1:0]			imm
);
	
	//  31    27    23    19    15    11     7     3     0
	//  ||    ||    ||    ||    ||    ||    ||    ||    ||
	//    iiii  iiii  iiii  _rs1  fun3  -rd-  -opc  opc_       I-type
	//    iiii  iii_  _rs2  _rs1  fun3  iiii  iopc  opc_       S-type
	//    iiii  iiii  iiii  iiii  iiii  -rd-  -opc  opc_       U-type
	
	//    12 10:5                       4:1  11
	//    iiii  iii_  _rs2  _rs1  fun3  iiii  iopc  opc_       B-type
	
	//    20      10:1   11      19:12
	//    iiii  iiii  iiii  iiii  iiii  -rd-  -opc  opc_       J-type
	
	
	always@(*)begin
		case (imm_type)
			`IMM_I:		imm = { {21{inst[31]}}, inst[30 : 20] };
			`IMM_S:		imm = { {21{inst[31]}}, inst[30 : 25], inst[11 : 7] };
			`IMM_U:		imm = { inst[31], inst[30 : 12], 12'b0000_0000_0000 };
			`IMM_J:		imm = { {12{inst[31]}}, inst[19 : 12], inst[20], inst[30 : 21], 1'b0 };
			default:	imm = { {21{inst[31]}}, inst[30 : 20] };
		endcase
	end
	
endmodule
