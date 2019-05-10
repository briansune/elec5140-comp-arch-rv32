`timescale 1ns / 1ps

module top(
	
	output				sdram_clk,
	output				sdram_cke,
	output				sdram_cs_n,
	output				sdram_cas_n,
	output				sdram_ras_n,
	output				sdram_we_n,
	
	output	[1 : 0]		sdram_dqm,
	
	output	[11 : 0]	sdram_addr,
	output	[1 : 0]		sdram_ba,
	inout	[15 : 0]	sdram_dq,
	
	input				clk,
	input				rst_n
);
	
	reg [22 : 0] wr_addr_sig;
	reg [15 : 0] wr_data_sig;
	reg wr_enable_sig;
	
	reg [22 : 0] rd_addr_sig;
	reg rd_enable_sig;
	wire [15 : 0] rd_data_sig;
	wire rd_ready_sig;
	
	wire busy_sig;
	wire startup_inc;
	
	reg startup;
	
	reg [12 : 0] delay_steady;
	
	reg hold_steady;
	
	assign sdram_clk = ~clk;
	
	assign startup_inc = (wr_enable_sig & !sdram_cs_n & sdram_ras_n & !sdram_cas_n & !sdram_we_n & startup) ? 1'b1 : 1'b0;
	
	sdram_ctrl sdram_ctrl_inst0(
		
		.clk(clk),						// input  clk_sig
		.rst_n(hold_steady),			// input  rst_n_sig
		
		.wr_addr(wr_addr_sig),			// input [HADDR_WIDTH-1:0] wr_addr_sig
		.wr_data(wr_data_sig),			// input [15:0] wr_data_sig
		.wr_enable(wr_enable_sig),		// input  wr_enable_sig
		
		.rd_addr(rd_addr_sig),			// input [HADDR_WIDTH-1:0] rd_addr_sig
		.rd_data(rd_data_sig),			// output [15:0] rd_data_sig
		.rd_ready(rd_ready_sig),		// output  rd_ready_sig
		.rd_enable(rd_enable_sig),		// input  rd_enable_sig
		
		.busy(busy_sig),				// output  busy_sig
		
		.addr(sdram_addr),				// output [SDRADDR_WIDTH-1:0] addr_sig
		.bank_addr(sdram_ba),			// output [BANK_WIDTH-1:0] bank_addr_sig
		.data(sdram_dq),				// inout [15:0] data_sig
		.clken(sdram_cke),				// output  clken_sig
		.cs_n(sdram_cs_n),				// output  cs_n_sig
		.ras_n(sdram_ras_n),			// output  ras_n_sig
		.cas_n(sdram_cas_n),			// output  cas_n_sig
		.we_n(sdram_we_n),				// output  we_n_sig
		.data_mask_low(sdram_dqm[0]),	// output  data_mask_low_sig
		.data_mask_high(sdram_dqm[1]) 	// output  data_mask_high_sig
	);
	
	always@(posedge clk or negedge rst_n)begin
		
		if(!rst_n)begin
			delay_steady <= 'd0;
			hold_steady <= 1'b0;
		end else begin
			if(delay_steady[12])begin
				hold_steady <= 1'b1;
			end else begin
				delay_steady <= delay_steady + 'd1;
			end
		end
	end
	
	always@(posedge clk or negedge hold_steady)begin
		
		if(!hold_steady)begin
			wr_enable_sig <= 'd0;
		end else begin
			if(startup)begin
				if(!busy_sig)begin
					wr_enable_sig <= 1'b1;
				end
			end else begin
				wr_enable_sig <= 1'b0;
			end
		end
	end
	
	always@(posedge clk or negedge hold_steady)begin
		
		if(!hold_steady)begin
			startup <= 'd1;
		end else begin
			if(wr_addr_sig == 'd11)begin
				startup <= 'd0;
			end
		end
	end
	
	always@(posedge clk or negedge hold_steady)begin
		
		if(!hold_steady)begin
			wr_addr_sig <= 'd0;
			wr_data_sig <= -'d100;
		end else begin
			
			if(startup_inc)begin
				wr_addr_sig <= wr_addr_sig + 'd1;
				wr_data_sig <= wr_data_sig + 'd103;
			end
		end
	end
	
	always@(posedge clk or negedge hold_steady)begin
		
		if(!hold_steady)begin
			rd_addr_sig <= 'd0;
			rd_enable_sig <= 'd0;
		end else begin
			
			if(startup == 'd0 && !busy_sig)begin
				rd_enable_sig <= 'd1;
			end
			
			if(rd_addr_sig == 'd10)begin
				rd_enable_sig <= 'd0;
			end
			
			if(rd_enable_sig && rd_ready_sig)begin
				rd_addr_sig <= rd_addr_sig + 'd1;
			end
		end
	end
	
endmodule
