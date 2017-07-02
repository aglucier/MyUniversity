//rxc: 接收数据时钟，由8212f提供;
//rxd: 接收数据总线
//rxdv:接收数据出现在数据总线上，由8212f提供；
//RAM_Dataout: 从RAM读出数据，送到8212f发送端口
//Data_Avl: 为1表示Buffer中有数据可读
//RAM_Clk_Read: 读RAM时钟，其应和8212f发送时钟同步
//RST: 系统复位，使用PLL的locked作为系统复位信号，低电平有效
module rxdata(rxc,rxd,rxdv,RAM_Dataout, New_Frame, RAM_Clk_Read, RD_EN, FIFO_Data_Num, RST, flag_crc);
input rxc,rxdv;
input[3:0]rxd;
input RAM_Clk_Read;
input RST;
input RD_EN;//为1可读取FIFO中数据，为0时可等待插入时间戳
wire [7:0] RAM0_Dataout, RAM1_Dataout;//RAMx的q端，数据输出
output New_Frame;//开始读一个帧
output [7:0] RAM_Dataout;
output [10:0] FIFO_Data_Num;//当前FIFO中还没读取的数据个数
output flag_crc;
wire [7:0] Data_Rev_From_8212f;//从8212f接收到的数据
reg RAM0_Frame_Inside, RAM1_Frame_Inside;//RAM0_Frame_Inside: 为0，RAM0里无数据或正在存储数据，收到的以太网数据帧可存放在RAM0；为1，RAM0中包含一个以太网帧，还没有完全读出 
wire[10:0] RAM0_Num, RAM1_Num;//RAMx中存储的以太网帧的字节数
reg RAM0_WR_EN, RAM1_WR_EN;//RAMx的写使能
reg RAM0_RD_EN, RAM1_RD_EN;//RAMx的读使能
reg RAM0_RD_EN_tmp, RAM1_RD_EN_tmp;//RAMx的读使能，其和RD_EN与的结果为RAM0_RD_EN和RAM1_RD_EN
reg RAM0_Writing, RAM1_Writing;//正在写入RAMx
wire RAM0_Empty, RAM1_Empty;//RAMx已读取完毕
wire RAM0_W_CLK, RAM1_W_CLK;
wire RAM0_R_CLK, RAM1_R_CLK;
reg RAM0_New_Frame, RAM1_New_Frame;
reg New_Frame_Flag0, New_Frame_Flag1;//为1表示本次读取的是帧的第一个字节，为0表示本次读取已经读过了帧第一个字节
reg [7:0] Data_Input;//一级流水线
reg rxdv_Buf;//一级流水线
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
//reg [2:0] RAM0_RD_Begin_Cnt;//在开始读取RAM信息时，先延时7个时钟
//reg [5:0]RAM0_Status;//RAM0的5个状态，00001表示RAM0可写，00010表示RAM0写入了一个帧，00100表示准备开始读RAM0，01000表示正在读RAM0，10000表示RAM0读完
//reg [5:0]RAM1_Status;//RAM1的5个状态，00001表示RAM0可写，00010表示RAM0写入了一个帧，00100表示准备开始读RAM0，01000表示正在读RAM0，10000表示RAM0读完
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
if (!RST) begin             //打4拍，计数器，8个前导码不加入校验
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
    if (!RST) begin             //接收完成计数器，计数最后4个crc值
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
   if (!RST) begin             //校验开始与复位
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
        Data_Rev_From_8212f_ff0 <= 0;       //打四拍
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
    if (!RST) begin                         //接受完成信号          
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

    if (!RST) begin             //将接收到的crc值赋给crc_num，用来与crc_cmp作比较
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
    if (!RST) begin             //将crc_out的值存在这里，用于和crc_num作比较
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

assign flag_crc = (crc_end_cnt==5)?((crc_cmp!=crc_num)?1'b1:1'b0):1'b0;      //比较两个crc结果 

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
			if((RAM0_Empty == 1'b1) && (RAM1_WR_EN == 1'b0))//在第一个时钟后，RAM0_Empty就为0了。在RAM0中数据读空后，如果正在写入数据到RAM1，此时不能写数到RAM0
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
	
