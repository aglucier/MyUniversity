//rxc: ��������ʱ�ӣ���8212f�ṩ;
//rxd: ������������
//rxdv:�������ݳ��������������ϣ���8212f�ṩ��
//RAM_Dataout: ��RAM�������ݣ��͵�8212f���Ͷ˿�
//Data_Avl: Ϊ1��ʾBuffer�������ݿɶ�
//RAM_Clk_Read: ��RAMʱ�ӣ���Ӧ��8212f����ʱ��ͬ��
//RST: ϵͳ��λ��ʹ��PLL��locked��Ϊϵͳ��λ�źţ��͵�ƽ��Ч
module rxdata(rxc,rxd,rxdv,RAM_Dataout, New_Frame, RAM_Clk_Read, RD_EN, FIFO_Data_Num, RST, flag_crc);
input rxc,rxdv;
input[3:0]rxd;
input RAM_Clk_Read;
input RST;
input RD_EN;//Ϊ1�ɶ�ȡFIFO�����ݣ�Ϊ0ʱ�ɵȴ�����ʱ���
wire [7:0] RAM0_Dataout, RAM1_Dataout;//RAMx��q�ˣ��������
output New_Frame;//��ʼ��һ��֡
output [7:0] RAM_Dataout;
output [10:0] FIFO_Data_Num;//��ǰFIFO�л�û��ȡ�����ݸ���
output flag_crc;
wire [7:0] Data_Rev_From_8212f;//��8212f���յ�������
reg RAM0_Frame_Inside, RAM1_Frame_Inside;//RAM0_Frame_Inside: Ϊ0��RAM0�������ݻ����ڴ洢���ݣ��յ�����̫������֡�ɴ����RAM0��Ϊ1��RAM0�а���һ����̫��֡����û����ȫ���� 
wire[10:0] RAM0_Num, RAM1_Num;//RAMx�д洢����̫��֡���ֽ���
reg RAM0_WR_EN, RAM1_WR_EN;//RAMx��дʹ��
reg RAM0_RD_EN, RAM1_RD_EN;//RAMx�Ķ�ʹ��
reg RAM0_RD_EN_tmp, RAM1_RD_EN_tmp;//RAMx�Ķ�ʹ�ܣ����RD_EN��Ľ��ΪRAM0_RD_EN��RAM1_RD_EN
reg RAM0_Writing, RAM1_Writing;//����д��RAMx
wire RAM0_Empty, RAM1_Empty;//RAMx�Ѷ�ȡ���
wire RAM0_W_CLK, RAM1_W_CLK;
wire RAM0_R_CLK, RAM1_R_CLK;
reg RAM0_New_Frame, RAM1_New_Frame;
reg New_Frame_Flag0, New_Frame_Flag1;//Ϊ1��ʾ���ζ�ȡ����֡�ĵ�һ���ֽڣ�Ϊ0��ʾ���ζ�ȡ�Ѿ�������֡��һ���ֽ�
reg [7:0] Data_Input;//һ����ˮ��
reg rxdv_Buf;//һ����ˮ��
reg rxdv_Buf_ff0;
reg [3:0] crc_cnt;
reg [2:0] crc_end_cnt;
reg [31:0] crc_num;
reg [31:0] crc_cmp;
wire flag_crc;
reg crc_en;
reg crc_rst;
wire [31:0] crc_out;
reg [7:0] Data_Rev_From_8212f_ff0;
reg [7:0] Data_Rev_From_8212f_ff1;
reg [7:0] Data_Rev_From_8212f_ff2;
reg [7:0] Data_Rev_From_8212f_ff3;
reg [7:0] Data_Rev_From_8212f_ff4;
reg [7:0] Data_Rev_From_8212f_ff5;
reg flag_rxd_end;
/*wire [10:0] RAM0_WR_Uesed;
wire RAM0_WR_Empty;
wire [10:0] RAM1_WR_Uesed;
wire RAM1_WR_Empty;*/
//reg [2:0] RAM0_RD_Begin_Cnt;//�ڿ�ʼ��ȡRAM��Ϣʱ������ʱ7��ʱ��
//reg [5:0]RAM0_Status;//RAM0��5��״̬��00001��ʾRAM0��д��00010��ʾRAM0д����һ��֡��00100��ʾ׼����ʼ��RAM0��01000��ʾ���ڶ�RAM0��10000��ʾRAM0����
//reg [5:0]RAM1_Status;//RAM1��5��״̬��00001��ʾRAM0��д��00010��ʾRAM0д����һ��֡��00100��ʾ׼����ʼ��RAM0��01000��ʾ���ڶ�RAM0��10000��ʾRAM0����
FIFO FIFO0(
	.aclr(!RST),
	.data(Data_Input),
	.rdclk(RAM_Clk_Read),
	.rdreq(RAM0_RD_EN),
	.wrclk(rxc),
	.wrreq(RAM0_WR_EN),
	.q(RAM0_Dataout),
	.rdempty(RAM0_Empty),
	.rdusedw(RAM0_Num));
