`include "rv32i_ctrl_constants.vh"
`include "rv32i_opcodes.vh"

module rv32i_PC_mux(	
	
	input		[`PC_SRC_SEL_WIDTH-1:0]	PC_src_sel,
	input		[`INST_WIDTH-1:0]		inst_DX,
	input		[`XPR_LEN-1:0]			rs1_data,
	input		[`XPR_LEN-1:0]			PC_IF,
	input		[`XPR_LEN-1:0]			PC_DX,
	input		[`XPR_LEN-1:0]			handler_PC,
	input		[`XPR_LEN-1:0]			epc,
	output		[`XPR_LEN-1:0]			PC_PIF
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
	
	// B-type
	wire	[`XPR_LEN-1:0]	imm_b = { {20{inst_DX[31]}}, inst_DX[7], inst_DX[30:25], inst_DX[11:8], 1'b0 };
	
	// J-type
	wire	[`XPR_LEN-1:0]	jal_offset = { {12{inst_DX[31]}}, inst_DX[19:12], inst_DX[20], inst_DX[30 : 21], 1'b0 };
	
	// I-type
	wire	[`XPR_LEN-1:0]	jalr_offset = { {21{inst_DX[31]}}, inst_DX[30:20] };
	
	reg		[`XPR_LEN-1:0]	base;
	reg		[`XPR_LEN-1:0]	offset;
	
	always@(*)begin
		
		case(PC_src_sel)
			
			`PC_JAL_TARGET: begin
				base = PC_DX;
				offset = jal_offset;
			end
			
			`PC_JALR_TARGET: begin
				base = rs1_data;
				offset = jalr_offset;
			end
			
			`PC_BRANCH_TARGET: begin
				base = PC_DX;
				offset = imm_b;
			end
			
			`PC_REPLAY: begin
				base = PC_IF;
				offset = `XPR_LEN'h0;
			end
			
			`PC_HANDLER: begin
				base = handler_PC;
				offset = `XPR_LEN'h0;
			end
			
			`PC_EPC: begin
				base = epc;
				offset = `XPR_LEN'h0;
			end
			
			default: begin
				base = PC_IF;
				offset = `XPR_LEN'h4;
			end
			
		endcase
	end
	
	assign PC_PIF = base + offset;
	
endmodule
