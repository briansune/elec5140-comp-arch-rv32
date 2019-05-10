module simple_dual_port_ram_dual_clock
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] read_addr, write_addr,
	input we, re, clk, rst,
	output reg [(DATA_WIDTH-1):0] q
);
	
	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	
	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[write_addr] <= data;
	end
	
	always @ (posedge clk or negedge rst)
	begin
		if(!rst)
			q <= 'd0;
		// Read
		else
			if(re)
				q <= ram[read_addr];
	end
	
endmodule