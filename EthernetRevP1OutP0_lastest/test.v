
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
reg FIFO_RD_EN;//为1可读取FIFO中数据，为0时可等待插入时间戳
//wire SignalTap_clk;// For SignalTap

reg [4:0] time_stamp;//时间戳状态机跳转信号
reg [7:0] sec_32_ff0      ;
reg [7:0] sec_32_ff1      ;
reg [7:0] sec_32_ff2      ;
reg [7:0] sec_32_ff3      ;
reg [7:0] ns_32_ff0       ;
reg [7:0] ns_32_ff1       ;
reg [7:0] ns_32_ff2       ;
reg [7:0] ns_32_ff3       ;
reg [7:0] sec_cnt_ff0_tmp ;
reg [7:0] sec_cnt_ff1_tmp ;
reg [7:0] sec_cnt_ff2_tmp ;
reg [7:0] sec_cnt_ff3_tmp ;
reg [7:0] ns_cnt_ff0_tmp  ;
reg [7:0] ns_cnt_ff1_tmp  ;
reg [7:0] ns_cnt_ff2_tmp  ;
reg [7:0] ns_cnt_ff3_tmp  ;
reg [10:0]fifo_data_len   ;
reg [3:0] time_stamp_cnt  ;
reg       time_stamp_over ;
reg       flag_time_cnt   ;
wire      flag_ns_8       ;
wire      flag_ns_16      ;
wire      flag_ns_24      ;
wire      flag_ns_1s      ;
wire      flag_sec_8      ;
wire      flag_sec_16     ;
wire      flag_sec_24     ;
wire      flag_crc        ;
reg       flag_crc_ff0    ;
reg       flag_crc_ff1    ;
reg       flag_crc_wrong  ;
reg       len_long        ;
reg       len_short       ;
reg       rxdv_ff0        ;

CRC32_D8_AAL5 CRC32(.crc_out(crc_out),.data(dataout),.enable(crc_en),.clk(txc_tmp),.reset(~crc_rst));   //fcs calculate module銆enable 涓锛reset涓鏃惰绠梒rc
//mypll pll1(.inclk0(clkin),.c0(txc),.c1(txc_tmp), .c2(SignalTap_clk), .locked(RST));        //pll module to generate 125MHZ TXC
mypll pll1(.inclk0(clkin),.c0(txc),.c1(txc_tmp), .locked(RST));        //pll module to generate 125MHZ TXC, TXC is 240 degree ahead of txc_tmp;
rxdata u_rxdata(.rxc(rxc),.rxd(rxd),.rxdv(rxdv),.RAM_Dataout(Data_From_FIFO), .New_Frame(Frame_Begin), .RAM_Clk_Read(txc_tmp), .RD_EN(FIFO_RD_EN), .FIFO_Data_Num(Remain_FIFO_Num), .RST(RST), .flag_crc(flag_crc));

//DDIO_OUT TXD_Output(.datain_h(txd_tmp[7:4]), .datain_l(txd_tmp[3:0]), .outclock(txc_tmp), .dataout(txd));
//assign txd = txc_tmp?txd_tmp[3:0]:txd_tmp[7:4] ;
assign txd = txc_tmp?txd_tmp[3:0]:txd_tmp[7:4] ;
//assign RAM_RD_Clk = Data_TX_EN? txc_tmp: 1'b0;
always @(posedge txc_tmp or negedge RST) begin
	if(!RST)
	begin
		New_Frame_Flag  <= 0;   //原为1
		FIFO_Data_Num   <= 0;
        dataout         <= 0;
        flag_time_cnt   <= 0;
    end
	else
	begin
		New_Frame_Flag  <= Frame_Begin    ;
		FIFO_Data_Num   <= Remain_FIFO_Num;
		////////////////////////////////////////////////for test,时间戳插入修改dataout的值
