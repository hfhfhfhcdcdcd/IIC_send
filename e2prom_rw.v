module  (
    input                   clk             ,// iicģ�������ʱ��
    input                   i2c_ack         ,// iicģ�������Ӧ���ź�
    input        [7:0]      i2c_data_r      ,// ��  iicģ�� ����������
    input                   i2c_done        ,// iicģ������ġ�һ�����ݴ�����done�ź�
    input                   rst_n           ,

    output  reg  [15:0]     i2c_addr        ,//E2PROM�� FPGAд�� 16bit �洢��Ԫ��ַ
    output  reg  [7:0]      i2c_data_w      ,//
    output  reg             i2c_exec        ,
    output  reg             i2c_rh_wl       ,
    output  reg             rw_done         ,
    output  reg             rw_result 
);
    
endmodule