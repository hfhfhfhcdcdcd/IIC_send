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
   //  reg                   dri_clk         ;// iicģ�������ʱ��
   //  reg                   i2c_ack         ;// iicģ�������Ӧ���ź�
   //  reg        [7:0]      i2c_data_r      ;// ��iicģ�� ����������
   //  reg                   i2c_done        ;// iicģ������ġ�һ�����ݴ�����done�ź�

//    wire       [15:0]     i2c_addr        ;// E2PROM�� FPGAд�� 16bit �洢��Ԫ��ַ
//    wire       [7:0]      i2c_data_w      ;//
//    wire                  i2c_exec        ;
//    wire                  bit_ctrl        ;
//    wire                  i2c_rh_wl       ;
  /*  wire                  rw_done         ;
    wire                  rw_result       ;*/
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