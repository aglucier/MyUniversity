`timescale 1 ns/1 ns

module pll_top_tb();

    reg       		 clk     ;
    reg       		 fin     ;

    wire [7:0]     fin_dac ;
    wire [7:0]     fout_dac;

        parameter CYCLE    = 20;

        pll_top u0(
            .clk     (clk     ),
            .fin     (fin     ),
            .fin_dac (fin_dac ),
            .fout_dac(fout_dac) 
            );
        

            initial begin
                clk = 0;
                forever
                #(CYCLE/2)
                clk=~clk;
            end

            initial begin
                #1;
                fin = 0;
                repeat(1000) begin
                    #(10*CYCLE);
                    fin = 1;
                    #(10*CYCLE);
                    fin = 0;
                end
                repeat(100) begin
                    #(15*CYCLE);
                    fin = 1;
                    #(15*CYCLE);
                    fin = 0;
                end
                repeat(100) begin
                    #(20*CYCLE);
                    fin = 1;
                    #(20*CYCLE);
                    fin = 0;
                end
                repeat(100) begin
                    #(25*CYCLE);
                    fin = 1;
                    #(25*CYCLE);
                    fin = 0;
                end
                repeat(100) begin
                    #(30*CYCLE);
                    fin = 1;
                    #(30*CYCLE);
                    fin = 0;
                end
				repeat(100) begin
                    #(25*CYCLE);
                    fin = 1;
                    #(25*CYCLE);
                    fin = 0;
                end
				repeat(100) begin
                    #(20*CYCLE);
                    fin = 1;
                    #(20*CYCLE);
                    fin = 0;
                end
				repeat(100) begin
                    #(15*CYCLE);
                    fin = 1;
                    #(15*CYCLE);
                    fin = 0;
                end
				repeat(1000) begin
                    #(10*CYCLE);
                    fin = 1;
                    #(10*CYCLE);
                    fin = 0;
                end
                    #33;            //10*20*2*(30/360)
				repeat(100) begin   //30
                    #(10*CYCLE);
                    fin = 1;
                    #(10*CYCLE);
                    fin = 0;
                end
                    #50;
				repeat(100) begin   //45
                    #(10*CYCLE);
                    fin = 1;
                    #(10*CYCLE);
                    fin = 0;
                end
                    #100;
				repeat(100) begin   //90
                    #(10*CYCLE);
                    fin = 1;
                    #(10*CYCLE);
                    fin = 0;
                end
                    #133;
				repeat(100) begin   //120
                    #(10*CYCLE);
                    fin = 1;
                    #(10*CYCLE);
                    fin = 0;
                end
                    #200;
				repeat(100) begin   //180
                    #(10*CYCLE);
                    fin = 1;
                    #(10*CYCLE);
                    fin = 0;
                end
				repeat(100) begin   //180
                    #(1000*CYCLE);
                    fin = 1;
                    #(1000*CYCLE);
                    fin = 0;
                end
				repeat(2000) begin   //180
                    #(10000*CYCLE);
                    fin = 1;
                    #(10000*CYCLE);
                    fin = 0;
                end
					 $stop;
            end

            endmodule

