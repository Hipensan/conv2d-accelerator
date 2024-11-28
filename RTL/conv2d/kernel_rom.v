module kernel_rom
	(
		input i_clk,
		input [9:0] i_ci,
		input [9:0] i_co,
		output [143:0] o_weight, 		// 16 * 9 = 144b
		output [15:0] o_bias 			// 16 (fixed point)
	);

//=====================
// regs
reg [159:0] rom;
assign o_weight 	= rom[143:0];
assign o_bias 		= rom[159:144];

always@(posedge i_clk)
begin
	case(i_ci)
		0: begin
			case(i_co)
				0: rom <= {16'h, 144'h};
				1: rom <= {16'h, 144'h};

		end

		1: begin


		end





end