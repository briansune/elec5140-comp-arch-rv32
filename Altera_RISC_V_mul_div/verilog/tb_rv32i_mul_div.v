`timescale 1ns / 1ps

`include "vscale_md_constants.vh"
`include "vscale_ctrl_constants.vh"
`include "rv32_opcodes.vh"

module tb_rv32i_mul_div;
	
	reg clk;
	reg rst;
	
	reg									req_valid_reg;
	wire								req_ready_signal;
	
	reg									req_in_1_signed_reg;
	reg									req_in_2_signed_reg;
	
	reg		[`MD_OP_WIDTH-1 : 0]		req_op_reg;
	reg		[`MD_OUT_SEL_WIDTH-1 : 0]	req_out_sel_reg;
	
	reg		[`XPR_LEN-1 : 0]			req_in_1_reg;
	reg		[`XPR_LEN-1 : 0]			req_in_2_reg;
	
	wire								resp_valid_signal;
	wire	[`XPR_LEN-1 : 0]			resp_result_signal;
	
	////////////////////////////////////////////////
	//	instantiate
	////////////////////////////////////////////////
	rv32i_mul_div DUT(
		
		.clk(clk),
		.reset(rst),
		
		.req_valid(req_valid_reg),
		.req_ready(req_ready_signal),
		
		.req_in_1_signed(req_in_1_signed_reg),
		.req_in_2_signed(req_in_2_signed_reg),
		
		.req_op(req_op_reg),
		.req_out_sel(req_out_sel_reg),
		
		.req_in_1(req_in_1_reg),
		.req_in_2(req_in_2_reg),
		
		.resp_valid(resp_valid_signal),
		.resp_result(resp_result_signal)
	);
	
	//50MHz system clock generator
	always begin
		#10 clk = ~clk;
	end
	
	integer i;
	
	initial begin
		clk = 'b0;
		rst = 'b1;
		
		req_op_reg = `MD_OP_MUL;
		req_out_sel_reg = 'b0;
		
		req_in_1_signed_reg = 'b0;
		req_in_2_signed_reg = 'b0;
		
		req_in_1_reg = 'b0;
		req_in_2_reg = 'b0;
		
		req_valid_reg = 'b1;
		
		fork begin
			
			#100 rst = 'b0;
			
			while(resp_valid_signal != 1'b1)begin
				#10 req_out_sel_reg = 'b1;
			end
			
			@(posedge clk)begin
				req_valid_reg = 'b1;
				req_out_sel_reg = 'b1;
				req_in_1_signed_reg = 'b1;
				req_in_2_signed_reg = 'b1;
				
				req_in_1_reg = $urandom_range(2**(32)-1,0);
				req_in_2_reg = $urandom_range(2**(32)-1,0);
			end
			
			#20 req_out_sel_reg = 'b1;
			
			while(resp_valid_signal != 1'b1)begin
				#10 req_out_sel_reg = 'b1;
			end
			
			#10 req_out_sel_reg = 'b0;
			#20 req_out_sel_reg = 'b0;
			
			while(resp_valid_signal != 1'b1)begin
				#10 req_out_sel_reg = 'b0;
			end
			
			#100 @(posedge clk)begin
				req_out_sel_reg = 'b1;
				req_in_1_signed_reg = 'b0;
				req_in_2_signed_reg = 'b0;
				
				req_in_1_reg = $urandom_range(2**(32)-1,0);
				req_in_2_reg = $urandom_range(2**(32)-1,0);
			end
			
			while(resp_valid_signal != 1'b1)begin
				#10 req_out_sel_reg = 'b1;
			end
			
			#50 @(posedge clk)begin
				req_out_sel_reg = 'b0;
			end
			
			while(resp_valid_signal != 1'b1)begin
				#10 req_out_sel_reg = 'b0;
			end
			
			#1000 $stop;
		end join
	end
	
endmodule
