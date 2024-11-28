module tb_conv2d_universal;

// Parameters
parameter DATA_WIDTH = 16;
parameter MAX_BUF_SIZE = 839;

// Inputs
reg i_clk;
reg i_rst;
reg i_start;
reg [8:0] i_max_width;
reg [8:0] i_max_height;
reg [1:0] i_kernel_size;
reg i_is_pad;
reg i_stride;
reg [9:0] i_max_ci;
reg [9:0] i_max_co;
reg [9:0] i_ci;
reg [9:0] i_co;
reg signed [DATA_WIDTH-1:0] i_data;
reg         [143:0] i_kernel_w;
wire o_valid;

// Outputs
wire o_done;
wire [DATA_WIDTH-1:0] o_data;


reg [15:0] ifmap[0:5][0:5];

// Instantiate the Unit Under Test (UUT)
conv2d_universal uut (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start(i_start),
    .i_max_width(i_max_width),
    .i_max_height(i_max_height),
    .i_kernel_size(i_kernel_size),
    .i_is_pad(i_is_pad),
    .i_stride(i_stride),
    .i_max_ci(i_max_ci),
    .i_max_co(i_max_co),
    .i_ci(i_ci),
    .i_co(i_co),
    .i_data(i_data),
    .i_kernel_w   (i_kernel_w),
    .o_done(o_done),
    .o_data(o_data),
    .o_valid(o_valid)
);

// Clock generation
initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk; // 10ns period
end
integer i, j;
// Test sequence
initial begin
    // Initialize Inputs
    i_rst = 0;
    i_start = 0;
    i_max_width = 9'd6;  // Example width
    i_max_height = 9'd6; // Example height
    i_kernel_size = 2'd3; // 3x3 kernel or 1x1
    i_is_pad = 1;         // Padding enabled
    i_stride = 1;         // Stride 1
    i_max_ci = 10'd8;     // Example max channels in
    i_max_co = 10'd8;     // Example max channels out
    i_ci = 10'd8;
    i_co = 10'd8;
    i_data = 16'sd0;
    // kernel = {kernel[8], kernel[7], ... kernel[0]}
    // for 3x3 conv
    i_kernel_w = {  16'h0080, 16'h0100, 16'h0100,       16'h0100, 16'hff80, 16'hff00,       16'h0100, 16'h0080, 16'h0100 };
    // for 1x1 conv
    // i_kernel_w = {128'h0, 16'h0080};

    ifmap[0][0] = 16'h0100;  ifmap[0][1] = 16'h0100; ifmap[0][2] = 16'h0100; ifmap[0][3] = 16'h0100; ifmap[0][4] = 16'h0100; ifmap[0][5] = 16'h0100;
    ifmap[1][0] = 16'h0200;  ifmap[1][1] = 16'h0200; ifmap[1][2] = 16'h0200; ifmap[1][3] = 16'h0200; ifmap[1][4] = 16'h0200; ifmap[1][5] = 16'h0200;
    ifmap[2][0] = 16'h0400;  ifmap[2][1] = 16'h0400; ifmap[2][2] = 16'h0400; ifmap[2][3] = 16'h0400; ifmap[2][4] = 16'h0400; ifmap[2][5] = 16'h0400;
    ifmap[3][0] = 16'h0200;  ifmap[3][1] = 16'h0200; ifmap[3][2] = 16'h0200; ifmap[3][3] = 16'h0200; ifmap[3][4] = 16'h0200; ifmap[3][5] = 16'h0200;
    ifmap[4][0] = 16'h0100;  ifmap[4][1] = 16'h0100; ifmap[4][2] = 16'h0100; ifmap[4][3] = 16'h0100; ifmap[4][4] = 16'h0100; ifmap[4][5] = 16'h0100;
    ifmap[5][0] = 16'h0200;  ifmap[5][1] = 16'h0200; ifmap[5][2] = 16'h0200; ifmap[5][3] = 16'h0200; ifmap[5][4] = 16'h0200; ifmap[5][5] = 16'h0200;

    // Reset the system
    #10 i_rst = 0;
    #10 i_rst = 1;

    // Start the convolution
    #15 i_start = 1;
    #10 i_start = 0;

    



    for(i=0; i<6; i=i+1) begin
        for(j=0; j<6; j=j+1) begin
            @(posedge i_clk) i_data = ifmap[i][j];
        end
    end

    // Wait for done signal
    wait(o_done);
    $display("Convolution completed!");

    // End simulation
    #100 $stop;
end

endmodule
