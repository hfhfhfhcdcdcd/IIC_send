module e2prom_top (
    input         clk         ,
    input         rst_n       ,
    output        led         ,      
    output        scl         ,
    inout         sda     
);
/*==================================i2c_dri================================*/

 
 i2c_dri i1(
    . bit_ctrl      (bit_ctrl  )      ,// bit_ctrl==0,send 4 bit 存储单元地址, bit_ctrl==1,send 16 bit 存储单元地址
    . clk           (clk       )      ,// 50MHz
    . i2c_addr      (i2c_addr  )      ,// 16 bit 存储单元地址 
    . i2c_data_w    (i2c_data_w)      ,// FPGA向E2PROM写的8bit数据
    . i2c_exec      (i2c_exec  )      ,// 一个脉冲信号
    . i2c_rh_wl     (i2c_rh_wl )      ,// 控制FPGA是向E2PROM写还是读，高电平读；低电平写
    . rst_n         (rst_n     )      ,

    . dri_clk       (dri_clk   )      ,//在50Mhz的基础上为IIC提供工作时钟
    . scl           (scl       )      ,//IIC工作时的工作时钟
    . i2c_ack       (i2c_ack   )      ,//IIC的应答信号
    . i2c_data_r    (i2c_data_r)      ,//FPGA从E2PROM读得的数据
    . i2c_done      (i2c_done  )      ,
    . sda           (sda       )      
 );
/*==================================e2prom_rw===============================*/
   //  reg                   dri_clk         ;// iic模块输出的时钟
   //  reg                   i2c_ack         ;// iic模块输出的应答信号
   //  reg        [7:0]      i2c_data_r      ;// 从iic模块 读到的数据
   //  reg                   i2c_done        ;// iic模块输出的、一次数据传输后的done信号

//    wire       [15:0]     i2c_addr        ;// E2PROM向 FPGA写的 16bit 存储单元地址
//    wire       [7:0]      i2c_data_w      ;//
//    wire                  i2c_exec        ;
//    wire                  bit_ctrl        ;
//    wire                  i2c_rh_wl       ;
  /*  wire                  rw_done         ;
    wire                  rw_result       ;*/
 defparam e1.time_5ms=25;//500ns  
 e2prom_rw e1(
    .  dri_clk              (dri_clk   )      ,// iic模块输出的时钟
    .  i2c_ack              (i2c_ack   )      ,// iic模块输出的应答信号
    .  i2c_data_r           (i2c_data_r)      ,// 从iic模块 读到的数据
    .  i2c_done             (i2c_done  )      ,// iic模块输出的、一次数据传输后的done信号
    .  rst_n                (rst_n     )      ,
    .  i2c_addr             (i2c_addr  )      ,// E2PROM向 FPGA写的 16bit 存储单元地址
    .  i2c_data_w           (i2c_data_w)      ,//
    .  i2c_exec             (i2c_exec  )      ,
    .  bit_ctrl             (bit_ctrl  )      ,
    .  i2c_rh_wl            (i2c_rh_wl )      ,
    .  rw_done              (rw_done   )      ,
    .  rw_result            (rw_result ) 
 );
/*==================================alarm===============================*/
   //  reg       rw_done             ;
   //  reg       rw_result           ;     
 alarm a1(
    .   clk             (clk      )           ,
    .   rst_n           (rst_n    )           ,
    .   rw_done         (rw_done  )           ,
    .   rw_result       (rw_result)           ,      
    .   led             (led)
 );

endmodule