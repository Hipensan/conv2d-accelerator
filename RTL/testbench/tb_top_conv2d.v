`timescale 1ns/1ps

module tb_top_conv2d;

    // Testbench Parameters
    parameter DATA_WIDTH = 16;

    // Testbench Signals
    reg i_clk;
    reg i_rst;

    wire [3:0] o_ctrl_addr;
    reg [31:0] i_ctrl_data;
    wire o_ctrl_we;
    wire [31:0] o_ctrl_data;

    wire [27:0] o_img_addr;
    reg [31:0] i_img_data;

    wire [27:0] o_addr;
    wire o_we;
    wire [31:0] o_data;

    // DUT (Device Under Test) Instantiation
    top_conv2d #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst(i_rst),

        .o_ctrl_addr(o_ctrl_addr),
        .i_ctrl_data(i_ctrl_data),
        .o_ctrl_we(o_ctrl_we),
        .o_ctrl_data(o_ctrl_data),

        .o_img_addr(o_img_addr),
        .i_img_data(i_img_data),

        .o_outimg_addr(o_addr),
        .o_outimg_we(o_we),
        .o_outimg_data(o_data)
    );

    // Clock Generation
    always #5 i_clk = ~i_clk;

    initial begin
        // Initialize Signals
        i_clk = 0;
        i_rst = 0;
        i_ctrl_data = 0;
        i_img_data = 0;

        // Reset Sequence
        #10 i_rst = 1; // Deassert reset
        #10;

        // Wait for Computation Completion
        wait(dut.o_ctrl_data[1]); // Wait until computation is done
        $display("Computation Done!");

        // Finish Simulation
        #100;
        $stop;
    end

    always@(posedge i_clk) begin        // ctrl memory structure
        case(o_ctrl_addr)
            0:  i_ctrl_data <= {23'b0, 4'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1};       // {cur_layer(4), maxpool(1), Bn&ReLU(1), Conv(1), done(1), start(1)}
            1:  i_ctrl_data <= 0;       //  X            
            2:  i_ctrl_data <= {11'b0, 2'd1, 1'b1, 2'd3, 8'd6, 8'd6};       // {stride(2), padding(1), kernel(2), height(8), width(8)}            
            3:  i_ctrl_data <= {12'b0, 10'd16, 10'd3};       // {out-channel(10), in-channel(10)}            
            4:  i_ctrl_data <= {16'b0, 16'h0100};       // Kernel 0            
            5:  i_ctrl_data <= {16'b0, 16'h0080};       // Kernel 1            
            6:  i_ctrl_data <= {16'b0, 16'h0100};       // Kernel 2            
            7:  i_ctrl_data <= {16'b0, 16'hFF00};       // Kernel 3            
            8:  i_ctrl_data <= {16'b0, 16'hFF80};       // Kernel 4            
            9:  i_ctrl_data <= {16'b0, 16'h0100};       // Kernel 5   
            10: i_ctrl_data <= {16'b0, 16'h0100};       // Kernel 6            
            11: i_ctrl_data <= {16'b0, 16'h0100};       // Kernel 7            
            12: i_ctrl_data <= {16'b0, 16'h0080};       // Kernel 8
            
            default : i_ctrl_data <= 0;
        endcase
    end


    always@(posedge i_clk) begin
        case(o_img_addr)
            0:  i_img_data <= {16'b0, 16'h0100};
            1:  i_img_data <= {16'b0, 16'h0100};
            2:  i_img_data <= {16'b0, 16'h0100};
            3:  i_img_data <= {16'b0, 16'h0100};
            4:  i_img_data <= {16'b0, 16'h0100};
            5:  i_img_data <= {16'b0, 16'h0100};

            6:  i_img_data <= {16'b0, 16'h0200};
            7:  i_img_data <= {16'b0, 16'h0200};
            8:  i_img_data <= {16'b0, 16'h0200};
            9:  i_img_data <= {16'b0, 16'h0200};
            10: i_img_data <= {16'b0, 16'h0200};
            11: i_img_data <= {16'b0, 16'h0200};

            12: i_img_data <= {16'b0, 16'h0400};
            13: i_img_data <= {16'b0, 16'h0400};
            14: i_img_data <= {16'b0, 16'h0400};
            15: i_img_data <= {16'b0, 16'h0400};
            16: i_img_data <= {16'b0, 16'h0400};
            17: i_img_data <= {16'b0, 16'h0400};

            18: i_img_data <= {16'b0, 16'h0200};
            19: i_img_data <= {16'b0, 16'h0200};
            20: i_img_data <= {16'b0, 16'h0200};
            21: i_img_data <= {16'b0, 16'h0200};
            22: i_img_data <= {16'b0, 16'h0200};
            23: i_img_data <= {16'b0, 16'h0200};

            24: i_img_data <= {16'b0, 16'h0100};
            25: i_img_data <= {16'b0, 16'h0100};
            26: i_img_data <= {16'b0, 16'h0100};
            27: i_img_data <= {16'b0, 16'h0100};
            28: i_img_data <= {16'b0, 16'h0100};
            29: i_img_data <= {16'b0, 16'h0100};

            30: i_img_data <= {16'b0, 16'h0200};
            31: i_img_data <= {16'b0, 16'h0200};
            32: i_img_data <= {16'b0, 16'h0200};
            33: i_img_data <= {16'b0, 16'h0200};
            34: i_img_data <= {16'b0, 16'h0200};
            35: i_img_data <= {16'b0, 16'h0200};

            default: i_img_data <= 0;
        endcase


    end

endmodule
