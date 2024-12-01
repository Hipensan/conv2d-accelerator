module dual_port_memory #(
    parameter DATA_WIDTH = 32,  // 데이터 폭
    parameter ADDR_WIDTH = 10   // 주소 폭 (2**n)
)(
    input                       	i_clk,      // 공통 클럭
    
    input       [3:0]              	i_we_a,     // Write Enable for Port A
    input       [ADDR_WIDTH-1:0] 	i_addr_a,   // 주소 입력 for Port A
    input       [DATA_WIDTH-1:0] 	i_din_a,    // 데이터 입력 for Port A
    output reg  [DATA_WIDTH-1:0] 	o_dout_a,   // 데이터 출력 for Port A
    
    input       [3:0]              	i_we_b,     // Write Enable for Port B
    input       [ADDR_WIDTH-1:0] 	i_addr_b,   // 주소 입력 for Port B
    input       [DATA_WIDTH-1:0] 	i_din_b,    // 데이터 입력 for Port B
    output reg  [DATA_WIDTH-1:0] 	o_dout_b    // 데이터 출력 for Port B
);

    // 메모리 배열
    reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];

    // 포트 A: 항상 읽기 및 쓰기 동작
    always @(posedge i_clk) begin
        if (|i_we_a) begin
            mem[i_addr_a] <= i_din_a;  // 쓰기
        end
        o_dout_a <= mem[i_addr_a];     // 항상 읽기
    end

    // 포트 B: 항상 읽기 및 쓰기 동작
    always @(posedge i_clk) begin
        if (|i_we_b) begin
            mem[i_addr_b] <= i_din_b;  // 쓰기
        end
        o_dout_b <= mem[i_addr_b];     // 항상 읽기
    end

endmodule