/*	.wrempty(RAM0_WR_Empty),
	.wrusedw(RAM0_WR_Uesed));*/

FIFO FIFO1(
	.aclr(!RST),
	.data(Data_Input),
	.rdclk(RAM_Clk_Read),
	.rdreq(RAM1_RD_EN),
	.wrclk(rxc),
	.wrreq(RAM1_WR_EN),
	.q(RAM1_Dataout),
	.rdempty(RAM1_Empty),
	.rdusedw(RAM1_Num));
	/*.wrempty(RAM1_WR_Empty),
	.wrusedw(RAM1_WR_Uesed));*/
	
ddio_in Data_Rev(.datain(rxd),.inclock(rxc),.dataout_l(Data_Rev_From_8212f[3:0]),.dataout_h(Data_Rev_From_8212f[7:4]));
CRC32_D8_AAL5 CRC32(.crc_out(crc_out),.data(Data_Rev_From_8212f_ff5),.enable(crc_en),.clk(rxc),.reset(~crc_rst));

//assign RAM0_RD_EN = (!RAM0_Empty && RAM0_Frame_Inside && !RAM1_RD_EN)? 1'b1: 1'b0;
//assign RAM1_RD_EN = (!RAM1_Empty && RAM1_Frame_Inside && !RAM0_RD_EN)? 1'b1: 1'b0;
//assign RAM0_R_CLK = RAM0_RD_EN? RAM_Clk_Read: 1'b0;
//assign RAM1_R_CLK = RAM1_RD_EN? RAM_Clk_Read: 1'b0;
//assign Data_Avl = RAM0_RD_EN || RAM1_RD_EN;
assign FIFO_Data_Num = RAM0_RD_EN? RAM0_Num: RAM1_Num;
assign RAM_Dataout = RAM0_RD_EN? RAM0_Dataout: RAM1_Dataout;
assign New_Frame = RAM0_New_Frame || RAM1_New_Frame;
//assign RAM0_W_CLK = (rxdv && !RAM0_Frame_Inside && !RAM1_Writing)? rxc: 1'b0;
//assign RAM1_W_CLK = (rxdv && !RAM1_Frame_Inside && !RAM0_Writing && RAM0_Frame_Inside)? rxc: 1'b0;
always@(posedge RAM_Clk_Read or negedge RST)//
begin
	if(!RST)
	begin
		RAM0_New_Frame <= 1'b0;
		RAM1_New_Frame <= 1'd0;
		New_Frame_Flag0 <= 1'd1;
		New_Frame_Flag1 <= 1'd1;
		RAM0_RD_EN <= 1'b0;
		RAM1_RD_EN <= 1'b0;
		RAM0_RD_EN_tmp <= 1'b0;
		RAM1_RD_EN_tmp <= 1'b0;
	end 
	else
	begin
		if(RAM0_Frame_Inside && New_Frame_Flag0 && ~RAM1_RD_EN)
		begin
			RAM0_New_Frame <= 1'b1;
			RAM0_RD_EN_tmp <= 1'b1;
			RAM0_RD_EN <= 1'b1;
			New_Frame_Flag0 <= 1'b0;
		end
		else if(RAM1_Frame_Inside && New_Frame_Flag1 && ~RAM0_RD_EN)
		begin
			RAM1_New_Frame <= 1'b1;
			RAM1_RD_EN_tmp <= 1'b1;
			RAM1_RD_EN <= 1'b1;
			New_Frame_Flag1 <= 1'b0;
		end
		else
		begin
			RAM0_New_Frame <= 1'b0;
			RAM1_New_Frame <= 1'b0;
			if((RAM0_RD_EN_tmp == 1'b1) && (RD_EN == 1'b1))
				RAM0_RD_EN <= 1'b1;
			else
				RAM0_RD_EN <= 1'b0;
			if((RAM1_RD_EN_tmp == 1'b1) && (RD_EN == 1'b1))
				RAM1_RD_EN <= 1'b1;
			else
				RAM1_RD_EN <= 1'b0;
		end
		if(RAM0_Empty)
		begin
			New_Frame_Flag0 <= 1'b1;
			RAM0_RD_EN_tmp <= 1'b0;
			RAM0_RD_EN <= 1'b0;
		end
		if(RAM1_Empty)
		begin
			New_Frame_Flag1 <= 1'b1;
			RAM1_RD_EN_tmp <= 1'b0;
			RAM1_RD_EN <= 1'b0;
		end
	end
