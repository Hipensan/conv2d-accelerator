`timescale 1ns/1ps

module tb_maxpool2d;

    // Parameters
    parameter DATA_WIDTH = 16;
    parameter IMG_WIDTH = 6;
    parameter IMG_HEIGHT = 6;
    parameter CLK_PERIOD = 10;

    // Inputs
    reg i_clk;
    reg i_rst;
    reg i_start;
    reg [DATA_WIDTH-1:0] i_data;

    // Outputs
    wire [DATA_WIDTH-1:0] o_data;
    wire o_valid;

    // Instantiate the Unit Under Test (UUT)
    maxpool2d #
    (
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    )
    uut
    (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_start(i_start),
        .i_data(i_data),
        .o_data(o_data),
        .o_done (o_done),
        .o_valid(o_valid)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #(CLK_PERIOD/2) i_clk = ~i_clk;
    end

    // Test vectors
    reg [DATA_WIDTH-1:0] image_data [0:IMG_WIDTH*IMG_HEIGHT-1];

    integer i;

    initial begin
        // Initialize Inputs
        i_rst = 0;
        i_start = 0;
        i_data = 0;

        // Reset sequence
        #(CLK_PERIOD);
        i_rst = 1;
        #(CLK_PERIOD);

        // Load image data
        // Here, we generate a test pattern; you can replace this with actual image data if needed
        for (i = 0; i < IMG_WIDTH*IMG_HEIGHT; i = i + 1) begin
            image_data[i] = {i, 8'h0};
        end

        image_data[0] = 16'hff00;

        // Start the maxpool2d operation
        #(CLK_PERIOD/2);
        i_start = 1;
        #(CLK_PERIOD);
        i_start = 0;
        
        // Feed input data
        for (i = 0; i < IMG_WIDTH*IMG_HEIGHT; i = i + 1) begin
            i_data = image_data[i];
            #(CLK_PERIOD);
            
        end

        // Wait for processing to complete
        wait(uut.o_done)

        // Finish simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $display("Time\tclk\trst\tstart\tdata_in\tdata_out\tvalid");
        $monitor("%0t\t%b\t%b\t%b\t%h\t%h\t%b", $time, i_clk, i_rst, i_start, i_data, o_data, o_valid);
    end

endmodule
