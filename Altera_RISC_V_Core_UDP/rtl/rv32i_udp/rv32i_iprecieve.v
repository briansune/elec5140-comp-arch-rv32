`timescale 1ns / 1ps

module rv32i_iprecieve(
	
	input					clk,
	input		[3 : 0]		datain,
	input					rxdv,
	input					rxer,
	
	input					tx_finish,
	output reg				rx_finish,
	
	output reg	[3 : 0]		state,
	
	output reg	[47 : 0]	board_mac,
	output reg	[47 : 0]	pc_mac,
	output reg	[15 : 0]	IP_Prtcl,
	output reg	[159 : 0]	IP_layer,
	output reg	[31 : 0]	pc_IP,
	output reg	[31 : 0]	board_IP,
	output reg	[15 : 0]	mydata_num,
	output reg	[63 : 0]	UDP_layer,
	output reg	[15 : 0]	total_len,
	output reg	[31 : 0]	data_o,
	output reg	[31 : 0]	data_cmd,
	output reg				valid_ip_P,
	output reg				data_o_valid
);
	
	////////////////////////////////////////////
	// include verilog header
	////////////////////////////////////////////
	`include "rv32i_udp_cmd.vh"
	
	localparam idle				= 4'd0;
	localparam rx_wait			= 4'd1;
	localparam start			= 4'd2;
	localparam frame			= 4'd3;
	localparam rx_mac			= 4'd4;
	localparam rx_IP_Protocol	= 4'd5;
	localparam rx_IP_layer		= 4'd6;
	localparam rx_UDP_layer		= 4'd7;
	localparam rx_data_cmd		= 4'd8;
	localparam rx_data			= 4'd9;
	localparam rx_end			= 4'd10;
	
	reg		[15 : 0]	myIP_Prtcl;
	reg		[159 : 0]	myIP_layer;
	reg		[63 : 0]	myUDP_layer;
	reg		[31 : 0]	mydata;
	reg		[9 : 0]		rx_num;
	reg		[7 : 0]		mybyte;
	reg					sig;
	reg		[2 : 0]		byte_counter;
	reg		[95 : 0]	mymac;
	reg		[4 : 0]		state_counter;
	reg		[7 : 0]		byte_data;
	//generate byte rxdv signal
	reg					byte_sig_t;
	reg					byte_sig;
	reg					byte_rxdv_t;
	reg					byte_rxdv;
	
	reg					icache_prg;
	
	////////////////////////////////////////////////////////////
	// command to program icache signal
	////////////////////////////////////////////////////////////
	always@(*)begin
		if(data_cmd == udp2risc_v_prg)begin
			icache_prg = 1'b1;
		end else begin
			icache_prg = 1'b0;
		end
	end
	
	always@(posedge clk)begin
		if(rxdv)begin
			if(rx_num < 10'd1023)begin
				rx_num <= rx_num + 1'b1;
			end else begin
				rx_num <= rx_num;
			end
		end else begin
			rx_num <= 10'd0;
		end
	end
	
	//4bit->byte
	always@(posedge clk)begin
		if(rxdv)begin
			mybyte <= {datain, mybyte[7:4]};
			sig <= ~sig;
		end else begin
			mybyte <= mybyte;
			sig <= 1'b0;
		end
	end
	
	//4bit->byte
	always@(posedge clk)begin
		if(sig && rxdv)begin
			byte_data <= {datain, mybyte[7:4]};
		end else if(!rxdv)begin
			byte_data <= 8'd0;
		end
	end
	
	always@(posedge clk)begin
		byte_sig_t <= sig;
		byte_sig <= byte_sig_t;
		byte_rxdv_t <= rxdv;
		byte_rxdv <= byte_rxdv_t;
	end
	
	initial begin
		state <= rx_wait;
	end
	
	always@(posedge clk)begin
		case(state)
			idle: begin
				valid_ip_P <= 1'b0;
				byte_counter <= 3'd0;
				rx_finish <= 1'b0;
				state_counter <= 5'd0;
				data_o_valid <= 1'b0;
				// wait tx complete
				if(tx_finish == 1'b1)begin
					state <= rx_wait;
				end
			end	
			
			rx_wait: begin
				valid_ip_P <= 1'b0;
				byte_counter <= 3'd0;
				rx_finish <= 1'b0;
				state_counter <= 5'd0;
				data_o_valid <= 1'b0;
				if(byte_rxdv && !byte_sig)begin
					if(byte_data == 8'h55)begin
						state <= start;
					end
				end
			end
			
			//receive 7 0x55
			start: begin
				if(byte_rxdv && !byte_sig)begin
					if(byte_data!=8'h55)begin
						state <= rx_wait;
						byte_counter <= 3'd0;
					end else begin
						if(byte_counter < 3'd5)begin
							byte_counter <= byte_counter + 1'b1;
						end else begin
							byte_counter <= 3'd0;
							state <= frame;
						end
					end
				end else if(!byte_rxdv)begin
					state <= rx_wait;
				end
			end
			
			//receive 0xd5
			frame: begin
				if(byte_rxdv && !byte_sig)begin
					if(byte_data == 8'hd5)
						state <= rx_mac;
					else
						state <= rx_wait;
				end else if(!byte_rxdv)begin
					state <= rx_wait;
				end
			end
			
			//receive destination mac address and source mac address
			rx_mac: begin
				if(byte_rxdv && !byte_sig)begin
					if(state_counter < 5'd11)begin
						mymac <= {mymac[87:0], byte_data};
						state_counter <= state_counter + 1'b1;
					end else begin
						board_mac <= mymac[87:40];
						pc_mac <= {mymac[39:0], byte_data};
						state_counter <= 5'd0;
						//source MAC address 00-0a-35-01-fe-c0
						//source MAC address 01-60-6E-11-02-0F
						if((mymac[87:72] == 16'h0160) && (mymac[71:56] == 16'h6E11) && (mymac[55:40] == 16'h020F))
							state <= rx_IP_Protocol;
						else
							state <= rx_wait;
					end
				end else if(!byte_rxdv)begin
					state <= rx_wait;
				end
			end
			
			//receive 2 bytes IP type
			rx_IP_Protocol: begin
				if(byte_rxdv && !byte_sig)begin
					if(state_counter < 5'd1)begin
						myIP_Prtcl <= {myIP_Prtcl[7:0], byte_data};
						state_counter <= state_counter + 1'b1;
					end else begin
						IP_Prtcl <= {myIP_Prtcl[7:0], byte_data};
						valid_ip_P <= 1'b1;
						state_counter <= 5'd0;
						state <= rx_IP_layer;
					end
				end else if(!byte_rxdv)begin
					state <= rx_wait;
				end
			end
			
			//receive 20bytes udp, ip address
			rx_IP_layer: begin
				valid_ip_P <= 1'b0;
				if(byte_rxdv && !byte_sig)begin
					if(state_counter < 5'd19)begin
						myIP_layer <= {myIP_layer[151:0], byte_data};
						state_counter <= state_counter + 1'b1;
					end else begin
						IP_layer <= {myIP_layer[151:0], byte_data};
						state_counter <= 5'd0;
						state <= rx_UDP_layer;
					end
				end else if(!byte_rxdv)begin
					state <= rx_wait;
				end
			end
			
			//accept 8bytes udp data header, port & packages
			rx_UDP_layer: begin
				total_len <= IP_layer[143:128];
				pc_IP <= IP_layer[63:32];
				board_IP <= IP_layer[31:0];
				if(byte_rxdv && !byte_sig)begin
					if(state_counter < 5'd7)begin
						myUDP_layer <= {myUDP_layer[53:0], byte_data};
						state_counter <= state_counter + 1'b1;
					end else begin
						UDP_layer <= {myUDP_layer[53:0], byte_data};
						state_counter <= 5'd0;
						state <= rx_data_cmd;
					end
				end else if(!byte_rxdv)begin
					state <= rx_wait;
				end
			end
			
			//receive udp data (cmd header 4 byte)
			rx_data_cmd: begin
				mydata_num <= UDP_layer[31:16];
				if(byte_rxdv && !byte_sig)begin
					if(state_counter < 5'd3)begin
						mydata <= {mydata[23:0], byte_data};
						state_counter <= state_counter + 1'b1;
					end else begin
						data_cmd <= {mydata[23:0], byte_data};
						state_counter <= 5'd0;
						state <= rx_data;
					end
				end else if(!byte_rxdv)begin
					state <= rx_end;
				end
			end
			
			//receive udp data
			rx_data: begin
				if(byte_rxdv && !byte_sig)begin
					if(state_counter < 5'd3)begin
						mydata <= {mydata[23:0], byte_data};
						state_counter <= state_counter + 1'b1;
						data_o_valid <= 1'b0;
					end else begin
						data_o <= {mydata[23:0], byte_data};
						state_counter <= 5'd0;
						//accept 4byes data, write fifo request
						data_o_valid <= rxdv & icache_prg;
					end
				end else if(!byte_rxdv)begin
					state <= rx_end;
				end
			end
			
			// not 4byte will pad with 0
			rx_end: begin
				//receive to frame data
				rx_finish <= 1'b1;
				state <= idle;
				data_o_valid <= 1'b0;
			end
			
			default: state <= idle;
			
		endcase
	end
	
endmodule
