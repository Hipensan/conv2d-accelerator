#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "time.h"

#define MEM_0 XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
#define MEM_1 XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR


void writeMEM_0(int addr, int value) {
	Xil_Out32(MEM_0 + addr, value);
}

void writeMEM_BYTE0(int addr, u8 value) {
	Xil_Out8(MEM_0 + addr, value);
}

u32 readMEM_0(int addr) {
	return Xil_In32(MEM_0 + addr);
}

void writeMEM_1(int addr, int value) {
	Xil_Out32(MEM_1 + addr, value);
}

u32 readMEM_1(int addr) {
	return Xil_In32(MEM_1 + addr);
}



int main()
{
    init_platform();
    u32 rdata = 0;
    // data input, ctrl input
    for(int i = 1; i < 4; i++) {
    	writeMEM_0(i*4,i*16000);
    }
    writeMEM_0(0x0, 0x10101);

    for(int i = 0; i < 4; i++) {
    	rdata = readMEM_0(i*4);
    	xil_printf("Input data #%d : 0x%08x\r\n",i,rdata);
    }
    usleep(1);

    for(int i = 0; i < 4; i++) {
    	rdata = readMEM_1(i*4);
    	xil_printf("Out #%d : 0x%08x\r\n",i,rdata);
    }
    cleanup_platform();
    return 0;
}
