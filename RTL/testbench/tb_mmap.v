// module tb_mmap_memory();

//     // 클럭 및 리셋
//     reg         tb_clk;
//     reg         tb_rst;

//     // 메모리 인터페이스
//     wire [9:0]  addr0;
//     wire [31:0] data0;
//     wire  [31:0] mem_data;
//     wire [9:0]  addr1;
//     wire        we;
//     wire [31:0] data1;

//     // DUT 인스턴스
//     mmap uut_mmap (
//         .i_clk(tb_clk),
//         .i_rst(tb_rst),
//         .o_addr0(addr0),
//         .i_data(mem_data),
//         .o_addr1(addr1),
//         .o_we(we),
//         .o_data(data1)
//     );

//     dual_port_memory #(
//         .DATA_WIDTH(32),
//         .ADDR_WIDTH(10)
//     ) uut_memory (
//         .i_clk(tb_clk),

//         .i_we_a(4'b0000),             // 포트 A는 읽기 전용
//         .i_addr_a(addr0),
//         .i_din_a(32'b0),
//         .o_dout_a(mem_data),          // mmap의 입력 데이터로 연결

//         .i_we_b(we ? 4'b1111 : 4'b0), // 포트 B는 mmap의 쓰기 제어
//         .i_addr_b(addr1),
//         .i_din_b(data1),
//         .o_dout_b()                   // 포트 B의 읽기 출력은 사용 안 함
//     );

//     // 클럭 생성
//     initial begin
//         tb_clk = 0;
//         forever #5 tb_clk = ~tb_clk; // 10ns 주기
//     end

//     // 리셋 및 초기화
//     initial begin
//         tb_rst = 0;
//         #20 tb_rst = 1; // 리셋 해제
//     end
//     integer i;

//     // 테스트 시퀀스
//     initial begin
//         // 초기화 후 0번 주소에 컨트롤 신호 설정
//         wait(tb_rst);
        

//         // 1번 주소에 데이터 작성
//         for(i=1; i<8; i=i+1) begin
//         	write_memory(i,i*16000);
//     	end

//         // 처리 완료 후 메모리에 쓰기된 값 확인
//         #10 write_memory(10'd0, 32'h00000001); // Start 비트 활성화

//         #100 $stop;
//     end

//     // 메모리에 데이터 쓰기 함수
//     task write_memory(input [9:0] addr, input [31:0] data);
//         begin
//             uut_memory.mem[addr] = data; // 메모리 직접 쓰기
//         end
//     endtask

//     // 메모리 데이터 확인 함수
//     task check_memory(input [9:0] addr, input [31:0] expected);
//         begin
//             #10;
//             if (uut_memory.mem[addr] !== expected) begin
//                 $display("ERROR: Address %d - Expected: %h, Got: %h", addr, expected, uut_memory.mem[addr]);
//             end else begin
//                 $display("PASS: Address %d - Value: %h", addr, uut_memory.mem[addr]);
//             end
//         end
//     endtask

// endmodule
