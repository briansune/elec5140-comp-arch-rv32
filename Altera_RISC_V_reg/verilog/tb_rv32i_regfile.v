`timescale 1ns / 1ps

`include "rv32_opcodes.vh"

module tb_rv32i_regfile;
	
	reg clk;
	
	reg		[`REG_ADDR_WIDTH-1:0]	ra1_reg;
	reg		[`REG_ADDR_WIDTH-1:0]	ra2_reg;
	
	reg								wen_reg;
	reg		[`REG_ADDR_WIDTH-1:0]	wa_reg;
	reg		[`XPR_LEN-1:0]			wd_reg;
	
	wire	[`XPR_LEN-1:0]			rd1;
	wire	[`XPR_LEN-1:0]			rd2;
	
	////////////////////////////////////////////////
	//	instantiate
	////////////////////////////////////////////////
	rv32i_regfile DUT(
		.clk(clk),
		.ra1(ra1_reg),
		.rd1(rd1),
		.ra2(ra2_reg),
		.rd2(rd2),
		.wen(wen_reg),
		.wa(wa_reg),
		.wd(wd_reg)
	);
	
	//50MHz system clock generator
	always begin
		#10 clk = ~clk;
	end
	
	integer i;
	
	initial begin
		
		clk = 'b0;
		
		ra1_reg = 'b0;
		ra2_reg = 'b0;
		wen_reg = 'b0;
		wa_reg = 'b0;
		wd_reg = 'b0;
		
		fork begin
			
			#100 @(posedge clk)begin
				ra1_reg = $urandom_range(2**(`REG_ADDR_WIDTH)-1,0);
				ra2_reg = $urandom_range(2**(`REG_ADDR_WIDTH)-1,0);
			end
			
			#100 @(posedge clk)begin
				ra1_reg = $urandom_range(2**(`REG_ADDR_WIDTH)-1,0);
				ra2_reg = $urandom_range(2**(`REG_ADDR_WIDTH)-1,0);
				
				wa_reg = $urandom_range(2**(`REG_ADDR_WIDTH)-1,0);
				wd_reg = $urandom_range(2**(`XPR_LEN)-1,0);
				wen_reg = 'b1;
			end
			
			#5 @(posedge clk)begin
				wen_reg = 'b0;
			end
			
			#100 wen_reg = 'b0;
			
			for(i = 0; i < 16; i = i + 1)begin
				#10 @(posedge clk)begin
					ra1_reg = 31-i;
					ra2_reg = i;
				end
			end
			
			#300 $stop;
		end join
	end
	
endmodule
