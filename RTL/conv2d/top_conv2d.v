module top_conv2d#
	(
		parameter DATA_WIDTH = 16
	)
	(
		input 				i_clk,
		input 				i_rst,

		output  	[3:0] 	o_ctrl_addr,
		input 		[31:0] 	i_ctrl_data,
		output reg			o_ctrl_we,
		output reg	[31:0] 	o_ctrl_data, 			// for end signal

		output 		[17:0] 	o_img_addr, 			// 2^18 > 416*416
		input 		[31:0] 	i_img_data, 

		output  	[17:0] 	o_outimg_addr,
		output 				o_outimg_we,
		output 		[31:0] 	o_outimg_data
	);

localparam 	IDLE 	= 0,
			CONV2D 	= 1;

localparam 	CTRL 	= 4'd0,
 			PARAM1 	= 4'd2,
 			PARAM2 	= 4'd3;

//===============================================================
// Regs & Wires
wire fKernel;
reg [DATA_WIDTH*9-1:0] 	c_kernel, 		n_kernel;
reg [0:0]				c_state, 		n_state;
reg [7:0]				c_width, 		n_width;
reg [7:0]				c_height, 		n_height;
reg [1:0]				c_kernel_sz, 	n_kernel_sz;
reg  					c_padding, 		n_padding;
reg [1:0]				c_stride, 		n_stride;
reg [9:0]				c_ci, 			n_ci;
reg [9:0]				c_co, 			n_co;
reg  					c_start, 		n_start;
reg  					c_conv, 		n_conv;
// reg  					r_bn;
// reg  					r_maxpool;

wire 					conv2d_o_done;
wire [15:0]				conv2d_o_data;
wire 					conv2d_o_valid;


reg [3:0] c_ctrl_addr, n_ctrl_addr;
reg [17:0] c_img_addr, n_img_addr; 			
reg conv2d_start;

reg [17:0] 	c_outimg_addr, n_outimg_addr;

// reg [15:0] r_tmp;
//===============================================================
// Nets
assign fKernel 	=  (c_ctrl_addr >= 4) && (c_ctrl_addr < 13); //4~12, exclude 13(1101), 14(1110), 15(1111)

assign o_ctrl_addr	= n_ctrl_addr; 		// 1 bram read latency
assign o_img_addr 	= n_img_addr; 		// 1 bram read latency

