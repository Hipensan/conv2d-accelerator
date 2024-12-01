// `timescale 1ns / 1ps

// module mmap_memory_tb;

//     // 파라미터 설정
//     parameter DATA_WIDTH = 16;
//     parameter ADDR_WIDTH = 2;

//     // Testbench 신호 선언
//     reg tb_clk;
//     reg tb_rst;

//     // mmap 모듈 신호
//     wire [1:0] mmap_o_addr0;
//     reg [DATA_WIDTH*2-1:0] mmap_i_data;
//     wire [1:0] mmap_o_addr1;
//     wire mmap_o_we;
//     wire [DATA_WIDTH*2-1:0] mmap_o_data;

//     // memory 모듈 신호
//     reg [DATA_WIDTH-1:0] memory_o_dout_a;
//     reg [DATA_WIDTH-1:0] memory_o_dout_b;
//     wire memory_i_we_a;
//     wire [ADDR_WIDTH-1:0] memory_i_addr_a;
//     wire [DATA_WIDTH-1:0] memory_i_din_a;
//     wire [ADDR_WIDTH-1:0] memory_i_addr_b;
//     wire [DATA_WIDTH-1:0] memory_i_din_b;

//     // 클럭 생성
//     initial begin
//         tb_clk = 0;
//         forever #5 tb_clk = ~tb_clk; // 주기 10ns
//     end

//     // 리셋 초기화
//     initial begin
//         tb_rst = 0;
//         #20 tb_rst = 1;
//     end

//     // DUT 연결
//     mmap mmap_inst (
//         .i_clk(tb_clk),
//         .i_rst(tb_rst),
//         .o_addr0(mmap_o_addr0),
//         .i_data(mmap_i_data),
//         .o_addr1(mmap_o_addr1),
//         .o_we(mmap_o_we),
//         .o_data(mmap_o_data)
//     );

//     dual_port_memory #(
//         .DATA_WIDTH(DATA_WIDTH),
//         .ADDR_WIDTH(ADDR_WIDTH)
//     ) memory_inst (
//         .i_clk(tb_clk),
//         .i_we_a(memory_i_we_a),
//         .i_addr_a(memory_i_addr_a),
//         .i_din_a(memory_i_din_a),
//         .o_dout_a(memory_o_dout_a),
//         .i_we_b(mmap_o_we),
//         .i_addr_b(mmap_o_addr1),
//         .i_din_b(mmap_o_data),
//         .o_dout_b(mmap_i_data)
//     );

//     // mmap 출력 연결
//     assign memory_i_we_a = mmap_o_we;
//     assign memory_i_addr_a = mmap_o_addr0;
//     assign memory_i_din_a = mmap_o_data;

//     // 테스트 시나리오
//     initial begin
//         // 초기화
//         #30;

//         // 테스트: Start 신호 전달
//         $display("Sending Start Signal...");
//         #10;
//         mmap_i_data = 32'h00000001; // start 신호
//         #10;

//         // 테스트: 메모리에 데이터 쓰기
//         $display("Writing Data...");
//         mmap_i_data = 32'h12345678;
//         #10;

//         // 테스트: 메모리 읽기 확인
//         $display("Reading Data...");
//         #10;

//         // 종료
//         #50;
//         $finish;
//     end

//     // 모니터링
//     initial begin
//         $monitor("Time=%0t, Addr0=%b, Addr1=%b, Data In=%h, Data Out=%h",
//                  $time, mmap_o_addr0, mmap_o_addr1, mmap_i_data, mmap_o_data);
//     end

// endmodule