//		dataout <= Data_From_FIFO;
		//if((FIFO_Data_Num != 11'h6e)&& (FIFO_Data_Num != 11'h71))
		//if((FIFO_Data_Num != 11'h28c)&& (FIFO_Data_Num != 11'h28b))
        if (FIFO_RD_EN) begin 
			dataout       <= Data_From_FIFO;
            flag_time_cnt <= 0;
        end
        else begin
           case (time_stamp)
               5'd0	 : begin
					dataout   <= 8'h50             ;   //时间戳标志，4个字
			   end
               5'd1	 : begin
					dataout   <= 8'h4B             ;								
			   end
               5'd2	 : begin
					dataout   <= 8'h54             ;								
			   end
               5'd3	 : begin
					dataout   <= 8'h45             ;								
			   end
               5'd4	 : begin
					dataout   <= 8'h00             ;	  //时间戳端口号，1个字							
			   end
               5'd5	 : begin
					dataout   <= {3'b0, flag_crc_wrong, 3'b0, len_long};	  //时间戳校验，4个字，先全为0							
			   end
               5'd6	 : begin
					dataout   <= {3'b0, len_short, 4'b0};								
			   end
               5'd7	 : begin
					dataout   <= 8'h00             ;								
			   end  
               5'd8	 : begin
					dataout   <= 8'h00             ;								
			   end
               5'd9	 : begin
					dataout   <= sec_cnt_ff0_tmp   ;	  //时间戳秒计数							
			   end
               5'd10 :	begin
					dataout   <= sec_cnt_ff1_tmp;								
			   end
               5'd11 :	begin
					dataout   <= sec_cnt_ff2_tmp;								
			   end
               5'd12 :	begin
					dataout   <= sec_cnt_ff3_tmp;								
			   end
               5'd13 :	begin
					dataout   <= ns_cnt_ff0_tmp    ;   //时间戳纳秒计数								
			   end
               5'd14 :	begin
					dataout   <= ns_cnt_ff1_tmp    ;								
			   end
               5'd15 :	begin
					dataout   <= ns_cnt_ff2_tmp    ;								
			   end
               5'd16 :	begin
					dataout   <= ns_cnt_ff3_tmp    ;
			   end
               5'd17 :	begin
					dataout   <= fifo_data_len[7:0];   								
                    flag_time_cnt   <= 1'b1        ;   //时间戳插入完成信号
			   end
               5'd18 :	begin
					dataout   <= {5'b0,fifo_data_len[10:8]};
			   end
				endcase
        end
		//else
		//	dataout <= 8'had;
		///////////////////////////////////////////////
	end
end

always  @(posedge txc_tmp or negedge RST)begin    //时间戳状态跳转
    if(!RST)begin
        time_stamp <= 0;
    end
    else if (!FIFO_RD_EN) begin
        if (time_stamp ==18) begin
            time_stamp <= 0;
        end
        else begin
            time_stamp <= time_stamp + 1'b1;
        end
    end
    else begin
        time_stamp <= 0;
    end
end

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
		FIFO_RD_EN <= 1'b1;     //随时有效，只有在需要插入时间戳时才为0
        fifo_data_len   <= 0;
        time_stamp_cnt  <= 0;
        len_long        <= 0;
        len_short       <= 0;
	end
	else
	begin
		if(New_Frame_Flag || Frame_Reading)
		begin
			if(New_Frame_Flag)
			begin
				//txen <= 1'b1                     ;
				Frame_Reading   <= 1'b1            ;
                fifo_data_len   <= Remain_FIFO_Num ;
                //FIFO_RD_EN    <= 1'b1            ;     //原没注释
			end
			else
				txen <= 1'b1;
            if (txen==1) begin
                if (fifo_data_len<47) begin
                    len_short <= 1'b1;
                end
                else if (fifo_data_len>1500) begin
                    len_long  <= 1'b1;
                end
                else begin
                    len_short <= 0;
                    len_long  <= 0;
                end
                if(data_snap != 0) begin			
				    data_snap      <= data_snap + 1'b1     ; 
                    time_stamp_cnt <= time_stamp_cnt + 1'b1;
                end
			    else begin
				    crc_en  <= 1'b1;   //地址要crc校验，preamble不需要
				    crc_rst <= 1'b1;
                    if (flag_time_cnt == 1) begin   //时间戳插入完成
                        time_stamp_cnt <= 0;
                    end
                    else begin      
                        time_stamp_cnt <= time_stamp_cnt;
                    end
			    end   
                if (time_stamp_cnt == 5) begin  //关闭FIFO读，时间戳开始
			        FIFO_RD_EN <= 0;
                end
                else if (flag_time_cnt == 1) begin
                    FIFO_RD_EN <= 1'b1;
                end
            end
            else begin
                len_long  <= 0;
                len_short <= 0;
            end
	    	case(FIFO_Data_Num)
			    11'd5:
			    begin
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
			   		data_snap <= 4'd8;
			   		Frame_Reading <= 1'b0;
			   		FIFO_RD_EN <= 1'b1;
			   		crc_rst <= 1'b0;
		    		txen <= 1'b0;
			   	end
		    	/*11'd0:
		    	begin
		    		//txen <= 1'b0;
		    		//crc_en <= 1'b0;
			    	//data_snap <= 4'd8;
			   		//Frame_Reading <= 1'b0;
			   		//FIFO_RD_EN <= 1'b1;
			   		//crc_rst <= 1'b0;
			   	end*/
		    	default:
		    		txd_tmp <= dataout;
	    endcase
		end
	end
end

always @(posedge txc_tmp or negedge RST)
begin
    if (!RST) begin
        flag_crc_ff0 <= 0;
        flag_crc_ff1 <= 0;
    end
    else begin
        flag_crc_ff0 <= flag_crc;
        flag_crc_ff1 <= flag_crc_ff0;
    end
end

always @(posedge txc_tmp or negedge RST)
begin
    if (!RST) begin
        flag_crc_wrong <= 0;
    end
    else if (txen==1) begin
        if (flag_crc_ff0==1 && flag_crc_ff1==0) begin
            flag_crc_wrong <= 1'b1;
        end
        else begin
            flag_crc_wrong <= flag_crc_wrong;
        end
    end
    else begin
        flag_crc_wrong <= 0;
    end
end

always  @(posedge rxc or negedge RST)begin   
    if(!RST)begin
        rxdv_ff0 <= 0;
    end
    else begin
        rxdv_ff0 <= rxdv;
    end
end

always  @(posedge txc_tmp or negedge RST)begin   
    if(!RST)begin
        sec_cnt_ff0_tmp <= 0;
        sec_cnt_ff1_tmp <= 0;
        sec_cnt_ff2_tmp <= 0;
        sec_cnt_ff3_tmp <= 0;
        ns_cnt_ff0_tmp  <= 0;
        ns_cnt_ff1_tmp  <= 0;
        ns_cnt_ff2_tmp  <= 0;
        ns_cnt_ff3_tmp  <= 0;
    end
    else if (rxdv==1&&rxdv_ff0==0) begin
        sec_cnt_ff0_tmp <= sec_32_ff0     ;
        sec_cnt_ff1_tmp <= sec_32_ff1     ;
        sec_cnt_ff2_tmp <= sec_32_ff2     ;
        sec_cnt_ff3_tmp <= sec_32_ff3     ;
        ns_cnt_ff0_tmp  <= ns_32_ff0      ;
        ns_cnt_ff1_tmp  <= ns_32_ff1      ;
        ns_cnt_ff2_tmp  <= ns_32_ff2      ;
        ns_cnt_ff3_tmp  <= ns_32_ff3      ;      
    end
end

assign flag_ns_8   = ns_32_ff0  == 248;                  //纳秒计数器，低8位记满信号
assign flag_ns_16  = ns_32_ff1  == 255 && flag_ns_8;     //纳秒计数器，低16位记满信号
assign flag_ns_24  = ns_32_ff2  == 255 && flag_ns_16;    //纳秒计数器，低24位记满信号
assign flag_ns_1s  = ns_32_ff3  == 59  && ns_32_ff2 == 154 && ns_32_ff1 == 201 && ns_32_ff0 == 248;   //纳秒计数器记满1s信号
assign flag_sec_8  = sec_32_ff0 == 255 && flag_ns_1s;    //秒计数器，低8位记满信号
assign flag_sec_16 = sec_32_ff1 == 255 && flag_sec_8;    //秒计数器，低16位记满信号
assign flag_sec_24 = sec_32_ff2 == 255 && flag_sec_16;   //秒计数器，低24位记满

always  @(posedge rxc or negedge RST)begin    //纳秒计数器，低8位
    if(!RST)begin
        ns_32_ff0 <= 0;
    end
    else if (flag_ns_1s) begin 
        ns_32_ff0 <= 0;
    end
    else if (flag_ns_8) begin
        ns_32_ff0 <= 0;
    end
    else begin
        ns_32_ff0 <= ns_32_ff0 + 8'd8;
    end
end

always  @(posedge rxc or negedge RST)begin    //8-16位
    if(!RST)begin
        ns_32_ff1 <= 0;
    end
    else if (flag_ns_1s) begin
        ns_32_ff1 <= 0;
    end
    else if (flag_ns_8) begin
        ns_32_ff1 <= ns_32_ff1 + 1'b1;
    end
    else begin
        ns_32_ff1 <= ns_32_ff1;
    end
end

always  @(posedge rxc or negedge RST)begin    //16-24位
    if(!RST)begin
        ns_32_ff2 <= 0;
    end
    else if (flag_ns_1s) begin 
        ns_32_ff2 <= 0;
    end
    else if (flag_ns_16) begin    
        ns_32_ff2 <= ns_32_ff2 + 1'b1;
    end  
    else begin
        ns_32_ff2 <= ns_32_ff2;
    end
end

always  @(posedge rxc or negedge RST)begin    //24-32位
    if(!RST)begin
        ns_32_ff3 <= 0;
    end
    else if (flag_ns_1s) begin 
        ns_32_ff3 <= 0;
    end
    else if (flag_ns_24) begin
        ns_32_ff3 <= ns_32_ff3 + 1'b1;
    end
    else begin
        ns_32_ff3 <= ns_32_ff3;
    end
end

always  @(posedge rxc or negedge RST)begin    //秒计数器低8位
    if(!RST)begin
        sec_32_ff0 <= 0;
    end
    else if (flag_ns_1s) begin 
        if (sec_32_ff0 == 255) begin
            sec_32_ff0 <=0;
        end
        else begin
            sec_32_ff0 <= sec_32_ff0 + 1'd1;
        end
    end
    else begin
        sec_32_ff0 <= sec_32_ff0;
    end
end

always  @(posedge rxc or negedge RST)begin    //8-16位
    if(!RST)begin
        sec_32_ff1 <= 0;
    end
    else if (flag_sec_8) begin
        if (sec_32_ff1 == 255) begin
            sec_32_ff1 <= 0;
        end
        else begin
            sec_32_ff1 <= sec_32_ff1 + 1'b1;
        end
    end
    else begin
        sec_32_ff1 <= sec_32_ff1;
    end
end

always  @(posedge rxc or negedge RST)begin    //16-24位
    if(!RST)begin
        sec_32_ff2 <= 0;
    end
    else if (flag_sec_16) begin
        if (sec_32_ff2 == 255) begin
            sec_32_ff2 <= 0;
        end
        else begin
            sec_32_ff2 <= sec_32_ff2 + 1'b1;
        end
    end 
    else begin
        sec_32_ff2 <= sec_32_ff2;
    end
end

always  @(posedge rxc or negedge RST)begin    //24-32位
    if(!RST)begin
        sec_32_ff3 <= 0;
    end
    else if (flag_sec_24) begin
        if (sec_32_ff3 == 255) begin
            sec_32_ff3 <= 0;
        end
        else begin
            sec_32_ff3 <= sec_32_ff3 + 1'b1;
        end
    end
    else begin
        sec_32_ff3 <= sec_32_ff3;
    end
end

endmodule


