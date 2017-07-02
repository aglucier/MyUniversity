
module test (	
					clkin,//Crystal clock in.			
									rxd,//Connect to 8212f P1RXD0~P1RXD3
									rxdv,//connect to 8212f Pin70 P1RXCTL, The RXCTL indicates RXDV at rising of RXC and the logical derivative（来源） of RXER and RXDV at the falling edge of RXC
									rxc,//connect to 8212f Pin71 P1RXC, All RGMII receive outputs must be synchronized to this clock. Its frequency (with +/-50ppm tolerance) depends upon the link speed. 1000M: 125MHz 100M: 25MHz 10M: 2.5MHz
									
									txd,//connect to 8212f P0TXD0~P0TXD3(they connect to pin75, pin 76, pin 72, pin 74 of fpga)
									txen,//connect to 8212f P0TXCTL, The TXCTL indicates TXEN at rising of GTXC and the logical derivative of TXER and TXEN at the falling edge of GTXC.
									txc//txc output directlly. 125MHz, Connect to 8212f P0GTXC,All transmit（发送信号） inputs must be synchronized to this clock.Its frequency depends upon the link speed.1000M: 125MHz 100M: 25MHz 10M: 2.5MHz
									

									//dataout,//RAM output
						//			wrireq
									//indicate//flash with data transmitting
									);

input [3:0] rxd ;
input rxc ;
input rxdv ;
input clkin;

output txc ;
output reg txen ;
output wire [3:0]txd ;
//output reg [7:0] dataout ;
reg [7:0] dataout ;
//output reg wrireq ;


reg [3:0]data_snap ;//一个数据包总长度为1301字节
//reg [24:0]delay_cnt ;
//reg[7:0] txd_reg ;//用以计算crc的数，并且txd_tmp <= txd_reg ;，即其同时也是发送的数据
//reg txen_reg ;//txen <= txen_reg ; 发送enable，在发送时一直为高，总是有效
//reg[8:0]pack_cnt;
wire [31:0] crc_out ;
reg crc_en ;
reg crc_rst ;
//wire clk_not;
reg[7:0] txd_tmp;
wire txc_tmp;
wire Data_TX_EN;//有数据可传输
wire RST;//使用PLL的locked作为系统复位信号，低电平有效，在PLL锁定后，其输出高电平
wire RAM_RD_Clk;//读Buffer时钟
//reg RAM_RD_Clk_En;//读Buffer时钟使能
//reg[1:0] CRC_cnt;//CRC鍙戦�佽鏁板櫒
//reg [2:0] RAM_RD_Begin_Cnt;//在开始读取RAM信息时，先延时7个时钟
reg [10 : 0] FIFO_Data_Num;//在读的FIFO中的剩下的数据个数
reg New_Frame_Flag;//开始读取一个帧的第一个字节
/*reg [10 : 0] FIFO_Data_Num_1;//流水线缓冲
reg New_Frame_Flag_1;//流水线缓冲
reg [7:0] dataout_1;//流水线缓冲*/
reg Frame_Reading;//正在读取一个帧
//reg Send_FIFO_Data;//为1表示发送从FIFO中读取的数据，为0表示不读最后4个字节，发送重新计算得到的CRC
wire [7:0] Data_From_FIFO;//一级流水线
wire Frame_Begin;//一级流水线
wire [10 : 0]Remain_FIFO_Num;//一级流水线
reg FIFO_RD_EN;////为1可读取FIFO中数据，为0时可等待插入时间戳
//wire SignalTap_clk;// For SignalTap

reg [4:0] time_stamp;//时间戳状态机跳转信号

//CRC32_D8_AAL5 CRC32(.crc_out(crc_out),.data(dataout),.enable(crc_en),.clk(txc_tmp),.reset(~crc_rst));   //fcs calculate module銆enable 涓锛reset涓鏃惰绠梒rc
//mypll pll1(.inclk0(clkin),.c0(txc),.c1(txc_tmp), .c2(SignalTap_clk), .locked(RST));        //pll module to generate 125MHZ TXC
mypll pll1(.inclk0(clkin),.c0(txc),.c1(txc_tmp), .locked(RST));        //pll module to generate 125MHZ TXC, TXC is 240 degree ahead of txc_tmp;
rxdata u_rxdata(.rxc(rxc),.rxd(rxd),.rxdv(rxdv),.RAM_Dataout(Data_From_FIFO), .New_Frame(Frame_Begin), .RAM_Clk_Read(txc_tmp),
 .RD_EN(FIFO_RD_EN), .FIFO_Data_Num(Remain_FIFO_Num), .RST(RST));

