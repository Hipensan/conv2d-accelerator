/*

	NOT Universal Conv2d, for Partial-sum
	Control output data on top_conv2d
	
	input parameters are considered as fixed parameter per one filter * ifmap

	Max width = 416, Max height = 416,
	Max ci = 1024, Max co = 1024

	kernel size = max 3
	padding size = max 1
	stride size = max 1

	------------ Support ------------
	for 3x3 kernel, padding only
	for 1x1 kernel, no padding only
	---------------------------------
*/

module conv2d_universal
	(
		input 						i_clk,
		input 						i_rst,
		input 						i_start,
		input 				[8:0] 	i_max_width,
		input 				[8:0] 	i_max_height,
		input 				[1:0] 	i_kernel_size,
		input 						i_is_pad,
		input 						i_stride, 		// not using, 1 fixed
		input 				[9:0] 	i_max_ci,
		input 				[9:0] 	i_max_co,
		input wire signed 	[15:0] 	i_data,
		input wire 	 	 	[143:0] i_kernel_w,
		output reg					o_done,
		output 				[15:0] 	o_data,
		output 						o_valid
	);


/*
	max line buffer size = 416 * 2 + 3 = 835;
	if i_is_pad ? (416 + 2) * 2 + 3 = 839 (+2, pad sync) => 841;
	// if 208x208 first,
	// (208 + 2) *2 + 3 = 423 + 2 = 425
*/

parameter 	DATA_WIDTH = 16;
parameter 	MAX_BUF_SIZE = 425;

localparam 	IDLE 	= 0,
			WORK 	= 1;



//=======================================================================================================
// regs
reg  		[0:0] 	 			c_state,  						n_state;
reg signed 	[15:0] 	 			c_line_buf[0:MAX_BUF_SIZE], 	n_line_buf[0:MAX_BUF_SIZE];
reg 		[8:0] 				c_x, 							n_x; 		// input image pos(x)
reg 		[8:0] 				c_y, 							n_y; 		// input image pos(y)


wire signed [15:0] 				PE_3x3_o_d, PE_1x1_o_d, mux_o_d;
wire  							pad_sync;
wire  		[15:0]  			PE_i_d0, PE_i_d1, PE_i_d2, PE_i_d3, PE_i_d4, PE_i_d5, PE_i_d6, PE_i_d7, PE_i_d8;
//=======================================================================================================
// Nets
assign o_data 	= mux_o_d;
assign o_valid 	= i_is_pad ? 
                 ((c_y >= 1 && c_x > 1) || c_y >= 2) && !(c_x >= 2 && c_y == i_max_height+1) && !o_done : 
                 ((c_y == i_max_height && c_x == 0) || (c_y < i_max_height)) && !o_done && !(c_x == 0 && c_y == 0);

assign pad_sync = c_y >= 1 && c_x == 1;
assign PE_i_d0 	= pad_sync ? c_line_buf[2*(i_max_width + 2)+2 	+2] : c_line_buf[2*(i_max_width + 2)+2];
assign PE_i_d1 	= pad_sync ? c_line_buf[2*(i_max_width + 2)+1 	+2] : c_line_buf[2*(i_max_width + 2)+1];
assign PE_i_d2 	= pad_sync ? c_line_buf[2*(i_max_width + 2) 	+2] : c_line_buf[2*(i_max_width + 2)  ];
assign PE_i_d3 	= pad_sync ? c_line_buf[1*(i_max_width + 2)+2 	+2] : c_line_buf[1*(i_max_width + 2)+2];
assign PE_i_d4 	= pad_sync ? c_line_buf[1*(i_max_width + 2)+1 	+2] : c_line_buf[1*(i_max_width + 2)+1];
assign PE_i_d5 	= pad_sync ? c_line_buf[1*(i_max_width + 2) 	+2] : c_line_buf[1*(i_max_width + 2)  ];
assign PE_i_d6 	= pad_sync ? c_line_buf[0  				  +2 	+2] : c_line_buf[0 					+2];
assign PE_i_d7 	= pad_sync ? c_line_buf[0  				  +1 	+2] : c_line_buf[0 					+1];
assign PE_i_d8 	= pad_sync ? c_line_buf[0  				   		+2] : c_line_buf[0 					  ];

// wire [9:0] debug_num[0:8];
// assign debug_num[0] =  pad_sync ?  2*(i_max_width + 2)+2 	+2 : 2*(i_max_width + 2)+2;
// assign debug_num[1] =  pad_sync ?  2*(i_max_width + 2)+1 	+2 : 2*(i_max_width + 2)+1;
// assign debug_num[2] =  pad_sync ?  2*(i_max_width + 2) 		+2 : 2*(i_max_width + 2)  ;
// assign debug_num[3] =  pad_sync ?  1*(i_max_width + 2)+2 	+2 : 1*(i_max_width + 2)+2;
// assign debug_num[4] =  pad_sync ?  1*(i_max_width + 2)+1 	+2 : 1*(i_max_width + 2)+1;
// assign debug_num[5] =  pad_sync ?  1*(i_max_width + 2) 		+2 : 1*(i_max_width + 2)  ;
// assign debug_num[6] =  pad_sync ?  0  				  +2 	+2 : 0 					+2;
// assign debug_num[7] =  pad_sync ?  0  				  +1 	+2 : 0 					+1;
// assign debug_num[8] =  pad_sync ?  0  				   		+2 : 0 					  ;


