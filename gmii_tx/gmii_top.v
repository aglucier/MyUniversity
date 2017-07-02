module gmii_top(
    clk     ,
    gtx_clk ,
    txd     ,
    tx_en   ,
    tx_er       //发送错误信号 
);

input clk;

output wire gtx_clk,tx_en,tx_er;
output wire [7:0] txd          ;

wire rst_n,clk_125m;

pll u0(
	.inclk0(clk     ),
	.c0    (clk_125m), //12M，0°偏移时钟
	.c1    (gtx_clk ), //125M,-120°偏移时钟
	.locked(rst_n   )  //locked信号作为复位信号
);

gmii_tx u1(
    .clk_125m(clk_125m),
    .txd     (txd     ),
    .tx_en   (tx_en   ),
    .tx_er   (tx_er   ),
    .rst_n   (rst_n   )
);

endmodule