//DDIO_OUT TXD_Output(.datain_h(txd_tmp[7:4]), .datain_l(txd_tmp[3:0]), .outclock(txc_tmp), .dataout(txd));
//assign txd = txc_tmp?txd_tmp[3:0]:txd_tmp[7:4] ;
assign txd = txc_tmp?txd_tmp[3:0]:txd_tmp[7:4] ;
//assign RAM_RD_Clk = Data_TX_EN? txc_tmp: 1'b0;
always @(posedge txc_tmp  or negedge RST)
begin
	if(!RST)
	begin
		New_Frame_Flag <= 1'b0;
		FIFO_Data_Num <= 11'b0;
	end
	else
	begin
		New_Frame_Flag <= Frame_Begin;
		FIFO_Data_Num <= Remain_FIFO_Num;
		////////////////////////////////////////////////for test,时间戳插入修改dataout的值
//		dataout <= Data_From_FIFO;
		//if((FIFO_Data_Num != 11'h6e)&& (FIFO_Data_Num != 11'h71))
		//if((FIFO_Data_Num != 11'h28c)&& (FIFO_Data_Num != 11'h28b)) 
			dataout <= Data_From_FIFO;
		//else
		//	dataout <= 8'had;
		///////////////////////////////////////////////
	end
end

/*always  @(posedge txc_tmp or negedge rst_n)begin
    if(!RST)begin
        datatout <= 0;
    end
    else begin
        if (Frame_Begin) begin
            FIFO_RD_EN <= 0;
            case (time_stamp)
                32'd0  : dataout <= 0x50;
                32'd1  : dataout <= 0x4B;
                32'd2  : dataout <= 0x54;
                32'd3  : dataout <= 0x45; 
                32'd4  : dataout <= 0x01; 
                32'd5  : dataout <= 0x00;
                32'd6  : dataout <= 0x00;
                32'd7  : dataout <= 0x00;
                32'd8  : dataout <= 0x00;
                32'd9  : dataout <= 0x00;
                32'd10 : dataout <= 0x00;
                32'd11 : dataout <= 0x00;
                32'd12 : dataout <= 0x00;
                32'd13 : dataout <= 0x00;
                32'd14 : dataout <= 0x00;
                32'd15 : dataout <= 0x00;
                32'd16 : dataout <= 0x00;
                32'd17 : dataout <= 0x00;
                32'd18 : begin
                    dataout    <= 0x00;
                    FIFO_RD_EN <= 1'b1;
                end
                default : dataout <= 
        end
    end
end */

/*
always @(posedge txc_tmp  or negedge RST)
begin
	if(!RST)
	begin
		New_Frame_Flag <= 1'b0;
		FIFO_Data_Num <= 11'b0;
	end
	else
	begin
		New_Frame_Flag <= New_Frame_Flag_1;
		FIFO_Data_Num <= FIFO_Data_Num_1;
		dataout <= dataout_1;
	end
end
*/
always @(posedge txc_tmp or negedge RST)
begin
	if(!RST)
	begin
		data_snap <= 4'd8;  
		crc_en <= 1'b0;
		Frame_Reading <= 1'b0;
		crc_rst <= 1'b0;
		txen <= 1'b0;
		FIFO_RD_EN <= 1'b1;//随时有效，只有在需要插入时间戳时才为0
	end
	else
	begin
		if(New_Frame_Flag || Frame_Reading)
		begin
			if(New_Frame_Flag)
			begin
				//txen <= 1'b1;
				Frame_Reading <= 1'b1;
				FIFO_RD_EN <= 1'b1;
			end
			else
				txen <= 1'b1;
			if(data_snap != 0)			
					data_snap <= data_snap + 1'b1 ; 
			else
			begin
				crc_en <= 1'b1;//地址要crc校验，preamble不需要
				crc_rst <= 1'b1;
			end
			case(FIFO_Data_Num)
				11'd5:
				begin
					crc_en <= 1'b0;
					txd_tmp <= dataout;				
				end
				11'd4:
				begin
					txd_tmp <= crc_out[7:0] ;
					crc_en <= 1'b0;
				end
				11'd3:
				begin
					txd_tmp <= crc_out[15:8] ;
					crc_en <= 1'b0;
				end
				11'd2:
				begin
					txd_tmp <= crc_out[23:16] ;
					crc_en <= 1'b0;
				end
				11'd1:
				begin
					txd_tmp <= crc_out[31:24] ;
					crc_en <= 1'b0;
					//data_snap <= 4'd8;
					//Frame_Reading <= 1'b0;
					//FIFO_RD_EN <= 1'b1;
					//crc_rst <= 1'b0;
					//txen <= 1'b0;
				end
				11'd0:
				begin
					txen <= 1'b0;
					crc_en <= 1'b0;
					data_snap <= 4'd8;
					Frame_Reading <= 1'b0;
					FIFO_RD_EN <= 1'b1;
					crc_rst <= 1'b0;
				end
				default:
					txd_tmp <= dataout;
			endcase	
		end
	end
end
endmodule

