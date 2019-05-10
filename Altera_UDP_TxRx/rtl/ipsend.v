`timescale 1ns / 1ps

module ipsend(
	input clk,
	input [31:0] datain,
	input [31:28]crcnext,
	input [31:0] crc,
	input clr,
	input rx_finish,
	input fifo_empty,
	input [15:0] mydata_num,
	input [15:0] total_len,
	output reg [3:0] dataout,
	output reg read_udp_fifo,
	output reg txen,
	output reg txer,
	output reg crcen,
	output reg crcre,
	output reg crc_valid,
	output reg tx_finish,
	output reg [2:0] stat
);
	
	//数据段为1K
	reg [31:0] mema [6:0];
	reg [31:0] datain_reg;
	
	reg [8:0] count2,n;
	reg [15:0] check_buffer1,check_buffer2;
	reg [16:0] check_buffer3;
	reg [31:0] check_buffer;
	reg [4:0] i;
	reg [4:0] j,p,q;
	reg [3:0] mema2 [43:0];
	reg [5:0] k;
	reg [7:0] r;
	
	parameter idle = 3'b000;
	parameter start = 3'b001;
	parameter make = 3'b010;
	parameter send = 3'b011;
	parameter senddata = 3'b100;
	parameter sendmac = 3'b101;
	parameter sendmac2 = 3'b110;
	
	initial begin
		stat <= idle;
		mema[1][31:16] <= 'd0;
		mema[2][15:0] <= 'd0;
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
		
		//此段为调试主机（例如用户的PC）的MAC地址，在调试时候，需要根据自己的电脑MAC地址修改本段内容
		mema2[16] <= 4'hf;	//目的MAC地址 84-7b-eb-48-94-13
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
		
		mema2[28] <= 4'h0;               //源MAC地址000a3501fec0
		mema2[29] <= 4'h0;
		mema2[30] <= 4'ha;
		mema2[31] <= 4'h0;
		mema2[32] <= 4'h5;
		mema2[33] <= 4'h3;
		mema2[34] <= 4'h1;
		mema2[35] <= 4'h0;
		mema2[36] <= 4'he;
		mema2[37] <= 4'hf;
		mema2[38] <= 4'h0;
		mema2[39] <= 4'hc;
		
		mema2[40] <= 4'h8;               //数据段长度033c,类型0800（ip）
		mema2[41] <= 4'h0;
		mema2[42] <= 4'h0;
		mema2[43] <= 4'h0;
		r <= 'd0;
	end
	
	always@(posedge clk)begin
		if(!clr)begin
			stat <= idle;
		end else begin
			case(stat)
				idle: begin
					crc_valid <= 'd0;
					count2 <= 'd0;
					check_buffer <= 'd0;
					i <= 'd0;
					j <= 'd0;
					p <= 'd0;
					q <= 'd0;
					txer <= 'd0;
					
					k <= 'd0;
					tx_finish <= 1'b0;
					crcen <= 'd0;
					read_udp_fifo <= 'd0;
					crcre <= 'd1;
					
					if(rx_finish)begin
						//约延时1微秒；
						stat <= start;
					end else begin
						stat <= idle;
					end
				end
				
				start: begin
					mema[0] <= {16'h4500,total_len};	//total length is 44 bytes
					mema[1][31:16] <= mema[1][31:16] + 'd1;
					mema[1][15:0] <= 16'h4000;
					mema[2] <= 32'h80110000;		//mema[2][15:0] ip  jiaoyanhe
					mema[3] <= 32'hc0a801B7;		//192.168.0.2源地址
					mema[4] <= 32'hc0a8011A;		//192.168.0.3目的地址广播地址
					mema[5] <= 32'h1F901F90;			//2个字节的源端口号和2个字节的目的端口号
					mema[6] <= {mydata_num,16'h0000};	//2个字节的数据长度(24byte数据)和2个字节的校验和（无）
					i <= 'd0;
					stat <= make;
				end
				
				//生成head的checksum
				make: begin
					if(i == 0)begin
						check_buffer <= mema[0][15:0] + 
										mema[0][31:16] + 
										mema[1][15:0] + 
										mema[1][31:16] + 
										mema[2][15:0] + 
										mema[2][31:16] + 
										mema[3][15:0] + 
										mema[3][31:16] + 
										mema[4][15:0] + 
										mema[4][31:16];
						i <= i + 'd1;
					end else if(i == 1)begin
						check_buffer[15:0] <= check_buffer[31:16] + check_buffer[15:0];
						i <= i + 'd1;
					end else begin
						mema[2][15:0] <= ~check_buffer[15:0];
						i <= 'd0;
						stat <= sendmac;
					end
				end
				
				//发送Premble,Mac address
				sendmac: begin
					txen <= 'd1;
					if(k == 43)begin
						dataout[3:0] <= mema2[k][3:0];
						stat <= send;
					end else if(k <= 15)begin
						crcre <= 'd1;
						dataout[3:0] <= mema2[k][3:0];
						k <= k + 'd1;
					end else begin
						crcen <= 'd1;
						crcre <= 'd0;
						dataout[3:0] <= mema2[k][3:0];
						k <= k + 'd1;
					end
				end
				
				//发送UDP包头,mema[0]~mema[6]
				send: begin
					if(j == 6)begin
						if(i == 0)begin
							dataout[3:0] <= mema[j][27:24];
							i <= i + 'd1;
						end else if(i == 1)begin
							dataout[3:0] <= mema[j][31:28];
							i <= i + 'd1;
						end else if(i == 2)begin
							dataout[3:0] <= mema[j][19:16];
							i <= i + 'd1;
						end else if(i == 3)begin
							dataout[3:0] <= mema[j][23:20];
							i <= i + 'd1;
						end else if(i == 4)begin
							dataout[3:0] <= mema[j][11:8];
							i <= i + 'd1;
							//read fifo,准备发送数据
							read_udp_fifo <= 'd1;
						end else if(i == 5)begin
							dataout[3:0] <= mema[j][15:12];
							i <= i + 'd1;
							read_udp_fifo <= 'd0;	
						end else if(i == 6)begin
							dataout[3:0] <= mema[j][3:0];
							i <= i + 'd1;					
						end else if(i == 7)begin
							dataout[3:0] <= mema[j][7:4];
							stat <= senddata;
							//把FIFO读出的数据保存到datain_reg中
							datain_reg <= datain;
						end else begin
							txer <= 'd1;
						end
					end else begin
						if(i == 0)begin
							dataout[3:0] <= mema[j][27:24];
							i <= i + 'd1;
						end else if(i == 1)begin
							dataout[3:0] <= mema[j][31:28];
							i <= i + 'd1;
						end else if(i == 2)begin
							dataout[3:0] <= mema[j][19:16];
							i <= i + 'd1;
						end else if(i == 3)begin
							dataout[3:0] <= mema[j][23:20];
							i <= i + 'd1;
						end else if(i == 4)begin
							dataout[3:0] <= mema[j][11:8];
							i <= i + 'd1;
						end else if(i == 5)begin
							dataout[3:0] <= mema[j][15:12];
							i <= i + 'd1;
						end else if(i == 6)begin
							dataout[3:0] <= mema[j][3:0];
							i <= i + 'd1;
						end else if(i == 7)begin
							dataout[3:0] <= mema[j][7:4];
							i <= 'd0;
							j <= j + 'd1;
						end else begin
							txer <= 'd1;
						end
					end
				end
				
				//发送数据
				senddata: begin
					if(p == 0)begin
						dataout[3:0] <= datain_reg[27:24];
						p <= p + 'd1;
					end else if(p == 1)begin
						dataout[3:0] <= datain_reg[31:28];
						p <= p + 'd1;
					end else if(p == 2)begin
						dataout[3:0] <= datain_reg[19:16];
						p <= p + 'd1;
					end else if(p == 3)begin
						dataout[3:0] <= datain_reg[23:20];
						p <= p + 'd1;
					end else if(p == 4)begin
						dataout[3:0] <= datain_reg[11:8];
						p <= p + 'd1;
						//read fifo,准备发送数据
						if(~fifo_empty)begin
							read_udp_fifo <= 'd1;
						end
					end else if(p == 5)begin
						dataout[3:0] <= datain_reg[15:12];
						p <= p + 'd1;
						read_udp_fifo <= 'd0;
					end else if(p == 6)begin
						dataout[3:0] <= datain_reg[3:0];
						p <= p + 'd1;
					end else if(p == 7)begin
						dataout[3:0] <= datain_reg[7:4];
						p <= 'd0;
						if(fifo_empty)begin
							stat <= sendmac2;
						end else begin
							//把FIFO读出的数据保存到datain_reg中
							datain_reg <= datain;
						end
					end else begin
						txer <= 'd1;
					end
				end
				
				//发送CRC32
				sendmac2: begin
					crcen <= 'd0;
					crc_valid <= 'd1;
					
					if(q == 0)begin
						dataout[3:0] <= {~crcnext[28], ~crcnext[29], ~crcnext[30], ~crcnext[31]};
						q <= q + 'd1;
					end else if(q == 1)begin
						dataout[3:0] <= {~crc[24], ~crc[25], ~crc[26], ~crc[27]};
						q <= q + 'd1;
					end else if(q == 2)begin
						dataout[3:0] <= {~crc[20], ~crc[21], ~crc[22], ~crc[23]};
						q <= q + 'd1;
					end else if(q == 3)begin
						dataout[3:0] <= {~crc[16], ~crc[17], ~crc[18], ~crc[19]};
						q <= q + 'd1;
					end else if(q == 4)begin
						dataout[3:0] <= {~crc[12], ~crc[13], ~crc[14], ~crc[15]};
						q <= q + 'd1;
					end else if(q == 5)begin
						dataout[3:0] <= {~crc[8], ~crc[9], ~crc[10], ~crc[11]};
						q <= q + 'd1;
					end else if(q == 6)begin
						dataout[3:0] <= {~crc[4], ~crc[5], ~crc[6], ~crc[7]};
						q <= q + 'd1;
					end else if(q == 7)begin
						dataout[3:0] <= {~crc[0], ~crc[1], ~crc[2], ~crc[3]};
						q <= q + 'd1;
					end else begin
						txen <= 'd0;
						tx_finish <= 1'b1;
						stat <= idle;
						crc_valid <= 'd0;
					end
				end
				
				default: stat <= idle;
			endcase
		end
	end
	
endmodule
