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