//=======================================================================================================
// FF
integer i;
always@(posedge i_clk, negedge i_rst)
	if(!i_rst) begin
		c_state <= 0;
		c_x 	<= 0;
		c_y 	<= 0;
		for(i=0; i<MAX_BUF_SIZE; i=i+1) 	c_line_buf[i] <= 0;
	end else begin
		c_state <= n_state;
		c_x 	<= n_x;
		c_y 	<= n_y;
		for(i=0; i<MAX_BUF_SIZE; i=i+1) 	c_line_buf[i] <= n_line_buf[i];
	end



always@* begin
	n_state = c_state;
	n_x 	= c_x;
	n_y 	= c_y;
	for(i=0; i<MAX_BUF_SIZE; i=i+1) 		n_line_buf[i] = c_line_buf[i];

	o_done = 0;

	case(c_state)
		IDLE: begin
			n_x = 0;
			n_y = 0;
			for(i=0; i<MAX_BUF_SIZE; i=i+1) 	n_line_buf[i] = 0;
			if(i_start) n_state = WORK;
		end




		WORK: begin
			// image pos
			if(c_x < i_max_width-1)	 		n_x = c_x + 1;
			else begin
				n_x = 0;
				if(c_y < i_max_height + 1) 	n_y = c_y + 1;
				else 						n_y = 0;
			end

			// end signal
			if(i_is_pad) begin
				if(c_x == 2 && c_y == i_max_height+1) begin
					o_done 	= 1;
					n_state = IDLE;
				end
			end 
			else begin 		// when no pad, end signal 
				if(c_x == 1 && c_y == i_max_height) begin
					o_done 	= 1;
					n_state = IDLE;
				end
			end


			// padding, 3x3
			if(i_is_pad) begin
				if(c_x == 0 && c_y != 0) begin
					n_line_buf[2] = 0;
					n_line_buf[1] = 0;
					if(c_y > i_max_height-1)		n_line_buf[0] = 0;
					else 							n_line_buf[0] = i_data;
					for(i=3;i<MAX_BUF_SIZE;i=i+1) 	n_line_buf[i] = c_line_buf[i-3];
				end
				else begin
					if(c_y > i_max_height-1)		n_line_buf[0] = 0;
					else 							n_line_buf[0] = i_data;
					for(i=1;i<MAX_BUF_SIZE;i=i+1) 	n_line_buf[i] = c_line_buf[i-1];
				end				
			end
			// no padding, 1x1
			else begin 		
				for(i=1;i<MAX_BUF_SIZE;i=i+1) 		n_line_buf[i] = c_line_buf[i-1];
				if(c_y > i_max_height-1)			n_line_buf[0] = 0;
				else 								n_line_buf[0] = i_data;

			end

		end
	endcase
end



//================================
// submodule // mult weight, pixel value
PE_3x3 	PE3_U0	
	(
		.i_w0(i_kernel_w[DATA_WIDTH*0+:DATA_WIDTH]),
		.i_w1(i_kernel_w[DATA_WIDTH*1+:DATA_WIDTH]),
		.i_w2(i_kernel_w[DATA_WIDTH*2+:DATA_WIDTH]),
		.i_w3(i_kernel_w[DATA_WIDTH*3+:DATA_WIDTH]),
		.i_w4(i_kernel_w[DATA_WIDTH*4+:DATA_WIDTH]),
		.i_w5(i_kernel_w[DATA_WIDTH*5+:DATA_WIDTH]),
		.i_w6(i_kernel_w[DATA_WIDTH*6+:DATA_WIDTH]),
		.i_w7(i_kernel_w[DATA_WIDTH*7+:DATA_WIDTH]),
		.i_w8(i_kernel_w[DATA_WIDTH*8+:DATA_WIDTH]),

		.i_d0(PE_i_d0),
		.i_d1(PE_i_d1),
		.i_d2(PE_i_d2),
		.i_d3(PE_i_d3),
		.i_d4(PE_i_d4),
		.i_d5(PE_i_d5),
		.i_d6(PE_i_d6),
		.i_d7(PE_i_d7),
		.i_d8(PE_i_d8),
		
		.o_d(PE_3x3_o_d)
	);



PE_1x1 PE1_U0 
	(
		.i_w(i_kernel_w[DATA_WIDTH*0+:DATA_WIDTH]),
		.i_d(c_line_buf[0]),
		.o_d(PE_1x1_o_d)
	);


mux_2x1 mux_U0
	(
		.i_sel(i_kernel_size),
		.i_d0(PE_1x1_o_d),
		.i_d1(PE_3x3_o_d),
		.o_d(mux_o_d)
	);





endmodule