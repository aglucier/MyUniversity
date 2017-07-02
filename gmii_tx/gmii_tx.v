module gmii_tx(
    clk_125m,
    txd     ,
    tx_en   ,
    tx_er   ,
    rst_n
);

`define IDLE 0
`define DATA 1
`define CRC  2
`define IFS  3

parameter ROM_DEP = 8'd255  ;
parameter ROM_CHG = 4'd8    ;
parameter CRC_CNT = 2'd3    ;
parameter IFS_CNT = 14'd10;

input clk_125m,rst_n  ;
output reg [7:0] txd ;
output reg  tx_en     ;
output wire tx_er     ;

reg  [1:0]  state_c, state_n;   //״̬����ǰ״̬����һ��״̬
reg         crc_en,crc_rst  ;   //crcʹ�ܣ�У��
reg         tx_en_tmp0      ;   //����ʹ��
reg         tx_en_tmp1      ;   //����ʹ���źţ���һ��
reg         idle,delay_cnt  ;   //idleΪ1��ʾ���źŸ�λ���ϣ�������`DATA״̬��delay_cnt����1������`CRC״̬
reg         delay_cnt_tmp0  ;   //delay_cnt_tmp0����1ʱ��ȡcrc_out��ֵ
reg         crcins_flag     ;   //��ʾcrc�ɲ����ź�
reg  [7:0]  rom_addr        ;   //rom��ַ
reg  [7:0]  txd_tmp0        ;   //�����ź�
reg  [7:0]  txd_tmp1        ;   //�������ݴ�һ��
reg  [1:0]  crc_cnt         ;   //4��ʱ����������`CRC
reg  [1:0]  crc_ins_cnt     ;   //crc����������
reg  [31:0] crc_out_tmp     ;   //����CRC���ս�����ֵ���ȴ���������֡��
reg  [13:0]  ifs_cnt        ;   //֡ʱ������������
wire [31:0] crc_out			;   //crc���� 
wire [7:0]  rom_data        ;   //rom�ж�ȡ������

crc u0(
   .data_in(rom_data),
   .crc_en (crc_en  ),
   .crc_out(crc_out ),
   .crc_rst(crc_rst ),
   .rst_n  (rst_n   ),
   .clk    (clk_125m) 
);

rom	u1(                    
	.address(rom_addr),
	.clock  (clk_125m),
	.q      (rom_data)	
);