end

always@(posedge rxc or negedge RST)
begin
if (!RST) begin             //��4�ģ���������8��ǰ���벻����У��
        crc_cnt <= 0;
    end
    else if (rxdv_Buf==1) begin
        if (crc_cnt==13) begin
            crc_cnt <= crc_cnt;
        end
        else begin
            crc_cnt <= crc_cnt + 1'b1;
        end
    end
    else begin
        crc_cnt <= 0;
    end
end

always@(posedge rxc or negedge RST)
begin
    if (!RST) begin             //������ɼ��������������4��crcֵ
        crc_end_cnt <= 0;
    end
    else if (flag_rxd_end==1) begin
        if (crc_end_cnt==6) begin
            crc_end_cnt <= crc_end_cnt;
        end
        else begin
            crc_end_cnt <= crc_end_cnt + 1'b1;
        end
    end
    else begin
        crc_end_cnt <= 0;
    end
end

always@(posedge rxc or negedge RST)
begin
   if (!RST) begin             //У�鿪ʼ�븴λ
		crc_en  <= 1'b0;
		crc_rst <= 1'b0;
    end
    else if (rxdv_Buf==1) begin 
        if (crc_cnt==13) begin
        crc_en  <= 1'b1;
        crc_rst <= 1'b1;
    end
    else begin
		crc_en  <= 1'b0;
		crc_rst <= 1'b0;
    end
end
end

