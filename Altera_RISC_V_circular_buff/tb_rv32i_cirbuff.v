`timescale 1ns / 1ps

module tb_rv32i_cirbuff;
	
	reg clk;
	reg nrst;
	
	reg wr_req_signal;
	reg rd_req_signal;
	
	wire buff_empty_signal;
	wire buff_full_signal;
	
	reg [7 : 0] wr_data;
	wire [7 : 0] rd_data;
	
	// Instantiate the Unit Under Test (UUT)
	rv32i_cirbuff  
	#(
		.DATA_WIDTH(8),
		.DATA_DEPTH(16)
	)
	DUT
	(
		.clk(clk),
		.nrst(nrst),
		
		.wr_req(wr_req_signal),
		.rd_req(rd_req_signal),
		
		.buff_empty(buff_empty_signal),
		.buff_full(buff_full_signal),
		
		.wr_data(wr_data),
		.rd_data(rd_data)
	);
	
	integer i, j;
	
	//50MHz system clock generator
	always begin
		#5 clk = ~clk;
	end
	
	initial begin
		
		clk = 1'b0;
		nrst = 1'b0;
		
		wr_req_signal <= 1'b0;
		rd_req_signal <= 1'b0;
		
		wr_data = 'd0;
		
		fork begin
			
			#100 nrst = 1'b1;
			
			for(i = 0; i < 16; i = i + 1)begin
				#40 @(posedge clk);
				wr_req_signal <= 1'b1;
				
				#10 wr_req_signal <= 1'b0;
				
				if(!buff_full_signal)begin
					wr_data = wr_data + 'd1;
				end
			end
			
			for(j = 0; j < 10; j = j + 1)begin
				
				for(i = 0; i < $urandom_range(16-1,0); i = i + 1)begin
					#40 @(posedge clk);
					wr_req_signal <= 1'b1;
					
					#10 wr_req_signal <= 1'b0;
					
					if(!buff_full_signal)begin
						wr_data = wr_data + 'd1;
					end
				end
				
				for(i = 0; i < $urandom_range(16-1,0); i = i + 1)begin
					#40 @(posedge clk);
					rd_req_signal <= 1'b1;
					
					#10 rd_req_signal <= 1'b0;
				end
			end
			
			for(i = 0; i < 16; i = i + 1)begin
				#40 @(posedge clk);
				rd_req_signal <= 1'b1;
				
				#10 rd_req_signal <= 1'b0;
			end
			
			#100 $stop;
		end join
	end
	
endmodule

