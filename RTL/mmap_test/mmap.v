module mmap(
	input 					i_clk,
	input 					i_rst,
	output  	[9:0]		o_addr0,
	input 		[31:0] 		i_data,

	output  	[9:0]		o_addr1,
	output 					o_we,
	output 		[31:0] 		o_data

	);	


reg [1:0] c_state, n_state;
reg [15:0] c_L, n_L;
reg [15:0] c_R, n_R;
reg [9:0] c_addr0, n_addr0;

assign o_addr0 = c_addr0 >> 2;

assign o_we = c_state == 1 | c_state == 2;
assign o_addr1 = c_addr0 >> 2;
assign o_data = {c_L, c_R};


always@(posedge i_clk, negedge i_rst)
	if(!i_rst) begin
		c_L <= 0;
		c_R <= 0;
		c_state <= 0;
		c_addr0 <= 0;
	end else begin
		c_L <= n_L;
		c_R <= n_R;
		c_state <= n_state;
		c_addr0 <= n_addr0;
	end




always@* begin
	n_L = c_L;
	n_R = c_R;
	n_state = c_state;
	n_addr0 = c_addr0 + 1;
	case(c_state)
		0: begin
			n_addr0 = c_addr0;
			if(c_addr0 == 0 && i_data[0] == 1'b1) begin
				// if start sign enabled;
				n_state = 1;
				n_addr0 = 1;
			end
		end
		1: begin
			n_L = i_data[31:16];
			n_R = i_data[15:0];
			if((c_addr0 >> 2) == 7) begin
				n_state = 2;
			end			
		end

		2: begin 		// end
			n_state = 3;
		end
		3: begin
			n_addr0 = 0;
			n_state = 0;
		end
	endcase
end
endmodule