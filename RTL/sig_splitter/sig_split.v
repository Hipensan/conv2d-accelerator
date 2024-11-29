module sig_split(
	input i_sig,
	output [3:0] o_sig
	);


assign o_sig = {i_sig, i_sig, i_sig, i_sig};

endmodule