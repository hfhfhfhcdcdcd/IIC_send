module i2c_tb;

    reg               bit_ctrl        ;// bit_ctrl==0,send 4 bit �洢��Ԫ��ַ, bit_ctrl==1,send 16 bit �洢��Ԫ��ַ
    reg               clk             ;// 50MHz
    reg [15:0]        i2c_addr        ;// 16 bit �洢��Ԫ��ַ 
    reg [7:0]         i2c_data_w      ;// FPGA��E2PROMд��4bit����
    reg               i2c_exec        ;// һ�������ź�
    reg               i2c_rh_wl       ;// ����FPGA����E2PROMд���Ƕ����ߵ�ƽ�����͵�ƽд
    reg               rst_n           ;

    wire          dri_clk             ;//��50Mhz�Ļ�����ΪIIC�ṩ����ʱ��
    wire          scl                 ;//IIC����ʱ�Ĺ���ʱ��
    wire          i2c_ack             ;//IIC��Ӧ���ź�
    wire [7:0]    i2c_data_r          ;//FPGA��E2PROM���õ�����
    wire          i2c_done            ;
    wire          sda                 ;

i2c_dri i1(
    .  bit_ctrl      (bit_ctrl  )  ,// bit_ctrl==0,send 4 bit �洢��Ԫ��ַ, bit_ctrl==1,send 16 bit �洢��Ԫ��ַ
    .  clk           (clk       )  ,// 50MHz
    .  i2c_addr      (i2c_addr  )  ,// 16 bit �洢��Ԫ��ַ 
    .  i2c_data_w    (i2c_data_w)  ,// FPGA��E2PROMд��4bit����
    .  i2c_exec      (i2c_exec  )  ,// һ�������ź�
    .  i2c_rh_wl     (i2c_rh_wl )  ,// ����FPGA����E2PROMд���Ƕ����ߵ�ƽ�����͵�ƽд
    .  rst_n         (rst_n     )  ,

    .  dri_clk       (dri_clk   )  ,//��50Mhz�Ļ�����ΪIIC�ṩ����ʱ��
    .  scl           (scl       )  ,//IIC����ʱ�Ĺ���ʱ��
    .  i2c_ack       (i2c_ack   )  ,//IIC��Ӧ���ź�
    .  i2c_data_r    (i2c_data_r)  ,//FPGA��E2PROM���õ�����
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