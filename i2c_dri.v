module i2c_dri (
    input               bit_ctrl        ,// bit_ctrl==0,send 4 bit 存储单元地址, bit_ctrl==1,send 16 bit 存储单元地址
    input               clk             ,// 50MHz
    input [15:0]        i2c_addr        ,// 16 bit 存储单元地址 
    input [7:0]         i2c_data_w      ,// FPGA向E2PROM写的4bit数据
    input               i2c_exec        ,// 一个脉冲信号
    input               i2c_rh_wl       ,// 控制FPGA是向E2PROM写还是读，高电平读；低电平写
    input               rst_n           ,
    
    output reg          dri_clk         ,//在50Mhz的基础上为IIC提供工作时钟
    output reg          scl             ,//IIC工作时的工作时钟
    output reg          i2c_ack         ,//IIC的应答信号
    output reg [7:0]    i2c_data_r      ,//FPGA从E2PROM读得的数据
    output reg          i2c_done        ,
    output reg          sda             
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

parameter SYS_CLK = 50_000_000;  // 系统时钟的频率  
parameter SCL_CLK = 250_000; // IIC工作的时钟频率，对应端口中的scl
/*----------------------------------------reg define------------------------------------*/
reg sda_out ;
wire sda_in ;
reg sda_dir ;
reg [7:0] sda_cnt ;
reg cur_state  ;
reg next_state ;
reg [7:0]div_clk_200_cnt;
reg [9:0]scl_800_cnt;
reg wr_flag;
reg st_done    ;//标志信号：存储单元高五位地址已经发送到了fpga上
/*-------------------------------------sda的assign-----------------------------------*/
//assign sda = (sda_dir) ? sda_out : 1'bz ;
//assign sda_in = sda ;
/*-------------------------------------div_clk_200_cnt-----------------------------------*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_clk_200_cnt <= 0;
    end
    else if (div_clk_200_cnt == (200/2)-1) begin
        div_clk_200_cnt<=0;
    end
    else 
        div_clk_200_cnt <= div_clk_200_cnt + 1;
end
/*----------------------------------------scl_800_cnt---------------------------------*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        scl_800_cnt <= 0;
    end
    else if (scl_800_cnt == (800/2)-1) begin
        scl_800_cnt<=0;
    end
    else 
        scl_800_cnt <= scl_800_cnt + 1;
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
/*----------------------------------------sda_cnt---------------------------------------------*/
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        sda_cnt <= 8'd0;
    end
    else if (sda_cnt == 148) begin
        sda_cnt <= 8'd0;
    end
    else
        sda_cnt <= sda_cnt + 1;
 end
/*-------------------------------------状态机第1段--------------------------------------*/
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
                if (i2c_exec==1) begin
                    next_state = st_sladdr;
                end
                else
                    next_state = cur_state;
            end 
            st_sladdr  :begin
                if (bit_ctrl==1) begin
                    next_state = st_addr8;
                end
                else if (bit_ctrl==0) begin
                    next_state = st_addr16;
                end
                else
                    next_state = cur_state;
            end 
            st_addr16  :begin
                if (st_done ==1) begin
                    next_state = st_addr8;
                end
                else
                    next_state = cur_state;
            end 
            st_addr8   :begin
                if (wr_flag ==0) begin
                    next_state = st_data_wr;
                end
                else if (wr_flag==1) begin
                    next_state = st_data_rd;
                end
                else
                    next_state = cur_state;
            end 
            st_data_wr :begin
                if (st_done ==1) begin
                    next_state = st_stop;
                end
                else
                    next_state = cur_state;
            end 
            st_stop    :begin
                if (st_done ==1) begin
                    next_state = st_idle;
                end
                else
                    next_state = cur_state;
            end 
            st_addr_rd :begin
                if (st_done ==1) begin
                    next_state = st_data_rd;
                end
                else
                    next_state = cur_state;
            end 
            st_data_rd :begin
                if (st_done ==1) begin
                    next_state = st_stop;
                end
                else
                    next_state = cur_state;
            end 
            default: ;
        endcase
end
/*----------------------------------状态机第3段-------------------------------------*/
always @(*) begin
    if (!rst_n) begin
        sda=1'b1;
    end
    else if ((scl)&&(sda_cnt==1)) begin
        sda_cnt=0;
    end
    else case (sda_cnt)
        4,12,64,100,138:sda=1;
        96,132:sda=0;
        default: sda=sda;
    endcase


end
endmodule
