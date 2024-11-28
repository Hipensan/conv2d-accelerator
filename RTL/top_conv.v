module top_conv2d#
	(
		parameter DATA_WIDTH = 16, 
	)
	(
		input i_clk,
		input i_rst,
		input i_addr,
		input i_data,
		output o_we,
		output o_data
	);



// input image max size = 416