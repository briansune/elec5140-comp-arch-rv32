module rv32i_cirbuff
#(

	parameter DATA_WIDTH = 8,
	parameter DATA_DEPTH = 16,
	parameter ADDR_WIDTH = log2(DATA_DEPTH - 1)
)
(
	input clk,
	input nrst,
	
	input wr_req,
	input rd_req,
	
	output buff_empty,
	output buff_full,
	
	input [DATA_WIDTH - 1:0] wr_data,
	output [DATA_WIDTH - 1:0] rd_data
);

	function integer log2 (input integer bd);
		integer bit_depth;
		begin
			bit_depth = bd;
			for(log2=0; bit_depth>0; log2=log2 + 1)
				bit_depth = bit_depth >> 1;
		end
	endfunction
	
	
	reg [ADDR_WIDTH-1 : 0] address_head;
	reg [ADDR_WIDTH-1 : 0] address_tail;
	reg [ADDR_WIDTH-1 : 0] address_tail_ram;
	
	//wire wr_trigger;
	//wire rd_trigger;
	
	reg wr_en_reg;
	reg rd_en_reg;
	
	reg [ADDR_WIDTH-1 : 0] addr_head_chk_tail_f;
	reg [ADDR_WIDTH-1 : 0] addr_tail_chk_tail_f;
	
	reg [ADDR_WIDTH-1 : 0] addr_head_chk_head_e;
	reg [ADDR_WIDTH-1 : 0] addr_tail_chk_head_e;
	
	reg tail_full;
	reg head_empty;
	
	assign buff_full = tail_full;
	assign buff_empty = head_empty;
	
	//assign wr_trigger = (!tail_full) & wr_req;
	//assign rd_trigger = (!head_empty) & rd_req;
	
	always@(*)begin
		
		addr_head_chk_tail_f = address_head;
		addr_tail_chk_tail_f = address_tail;
		
		if(addr_tail_chk_tail_f == addr_head_chk_tail_f)begin
			tail_full = 1'b1;
		end else begin
			tail_full = 1'b0;
		end
	end
	
	always@(*)begin
		
		addr_head_chk_head_e = address_head + 'd1;
		addr_tail_chk_head_e = address_tail;
		
		if(addr_head_chk_head_e == addr_tail_chk_head_e)begin
			head_empty = 1'b1;
		end else begin
			head_empty = 1'b0;
		end
	end
	
	always@(posedge clk or negedge nrst)begin
		
		if(!nrst)begin
			address_tail <= 'd1;
			address_tail_ram <= 'd0;
			wr_en_reg <= 1'b0;
		end else begin
			if(wr_req)begin
				wr_en_reg <= (!tail_full);
			end else begin
				wr_en_reg <= 1'b0;
			end
			
			if(wr_en_reg)begin
				address_tail <= address_tail + 'd1;
				address_tail_ram <= address_tail_ram + 'd1;
			end
		end
	end
	
	always@(posedge clk or negedge nrst)begin
		
		if(!nrst)begin
			address_head <= 'd0;
			rd_en_reg <= 1'b0;
		end else begin
			if(rd_req)begin
				rd_en_reg <= (!head_empty);
			end else begin
				rd_en_reg <= 1'b0;
			end
			
			if(rd_en_reg)begin
				address_head <= address_head + 'd1;
			end
		end
	end
	
	simple_dual_port_ram_dual_clock #(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH)
	)ram_inst0(
		
		.rst			(nrst),
		.clk			(clk),
		
		.we				(wr_en_reg),
		.data			(wr_data),
		.write_addr		(address_tail_ram),
		
		.re				(rd_en_reg),
		.read_addr		(address_head),
		.q				(rd_data)
	);
	
endmodule
