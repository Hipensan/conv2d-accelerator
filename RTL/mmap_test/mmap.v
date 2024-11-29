module mmap(
	input 			i_clk,
	input 			i_rst,
	input  			i_addr,
	input [31:0] 	i_data,

	output  		o_addr,
	output 			o_we,
	output [31:0] 	o_data

	);	


// addr = 0 : ctrl
// addr = 1 : data0 (0x12345678)


reg c_state, n_state;
reg [15:0] c_L, n_L;
reg [15:0] c_R, n_R;

assign o_we = 1'b1;
assign o_addr = 1'b0;
assign o_data = {c_L, c_R};


always@(posedge i_clk, negedge i_rst)
	if(!i_rst) begin
		c_L <= 0;
		c_R <= 0;
		c_state <= 0;
	end else begin
		c_L <= n_L;
		c_R <= n_R;
		c_state <= n_state;
	end




always@* begin
	n_L = c_L;
	n_R = c_R;
	n_state = c_state;
	case(c_state)
		0: begin
			if(i_addr == 0) begin
				n_state = 1;
			end
		end
		1: begin
			if(i_addr == 1) begin
				n_L = i_data[31:16];
				n_R = i_data[15:0];
				n_state = 0;
			end
		end
	endcase
end
endmodule