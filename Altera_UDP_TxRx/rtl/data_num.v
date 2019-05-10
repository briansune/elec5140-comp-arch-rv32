module data_num(
	input clk,
	input txen,
	output reg [12:0] mynum
);
	
	always @(posedge clk)begin
		if(txen)begin
			mynum <= mynum + 'b1;
		end else begin
			mynum <= 13'b0;
		end
	end
	
endmodule
