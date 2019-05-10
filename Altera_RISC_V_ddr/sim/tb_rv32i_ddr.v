`timescale 1ns / 1ps


module tb_rv32i_ddr;
	
	reg clk;
	reg rst_n;
	
	wire				sdram_clk;
	wire				sdram_cke;
	wire				sdram_cs_n;
	wire				sdram_cas_n;
	wire				sdram_ras_n;
	wire				sdram_we_n;
	wire	[1 : 0]		sdram_dqm;
	wire	[11 : 0]	sdram_addr;
	wire	[1 : 0]		sdram_ba;
	wire	[15 : 0]	sdram_dq;
	
	////////////////////////////////////////////////
	//	instantiate
	////////////////////////////////////////////////
	top DUT(
		.sdram_clk(sdram_clk),
		.sdram_cke(sdram_cke),
		.sdram_cs_n(sdram_cs_n),
		.sdram_cas_n(sdram_cas_n),
		.sdram_ras_n(sdram_ras_n),
		.sdram_we_n(sdram_we_n),
		.sdram_dqm(sdram_dqm),
		.sdram_addr(sdram_addr),
		.sdram_ba(sdram_ba),
		.sdram_dq(sdram_dq),
		.clk(clk),
		.rst_n(rst_n)
	);
	
	sdr sdram_model(
		.Dq(sdram_dq),
		.Addr(sdram_addr),
		.Ba(sdram_ba),
		.Clk(sdram_clk),
		.Cke(sdram_cke),
		.Cs_n(sdram_cs_n),
		.Ras_n(sdram_ras_n),
		.Cas_n(sdram_cas_n),
		.We_n(sdram_we_n),
		.Dqm(sdram_dqm)
	);
	
	//50MHz system clock generator
	always begin
		#10 clk = ~clk;
	end
	
	integer i;
	
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		
		fork begin
			
			#30 rst_n = 1'b1;
			
			//#100 $stop;
		end join
	end
	
endmodule
