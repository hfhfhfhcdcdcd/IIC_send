    121   122   123    124   125  126   127    128   129  130   131   132   133   134    135   136   137   138   139   140  141   142   143    144   145  146   147    148   149  150   151   152   153   154   155   156   157   158   159   160    161   162   163   164   165  166   167   168   169

   e2prom_rw ���ģ������ã��������洢fpga��e2prom���������ݡ��Լ�fpgaд��e2prom�е����ݵġ�

  ����I2Cģ��Ļ���ֻ��д��һ����ѭI2Cͨ��Э���ʱ��ģ�飬�൱�ڽ������һ��ͨ��ģ�飬���������������洫����С�

  @[toc]
# һ������IICͨ��
* IICͨ�ŵ�����㣺���������д����ߣ�scl = => IICͨ�ŵ�ʱ�ӣ�sda = =>IICͨ�ŵĴ������ݵ��ߡ�
* IICЭ��㣺IICͨ�����1�εĹ��̿��Է�Ϊ4���֣�
  *  �� scl��sdaδ�շ����ݵĳ�ʼ״̬��
  *  �� scl��sda��ʼ�շ����ݵĴ���������
  *  �� scl��sda����շ����ݵ�״̬��
  *  �� scl��sda�����շ����ݵ���ɶ�����
  ![���������ͼƬ����](https://i-blog.csdnimg.cn/direct/a3632a3e029e49b284c4cd2b98d5a13c.png)


�۾���IIC��E2PROMд���ݺͶ����ݵ�һ�Ρ�
# ����д���ݺͶ�����Ҳ��Ϊ��ͬ��ģʽ��
д�����У�
* �ֽ�д������д

���У�
* ��ǰ��ַ��
* �����
* ��ǰ��ַ������
* �����ַ������
# ������ϸ���ܶ�д
* д��
  * �ֽ�д��
    * FPGAоƬ����1����ʼ�źš�Ҳ������scl�ߵ�ƽ��ʱ�򣬽�sda���͡�
    * FPGA����7λ������ַ��FPGA����д����λ(Ҳ����0)��-------> �ӻ��յ���Ӧ��Ӧ��λ��һλ�͵�ƽ
    * FPGA����16bit�ֵ�ַ����Ϊ2��8bit�����ͣ��ȷ����ֵ�ַ�ĸ�8bit ( addr[15]��addr[14]......addr[8] ) ;�ٷ����ֵ�ַ�ĵ�8bit ( addr[7] �� addr[6]......addr[0] )�� -------> �ӻ��յ��ֵ�ַ�ĸ�8bit��FPGA����Ӧ��λ���ӻ��յ��ֵ�ַ�ĵ�8bit��FPGA����Ӧ��λ��
    * FPGA����8bit���ݡ�-------> �ӻ��յ���Ӧ��Ӧ��λ��һλ�͵�ƽ��
    * FPGA����1λ�����źš�-------->Ҳ������scl�ߵ�ƽ��ʱ�򣬽�sda���ߡ�
    ![���������ͼƬ����](https://i-blog.csdnimg.cn/direct/b3e5444fab0d4e44883047f11f9d6eee.png)

  * ����д��
    *  ���ϱߵ�����������ڣ� �� FPGA����8bit���� �� �ⲿ�֡�����д����E2PROM��˵Ҳ��ҳд���������һ��8bit����֮����Լ�����������n���ֽڡ�ֱ��sda����Ϊֹ����scl�ߵ�ƽ��״̬�£���������Ŵ��������
  ![���������ͼƬ����](https://i-blog.csdnimg.cn/direct/a46b4fd9c0e943c89b75d9ded965e23f.png)

* ����
  *  ��ǰ��ַ����
     * FPGA������ʼ�źţ�
     * FPGA��ӻ�����7λ������ַ + 1λ�����1����-------->�ӻ�����1λӦ��λ��
     * �ӻ�����8λ���ݸ�FPGA��----------> ��������һλ����Ӧ��λ����1����
     * FPGA�Ƚ�sda�����ٽ�sda���ߡ�
     ![���������ͼƬ����](https://i-blog.csdnimg.cn/direct/43dda2a23b5447cebae983c1bc9a205d.png)

  *  ������������ֽ�д��ǰ������һ��һ���ģ�
     * FPGAоƬ����1����ʼ�źš�Ҳ������scl�ߵ�ƽ��ʱ�򣬽�sda���͡�
     * FPGA����7λ������ַ��FPGA����д����λ(Ҳ����0)��-------> �ӻ��յ���Ӧ��Ӧ��λ��һλ�͵�ƽ
     * FPGA����16bit�ֵ�ַ��-------> �ӻ��յ���Ӧ��
     * ��һ��������Ĳ�����֮ǰ�ġ� ��ǰ�� �� ��һ���ˣ�
     	* FPGAоƬ�ٷ���1����ʼ�źš�
    	* FPGA��ӻ�����7λ������ַ + 1λ�����1����-------->�ӻ�����1λӦ��λ��
     	* �ӻ�����8λ���ݸ�FPGA��----------> ��������һλ����Ӧ��λ����1����
     	* FPGA�Ƚ�sda�����ٽ�sda���ߡ�
  # �ġ�ģ�����
  
  ģ������|˵��
   :----|:----
   i2c_dri.v|��IICЭ��Ҫ�һ���ȿ��Զ����ݣ�Ҳ����д���ݾݵ�ģ�顣����Ķ�дIICʱ��Ҫд�����ģ���
    e2prom_rw.v |ͨ��IICЭ���FPGAд��E2PROM�ĵ�ַ�����ݡ���ʼ�����źţ���Щ����ҪPFPGA�����ר�Ŵ洢���ݵ�ģ�鴫��E2PROM��FPGA��E2PROM����������Ҳ�浽���ģ�����档
     led_alarm.v |���FPGAд��E2PROM������ݾ���FPGA��E2PROM����������һ������led��������ͬ����˸�����ģ������������led�ġ�
    e2prom_top.v  |����ģ������������ģ�顣
    
# �塢����
## i2c_dri.v
```c
module i2c_dri (
    input               bit_ctrl        ,// bit_ctrl==0,send 4 bit �洢��Ԫ��ַ, bit_ctrl==1,send 16 bit �洢��Ԫ��ַ
    input               clk             ,// 50MHz
    input [15:0]        i2c_addr        ,// 16 bit �洢��Ԫ��ַ 
    input [7:0]         i2c_data_w      ,// FPGA��E2PROMд��8bit����
    input               i2c_exec        ,// һ�������ź�
    input               i2c_rh_wl       ,// ����FPGA����E2PROMд���Ƕ����ߵ�ƽ�����͵�ƽд
    input               rst_n           ,
    
    output reg          dri_clk         ,//��50Mhz�Ļ�����ΪIIC�ṩ����ʱ��
    output reg          scl             ,//IIC����ʱ�Ĺ���ʱ��
    output reg          i2c_ack         ,//IIC��Ӧ���ź�
    output reg [7:0]    i2c_data_r      ,//FPGA��E2PROM���õ�����
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
 parameter SYS_CLK = 50_000_000;  // ϵͳʱ�ӵ�Ƶ��  
 parameter SCL_CLK = 250_000; // IIC������ʱ��Ƶ�ʣ���Ӧ�˿��е�scl
/*----------------------------------------define------------------------------------*/
 reg  [7:0]       dri_cnt              ; 
 reg              cur_state            ;    
 reg              next_state           ;    
 reg  [7:0]       div_clk_200_cnt      ;        
 reg  [9:0]       scl_800_cnt          ;    
 reg              wr_flag              ;
 reg  [15:0]      addr_t               ;//����˿�i2c_addr ���� 16bit�ļĴ���        
 reg  [7:0]       data_wr_t            ;//i2c_data_w ���� 8bit���ݵļĴ��� 
 reg  [7:0]       data_r               ;//i2c_data_r ���� 8bit���ݵļĴ���
 reg              st_done              ;//��־�źţ��洢��Ԫ����λ��ַ�Ѿ����͵���fpga��
/*-------------------------------------sda��assign-----------------------------------*/
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
/*----------------------------------------sclʱ��---------------------------------------------*/
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
/*--------------------------------------״̬����1��--------------------------------------*/
 always@(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_state <= st_idle;
    end
    else    
        cur_state <= next_state;
 end
/*--------------------------------------״̬����2��-----------------------------------------*/
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
/*--------------------------------------״̬����3��-------------------------------------*/
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
                8'd32 : sda_out = 0;//д����
                8'd36 : sda_dir = 1'b0;//�ͷ�������sda�źŵĿ���
                8'd38 : begin//���Ӧ��1
                    st_done = 1'b1;
                    if (sda_in == 1'b1) begin//����ӻ�Ӧ���ź�Ϊ 1 
                            i2c_ack <= 1'b1;//����Ӧ���־λ����ʾ�������
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
                8'd32 : sda_dir = 1'b0;//�ͷ�������sda�źŵĿ��� 
                8'd34 : begin//���Ӧ��2
                            st_done = 1'b1;
                            if (sda_in == 1'b1) begin//����ӻ�Ӧ���ź�Ϊ 1 
                                    i2c_ack = 1'b1;//����Ӧ���־λ����ʾ�������
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
                8'd32 : sda_dir = 1'b0;//�ͷ�������sda�źŵĿ��� 
                8'd34 : begin//���Ӧ��3
                            st_done = 1'b1;
                            if (sda_in == 1'b1) begin//����ӻ�Ӧ���ź�Ϊ 1 
                                    i2c_ack = 1'b1;//����Ӧ���־λ����ʾ�������
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
                8'd32 : sda_dir = 1'b0;//�ͷ�������sda�źŵĿ��� 
                8'd34 : begin //���Ӧ��4
                            st_done = 1'b1;
                            if (sda_in == 1'b1) begin//����ӻ�Ӧ���ź�Ϊ 1 
                                    i2c_ack = 1'b1;//����Ӧ���־λ����ʾ�������
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
                8'd28 : sda_out = 0;//д����
                8'd32 : sda_dir = 1'b0;//�ͷ�������sda�źŵĿ��� 
                8'd34 : begin//���Ӧ��1
                    st_done = 1'b1;
                    if (sda_in == 1'b1) begin//����ӻ�Ӧ���ź�Ϊ 1 
                            i2c_ack = 1'b1;//����Ӧ���־λ����ʾ�������
                    end
                end 
                default:;
            endcase
        end
        st_data_rd:begin
            sda_dir = 1'b0;//�ͷ�������sda�źŵĿ���
            case (dri_cnt)
                8'd0  : data_r[7] = sda_in ; 
                8'd4  : data_r[6] = sda_in ; 
                8'd8  : data_r[5] = sda_in ; 
                8'd12 : data_r[4] = sda_in ; 
                8'd16 : data_r[3] = sda_in ; 
                8'd20 : data_r[2] = sda_in ; 
                8'd24 : data_r[1] = sda_in ; 
                8'd28 : data_r[0] = sda_in ; 
                8'd30 : begin//���Ӧ��1
                    i2c_data_r = data_r;
                    st_done = 1'b1;
                    if (sda_in == 1'b1) begin//����ӻ�Ӧ���ź�Ϊ 1 
                            i2c_ack = 1'b1;//����Ӧ���־λ����ʾ�������
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
    input                   dri_clk         ,// iicģ�������ʱ��
    input                   i2c_ack         ,// iicģ�������Ӧ���ź�
    input        [7:0]      i2c_data_r      ,// ��iicģ�� ����������
    input                   i2c_done        ,// iicģ������ġ�һ�����ݴ�����done�ź�
    input                   rst_n           ,

    output  reg  [15:0]     i2c_addr        ,// E2PROM�� FPGAд�� 16bit �洢��Ԫ��ַ
    output  reg  [7:0]      i2c_data_w      ,//
    output  reg             i2c_exec        ,
    output  wire            bit_ctrl        ,
    output  reg             i2c_rh_wl       ,
    output  reg             rw_done         ,
    output  reg             rw_result 
);
/*------------------------i2c_addr---------------------*/
 //�� 16 bit �Ĵ浥Ԫ��ַ
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_addr <= 16'd0;
    end
    else if (i2c_exec) begin//��������ź�����
        if (i2c_addr == 256) begin//ÿ��д1����ַ��1����ַ��16bit��Ҫд256��
            i2c_addr <= 16'd0;
        end
        else 
            i2c_addr <= i2c_addr + 16'd1;
    end
    else
        i2c_addr <= i2c_addr;
 end
/*------------------------auto_w_to_r---------------------*/
 //д�ĵ�ַ�ﵽ256֮���Զ���ʼ���źţ�auto_w_to_r�����Ǹ���־�ź�
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
 //�� 8bit����
 always @(posedge dri_clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_data_w <= 8'd0;
    end
    else if (i2c_exec) begin//��������ź�����
        if (i2c_data_w == 255) begin//ÿ��д1�����ݣ�1��������8bit��Ҫд256��
            i2c_data_w <= 8'd0;
        end
        else 
            i2c_data_w <= i2c_data_w + 8'd1;
    end
    else
        i2c_data_w <= i2c_data_w;
 end
/*------------------------i2c_exec_cnt---------------------*/
 //����i2c_exec��5ms������
 parameter time_5ms = 250_000;
 reg [17:0] i2c_exec_cnt;//250_000��Ӧ5ms,ÿ�ǵ�5ms��ʱ�����㡣ÿ����һ������һ�δ����ź�
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
 //�����ź�
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
 //���ƼĴ浥Ԫ��λ����1 => 16 bit,   0 => 8 bit
 assign bit_ctrl = 1'b1;
/*------------------------i2c_rh_wl---------------------*/
 //����II2Cģ��Ķ�����д��0 => д�� 1 => ��
 always @(posedge dri_clk or negedge rst_n) begin
 if (!rst_n) begin
    i2c_rh_wl <= 1'b0;//д�ź�
 end
 else if (auto_w_to_r) begin
    i2c_rh_wl <= 1'b1;//���ź�
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
    else if((i2c_rh_wl)&&(i2c_exec)) begin//��������ź�����
        if (compare_cnt == 256) begin//ÿ��д1����ַ��1����ַ��16bit��Ҫд256��
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
    . bit_ctrl      (bit_ctrl  )      ,// bit_ctrl==0,send 4 bit �洢��Ԫ��ַ, bit_ctrl==1,send 16 bit �洢��Ԫ��ַ
    . clk           (clk       )      ,// 50MHz
    . i2c_addr      (i2c_addr  )      ,// 16 bit �洢��Ԫ��ַ 
    . i2c_data_w    (i2c_data_w)      ,// FPGA��E2PROMд��8bit����
    . i2c_exec      (i2c_exec  )      ,// һ�������ź�
    . i2c_rh_wl     (i2c_rh_wl )      ,// ����FPGA����E2PROMд���Ƕ����ߵ�ƽ�����͵�ƽд
    . rst_n         (rst_n     )      ,

    . dri_clk       (dri_clk   )      ,//��50Mhz�Ļ�����ΪIIC�ṩ����ʱ��
    . scl           (scl       )      ,//IIC����ʱ�Ĺ���ʱ��
    . i2c_ack       (i2c_ack   )      ,//IIC��Ӧ���ź�
    . i2c_data_r    (i2c_data_r)      ,//FPGA��E2PROM���õ�����
    . i2c_done      (i2c_done  )      ,
    . sda           (sda       )      
 );
/*==================================e2prom_rw===============================*/
 defparam e1.time_5ms=25;//500ns  
 e2prom_rw e1(
    .  dri_clk              (dri_clk   )      ,// iicģ�������ʱ��
    .  i2c_ack              (i2c_ack   )      ,// iicģ�������Ӧ���ź�
    .  i2c_data_r           (i2c_data_r)      ,// ��iicģ�� ����������
    .  i2c_done             (i2c_done  )      ,// iicģ������ġ�һ�����ݴ�����done�ź�
    .  rst_n                (rst_n     )      ,
    .  i2c_addr             (i2c_addr  )      ,// E2PROM�� FPGAд�� 16bit �洢��Ԫ��ַ
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
  
