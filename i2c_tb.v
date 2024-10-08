module i2c_tb;

    reg               bit_ctrl        ;// bit_ctrl==0,send 4 bit 存储单元地址, bit_ctrl==1,send 16 bit 存储单元地址
    reg               clk             ;// 50MHz
    reg [15:0]        i2c_addr        ;// 16 bit 存储单元地址 
    reg [7:0]         i2c_data_w      ;// FPGA向E2PROM写的4bit数据
    reg               i2c_exec        ;// 一个脉冲信号
    reg               i2c_rh_wl       ;// 控制FPGA是向E2PROM写还是读，高电平读；低电平写
    reg               rst_n           ;

    wire          dri_clk             ;//在50Mhz的基础上为IIC提供工作时钟
    wire          scl                 ;//IIC工作时的工作时钟
    wire          i2c_ack             ;//IIC的应答信号
    wire [7:0]    i2c_data_r          ;//FPGA从E2PROM读得的数据
    wire          i2c_done            ;
    wire          sda                 ;

i2c_dri i1(
    .  bit_ctrl      (bit_ctrl  )  ,// bit_ctrl==0,send 4 bit 存储单元地址, bit_ctrl==1,send 16 bit 存储单元地址
    .  clk           (clk       )  ,// 50MHz
    .  i2c_addr      (i2c_addr  )  ,// 16 bit 存储单元地址 
    .  i2c_data_w    (i2c_data_w)  ,// FPGA向E2PROM写的4bit数据
    .  i2c_exec      (i2c_exec  )  ,// 一个脉冲信号
    .  i2c_rh_wl     (i2c_rh_wl )  ,// 控制FPGA是向E2PROM写还是读，高电平读；低电平写
    .  rst_n         (rst_n     )  ,

    .  dri_clk       (dri_clk   )  ,//在50Mhz的基础上为IIC提供工作时钟
    .  scl           (scl       )  ,//IIC工作时的工作时钟
    .  i2c_ack       (i2c_ack   )  ,//IIC的应答信号
    .  i2c_data_r    (i2c_data_r)  ,//FPGA从E2PROM读得的数据
    .  i2c_done      (i2c_done  )  ,
    .  sda           (sda       )  
);
    
/*-----------------------------clk----------------------------*/
initial begin
    clk=0;
end
always #10 clk=~clk;
/*-----------------------------clk----------------------------*/
initial begin
    rst_n=0;
    #201;
    rst_n=1;
    #2_384_000;
    $stop;
end


endmodule