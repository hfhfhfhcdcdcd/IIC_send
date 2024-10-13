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