module e2prom_rw (
    input                   dri_clk         ,// iic模块输出的时钟
    input                   i2c_ack         ,// iic模块输出的应答信号
    input        [7:0]      i2c_data_r      ,// 从iic模块 读到的数据
    input                   i2c_done        ,// iic模块输出的、一次数据传输后的done信号
    input                   rst_n           ,

    output  reg  [15:0]     i2c_addr        ,// E2PROM向 FPGA写的 16bit 存储单元地址
    output  reg  [7:0]      i2c_data_w      ,//
    output  reg             i2c_exec        ,
    output  wire            bit_ctrl        ,
    output  reg             i2c_rh_wl       ,
    output  reg             rw_done         ,
    output  reg             rw_result 
);
/*------------------------i2c_addr---------------------*/
 //② 16 bit 寄存单元地址
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_addr <= 16'd0;
    end
    else if (i2c_exec) begin//如果触发信号拉高
        if (i2c_addr == 256) begin//每次写1个地址，1个地址是16bit，要写256次
            i2c_addr <= 16'd0;
        end
        else 
            i2c_addr <= i2c_addr + 16'd1;
    end
    else
        i2c_addr <= i2c_addr;
 end
/*------------------------auto_w_to_r---------------------*/
 //写的地址达到256之后，自动开始读信号，auto_w_to_r就是那个标志信号
 reg auto_w_to_r;
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        auto_w_to_r <= 1'd0;
    end
    else if(i2c_addr == 256) begin
        auto_w_to_r <= 1'd1;
    end
    else
        auto_w_to_r <= auto_w_to_r;
 end
/*------------------------i2c_data_w---------------------*/
 //③ 8bit数据
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_data_w <= 8'd0;
    end
    else if (i2c_exec) begin//如果触发信号拉高
        if (i2c_data_w == 255) begin//每次写1个数据，1个数据是8bit，要写256次
            i2c_data_w <= 8'd0;
        end
        else 
            i2c_data_w <= i2c_data_w + 8'd1;
    end
    else
        i2c_data_w <= i2c_data_w;
 end
/*------------------------i2c_exec_cnt---------------------*/
 //控制i2c_exec的5ms计数器
 parameter time_5ms = 250_000;
 reg [17:0] i2c_exec_cnt;//250_000对应5ms,每记到5ms的时候清零。每清零一次拉高一次触发信号
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_exec_cnt <= 18'd0;
    end
    else if (i2c_exec_cnt == time_5ms - 1) begin
        i2c_exec_cnt <= 18'd0;
    end
    else
        i2c_exec_cnt <=  i2c_exec_cnt + 18'd1;
 end
/*------------------------i2c_exec---------------------*/
 //触发信号
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_exec <= 1'd0;
    end
    else if (i2c_exec_cnt == time_5ms - 1) begin
        i2c_exec <= 1'd1;
    end
    else
        i2c_exec <=  1'd0 ;
 end
/*------------------------bit_ctrl---------------------*/
 //控制寄存单元的位数：1 => 16 bit,   0 => 8 bit
 assign bit_ctrl = 1'b1;
/*------------------------i2c_rh_wl---------------------*/
 //控制II2C模块的读还是写：0 => 写； 1 => 读
 always @(posedge dri_clk or negedge rst_n) begin
 if (!rst_n) begin
    i2c_rh_wl <= 1'b0;//写信号
 end
 else if (auto_w_to_r) begin
    i2c_rh_wl <= 1'b1;//读信号
 end
 else
    i2c_rh_wl <= i2c_rh_wl;
 end
/*------------------------compare_cnt---------------------*/
 reg [15:0] compare_cnt;
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        compare_cnt <= 16'd0;
    end
    else if((i2c_rh_wl)&&(i2c_exec)) begin//如果触发信号拉高
        if (compare_cnt == 256) begin//每次写1个地址，1个地址是16bit，要写256次
            compare_cnt <= 16'd0;
        end
        else 
            compare_cnt <= compare_cnt + 16'd1;
    end
    else
        compare_cnt <= compare_cnt;
 end
/*------------------------rw_done---------------------*/
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        rw_done <= 1'd0;
    end
    else if(compare_cnt == 256)begin
        rw_done <= 1'd1;
    end
    else
        rw_done <= rw_done;
 end
/*------------------------rw_result---------------------*/
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        rw_result <= 1'd0;
    end
    else if ((i2c_rh_wl)&&(i2c_exec)) begin
        if(compare_cnt <= 256) begin
            if () begin
                rw_done <= 1'd1;
            end
            else
                rw_done <= 1'd0;
        end
        else
            rw_done <= 1'd1;
    end
    else
        rw_done <= rw_done;
 end
endmodule