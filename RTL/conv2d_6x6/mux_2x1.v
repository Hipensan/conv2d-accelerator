module mux_2x1
	(
		input 		[1:0]		i_sel,
		input 		[15:0] 		i_d0,
		input 		[15:0] 		i_d1,
		output reg 	[15:0] 		o_d
	);


always@* begin
	case(i_sel)
		2'd1 	: 	o_d = i_d0;
		2'd3 	: 	o_d = i_d1;
		default :	o_d = 16'h0; 
	endcase
end
endmodule