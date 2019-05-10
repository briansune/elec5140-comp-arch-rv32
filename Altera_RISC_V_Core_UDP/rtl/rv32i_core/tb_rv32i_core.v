`timescale 1ns / 1ps

`include "rv32i_bus_constants.vh"
`include "rv32i_ctrl_constants.vh"
`include "rv32i_csr_addr_map.vh"
`include "rv32i_platform_constants.vh"

module tb_rv32i_core;
	
	reg clk;
	reg reset;
	
	reg										htif_pcr_req_valid;
	reg										htif_pcr_req_rw;
	reg		[`CSR_ADDR_WIDTH-1:0]			htif_pcr_req_addr;
	reg		[`HTIF_PCR_WIDTH-1:0]			htif_pcr_req_data;
	reg										htif_pcr_resp_ready;
	
	wire									htif_pcr_req_ready;
	wire									htif_pcr_resp_valid;
	wire		[`HTIF_PCR_WIDTH-1:0]		htif_pcr_resp_data;
	
	////////////////////////////////////////////////
	//	instantiate
	////////////////////////////////////////////////
	rv32i_core DUT(
		
		.clk					(clk),
		.reset					(reset),
		
		.ext_interrupts			('d0),
		
		.htif_pcr_req_valid		(htif_pcr_req_valid),
		.htif_pcr_req_ready		(htif_pcr_req_ready),
		.htif_pcr_req_rw		(htif_pcr_req_rw),
		.htif_pcr_req_addr		(htif_pcr_req_addr),
		.htif_pcr_req_data		(htif_pcr_req_data),
		.htif_pcr_resp_valid	(htif_pcr_resp_valid),
		.htif_pcr_resp_ready	(htif_pcr_resp_ready),
		.htif_pcr_resp_data		(htif_pcr_resp_data)
	);
	
	//50MHz system clock generator
	always begin
		#10 clk = ~clk;
	end
	
	integer i;
	
	initial begin
		
		clk = 'd0;
		reset = 'd1;
		
		htif_pcr_req_valid = 'd1;
		htif_pcr_req_rw = 'd0;
		htif_pcr_req_addr = 'd0;
		htif_pcr_req_data = 'd0;
		htif_pcr_resp_ready = 'd1;
		
		fork begin
			
			#100 reset = 'b0;
			
			#1700 $stop;
		end join
	end
	
endmodule
