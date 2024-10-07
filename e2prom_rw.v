module  (
    input                   clk             ,// iic模块输出的时钟
    input                   i2c_ack         ,// iic模块输出的应答信号
    input        [7:0]      i2c_data_r      ,// 从  iic模块 读到的数据
    input                   i2c_done        ,// iic模块输出的、一次数据传输后的done信号
    input                   rst_n           ,

    output  reg  [15:0]     i2c_addr        ,//E2PROM向 FPGA写的 16bit 存储单元地址
    output  reg  [7:0]      i2c_data_w      ,//
    output  reg             i2c_exec        ,
    output  reg             i2c_rh_wl       ,
    output  reg             rw_done         ,
    output  reg             rw_result 
);
    
endmodule