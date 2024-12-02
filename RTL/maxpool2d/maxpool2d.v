module maxpool2d#
(
    parameter DATA_WIDTH    = 16,  // fixed point 16-bit
    parameter IMG_WIDTH     = 6,    // original image size
    parameter IMG_HEIGHT    = 6
)
(
    input   wire                    i_clk,
    input   wire                    i_rst,
    input   wire                    i_start,
    input   wire [DATA_WIDTH-1:0]   i_data,
    output  wire [DATA_WIDTH-1:0]   o_data,
    output  reg                     o_done,
    output  reg                     o_valid        // current o_data validation flag
);

//========================================
// P A R A M

localparam  IDLE        = 0,
            BUF_FILL    = 1,
            WORK        = 2;

localparam  LINE_BUF_SIZE   = IMG_WIDTH * 2;
localparam  MAX_WORK        = IMG_WIDTH / 2;
localparam  HALF_BUF_SIZE   = LINE_BUF_SIZE / 2;

//========================================
// R E G & W I R E S
reg [DATA_WIDTH-1:0]            c_line_buf[0:LINE_BUF_SIZE-1], n_line_buf[0:LINE_BUF_SIZE-1];  // 2 lines of image width size buffer

reg [1:0]                       c_state,        n_state;
reg [$clog2(IMG_WIDTH):0]       c_x,            n_x;         // line buf x-counter // log2(IMG_WIDTH) + 1 bit width
reg [$clog2(IMG_WIDTH):0]       c_y,            n_y;         // line buf y-counter
reg [$clog2(MAX_WORK):0]        c_work_cnt,     n_work_cnt;

integer i;

wire signed [DATA_WIDTH-1:0]    comp1, comp2, result;


wire [$clog2(LINE_BUF_SIZE):0]  idx1_comp1,
                                idx2_comp1,
                                idx1_comp2,
                                idx2_comp2;
//========================================
// N e t 

// Result calculation
// cannot be replaced to parameter assign 
assign idx1_comp1   = LINE_BUF_SIZE - c_work_cnt-1;
assign idx2_comp1   = LINE_BUF_SIZE - c_work_cnt-2;
assign idx1_comp2   = HALF_BUF_SIZE - c_work_cnt-1;
assign idx2_comp2   = HALF_BUF_SIZE - c_work_cnt-2;


assign comp1        = (c_line_buf[idx1_comp1] > c_line_buf[idx2_comp1]) ? c_line_buf[idx1_comp1] : c_line_buf[idx2_comp1];
assign comp2        = (c_line_buf[idx1_comp2] > c_line_buf[idx2_comp2]) ? c_line_buf[idx1_comp2] : c_line_buf[idx2_comp2];
assign result       = (comp1 > comp2)   ? comp1 : comp2;
// ReLU integrated
assign o_data       = result[15]        ? 0     : result;

//========================================
// F F

always@(posedge i_clk or negedge i_rst) begin
    if(!i_rst) begin
        c_state     <= IDLE;
        c_x         <= 0;
        c_y         <= 0;
        c_work_cnt  <= 0;
        for(i = 0; i < LINE_BUF_SIZE; i=i+1)        c_line_buf[i] <= 0;
    end else begin
        c_state     <= n_state;
        c_x         <= n_x;
        c_y         <= n_y;
        c_work_cnt  <= n_work_cnt;  
        for(i = 0; i < LINE_BUF_SIZE; i=i+1)        c_line_buf[i] <= n_line_buf[i];
    end
end

//========================================
// C O M B

always@* begin
    n_state     = c_state;
    n_x         = c_x;
    n_y         = c_y;
    n_work_cnt  = c_work_cnt;    
    o_done      = 0;
    o_valid     = 0;    
    for(i = 0; i < LINE_BUF_SIZE; i=i+1)            n_line_buf[i] = c_line_buf[i];
   

    case(c_state)
        IDLE: begin
            n_x = 0;
            n_y = 0;
            for(i = 0; i < LINE_BUF_SIZE; i=i+1)    n_line_buf[i] = 0;

            if(i_start) begin
                n_state = BUF_FILL;
            end
        end

        BUF_FILL: begin
            // buffer movement
            n_line_buf[0]   = i_data;
            // buffer left shift 
            for(i = 1; i < LINE_BUF_SIZE; i=i+1)    n_line_buf[i] = c_line_buf[i-1];       

            // x, y movement
            if (c_x == IMG_WIDTH - 1) begin
                n_x     = 0;
                n_y     = c_y + 1;
            end else begin
                n_x     = c_x + 1;
                n_y     = c_y;
            end


            // if buffer filled
            if(c_x == IMG_WIDTH-1 && c_y[0]) begin      
                n_state     = WORK;
                n_work_cnt  = 0;
            end

            // if error y value
            if(c_y == IMG_HEIGHT + 1) begin
                n_state     = IDLE;
                o_done      = 1;
            end
        end

        WORK: begin
            o_valid = 1;
            
            // buffer movement
            n_line_buf[0] = i_data;
            // buffer left shift 
            for(i = 1; i < LINE_BUF_SIZE; i=i+1)    n_line_buf[i] = c_line_buf[i-1];       

            // x, y movement
            if (c_x == IMG_WIDTH - 1) begin
                n_x     = 0;
                n_y     = c_y + 1;
            end else begin
                n_x     = c_x + 1;
                n_y     = c_y;
            end

            // work counter, MAX == IMG_WIDTH / 2
            n_work_cnt  = c_work_cnt + 1;

            if (c_work_cnt == MAX_WORK - 1) begin
                if (c_y == IMG_HEIGHT - 1) begin
                    n_state     = IDLE;
                    o_done      = 1;
                end else begin
                    n_state     = BUF_FILL;
                end
            end
        end
    endcase
end


endmodule