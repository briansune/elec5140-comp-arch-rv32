`timescale 1ns / 1ps

module ethernet(
	
	input			FPGA_GCLK1,
	input			rst,
	
	//signal connect to PHY//
	output			E_RESET,
	input			E_RXC,
	input			E_RXDV,
	input	[3:0]	E_RXD,
	input			E_RXER,
	input			E_TXC,
	output			E_TXEN,
	output	[3:0]	E_TXD
);
	
	//added for receive test/
	reg				data_o_valid_reg1;
	reg				data_o_valid_reg2;
	//added for receive test/
	reg				icache_wr_en;
	reg				icache_rd_en;
	
	(*KEEP = "True"*) wire	[31:0]	icache_rd_data;
	wire	[31:0]	icache_wr_data;
	
	// 2kB FIFO with 4Byte word 32 bit line
	reg		[8:0]	icache_wr_addr;
	reg		[8:0]	icache_rd_addr;
	
	wire			tx_finish_sig;
	wire			rx_finish_sig;
	
	udp udp_inst(
		
		.phy_eth_rst(E_RESET),
		
		.phy_eth_tclk(E_TXC),
		.phy_eth_txen(E_TXEN),
		.phy_eth_tdata(E_TXD),
		.phy_eth_txer(),
		
		.phy_eth_rxc(E_RXC),
		.phy_eth_rxdv(E_RXDV),
		.phy_eth_rxer(E_RXER),
		.phy_eth_rdata(E_RXD),
		
		.valid_ip_p(),
		.data_o_valid(data_o_valid),
		.icache_wr_data(icache_wr_data),
		
		.tx_finish(tx_finish_sig),
		.rx_finish(rx_finish_sig)
	);
	
	// added for receive test
	udp_icache udp_icache_inst0(
		.clock(E_RXC),				// input  clock_sig
		.aclr(~rst),				// input  aclr_sig
		
		.wren(icache_wr_en),		// input  wren_sig
		.wraddress(icache_wr_addr),	// input [8:0] wraddress_sig
		.data(icache_wr_data),		// input [31:0] data_sig
		
		.rden(icache_rd_en),		// input  rden_sig
		.rdaddress(icache_rd_addr),	// input [8:0] rdaddress_sig
		.q(icache_rd_data)			// output [31:0] q_sig
	);
	
	// added for receive test
	always@(negedge E_RXC)begin
		if(!rst)begin
			data_o_valid_reg1 <= 1'b0;
			data_o_valid_reg2 <= 1'b0;
			icache_wr_en <= 1'b0;
			icache_wr_addr <= 'd0;
		end else begin
			data_o_valid_reg1 <= data_o_valid;
			data_o_valid_reg2 <= data_o_valid_reg1;
			
			// edge triggered data_o_valid (rising), fifo wr request
			if(data_o_valid_reg1 && !data_o_valid_reg2)begin
				icache_wr_en <= 1'b1;
			end else begin
				icache_wr_en <= 1'b0;
			end
			
			if(!data_o_valid_reg1 && data_o_valid_reg2)begin
				icache_wr_addr <= icache_wr_addr + 'd1;
			end
			
			if(icache_rd_addr == icache_wr_addr && icache_rd_en)begin
				icache_wr_addr <= 'd0;
			end
		end
	end	
	
	always@(negedge E_RXC)begin
		if(!rst)begin
			icache_rd_en <= 1'b0;
			icache_rd_addr <= 'd0;
		end else begin
			if(rx_finish_sig)begin
				icache_rd_en <= 1'b1;
			end
			
			if(icache_rd_en)begin
				if(icache_rd_addr == icache_wr_addr)begin
					icache_rd_en <= 1'b0;
					icache_rd_addr <= 'd0;
				end else begin
					icache_rd_addr <= icache_rd_addr + 'd1;
				end
			end
		end
	end
	
endmodule
