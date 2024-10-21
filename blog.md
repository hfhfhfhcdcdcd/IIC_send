    121   122   123    124   125  126   127    128   129  130   131   132   133   134    135   136   137   138   139   140  141   142   143    144   145  146   147    148   149  150   151   152   153   154   155   156   157   158   159   160    161   162   163   164   165  166   167   168   169

   e2prom_rw 这个模块的作用，是用来存储fpga从e2prom读到的数据、以及fpga写道e2prom中的数据的。

  光有I2C模块的话，只是写了一个遵循I2C通信协议的时序模块，相当于仅仅搭建了一个通信模块，还得有数据在上面传输才行。

  @[toc]
# 一、描述IIC通信
* IIC通信的物理层：有两根串行传输线：scl = => IIC通信的时钟；sda = =>IIC通信的传输数据的线。
* IIC协议层：IIC通信完成1次的过程可以分为4部分：
  *  ① scl、sda未收发数据的初始状态；
  *  ② scl、sda开始收发数据的触发动作；
  *  ③ scl、sda配合收发数据的状态；
  *  ④ scl、sda结束收发数据的完成动作。
  ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a3632a3e029e49b284c4cd2b98d5a13c.png)


③就是IIC向E2PROM写数据和读数据的一段。
# 二、写数据和读数据也分为不同的模式：
写数据有：
* 字节写和连续写

读有：
* 当前地址读
* 随机读
* 当前地址连续读
* 随机地址连续读
# 三、详细介绍读写
* 写：
  * 字节写：
    * FPGA芯片发送1个起始信号。也就是在scl高电平的时候，将sda拉低。
    * FPGA发送7位器件地址；FPGA发送写控制位(也就是0)。-------> 从机收到则应答，应答位是一位低电平
    * FPGA发送16bit字地址。分为2个8bit来发送：先发送字地址的高8bit ( addr[15]、addr[14]......addr[8] ) ;再发送字地址的低8bit ( addr[7] 、 addr[6]......addr[0] )。 -------> 从机收到字地址的高8bit向FPGA发送应答位；从机收到字地址的低8bit向FPGA发送应答位。
    * FPGA发送8bit数据。-------> 从机收到则应答，应答位是一位低电平。
    * FPGA发送1位结束信号。-------->也就是在scl高电平的时候，将sda拉高。
    ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b3e5444fab0d4e44883047f11f9d6eee.png)

  * 连续写：
    *  与上边的区别仅仅在于： “ FPGA发送8bit数据 ” 这部分。连续写对于E2PROM来说也叫页写。当发完第一个8bit数据之后可以继续连续发送n个字节。直到sda拉高为止（在scl高电平的状态下）。这代表着传输结束。
  ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a46b4fd9c0e943c89b75d9ded965e23f.png)

* 读：
  *  当前地址读：
     * FPGA发送起始信号；
     * FPGA向从机发送7位器件地址 + 1位读命令（1）。-------->从机发送1位应答位。
     * 从机发送8位数据给FPGA。----------> 主机发送一位“非应答位”（1）。
     * FPGA先将sda拉低再将sda拉高。
     ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/43dda2a23b5447cebae983c1bc9a205d.png)

  *  随机读：（和字节写的前三个点一样一样的）
     * FPGA芯片发送1个起始信号。也就是在scl高电平的时候，将sda拉低。
     * FPGA发送7位器件地址；FPGA发送写控制位(也就是0)。-------> 从机收到则应答，应答位是一位低电平
     * FPGA发送16bit字地址。-------> 从机收到则应答
     * 这一步和下面的步骤与之前的“ 当前读 ” 就一样了：
     	* FPGA芯片再发送1个起始信号。
    	* FPGA向从机发送7位器件地址 + 1位读命令（1）。-------->从机发送1位应答位。
     	* 从机发送8位数据给FPGA。----------> 主机发送一位“非应答位”（1）。
     	* FPGA先将sda拉低再将sda拉高。
  # 四、模块设计
  
  模块名称|说明
   :----|:----
   i2c_dri.v|对IIC协议要搭建一个既可以读数据，也可以写数据据的模块。具体的读写IIC时序要写在这个模块里。
    e2prom_rw.v |通过IIC协议从FPGA写到E2PROM的地址、数据、起始结束信号，这些数据要PFPGA从这个专门存储数据的模块传到E2PROM。FPGA从E2PROM读到的数据也存到这个模块里面。
     led_alarm.v |如果FPGA写到E2PROM里的数据据与FPGA从E2PROM读到的数据一样则让led常亮；不同则闪烁。这个模块是用来驱动led的。
    e2prom_top.v  |顶层模块例化这三个模块。
    
