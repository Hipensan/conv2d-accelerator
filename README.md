# yolov3-tiny-accelerator

Warning! not done project

![img_error](./img/under_construction.png)



[testing] accelerate conv, maxpool in yolov3-tiny w. Verilog, vivado <br>
hw / sw co-design

<h3>Quickstart</h3>

1. run all code in py/read_weights.ipynb
2. generate JSON, npy, txt, and header file


<h3> Requirements </h3>

* Vivado 2018.3
* Python
* ZYNQ Z7020 board or greater (i'm using edge fpga z7020 board)
* OV7670 camera



<h3>Model</h3>

![img_error](./img/model.png)
<p> use yolov3-tiny, more simple structure to detect big objects and accelerated in conv2d</p>

---
---

<h3> mio test</h3>
if you want to test memory i/o structure, access to <br>

* RTL/mmap_test<br>
* C/mmap.c<br>

![img_error](./img/mmap_bd.png)

![img_error](./img/mmap_ila.png)

![img_error](./img/mmap_result.png)


---
---
<h3> Small convolution reference test </h3>
Use <br>

* C/testheader_6x6_files, <br>
* RTL/conv2d_6x6/conv2d_universal.v, mux_2x1.v, PE.v, top_conv2d.v, <br>
* RTL/sig_splitter <br>

![img_error](./img/smol_bd.png)

| CTRL | IMG  | RESULT |
|------|------|--------|
| ![img_error](./img/smol_ctrl.png) | ![img_error](./img/smol_img.png) | ![img_error](./img/smol_result.png) |


* Validation --> py/test_layer/test_layer.ipynb

---