`timescale 1 ns/1 ns

module gmii_top_tb();

reg clk;

wire gtx_clk,tx_en,tx_er;
wire [7:0] txd          ;

parameter CYCLE    = 20;

gmii_top u0(
    .clk    (clk    ),
    .gtx_clk(gtx_clk),
    .txd    (txd    ),
    .tx_en  (tx_en  ),
    .tx_er  (tx_er  ) 
);



initial begin
clk = 0;
forever
#(CYCLE/2)
clk=~clk;
end

endmodule

