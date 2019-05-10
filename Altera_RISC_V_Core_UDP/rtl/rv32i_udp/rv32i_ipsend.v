`timescale 1ns / 1ps

module rv32i_ipsend(
	
	input					clk,
	input		[31:28]		crcnext,
	input		[31:0]		crc,
	input					clr,
	input					rx_finish,
	
	output reg	[3:0]		dataout,
	
	output reg				txen,
	output reg				txer,
	output reg				crcen,
	output reg				crcre,
	output reg				tx_finish,
	output reg	[2:0]		state,
	
	input		[31 : 0]	udp_tx_cmd,
	input		[31 : 0]	udp_tx_result
);
	
	////////////////////////////////////////////
	// include verilog header
	////////////////////////////////////////////
	`include "rv32i_udp_cmd.vh"
	
	////////////////////////////////////////////
	// local parameters
	////////////////////////////////////////////
	localparam idle		= 3'b000;
	localparam start	= 3'b001;
	localparam make		= 3'b010;
	localparam send		= 3'b011;
	localparam senddata	= 3'b100;
	localparam sendmac	= 3'b101;
	localparam sendmac2	= 3'b110;
	
	reg		[31 : 0]	mema[6 : 0];
	reg		[3 : 0]		mema2[43 : 0];
	reg		[31 : 0]	datain_reg;
	
	reg		[8 : 0]		n;
	reg		[15 : 0]	check_buffer1;
	reg		[15 : 0]	check_buffer2;
	reg		[16 : 0]	check_buffer3;
	reg		[31 : 0]	check_buffer;
	reg		[4 : 0]		i;
	reg		[4 : 0]		j;
	reg		[4 : 0]		p;
	reg		[4 : 0]		q;
	reg		[5 : 0]		k;
	reg		[3 : 0]		package_cnt;
	
	reg		[31 : 0]	response2udp;
	
	initial begin
		state <= idle;
	end
	
	initial begin
		mema[0] <= 32'd0;
		mema[1] <= 32'd0;
		mema[2] <= 32'd0;
		mema[3] <= 32'd0;
		mema[4] <= 32'd0;
		mema[5] <= 32'd0;
		mema[6] <= 32'd0;
	end
	
	initial begin
		mema2[0] <= 4'h5;
		mema2[1] <= 4'h5;
		mema2[2] <= 4'h5;
		mema2[3] <= 4'h5;
		mema2[4] <= 4'h5;
		mema2[5] <= 4'h5;
		mema2[6] <= 4'h5;
		mema2[7] <= 4'h5;
		mema2[8] <= 4'h5;
		mema2[9] <= 4'h5;
		mema2[10] <= 4'h5;
		mema2[11] <= 4'h5;
		mema2[12] <= 4'h5;
		mema2[13] <= 4'h5;
		mema2[14] <= 4'h5;
		mema2[15] <= 4'hd;
		// destination MAC address FF-FF-FF-FF-FF-FF
		mema2[16] <= 4'hf;
		mema2[17] <= 4'hf;
		mema2[18] <= 4'hf;
		mema2[19] <= 4'hf;
		mema2[20] <= 4'hf;
		mema2[21] <= 4'hf;
		mema2[22] <= 4'hf;
		mema2[23] <= 4'hf;
		mema2[24] <= 4'hf;
		mema2[25] <= 4'hf;
		mema2[26] <= 4'hf;
		mema2[27] <= 4'hf;
		//source MAC address 00-0a-35-01-fe-c0
		//source MAC address 01-60-6E-11-02-0F
		mema2[28] <= 4'h1;
		mema2[29] <= 4'h0;
		mema2[30] <= 4'h0;
		mema2[31] <= 4'h6;
		mema2[32] <= 4'hE;
		mema2[33] <= 4'h6;
		mema2[34] <= 4'h1;
		mema2[35] <= 4'h1;
		mema2[36] <= 4'h2;
		mema2[37] <= 4'h0;
		mema2[38] <= 4'hF;
		mema2[39] <= 4'h0;
		// type 0800 (ip)
		mema2[40] <= 4'h8;
		mema2[41] <= 4'h0;
		mema2[42] <= 4'h0;
		mema2[43] <= 4'h0;
	end
	
	////////////////////////////////////////////////////////////
	// command LUT
	////////////////////////////////////////////////////////////
	always@(*)begin
		if(udp_tx_cmd == udp2risc_v_nop)begin
			response2udp = risc_v2udp_OK;
		end else if(udp_tx_cmd == udp2risc_v_nop)begin
			response2udp = risc_v2udp_OK;
		end else if(udp_tx_cmd == udp2risc_v_rst)begin
			response2udp = risc_v2udp_OK;
		end else if(udp_tx_cmd == udp2risc_v_prg)begin
			response2udp = risc_v2udp_OK;
		end else if(udp_tx_cmd == udp2risc_v_run)begin
			response2udp = risc_v2udp_OK;
		end else if(udp_tx_cmd == udp2risc_v_held)begin
			response2udp = risc_v2udp_OK;
		end else if(udp_tx_cmd[31 : 16] == udp2risc_v_RROM[31 : 16])begin
			response2udp = udp_tx_result;
		end else begin
			response2udp = risc_v2udp_ERROR;
		end
	end
	
	always@(posedge clk)begin
		if(!clr)begin
			state <= idle;
			package_cnt <= 4'd0;
		end else begin
			case(state)
				idle: begin
					check_buffer <= 'd0;
					i <= 5'd0;
					j <= 5'd0;
					p <= 5'd0;
					q <= 5'd0;
					k <= 6'd0;
					
					txer <= 1'b0;
					tx_finish <= 1'b0;
					crcen <= 1'b0;
					crcre <= 1'b1;
					
					package_cnt <= 4'd0;
					
					if(rx_finish)begin
						state <= start;
					end else begin
						state <= idle;
					end
				end
				
				start: begin
					// total length is xxx bytes
					mema[0] <= {16'h4500, 16'd52};
					mema[1][31:16] <= mema[1][31:16] + 16'd1;
					mema[1][15:0] <= 16'h4000;
					// mema[2][15:0]
					mema[2] <= 32'h80110000;
					// 192.168.1.183 source IP
					mema[3] <= 32'hc0a801B7;
					// 192.168.1.26 destination IP
					mema[4] <= 32'hc0a8011A;
					// 2 ports 8080 8080
					mema[5] <= 32'h1F901F90;
					// 2bytes for length, no checksum
					mema[6] <= {16'd32,16'h0000};
					i <= 5'd0;
					state <= make;
				end
				
				//create header checksum
				make: begin
					if(i == 0)begin
						check_buffer <= mema[0][15:0] + mema[0][31:16] + mema[1][15:0] + mema[1][31:16] + 
										mema[2][15:0] + mema[2][31:16] + mema[3][15:0] + mema[3][31:16] + 
										mema[4][15:0] + mema[4][31:16];
						i <= i + 5'd1;
					end else if(i == 5'd1)begin
						check_buffer[15:0] <= check_buffer[31:16] + check_buffer[15:0];
						i <= i + 5'd1;
					end else begin
						mema[2][15:0] <= ~check_buffer[15:0];
						i <= 5'd0;
						state <= sendmac;
					end
				end
				
				//transmit Premble, Mac address
				sendmac: begin
					txen <= 1'b1;
					if(k == 6'd43)begin
						dataout[3:0] <= mema2[k][3:0];
						state <= send;
					end else if(k <= 6'd15)begin
						crcre <= 'd1;
						dataout[3:0] <= mema2[k][3:0];
						k <= k + 6'd1;
					end else begin
						crcen <= 'd1;
						crcre <= 'd0;
						dataout[3:0] <= mema2[k][3:0];
						k <= k + 6'd1;
					end
				end
				
				// send UDP header
				// mema[0] to mema[6]
				send: begin
					if(j == 5'd6)begin
						if(i == 5'd0)begin
							dataout[3:0] <= mema[j][27:24];
							i <= i + 5'd1;
						end else if(i == 5'd1)begin
							dataout[3:0] <= mema[j][31:28];
							i <= i + 5'd1;
						end else if(i == 5'd2)begin
							dataout[3:0] <= mema[j][19:16];
							i <= i + 5'd1;
						end else if(i == 5'd3)begin
							dataout[3:0] <= mema[j][23:20];
							i <= i + 5'd1;
						end else if(i == 5'd4)begin
							dataout[3:0] <= mema[j][11:8];
							i <= i + 5'd1;
						end else if(i == 5'd5)begin
							dataout[3:0] <= mema[j][15:12];
							i <= i + 5'd1;
						end else if(i == 5'd6)begin
							dataout[3:0] <= mema[j][3:0];
							i <= i + 5'd1;					
						end else if(i == 5'd7)begin
							dataout[3:0] <= mema[j][7:4];
							state <= senddata;
							// put data to the data register
							datain_reg <= risc_v2udp_ack;
							package_cnt <= package_cnt + 4'd1;
						end else begin
							txer <= 1'b1;
						end
					end else begin
						if(i == 5'd0)begin
							dataout[3:0] <= mema[j][27:24];
							i <= i + 5'd1;
						end else if(i == 5'd1)begin
							dataout[3:0] <= mema[j][31:28];
							i <= i + 5'd1;
						end else if(i == 5'd2)begin
							dataout[3:0] <= mema[j][19:16];
							i <= i + 5'd1;
						end else if(i == 5'd3)begin
							dataout[3:0] <= mema[j][23:20];
							i <= i + 5'd1;
						end else if(i == 5'd4)begin
							dataout[3:0] <= mema[j][11:8];
							i <= i + 5'd1;
						end else if(i == 5'd5)begin
							dataout[3:0] <= mema[j][15:12];
							i <= i + 5'd1;
						end else if(i == 5'd6)begin
							dataout[3:0] <= mema[j][3:0];
							i <= i + 5'd1;
						end else if(i == 5'd7)begin
							dataout[3:0] <= mema[j][7:4];
							i <= 5'd0;
							j <= j + 5'd1;
						end else begin
							txer <= 1'b1;
						end
					end
				end
				
				// send data packages
				senddata: begin
					if(p == 5'd0)begin
						dataout[3:0] <= datain_reg[27:24];
						p <= p + 5'd1;
					end else if(p == 5'd1)begin
						dataout[3:0] <= datain_reg[31:28];
						p <= p + 5'd1;
					end else if(p == 5'd2)begin
						dataout[3:0] <= datain_reg[19:16];
						p <= p + 5'd1;
					end else if(p == 5'd3)begin
						dataout[3:0] <= datain_reg[23:20];
						p <= p + 5'd1;
					end else if(p == 5'd4)begin
						dataout[3:0] <= datain_reg[11:8];
						p <= p + 5'd1;
					end else if(p == 5'd5)begin
						dataout[3:0] <= datain_reg[15:12];
						p <= p + 5'd1;
					end else if(p == 5'd6)begin
						dataout[3:0] <= datain_reg[3:0];
						p <= p + 5'd1;
					end else if(p == 5'd7)begin
						dataout[3:0] <= datain_reg[7:4];
						p <= 5'd0;
						if(package_cnt == 4'd6)begin
							state <= sendmac2;
						end else begin
							if(package_cnt == 4'd1)begin
								datain_reg <= udp_tx_cmd;
							end else if(package_cnt == 4'd2)begin
								datain_reg <= response2udp;
							end else begin
								datain_reg <= 32'd0;
							end
							package_cnt <= package_cnt + 4'd1;
						end
					end else begin
						txer <= 1'b1;
					end
				end
				
				// send CRC checking
				sendmac2: begin
					crcen <= 1'b0;
					
					if(q == 5'd0)begin
						dataout[3:0] <= {~crcnext[28], ~crcnext[29], ~crcnext[30], ~crcnext[31]};
						q <= q + 5'd1;
					end else if(q == 5'd1)begin
						dataout[3:0] <= {~crc[24], ~crc[25], ~crc[26], ~crc[27]};
						q <= q + 5'd1;
					end else if(q == 5'd2)begin
						dataout[3:0] <= {~crc[20], ~crc[21], ~crc[22], ~crc[23]};
						q <= q + 5'd1;
					end else if(q == 5'd3)begin
						dataout[3:0] <= {~crc[16], ~crc[17], ~crc[18], ~crc[19]};
						q <= q + 5'd1;
					end else if(q == 5'd4)begin
						dataout[3:0] <= {~crc[12], ~crc[13], ~crc[14], ~crc[15]};
						q <= q + 5'd1;
					end else if(q == 5'd5)begin
						dataout[3:0] <= {~crc[8], ~crc[9], ~crc[10], ~crc[11]};
						q <= q + 5'd1;
					end else if(q == 5'd6)begin
						dataout[3:0] <= {~crc[4], ~crc[5], ~crc[6], ~crc[7]};
						q <= q + 5'd1;
					end else if(q == 5'd7)begin
						dataout[3:0] <= {~crc[0], ~crc[1], ~crc[2], ~crc[3]};
						q <= q + 5'd1;
					end else begin
						txen <= 1'b0;
						tx_finish <= 1'b1;
						state <= idle;
					end
				end
				
				default: state <= idle;
			endcase
		end
	end
	
endmodule
