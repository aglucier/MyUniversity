module dds_top(
    clk     ,
    rst_n   ,
    pha_ctrl,
    frq_ctrl,
    sin_dac 
    );

    input               clk     ;
    input               rst_n   ;
    input [7:0]         pha_ctrl;   //phase control word
    input [7:0]         frq_ctrl;   //frequency control word

    output wire [7:0]   sin_dac ;   //to output analog sine wave

    wire                clk_100m;
    wire [7:0]          rd_address;

    pll pll_u0(        //generate 100M clk
	    .inclk0(clk),
	    .c0(clk_100m)
    );

    accumulator accumulator_u1(     //accumulator
        .clk_100m  (clk_100m  ),
        .rst_n     (rst_n     ),
        .pha_ctrl  (pha_ctrl  ),
        .frq_ctrl  (frq_ctrl  ),
        .rd_address(rd_address)     //rd_address which reads rom
    );

    sin_rom sin_rom_u2(             //rom which stored sine wave
        .clk_100m  (clk_100m  ), 
        .rst_n     (rst_n     ),
        .rd_address(rd_address),
        .sin_dac   (sin_dac   )  
    );
    endmodule

