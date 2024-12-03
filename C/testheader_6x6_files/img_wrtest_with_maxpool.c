/*include custom files*/
#include "test_image.h"
#include "test_kernel.h"

/*include xil_defined headers*/
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "time.h"
#include "xscutimer.h"
#define TIMER_DEVICE_ID XPAR_SCUTIMER_DEVICE_ID

#define CTRL_MEM 	XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
#define IMG_MEM 	XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR
#define OUTIMG_MEM 	XPAR_AXI_BRAM_CTRL_2_S_AXI_BASEADDR


void writeParam1(int width, int height, int kernel, int padding, int stride) {
    // 데이터 결합: {stride(2), padding(1), kernel(2), height(8), width(8)}
	// 실제 구현은 한 번 sw로 convolution - maxpool 진행하고 208x208x16 데이터부터 하드웨어로 진행하게 됨
    u32 data = 0;

    data |= (width & 0xFF);               // width: 하위 8비트
    data |= (height & 0xFF) << 8;         // height: 9~16비트
    data |= (kernel & 0x3) << 16;         // kernel: 17~18비트
    data |= (padding & 0x1) << 18;        // padding: 19비트
    data |= (stride & 0x3) << 19;         // stride: 20~21비트

    Xil_Out32(CTRL_MEM + 0x8, data);
}

void writeParam2(int ci, int co) {
	// {out-channel(10), in-channel(10)}
	u32 data = 0;
	data |= ci & 0x3FF;
	data |= (co & 0x3FF) << 10;

	Xil_Out32(CTRL_MEM + 0xc, data);
}

void writeCTRL(int start, int done, int conv, int bn, int maxpool, int cur_layer) {
    // 데이터 초기화
    u32 data = 0;

    // 비트 결합
    data |= (start & 0x1);             // start: 0번째 비트
    data |= (done & 0x1) << 1;         // done: 1번째 비트
    data |= (conv & 0x1) << 2;         // conv: 2번째 비트
    data |= (bn & 0x1) << 3;           // bn: 3번째 비트
    data |= (maxpool & 0x1) << 4;      // maxpool: 4번째 비트
    data |= (cur_layer & 0xF) << 5;    // cur_layer: 5~8번째 비트 (4비트)

    // 데이터 출력
    Xil_Out32(CTRL_MEM, data);
}

void writeKernel(int16_t *data, int cur_layer) {
	// if layer # use 1x1 conv, then make param to 1. else 3x3=9
	u8 w_sz = 0; 	// weight size
	if(cur_layer == 13 || cur_layer == 15) 	w_sz = 1;
	else 									w_sz = 9;

	for(int i =0; i < w_sz; i++) {
		Xil_Out32(CTRL_MEM + 0x10 + 4*i, data[i] & 0xFFFF);
	}
}

void writeImg(int16_t *data, int cur_layer) {
	u32 img_sz = 6;
//	if(cur_layer == 2) img_sz = 208;
//	else if(cur_layer == 4) img_sz = 104;
//	else if(cur_layer == 6) img_sz = 52;
//	else if(cur_layer == 8) img_sz = 26;
//	else if(cur_layer == 10 || cur_layer == 12 || cur_layer == 13 || cur_layer == 14 || cur_layer == 15) img_sz = 13;
//	else img_sz = 0;

	for(int i = 0; i < img_sz*img_sz; i++) {
		Xil_Out32(IMG_MEM + 4*i, data[i] & 0xFFFF);
	}

}


void readAllCTRL(u32 *output) {
    for (int i = 0; i < 16; i++) {
        output[i] = Xil_In32(CTRL_MEM + i * 4);
    }
}

u32 readCTRL() {
	return Xil_In32(CTRL_MEM);
}

u32 readOutImg(u32 *output, int cur_layer) {
	u32 img_sz = 6;
//	if(cur_layer == 2) img_sz = 208;
//	else if(cur_layer == 4) img_sz = 104;
//	else if(cur_layer == 6) img_sz = 52;
//	else if(cur_layer == 8) img_sz = 26;
//	else if(cur_layer == 10 || cur_layer == 12 || cur_layer == 13 || cur_layer == 14 || cur_layer == 15) img_sz = 13;
//	else img_sz = 0;

	for (int i = 0; i < img_sz*img_sz; i++) {
	    output[i] = Xil_In32(OUTIMG_MEM + i * 4);
	}
}

int main()
{
    init_platform();
    u32 rdata;
    // timer
    XScuTimer timer;
    XScuTimer_Config *config = XScuTimer_LookupConfig(TIMER_DEVICE_ID);
    XScuTimer_CfgInitialize(&timer, config, config->BaseAddr);
    XScuTimer_LoadTimer(&timer, 0xFFFFFFFF);
    XScuTimer_Start(&timer);
    //

    u32 start_time = XScuTimer_GetCounterValue(&timer);
    writeImg(&test_image, 0);
    for(int i =0; i < 36; i++) {
    	rdata = Xil_In32(IMG_MEM + 4*i);
    	xil_printf("IMG #%d : 0x%08x\r\n",i,rdata);
    }


    writeParam1(6,6,3,1,1); 		//  1111 00000110 00000110 = F0606
    writeParam2(3,16); 				//
    writeKernel(&test_kernel, 0);
    writeCTRL(1,0,1,0,0,0);


//    u32 out_ctrl[16];
//    readAllCTRL(out_ctrl);
//    for(int i = 0; i < 16; i++)
//    	xil_printf("#%d : 0x%08x\r\n",i,out_ctrl[i]);


    while(1) {
    	rdata = readCTRL();
    	if(rdata & 0x2) {
    		xil_printf("convolution done\r\n");
    		break;
    	}
    }

    u32 out_img[36];
    readOutImg(out_img, 0);
    for(int i =0; i<36; i++) {
    	xil_printf("Out IMG #%d : 0x%08x\r\n",i,out_img[i]);
    	Xil_Out32(IMG_MEM + 4*i, out_img[i]);
    }
//    xil_printf("Conv done image to img memory\r\n");
//    for(int i =0; i < 36; i++) {
//        	rdata = Xil_In32(IMG_MEM + 4*i);
//        	xil_printf("CONV IMG #%d : 0x%08x\r\n",i,rdata);
//        }


    xil_printf("maxpool start\r\n");
    writeCTRL(1,0,0,0,1,0);
    while(1) {
        	rdata = readCTRL();
        	if(rdata & 0x2) {
        		xil_printf("maxpool done\r\n");
        		break;
        	}
        }
    readOutImg(out_img, 0);
        for(int i =0; i<9; i++) {
        	xil_printf("Out IMG #%d : 0x%08x\r\n",i,out_img[i]);
        }

    u32 end_time = XScuTimer_GetCounterValue(&timer);

    u32 elapsed = start_time - end_time; // 클럭 주기 차이
    uint64_t elapsed_ns = ((uint64_t)elapsed * 1000000000) / 666666666;
    uint32_t elapsed_sec = elapsed_ns / 1000000000;
    uint32_t remaining_ns = elapsed_ns % 1000000000;
    xil_printf("elapsed cycle / time(s) : %u / %u.%09u (s)  ", elapsed, elapsed_sec, remaining_ns);

    cleanup_platform();
    return 0;
}
