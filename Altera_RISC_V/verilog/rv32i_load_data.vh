/////////////////////////////////////////////////////////////////
// function for load
/////////////////////////////////////////////////////////////////
function [`XPR_LEN-1:0] load_data;
	
	input	[`XPR_LEN-1:0]			addr;
	input	[`XPR_LEN-1:0]			data;
	input	[`MEM_TYPE_WIDTH-1:0]	mem_type;
	
	reg		[`XPR_LEN-1:0]			shifted_data;
	reg		[`XPR_LEN-1:0]			b_extend;
	reg		[`XPR_LEN-1:0]			h_extend;
	
	begin
		
		shifted_data = data >> {addr[1:0],3'b0};
		b_extend = {{24{shifted_data[7]}},8'b0};
		h_extend = {{16{shifted_data[15]}},16'b0};
		
		case(mem_type)
			`MEM_TYPE_LB:	load_data = (shifted_data & `XPR_LEN'hff) | b_extend;
			`MEM_TYPE_LH:	load_data = (shifted_data & `XPR_LEN'hffff) | h_extend;
			`MEM_TYPE_LBU:	load_data = (shifted_data & `XPR_LEN'hff);
			`MEM_TYPE_LHU:	load_data = (shifted_data & `XPR_LEN'hffff);
			default:		load_data = shifted_data;
		endcase
	end
endfunction
/////////////////////////////////////////////////////////////////
