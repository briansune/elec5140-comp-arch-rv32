`timescale 1ns / 1ps

`include "vscale_alu_ops.vh"
`include "rv32_opcodes.vh"

module tb_rv32i_alu;
	
	reg clk;
	
	reg [`ALU_OP_WIDTH-1 : 0] op_reg;
	
	reg [`XPR_LEN-1 : 0] data_a;
	reg [`XPR_LEN-1 : 0] data_b;
	
	wire [`XPR_LEN-1 : 0] data_out;
	
	////////////////////////////////////////////////
	//	instantiate
	////////////////////////////////////////////////
	rv32i_alu DUT(
		.op(op_reg),
		.in1(data_a),
		.in2(data_b),
		.out(data_out)
	);
	
	//50MHz system clock generator
	always begin
		#10 clk = ~clk;
	end
	
	integer i;
	
	initial begin
		clk = 1'b0;
		
		op_reg = 'b0;
		data_a = 'b0;
		data_b = 'b0;
		
		fork begin
			
			for(i = 0; i < 2**(`ALU_OP_WIDTH); i = i + 1)begin
				
				#100 @(posedge clk)begin
					op_reg = i;
					data_a = $urandom_range(2**(`XPR_LEN)-1,0);
					data_b = $urandom_range(2**(`XPR_LEN)-1,0);
				end
			end
			
			#100 $stop;
		end join
	end
	
endmodule
