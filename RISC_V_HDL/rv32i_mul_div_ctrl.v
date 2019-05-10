`include "rv32i_opcodes.vh"
`include "rv32i_md_constants.vh"

module rv32i_mul_div_ctrl(
	
	input			[2:0]					funct3,
	input									uses_md,
	
	output									md_req_valid,
	output reg		[`MD_OP_WIDTH-1:0]		md_req_op,
	output reg								md_req_in_1_signed,
	output reg								md_req_in_2_signed,
	output reg		[`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel
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
	
	
	assign md_req_valid = uses_md;
	
	/////////////////////////////////////////////////////////////////////////////
	// OP code from funct3
	/////////////////////////////////////////////////////////////////////////////
	always@(*)begin
		md_req_op = `MD_OP_MUL;
		md_req_in_1_signed = 0;
		md_req_in_2_signed = 0;
		md_req_out_sel = `MD_OUT_LO;
		
		case(funct3)
			`RV32_FUNCT3_MUL: begin
			end
			
			`RV32_FUNCT3_MULH: begin
				md_req_in_1_signed = 1;
				md_req_in_2_signed = 1;
				md_req_out_sel = `MD_OUT_HI;
			end
			
			`RV32_FUNCT3_MULHSU: begin
				md_req_in_1_signed = 1;
				md_req_out_sel = `MD_OUT_HI;
			end
			
			`RV32_FUNCT3_MULHU: begin
				md_req_out_sel = `MD_OUT_HI;
			end
			
			`RV32_FUNCT3_DIV: begin
				md_req_op = `MD_OP_DIV;
				md_req_in_1_signed = 1;
				md_req_in_2_signed = 1;
			end
			
			`RV32_FUNCT3_DIVU: begin
				md_req_op = `MD_OP_DIV;
			end
			
			`RV32_FUNCT3_REM: begin
				md_req_op = `MD_OP_REM;
				md_req_in_1_signed = 1;
				md_req_in_2_signed = 1;
				md_req_out_sel = `MD_OUT_REM;
			end
			
			`RV32_FUNCT3_REMU: begin
				md_req_op = `MD_OP_REM;
				md_req_out_sel = `MD_OUT_REM;
			end
		endcase
	end
	
endmodule
