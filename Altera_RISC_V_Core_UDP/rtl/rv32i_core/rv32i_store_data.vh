/////////////////////////////////////////////////////////////////
// function for store
/////////////////////////////////////////////////////////////////
function [`XPR_LEN-1:0] store_data;
	
	input	[`XPR_LEN-1:0]			addr;
	input	[`XPR_LEN-1:0]			data;
	input	[`MEM_TYPE_WIDTH-1:0]	mem_type;
	
	begin
		case(mem_type)
			`MEM_TYPE_SB:	store_data = {4{data[7:0]}};
			`MEM_TYPE_SH:	store_data = {2{data[15:0]}};
			default:		store_data = data;
		endcase
	end
endfunction
/////////////////////////////////////////////////////////////////