always@(posedge rxc or negedge RST)
begin
	if(!RST)
	begin
		rxdv_Buf <= 1'b0;
        rxdv_Buf_ff0 <= 0;
		Data_Input <= 8'd0;
        Data_Rev_From_8212f_ff0 <= 0;       //������
        Data_Rev_From_8212f_ff1 <= 0;
        Data_Rev_From_8212f_ff2 <= 0;
        Data_Rev_From_8212f_ff3 <= 0;
        Data_Rev_From_8212f_ff4 <= 0;
        Data_Rev_From_8212f_ff5 <= 0;
	end 
	else 
	begin
		rxdv_Buf <= rxdv;
        rxdv_Buf_ff0 <= rxdv_Buf;
		Data_Input <= Data_Rev_From_8212f;
        Data_Rev_From_8212f_ff0 <= Data_Rev_From_8212f;
        Data_Rev_From_8212f_ff1 <= Data_Rev_From_8212f_ff0;
        Data_Rev_From_8212f_ff2 <= Data_Rev_From_8212f_ff1;
        Data_Rev_From_8212f_ff3 <= Data_Rev_From_8212f_ff2;
        Data_Rev_From_8212f_ff4 <= Data_Rev_From_8212f_ff3;
        Data_Rev_From_8212f_ff5 <= Data_Rev_From_8212f_ff4;
	end
    if (!RST) begin                         //��������ź�          
        flag_rxd_end <=0;
    end
    else if (rxdv_Buf==0 && rxdv_Buf_ff0==1) begin
        flag_rxd_end <= 1'b1;
    end
    else if (rxdv_Buf==1) begin
        flag_rxd_end <= 0;
    end
    else begin
        flag_rxd_end <= flag_rxd_end;
    end

    if (!RST) begin             //�����յ���crcֵ����crc_num��������crc_cmp���Ƚ�
        crc_num <= 0;
    end
    else if (flag_rxd_end==1) begin
        if (crc_end_cnt==1) begin
            crc_num <= {24'd0,Data_Rev_From_8212f_ff5};
        end
        else if (crc_end_cnt==2) begin
            crc_num <= {16'd0,Data_Rev_From_8212f_ff5,crc_num[7:0]};
        end
        else if (crc_end_cnt==3) begin
            crc_num <= {8'd0,Data_Rev_From_8212f_ff5,crc_num[15:0]};
        end
        else if (crc_end_cnt==4) begin
            crc_num <= {Data_Rev_From_8212f_ff5,crc_num[23:0]};
        end
    end
    else begin
        crc_num <= 0;
    end
    if (!RST) begin             //��crc_out��ֵ����������ں�crc_num���Ƚ�
        crc_cmp <= 0;
    end
    else if (flag_rxd_end==1) begin
        if (crc_end_cnt==1) begin
            crc_cmp <= crc_out;
        end
        else begin
            crc_cmp <= crc_cmp;
        end
    end
    else begin
        crc_cmp <= 0;
    end
end

assign flag_crc = (crc_end_cnt==5)?((crc_cmp!=crc_num)?1'b1:1'b0):1'b0;      //�Ƚ�����crc��� 

always@(posedge rxc or negedge RST)
begin
	if(!RST)
	begin
		RAM0_WR_EN <= 1'b0;
		RAM0_Frame_Inside <= 1'd0;
		RAM1_WR_EN <= 1'b0;
		RAM1_Frame_Inside <= 1'd0;
	end 
	else 
	begin
		if(rxdv_Buf == 1'b1)
		begin
			if((RAM0_Empty == 1'b1) && (RAM1_WR_EN == 1'b0))//�ڵ�һ��ʱ�Ӻ�RAM0_Empty��Ϊ0�ˡ���RAM0�����ݶ��պ��������д�����ݵ�RAM1����ʱ����д����RAM0
			begin
				RAM0_Frame_Inside <= 1'b0;
				RAM0_WR_EN <= 1'b1;
				//RAM1_WR_EN <= 1'b0;
			end
			else if((RAM1_Empty == 1'b1)  && (RAM0_WR_EN == 1'b0))
			begin
				RAM1_Frame_Inside <= 1'b0;
				RAM1_WR_EN <= 1'b1;
				//RAM0_WR_EN <= 1'b0;
			end
		end	
		else
		begin
			//RAM0_WR_EN <= 1'b0;
			//RAM1_WR_EN <= 1'b0;
			if(RAM0_WR_EN == 1'b1)
			begin
				RAM0_WR_EN <= 1'b0;
				RAM0_Frame_Inside <= 1'b1;
			end
			//else
			//	RAM0_Frame_Inside <= 1'b0;
			if(RAM1_WR_EN == 1'b1)
			begin
				RAM1_WR_EN <= 1'b0;
				RAM1_Frame_Inside <= 1'b1;
			end
			//else
			//	RAM1_Frame_Inside <= 1'b0;
			if(RAM0_Empty == 1'b1)
					RAM0_Frame_Inside <= 1'b0;
			if(RAM1_Empty == 1'b1)
					RAM1_Frame_Inside <= 1'b0;
		end
	end
end

endmodule
	