module udp(
	
	output			phy_eth_rst,
	
	input			phy_eth_tclk,
	output			phy_eth_txen,
	output	[3:0]	phy_eth_tdata,
	output			phy_eth_txer,
	
	input			phy_eth_rxc,
	input			phy_eth_rxdv,
	input	[3:0]	phy_eth_rdata,
	input			phy_eth_rxer,
	
	output			valid_ip_p,
	output			data_o_valid,
	output	[31:0]	icache_wr_data,
	
	output			tx_finish,
	output			rx_finish
);
	
	wire	[31:0]	board_IP;
	wire	[47:0]	board_mac;
	
	wire	[31:0]	crcnext;
	wire	[31:0]	SYNTHESIZED_WIRE_2;
	wire			crc_reset;
	wire			crc_enable;
	wire	[3:0]	data_out;
	
	(*KEEP = "True"*) wire	[31 : 0]	data_cmd_signal;
	
	(*KEEP = "True"*) wire	[15:0]	mydata_num;
	wire	[15:0]	total_len;
	
	wire	[2:0]	tx_state;
	wire	[3:0]	rx_state;
	
	assign phy_eth_rst = 1;
	assign phy_eth_tdata = data_out;
	
	//IP frame transmit
	ipsend b2v_inst(
		.clk(phy_eth_tclk),
		.txen(phy_eth_txen),
		.txer(phy_eth_txer),
		
		.clr(1),
		.crc(SYNTHESIZED_WIRE_2),
		.crcnext(crcnext[31:28]),
		.tx_finish(tx_finish),
		.rx_finish(rx_finish),
		.crcen(crc_enable),
		.crcre(crc_reset),
		.dataout(data_out),
		.state(tx_state),
		
		.udp_tx_cmd(data_cmd_signal)
	);
	
	crc	b2v_inst4(
		.Clk(phy_eth_tclk),
		.Reset(crc_reset),
		.Enable(crc_enable),
		.Data(data_out),
		.Crc(SYNTHESIZED_WIRE_2),
		.CrcNext(crcnext)
	);
	
	//IP frame receive
	iprecieve b2v_inst8(
		.clk(phy_eth_rxc),
		.rxdv(phy_eth_rxdv),
		.rxer(phy_eth_rxer),
		.datain(phy_eth_rdata),
		.valid_ip_P(valid_ip_p),
		.board_IP(board_IP),
		.board_mac(board_mac),
		
		.data_o(icache_wr_data),
		.data_cmd(data_cmd_signal),
		
		.IP_layer(IP_layer),
		.IP_Prtcl(IP_Ptrcl),
		.mydata_num(mydata_num),
		.total_len(total_len),
		.pc_IP(pc_IP),
		.pc_mac(pc_mac),
		.state(rx_state),
		.data_o_valid(data_o_valid),
		.tx_finish(tx_finish),
		.rx_finish(rx_finish),
		.UDP_layer(UDP_layer)
	);
	
endmodule