# 五、代码
## i2c_dri.v
```c
module i2c_dri (
    input               bit_ctrl        ,// bit_ctrl==0,send 4 bit 存储单元地址, bit_ctrl==1,send 16 bit 存储单元地址
    input               clk             ,// 50MHz
    input [15:0]        i2c_addr        ,// 16 bit 存储单元地址 
    input [7:0]         i2c_data_w      ,// FPGA向E2PROM写的8bit数据
    input               i2c_exec        ,// 一个脉冲信号
    input               i2c_rh_wl       ,// 控制FPGA是向E2PROM写还是读，高电平读；低电平写
    input               rst_n           ,
    
    output reg          dri_clk         ,//在50Mhz的基础上为IIC提供工作时钟
    output reg          scl             ,//IIC工作时的工作时钟
    output reg          i2c_ack         ,//IIC的应答信号
    output reg [7:0]    i2c_data_r      ,//FPGA从E2PROM读得的数据
    output reg          i2c_done        ,
    inout               sda             
);
/*-------------------------------parameter declaration---------------------------------*/    
 localparam st_idle      = 3'd0;
 localparam st_sladdr    = 3'd1;
 localparam st_addr16    = 3'd2;
 localparam st_addr8     = 3'd3;
 localparam st_data_wr   = 3'd4;
 localparam st_stop      = 3'd5;
 localparam st_addr_rd   = 3'd6;
 localparam st_data_rd   = 3'd7;
 
 parameter slave_addr = 7'b1010_000;
 parameter SYS_CLK = 50_000_000;  // 系统时钟的频率  
 parameter SCL_CLK = 250_000; // IIC工作的时钟频率，对应端口中的scl
/*----------------------------------------define------------------------------------*/
 reg  [7:0]       dri_cnt              ; 
 reg              cur_state            ;    
 reg              next_state           ;    
 reg  [7:0]       div_clk_200_cnt      ;        
 reg  [9:0]       scl_800_cnt          ;    
 reg              wr_flag              ;
 reg  [15:0]      addr_t               ;//输入端口i2c_addr —— 16bit的寄存器        
 reg  [7:0]       data_wr_t            ;//i2c_data_w —— 8bit数据的寄存器 
 reg  [7:0]       data_r               ;//i2c_data_r —— 8bit数据的寄存器
 reg              st_done              ;//标志信号：存储单元高五位地址已经发送到了fpga上
/*-------------------------------------sda的assign-----------------------------------*/
 reg             sda_out              ; 
 wire            sda_in               ;
 reg             sda_dir              ; 
 assign sda = (sda_dir) ? sda_out : 1'bz ;
 assign sda_in = sda ;
/*-------------------------------------div_clk_200_cnt-----------------------------------*/
 always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_clk_200_cnt <= 8'd0;
    end
    else if (div_clk_200_cnt == (200/2)-1) begin
        div_clk_200_cnt<=8'd0;
    end
    else 
        div_clk_200_cnt <= div_clk_200_cnt + 8'd1;
 end
/*----------------------------------------scl_800_cnt---------------------------------*/
 always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scl_800_cnt <= 10'd0;
    end
    else if (scl_800_cnt == (800/2)-1) begin
        scl_800_cnt<= 10'd0;
    end
    else case (cur_state)
            st_idle,st_sladdr,st_addr16,st_addr8,st_data_wr,st_stop,st_addr_rd,st_data_rd:scl_800_cnt <= scl_800_cnt + 10'd1;
        default: scl_800_cnt <= 10'd0;
        endcase         
 end
/*----------------------------------------div_clk---------------------------------------*/
 always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dri_clk <= 1'b1;
    end
    else if (div_clk_200_cnt == (200/2)-1) begin
        dri_clk <= ~dri_clk;
    end
    else
        dri_clk <= dri_clk;
 end
/*----------------------------------------scl时钟---------------------------------------------*/
 always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scl <= 1'b1;
    end
    else if (scl_800_cnt == (800/2)-1) begin
        scl <= ~scl;
    end
    else
        scl <= scl;
 end
/*----------------------------------------dri_cnt---------------------------------------------*/
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        dri_cnt <= 8'd0;
    end
    else
        dri_cnt <= dri_cnt + 1;
 end
/*--------------------------------------状态机第1段--------------------------------------*/
 always@(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state <= st_idle;
    end
    else    
        cur_state <= next_state;
 end
/*--------------------------------------状态机第2段-----------------------------------------*/
 always @(*) begin
    if(!rst_n)
        next_state = st_idle;
    else
        case (cur_state)
            st_idle    :begin
                if ((i2c_exec==1)&&(i2c_rh_wl==0)) begin
                    dri_cnt  = 8'd0;
                    next_state = st_sladdr;
                end
                else
                    next_state = cur_state;
            end 
            st_sladdr  :begin
                if ((bit_ctrl==1)&&(st_done)) begin
                    dri_cnt  = 8'd0;
                    next_state = st_addr16;
                end
                else if (bit_ctrl==0) begin
                    dri_cnt  = 8'd0;
                    next_state = st_addr8;
                end
                else
                    next_state = cur_state;
            end 
            st_addr16  :begin
                if (st_done ==1) begin
                    dri_cnt  = 8'd0;
                    next_state = st_addr8;
                end
                else
                    next_state = cur_state;
            end 
            st_addr8   :begin
                if ((wr_flag == 0)&&((st_done == 1))) begin
                    dri_cnt  = 8'd0;
                    next_state = st_data_wr;
                end
                else if ((wr_flag == 1)&&((st_done == 1))) begin
                    dri_cnt  = 8'd0;
                    next_state = st_data_rd;
                end
                else
                    next_state = cur_state;
            end 
            st_data_wr :begin
                if (st_done ==1) begin
                    dri_cnt  = 8'd0;
                    next_state = st_stop;
                end
                else
                    next_state = cur_state;
            end 
            st_stop    :begin
                if (st_done ==1) begin
                    dri_cnt  = 8'd0;
                    next_state = st_idle;
                end
                else
                    next_state = cur_state;
            end 
            st_addr_rd :begin
                if (st_done ==1) begin
                    dri_cnt  = 8'd0;
                    next_state = st_data_rd;
                end
                else
                    next_state = cur_state;
            end 
            st_data_rd :begin
                if (st_done ==1) begin
                    dri_cnt  = 8'd0;
                    next_state = st_stop;
                end
                else
                    next_state = cur_state;
            end 
            default: ;
        endcase
 end
/*--------------------------------------状态机第3段-------------------------------------*/
 always @(*) begin
     wr_flag = i2c_rh_wl;
     addr_t  = i2c_addr;
     data_wr_t = i2c_data_w;
     i2c_ack = 0;
     sda_dir = 1'b1;

     case (cur_state)
        st_idle   :begin
            wr_flag = i2c_rh_wl;
            addr_t  = i2c_addr;
            data_wr_t = i2c_data_w;
            i2c_ack = 0;
            sda_dir = 1'b1;
        end
        st_sladdr :begin
            case (dri_cnt)
                8'd1  : sda_out =1'b0;
                8'd4  : sda_out = slave_addr[6];
                8'd8  : sda_out = slave_addr[5];
                8'd12 : sda_out = slave_addr[4];
                8'd16 : sda_out = slave_addr[3];
                8'd20 : sda_out = slave_addr[2];
                8'd24 : sda_out = slave_addr[1];
                8'd28 : sda_out = slave_addr[0];
                8'd32 : sda_out = 0;//写命令
                8'd36 : sda_dir = 1'b0;//释放主机对sda信号的控制
                8'd38 : begin//检测应答1
                    st_done = 1'b1;
                    if (sda_in == 1'b1) begin//如果从机应答信号为 1 
                            i2c_ack <= 1'b1;//拉高应答标志位，表示传输错误
                    end
                end 
                default:;
            endcase
        end
        st_addr16 :begin
            sda_dir = 1'b1;
            case (dri_cnt)
                8'd0  : sda_out = addr_t[15];
                8'd4  : sda_out = addr_t[14];
                8'd8  : sda_out = addr_t[13];
                8'd12 : sda_out = addr_t[12];
                8'd16 : sda_out = addr_t[11];
                8'd20 : sda_out = addr_t[10];
                8'd24 : sda_out = addr_t[9];
                8'd28 : sda_out = addr_t[8];
                8'd32 : sda_dir = 1'b0;//释放主机对sda信号的控制 
                8'd34 : begin//检测应答2
                            st_done = 1'b1;
                            if (sda_in == 1'b1) begin//如果从机应答信号为 1 
                                    i2c_ack = 1'b1;//拉高应答标志位，表示传输错误
                            end
                        end 
                default:;
            endcase
        end
        st_addr8  :begin
            sda_dir = 1'b1;
            case (dri_cnt)
                8'd0  : sda_out = addr_t[7];
                8'd4  : sda_out = addr_t[6];
                8'd8  : sda_out = addr_t[5];
                8'd12 : sda_out = addr_t[4];
                8'd16 : sda_out = addr_t[3];
                8'd20 : sda_out = addr_t[2];
                8'd24 : sda_out = addr_t[1];
                8'd28 : sda_out = addr_t[0];
                8'd32 : sda_dir = 1'b0;//释放主机对sda信号的控制 
                8'd34 : begin//检测应答3
                            st_done = 1'b1;
                            if (sda_in == 1'b1) begin//如果从机应答信号为 1 
                                    i2c_ack = 1'b1;//拉高应答标志位，表示传输错误
                            end
                        end 
                default:;
            endcase
        end
        st_data_wr:begin
            sda_dir = 1'b1;
            data_wr_t = i2c_data_w ;
            case (dri_cnt)
                8'd0  : sda_out = data_wr_t[7];
                8'd4  : sda_out = data_wr_t[6];
                8'd8  : sda_out = data_wr_t[5];
                8'd12 : sda_out = data_wr_t[4];
                8'd16 : sda_out = data_wr_t[3];
                8'd20 : sda_out = data_wr_t[2];
                8'd24 : sda_out = data_wr_t[1];
                8'd28 : sda_out = data_wr_t[0];
                8'd32 : sda_dir = 1'b0;//释放主机对sda信号的控制 
                8'd34 : begin //检测应答4
                            st_done = 1'b1;
                            if (sda_in == 1'b1) begin//如果从机应答信号为 1 
                                    i2c_ack = 1'b1;//拉高应答标志位，表示传输错误
                            end
                        end 
                default:;
            endcase
        end
        st_stop   :begin
            sda_dir = 1'b1;
            case (dri_cnt)
                0: sda_out  = 1'b0;
                1: sda_out  = 1'b1;
                4: st_done  = 1'b1;
                8: i2c_done = 1'b1;
                default: ;
            endcase
        end
        st_addr_rd:begin
            sda_dir = 1'b1;
            case (dri_cnt)
                8'd1  : sda_out = slave_addr[6];
                8'd4  : sda_out = slave_addr[5];
                8'd8  : sda_out = slave_addr[4];
                8'd12 : sda_out = slave_addr[3];
                8'd16 : sda_out = slave_addr[2];
                8'd20 : sda_out = slave_addr[1];
                8'd24 : sda_out = slave_addr[0];
                8'd28 : sda_out = 0;//写命令
                8'd32 : sda_dir = 1'b0;//释放主机对sda信号的控制 
                8'd34 : begin//检测应答1
                    st_done = 1'b1;
                    if (sda_in == 1'b1) begin//如果从机应答信号为 1 
                            i2c_ack = 1'b1;//拉高应答标志位，表示传输错误
                    end
                end 
                default:;
            endcase
        end
        st_data_rd:begin
            sda_dir = 1'b0;//释放主机对sda信号的控制
            case (dri_cnt)
                8'd0  : data_r[7] = sda_in ; 
                8'd4  : data_r[6] = sda_in ; 
                8'd8  : data_r[5] = sda_in ; 
                8'd12 : data_r[4] = sda_in ; 
                8'd16 : data_r[3] = sda_in ; 
                8'd20 : data_r[2] = sda_in ; 
                8'd24 : data_r[1] = sda_in ; 
                8'd28 : data_r[0] = sda_in ; 
                8'd30 : begin//检测应答1
                    i2c_data_r = data_r;
                    st_done = 1'b1;
                    if (sda_in == 1'b1) begin//如果从机应答信号为 1 
                            i2c_ack = 1'b1;//拉高应答标志位，表示传输错误
                    end
                end 
                default:;
            endcase
         end
        default: ;
    endcase              
 end

endmodule

```
## e2prom_rw.v
```c
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
            if (i2c_data_r == i2c_data_w) begin
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
```
## led_alarm.v
```c
module alarm (
    input           clk                 ,
    input           rst_n               ,
    input           rw_done             ,
    input           rw_result           ,     
    
    output  reg     led
);
/*-----------------led----------------*/ 
 always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        led <= 1'd0;
    end
    else if (rw_done) begin
        if (rw_result) begin
            led <= 1'd1;
        end
        else if (!rw_done) begin
            if (cnt_500ms == time_500ms - 1) begin
                led <= ~led;
            end            
        end           
    end
 end  
/*-----------------cnt_500ms----------------*/ 
 parameter time_500ms = 25_000_000; 
 reg [24:0] cnt_500ms;
 always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_500ms <= 25'd0;
    end
    else if (cnt_500ms == time_500ms - 1) begin
        cnt_500ms <= 25'd0;
    end
    else 
        cnt_500ms <= cnt_500ms + 25'd1;
 end
endmodule
```
## e2prom_top.v
```c
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
```
  
