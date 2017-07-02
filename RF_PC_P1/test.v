module test (	
					clkin,				
									rxd,
									rxdv,
									rxc,
									
									txd,
									txen,
									txc,
									

									dataout,
						//			wrireq
									indicate 
									);

input [3:0] rxd ;
input rxc ;
input rxdv ;
input clkin;

output txc ;
output reg txen ;
output wire [3:0]txd ;
output reg indicate ;
output reg [7:0] dataout ;
//output reg wrireq ;



reg [10:0]data_snap ;
reg [24:0]delay_cnt ;
reg[7:0] txd_reg ;
reg txen_reg ;
reg[8:0]pack_cnt;
wire [31:0] crc_out ;
reg crc_en ;
reg crc_rst ;
wire clk_not;
reg[7:0] txd_tmp;
wire txc_tmp;
CRC32_D8_AAL5 CRC32(.crc_out(crc_out),.data(txd_reg),.enable(crc_en),.clk(txc_tmp),.reset(~crc_rst));   //fcs calculate module
mypll pll1(.inclk0(clkin),.c0(txc),.c1(txc_tmp));        //pll module to generate 125MHZ TXC
assign clk_not = txc_tmp ;
assign txd = clk_not?txd_tmp[3:0]:txd_tmp[7:4] ;

always @(posedge txen)
begin
		indicate <= ~indicate ;
end

always @(posedge txc_tmp )
begin

		txd_tmp <= txd_reg ;
		txen <= txen_reg ;
				case ( data_snap )
					11'd0	:	begin
								data_snap <= data_snap + 1'b1 ;           //preamble code  0x55 0x55 0x55 0x55 0x55 0x55 0x55 0xd5
								txd_reg <= 8'h55 ;
								txen_reg <= 1'b1 ;
								crc_rst <= 1'b1 ;
								end
					11'd1	:	begin
								data_snap <= data_snap + 1'b1 ;
								txd_reg <= 8'h55 ;
								end
					11'd2	:	begin
								data_snap <= data_snap + 1'b1 ;
								txd_reg <= 8'h55 ;
								end
					11'd3	:	begin
								data_snap <= data_snap + 1'b1 ;
								txd_reg <= 8'h55 ;
								end
					11'd4	:	begin
								data_snap <= data_snap + 1'b1 ;
								txd_reg <= 8'h55 ;
								end
					11'd5	:	begin
									data_snap <= data_snap + 1'b1 ;
									txd_reg <= 8'h55 ;
								end
					11'd6	:	begin
									data_snap <= data_snap + 1'b1 ;
									txd_reg <= 8'h55 ;
								end
					11'd7	:	begin
									data_snap <= data_snap+1'b1 ;
									txd_reg <= 8'hd5 ;
									
								end
					11'd8 :  begin
										data_snap <= data_snap + 1'b1 ;                 //boradcast destination address  
										txd_reg <= 8'h02 ;										// 0xff 0xff 0xff 0xff 0xff 0xff
										crc_en <= 1'b1 ;
								end
					11'd9 :  begin
										data_snap <= data_snap + 1'b1 ;
										txd_reg <= 8'h02 ;
								end
					11'd10 :  begin
										data_snap <= data_snap + 1'b1 ;
										txd_reg <= 8'h02 ;
								end
					11'd11 :  begin
										data_snap <= data_snap + 1'b1 ;
										txd_reg <= 8'h02 ;
								end
					11'd12 :  begin
										data_snap <= data_snap + 1'b1 ;
										txd_reg <= 8'h02 ;
								end
					11'd13	:	begin
										data_snap <= data_snap + 1'b1 ;
										txd_reg <= 8'h02 ;
									end
					11'd14   :  begin
										data_snap <= data_snap + 1'b1;
										txd_reg <= pack_cnt[7:0];
									//	pack_cnt <= pack_cnt + 1'b1;
									end
					11'd15  :   begin
										data_snap <= data_snap + 1'b1;
										txd_reg <= {7'd0,pack_cnt[8]};
										if(pack_cnt == 9'd479)begin
											pack_cnt <= 9'd0;
										end
										else begin
											pack_cnt <= pack_cnt + 1'b1;
										end
										data_snap <= data_snap + 1'b1;
									end
					11'd1296	:	begin
										data_snap <= data_snap+ 1'b1 ;
										txd_reg <= data_snap [7:0] ;
										crc_en <= 1'b0 ;
									end
					11'd1297	: begin
										data_snap <= data_snap + 1'b1 ;
										txd_tmp <= crc_out[7:0] ;                    //crc32 lst byte
										
									end
					11'd1298	: begin
										data_snap <= data_snap + 1'b1 ;          //crc32 2st byte
										txd_tmp <= crc_out[15:8] ;
									end
					11'd1299	: begin
										data_snap <= data_snap + 1'b1 ;          //crc32 3st byte
										txd_tmp <= crc_out[23:16] ;
									end
					11'd1300	: begin
										data_snap <= data_snap + 1'b1 ;          //crc32 4st byte
										txd_tmp <= crc_out[31:24] ;
										txen_reg <= 1'b0 ;
									end
					11'd1301	:	begin
										
										crc_rst <= 1'b0 ;
										crc_en <= 1'b0 ;
										if(delay_cnt == 10000)                //delay 
										begin
											data_snap <= 11'd0;
											delay_cnt <= 25'd0 ;
										end
										else
											delay_cnt <= delay_cnt + 1'b1 ;
									end
					default	:	begin
										txd_reg <= data_snap[7:0] ;
										data_snap <= data_snap + 1'b1 ;
									end
				endcase
		end
endmodule
