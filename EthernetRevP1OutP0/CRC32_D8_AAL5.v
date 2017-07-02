module CRC32_D8_AAL5(clk,data,enable,crc_out,reset);
input clk;

input [7:0] data;
input enable;
input reset;
	 
output [31:0] crc_out;

	
reg [31:0] crc_out;
wire[31:0] crc_tmp1 ;
wire[31:0] crc_tmp2 ;
wire[3:0] crc_table_adr1;
wire[3:0] crc_table_adr2;

reg[31:0] crc_table_data1;
reg[31:0] crc_table_data2;

always @(crc_table_adr1) begin
	 case (crc_table_adr1) 
		4'h0:crc_table_data1=32'h4DBDF21C; 
		4'h1:crc_table_data1=32'h500AE278; 
		4'h2:crc_table_data1=32'h76D3D2D4; 
		4'h3:crc_table_data1=32'h6B64C2B0;
		4'h4:crc_table_data1=32'h3B61B38C;
		4'h5:crc_table_data1=32'h26D6A3E8;
		4'h6:crc_table_data1=32'h000F9344;
		4'h7:crc_table_data1=32'h1DB88320;
		4'h8:crc_table_data1=32'hA005713C;
		4'h9:crc_table_data1=32'hBDB26158;
		4'hA:crc_table_data1=32'h9B6B51F4; 
		4'hB:crc_table_data1=32'h86DC4190;
		4'hC:crc_table_data1=32'hD6D930AC; 
		4'hD:crc_table_data1=32'hCB6E20C8; 
		4'hE:crc_table_data1=32'hEDB71064;
		4'hF:crc_table_data1=32'hF0000000;
	 
	 endcase
end

always @(crc_table_adr2) begin
	 case (crc_table_adr2) 
		4'h0:crc_table_data2=32'h4DBDF21C; 
		4'h1:crc_table_data2=32'h500AE278; 
		4'h2:crc_table_data2=32'h76D3D2D4; 
		4'h3:crc_table_data2=32'h6B64C2B0;
		4'h4:crc_table_data2=32'h3B61B38C;
		4'h5:crc_table_data2=32'h26D6A3E8;
		4'h6:crc_table_data2=32'h000F9344;
		4'h7:crc_table_data2=32'h1DB88320;
		4'h8:crc_table_data2=32'hA005713C;
		4'h9:crc_table_data2=32'hBDB26158;
		4'hA:crc_table_data2=32'h9B6B51F4; 
		4'hB:crc_table_data2=32'h86DC4190;
		4'hC:crc_table_data2=32'hD6D930AC; 
		4'hD:crc_table_data2=32'hCB6E20C8; 
		4'hE:crc_table_data2=32'hEDB71064;
		4'hF:crc_table_data2=32'hF0000000;
	 
	 endcase
end
	
 always @(posedge clk)begin
	if(reset==1 && enable==0) begin
		crc_out<=32'h00000000;
   end
	
	else if(reset==0 && enable==1) begin
		crc_out <= crc_tmp2 ;
	end
	
end
	assign crc_table_adr1=crc_out[3:0] ^ data[3:0]; 
	assign crc_table_adr2=crc_tmp1[3:0] ^ data[7:4]; 
	assign crc_tmp1 = (crc_out>>4)^crc_table_data1;
	assign crc_tmp2 = (crc_tmp1>>4)^crc_table_data2 ;
	
endmodule