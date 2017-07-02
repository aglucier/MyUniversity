module gmii_top(
    clk     ,
    gtx_clk ,
    txd     ,
    tx_en   ,
    tx_er       //���ʹ����ź� 
);

input clk;

output wire gtx_clk,tx_en,tx_er;
output wire [7:0] txd          ;

wire rst_n,clk_125m;

pll u0(
	.inclk0(clk     ),
	.c0    (clk_125m), //12M��0��ƫ��ʱ��
	.c1    (gtx_clk ), //125M,-120��ƫ��ʱ��
	.locked(rst_n   )  //locked�ź���Ϊ��λ�ź�
);

gmii_tx u1(
    .clk_125m(clk_125m),
    .txd     (txd     ),
    .tx_en   (tx_en   ),
    .tx_er   (tx_er   ),
    .rst_n   (rst_n   )
);

endmodule