// assign o_outimg_addr = c_outimg_addr;
// assign o_outimg_we = c_state == CONV2D ? conv2d_o_valid : 0; 		// | bn_valid | maxpool_valid
// assign o_outimg_data = {16'b0, conv2d_o_data}; 		// {16'b0, conv2d_o_data};
assign o_outimg_we = 1;
assign o_outimg_addr = 0;
assign o_outimg_data = {3'b0, c_width, c_height, c_kernel_sz, c_padding, c_ci};  // 0000 0000 0110 0000 0111 1100 0000 0011
//===============================================================
// Submodule
conv2d_universal conv2d_inst_
	(
		.i_clk			(i_clk),
		.i_rst			(i_rst),
		.i_start		(conv2d_start),
		.i_max_width	(c_width),
		.i_max_height	(c_height),
		.i_kernel_size	(c_kernel_sz),
		.i_is_pad		(c_padding),
		.i_stride		(1'b1), 		// conv2d not using, 1 fixed
		.i_max_ci		(c_ci),
		.i_max_co		(c_co),
		.i_data			(i_img_data[15:0]),
		.i_kernel_w		(c_kernel),
		.o_done			(conv2d_o_done),
		.o_data			(conv2d_o_data),
		.o_valid		(conv2d_o_valid)
	);
//===============================================================
// FF


always@(posedge i_clk, negedge i_rst)
	if(!i_rst) begin
		c_kernel 		<= 0;
		c_state 		<= 0;
		c_width 		<= 0;
		c_height 		<= 0;
		c_kernel_sz 	<= 0;
		c_padding 		<= 0;
		c_stride 		<= 0;
		c_ci 			<= 0;
		c_co 			<= 0;
		c_start 		<= 0;
		c_conv 			<= 0;

		c_ctrl_addr 	<= 0;
		c_img_addr 		<= 0;
		c_outimg_addr 	<= 0;

		// r_tmp <= 0;
	end else begin
		c_kernel 		<= n_kernel;
		c_state 		<= n_state;
		c_width 		<= n_width;
		c_height 		<= n_height;
		c_kernel_sz 	<= n_kernel_sz;
		c_padding 		<= n_padding;
		c_stride 		<= n_stride;
		c_ci 			<= n_ci;
		c_co 			<= n_co;
		c_start 		<= n_start;
		c_conv 			<= n_conv;

		c_ctrl_addr 	<= n_ctrl_addr;
		c_img_addr 		<= n_img_addr;
		c_outimg_addr 	<= n_outimg_addr;

		// r_tmp <= conv2d_o_valid ? r_tmp + 1 : r_tmp;
	end




always@* begin
	n_state 		= c_state;
	n_kernel 		= c_kernel;
	n_width 		= c_ctrl_addr == PARAM1 ? i_ctrl_data[0+:8] 	: c_width;
	n_height 		= c_ctrl_addr == PARAM1 ? i_ctrl_data[8+:8] 	: c_height;
	n_kernel_sz 	= c_ctrl_addr == PARAM1 ? i_ctrl_data[16+:2] 	: c_kernel_sz;
	n_padding 		= c_ctrl_addr == PARAM1 ? i_ctrl_data[18+:1] 	: c_padding;
	n_stride 		= c_ctrl_addr == PARAM1 ? i_ctrl_data[19+:2] 	: c_stride;
	n_ci 			= c_ctrl_addr == PARAM2 ? i_ctrl_data[0+:10] 	: c_ci;
	n_co 			= c_ctrl_addr == PARAM2 ? i_ctrl_data[10+:10] 	: c_co;
	n_start 		= c_ctrl_addr == CTRL 	? i_ctrl_data[0] 		: c_start;
	n_conv 			= c_ctrl_addr == CTRL 	? i_ctrl_data[2] 		: c_conv;

	n_ctrl_addr 	= c_ctrl_addr;
	o_ctrl_data 	= i_ctrl_data;
	o_ctrl_we 		= 0;

	n_img_addr 		= c_img_addr;
	n_outimg_addr 	= c_outimg_addr;
	conv2d_start 	= 0;

	case(c_state)
		IDLE: begin
			if(c_start) begin
				n_ctrl_addr = c_ctrl_addr + 1;
				if(fKernel) 	n_kernel[(c_ctrl_addr-4)*DATA_WIDTH+:DATA_WIDTH] = i_ctrl_data[15:0];
				if(&c_ctrl_addr) begin
					n_state = CONV2D;
					// make n_start == 0 (o_ctrl_addr == 0, o_ctrl_data == {..., 1'b0}, o_ctrl_we = 1)
					o_ctrl_data = {23'b0, 4'b0, 1'b0, 1'b0, c_conv, 1'b0, 1'b0}; 		// {cur_layer(4), maxpool(1), Bn&ReLU(1), Conv(1), done(1), start(1)}
					o_ctrl_we = 1;
					n_ctrl_addr = 0;
					// n_state = c_conv ? CONV2D : c_bn ? BN : c_maxpool ? MAXPOOL2D : c_state;
					conv2d_start = 1;
				end
			end

		end

		CONV2D: begin
			n_img_addr = c_img_addr + 1;
			n_outimg_addr = o_outimg_we ? c_outimg_addr + 1 : c_outimg_addr;


			if(conv2d_o_done) begin
				n_state = IDLE;
				// done flag to ctrl memory
				o_ctrl_data = {23'b0, 4'b0, 1'b0, 1'b0, c_conv, 1'b1, 1'b0}; 		// {cur_layer(4), maxpool(1), Bn&ReLU(1), Conv(1), done(1), start(1)}
				o_ctrl_we = 1;

				// init img_addr
				n_img_addr = 0;
				n_outimg_addr = 0;
			end
		end

	endcase
end

endmodule

