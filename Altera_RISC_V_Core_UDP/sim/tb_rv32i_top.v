`timescale 1ns / 1ns

module tb_rv32i_top;
	
	reg clk, rst;
	reg eth_rxc, eth_txc;
	
	////////////////////////////////////////////////
	//	instantiate
	////////////////////////////////////////////////
	rv32i_top DUT(
		.sys_clk(clk),
		.rst(rst),
		
		.E_RESET(),
		.E_RXC(eth_rxc),
		.E_RXDV(),
		.E_RXD(),
		.E_RXER(),
		.E_TXC(eth_txc),
		.E_TXEN(),
		.E_TXD(),
		
		.dmem_rdata()
	);
	
	//50MHz system clock generator
	always begin
		#10 clk = ~clk;
	end
	
	//50MHz system clock generator
	always begin
		#20 eth_rxc = ~eth_rxc;
	end
	
	//50MHz system clock generator
	always begin
		#20 eth_txc = ~eth_txc;
	end
	
	initial begin
		
		clk = 1'b0;
		eth_rxc = 1'b0;
		eth_txc = 1'b0;
		rst = 1'b0;
		
		fork begin
		
			#100 rst = 1'b1;
			
		end join
	end
	
endmodule
