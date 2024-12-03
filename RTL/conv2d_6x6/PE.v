module PE_3x3 		// 3x3 PE
	(
		input wire signed [15:0] i_w0,
		input wire signed [15:0] i_w1,
		input wire signed [15:0] i_w2,
		input wire signed [15:0] i_w3,
		input wire signed [15:0] i_w4,
		input wire signed [15:0] i_w5,
		input wire signed [15:0] i_w6,
		input wire signed [15:0] i_w7,
		input wire signed [15:0] i_w8,

		input wire signed [15:0] i_d0,
		input wire signed [15:0] i_d1,
		input wire signed [15:0] i_d2,
		input wire signed [15:0] i_d3,
		input wire signed [15:0] i_d4,
		input wire signed [15:0] i_d5,
		input wire signed [15:0] i_d6,
		input wire signed [15:0] i_d7,
		input wire signed [15:0] i_d8,
		
		output [15:0] o_d

	);



wire signed [31:0] part_sum[0:8];
wire signed [31:0] sum;

assign part_sum[0] 	= 	i_w0 * i_d0;
assign part_sum[1] 	= 	i_w1 * i_d1;
assign part_sum[2] 	= 	i_w2 * i_d2;
assign part_sum[3] 	= 	i_w3 * i_d3;
assign part_sum[4] 	= 	i_w4 * i_d4;
assign part_sum[5] 	= 	i_w5 * i_d5;
assign part_sum[6] 	= 	i_w6 * i_d6;
assign part_sum[7] 	= 	i_w7 * i_d7;
assign part_sum[8] 	= 	i_w8 * i_d8;

assign sum 			= 	part_sum[0] +
						part_sum[1] +
						part_sum[2] +
						part_sum[3] +
						part_sum[4] +
						part_sum[5] +
						part_sum[6] +
						part_sum[7] +
						part_sum[8];
				
assign o_d 	 		= 	sum[23:8];

endmodule



module PE_1x1
	(
		input 	wire signed [15:0] i_w,
		input 	wire signed [15:0] i_d,
		output 	wire signed [15:0] o_d
	);



wire signed [31:0] part_sum;


assign part_sum = i_w * i_d;
assign o_d 		= part_sum[23:8];

endmodule

