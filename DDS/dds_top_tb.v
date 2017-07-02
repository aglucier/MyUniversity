`timescale 1 ns/1 ns

module dds_top_tb();

reg clk  ;
reg rst_n;

reg[7:0]  pha_ctrl;
reg[7:0]  frq_ctrl;

    wire[7:0] sin_dac;

        parameter CYCLE    = 20;

        parameter RST_TIME = 3 ;

        dds_top dds_top_u0(
            .clk     (clk     ),
            .rst_n   (rst_n   ),
            .pha_ctrl(pha_ctrl),
            .frq_ctrl(frq_ctrl),
            .sin_dac (sin_dac )
            );


            initial begin
                clk = 0;
                forever
                #(CYCLE/2)
                clk=~clk;
            end

            initial begin
                rst_n = 1;
                #2;
                rst_n = 0;
                #(CYCLE*RST_TIME);
                rst_n = 1;
            end

            initial begin
                #1;
                pha_ctrl = 0;
                frq_ctrl = 0;
                #(10*CYCLE);
                frq_ctrl = 1;
                #(256*3*CYCLE);
                pha_ctrl = 64; 
                frq_ctrl = 2;
                #(0.5*CYCLE);
                pha_ctrl = 0;
                #(256*3*CYCLE);
                $stop;
            end

            endmodule

