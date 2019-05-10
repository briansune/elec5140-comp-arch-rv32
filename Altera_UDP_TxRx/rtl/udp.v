module udp(
	rxdv,
	rxer,
	clk3,
	e_rxc,
	datain,
	txen,
	txer,
	phyreset,
	valid_ip_p,
	crc_valid,
	data_o_valid,
	fifo_wr_data,
	Data,
	read_udp_fifo,
	fifo_empty,
	fifo_r_data
);
	
	input wire	rxdv;
	input wire	rxer;
	input wire	clk3;
	input wire	e_rxc;
	input wire	[3:0] datain;
	output wire	txen;
	output wire	txer;
	output wire	phyreset;
	output wire	valid_ip_p;
	output wire	crc_valid;
	output wire	[3:0] Data;
	
	(*KEEP = "True"*) output wire read_udp_fifo;
	input [31:0] fifo_r_data;
	
	input wire fifo_empty;
	(*KEEP = "True"*) output wire  data_o_valid;
	
	//output wire	[31:0] board_IP;
	//output wire	[47:0] board_mac;
	
	output wire	[31:0] fifo_wr_data;
	
	wire	[31:0] crcnext;
	wire	[31:0] SYNTHESIZED_WIRE_2;
	wire	crc_reset;
	wire	crc_enable;
	wire	[3:0] data_out;
	wire	SYNTHESIZED_WIRE_7;
	wire	[15:0] mydata_num;
	wire	[15:0] total_len;
	
	(*KEEP = "True"*) wire tx_finish;
	(*KEEP = "True"*) wire rx_finish;
	
	assign phyreset = 1;
	assign Data = data_out;
	
	//IP frame发送
	ipsend b2v_inst(
		.clk(clk3),
		.fifo_empty(fifo_empty),
		.clr(1),
		.crc(SYNTHESIZED_WIRE_2),
		.crcnext(crcnext[31:28]),
		.datain(fifo_r_data),
		.tx_finish(tx_finish),
		.rx_finish(rx_finish),
		.crcen(crc_enable),
		.read_udp_fifo(read_udp_fifo),
		.txen(txen),
		.txer(txer),
		.crcre(crc_reset),
		.crc_valid(crc_valid),
		.dataout(data_out),
		.mydata_num(mydata_num),
		.total_len(total_len),
		.stat(send_state)
	);
	
	crc	b2v_inst4(
		.Clk(clk3),
		.Reset(crc_reset),
		.Enable(crc_enable),
		.Data(data_out),
		.Crc(SYNTHESIZED_WIRE_2),
		.CrcNext(crcnext)
	);
	
	//IP frame接收
	iprecieve b2v_inst8(
		.clk(e_rxc),
		.rxdv(rxdv),
		.rxer(rxer),
		.datain(datain),
		.valid_ip_P(valid_ip_p),
		.board_IP(board_IP),
		.board_mac(board_mac),
		.data_o(fifo_wr_data),
		.IP_layer(IP_layer),
		.IP_Prtcl(IP_Ptrcl),
		.mydata_num(mydata_num),
		.total_len(total_len),
		.pc_IP(pc_IP),
		.pc_mac(pc_mac),
		.state(stat),
		.data_o_valid(data_o_valid),
		.tx_finish(tx_finish),
		.rx_finish(rx_finish),
		.UDP_layer(UDP_layer)
	);
	
endmodule