always  @(posedge clk_125m or negedge rst_n)begin  //����ʽ״̬�� 
    if(rst_n==1'b0)begin
        state_c <= `IDLE;
    end
    else begin
        state_c <= state_n;
    end
end

always  @(*)begin  
    if(!rst_n)
        state_n = 1'b0;
    else begin
        case(state_c)
            `IDLE: if(idle==1'b1) begin
                       state_n = `DATA;
                   end
                   else begin
                       state_n = `IDLE;
                   end
            `DATA: if(delay_cnt==1) begin
                       state_n = `CRC;
                   end
                   else begin 
                       state_n = `DATA; 
                   end
            `CRC:  if(crc_cnt==CRC_CNT) begin
                       state_n = `IFS;
                   end
                   else begin
                       state_n = `CRC;
                   end
            `IFS:  if(ifs_cnt==IFS_CNT) begin
                       state_n = `IDLE;
                   end
                   else begin
                       state_n = `IFS;          
                   end
                   default: state_n = `IDLE;
        endcase
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //rom��ַ����`DATA״̬���ϼ�һ
    if(rst_n==1'b0)begin
        rom_addr <= 1'b0;
    end
    else if(state_c==`DATA) begin
        if(rom_addr==ROM_DEP) begin
            rom_addr <= 1'b0;
        end 
        else begin
            rom_addr <= rom_addr + 1'b1;
        end
    end
    else begin
        rom_addr <= 1'b0;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin  //idleΪ1����ʾ���ź��Ѹ�λ�����Է����µ�һ֡ 
    if(rst_n==1'b0)begin
        idle <= 1'b0;
    end
    else if(rom_addr==0&&crc_en==0&&crc_rst==0&&tx_en_tmp0==0&&crc_cnt==0&&ifs_cnt==0&&tx_er==0) begin
        idle <= 1'b1;
    end
    else begin
        idle <= 1'b0;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //CRCʹ���ź�
    if(rst_n==1'b0)begin
        crc_en <= 1'b0;
    end
    else if(state_c==`DATA&&delay_cnt!=1) begin
        if(rom_addr==ROM_CHG) begin
            crc_en <= 1'b1; 
        end
        else begin
            crc_en <= crc_en;
        end
    end
    else begin
        crc_en <= 1'b0; 
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //CRC��λ�ź�
    if(rst_n==1'b0)begin
        crc_rst <= 1'b0;
    end
    else if(crc_cnt==3) begin
        crc_rst <= 1'b1;  
    end
    else begin
        crc_rst <= 1'b0;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //����ʹ�ܣ���`DATA��`CRC״̬��Ϊ1
    if(rst_n==1'b0)begin
        tx_en_tmp0 <= 1'b0;
    end
    else if(state_c==`DATA||state_c==`CRC) begin
        tx_en_tmp0 <= 1'b1;
    end
    else begin
        tx_en_tmp0 <= 1'b0;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //��һ�ģ���txd�źŶ���
    if(rst_n==1'b0)begin
        tx_en_tmp1 <= 1'b0;
        tx_en      <= 1'b0;
    end
    else begin
        tx_en_tmp1 <= tx_en_tmp0;
        tx_en      <= tx_en_tmp1;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //delay_cntΪ1ʱ״̬��`DATA״̬��ת��`CRC״̬
    if(rst_n==1'b0)begin                            //delay_cnt_tmp0Ϊ1ʱȡcrc_out��ֵ
        delay_cnt <= 1'b0;
        delay_cnt_tmp0 <= 1'b0;
    end
    else if(rom_addr==ROM_DEP) begin
        delay_cnt <= 1'b1;
    end
    else begin
        delay_cnt <= 1'b0;
        delay_cnt_tmp0 <= delay_cnt;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //Ϊ1ʱ��ʼ����crc_ins_cnt����tx_en_tmp1�в���crc���ս���
    if(rst_n==1'b0)begin
        crcins_flag <= 1'b0;
    end
    else if(delay_cnt_tmp0==1) begin
        crcins_flag <= 1'b1;
    end
    else if (state_c==`IDLE||crc_ins_cnt==3) begin
        crcins_flag <= 1'b0;
    end
    else begin
        crcins_flag <= crcins_flag;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //��ȡrom�е�ֵ
    if(rst_n==1'b0)begin
        txd_tmp0 <= 1'b0;
    end
    else if(state_c==`DATA&&tx_en_tmp0==1) begin
        txd_tmp0 <= rom_data;
    end
    else begin
        txd_tmp0 <= 1'b0;    
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //txd�źŴ�һ�ģ�����CRC
    if(rst_n==1'b0)begin
        txd_tmp1 <= 1'b0;
    end
    else if(crcins_flag==1) begin
        case(crc_ins_cnt)
            0 : txd_tmp1 <= crc_out_tmp[7:0];
            1 : txd_tmp1 <= crc_out_tmp[15:8];
            2 : txd_tmp1 <= crc_out_tmp[23:16];
            3 : txd_tmp1 <= crc_out_tmp[31:24];
            default : txd_tmp1 <= 8'hff;
        endcase
    end
    else begin
        txd_tmp1 <= txd_tmp0;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //��`CRC״̬�¼�����4��CRC���ս���������������`IFS״̬
    if(rst_n==1'b0)begin
        crc_cnt <= 1'b0;
    end
    else if(state_c==`CRC) begin
        if(crc_cnt==CRC_CNT) begin
            crc_cnt <= 1'b0;
        end
        else begin
            crc_cnt <= crc_cnt + 1'b1;
        end
    end
    else begin
        crc_cnt <= 1'b0;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin    //����CRC���ս����ļ�����
    if(rst_n==1'b0)begin
        crc_ins_cnt <= 1'b0;
    end
    else if(crcins_flag==1) begin
        if(crc_ins_cnt==4) begin
            crc_ins_cnt <= 1'b0;
        end
        else begin
            crc_ins_cnt <= crc_ins_cnt + 1'b1;
        end
    end
    else begin
        crc_ins_cnt <= 1'b0;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //����CRC���ս������ȴ�����
    if(rst_n==1'b0)begin
        crc_out_tmp <= 1'b0;
    end
    else if(delay_cnt_tmp0==1) begin
        crc_out_tmp <= crc_out;
    end
    else if(state_c==`IDLE) begin
        crc_out_tmp <= 1'b0;
    end
    else begin
        crc_out_tmp <= crc_out_tmp;
    end
end

always  @(posedge clk_125m or negedge rst_n)begin   //�����ź�
    if(rst_n==1'b0)begin
        txd <= 1'b0;
    end
    else if(tx_en==1) begin
        txd <= txd_tmp1;
    end
    else begin
        txd <= 1'b0;
    end
end

assign tx_er = 1'b0;

always  @(posedge clk_125m or negedge rst_n)begin   //֡ʱ������
    if(rst_n==1'b0)begin
        ifs_cnt <= 1'b0;
    end
    else if(state_c==`IFS) begin
        if(ifs_cnt==IFS_CNT) begin
            ifs_cnt <= 1'b0;
        end
        else begin
            ifs_cnt <= ifs_cnt + 1'b1;
        end
    end
    else begin
        ifs_cnt <= 1'b0;
    end
end

endmodule
