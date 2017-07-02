`timescale 1 ns/1 ns

module dlf_tb();

reg clk  ;
reg rst_n;
reg se   ;

    wire      add  ;
    wire      sub  ;

        parameter CYCLE    = 20;

        parameter RST_TIME = 3 ;

        dlf u0(   
            .clk  (clk  ),
            .rst_n(rst_n),
            .se   (se   ),
            .add  (add  ),
            .sub  (sub  )
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
                se = 0;
                repeat(10) begin
                    #(CYCLE);
                    se = 1;
                    #(CYCLE);
                    se = 0;
                end
                repeat(10) begin
                    #(5*CYCLE);
                    se = 1;
                    #(5*CYCLE);
                    se = 0;
                end
                repeat(10) begin
                    #(10*CYCLE);
                    se = 1;
                    #(10*CYCLE);
                    se = 0;
                end
                repeat(10) begin
                    #(15*CYCLE);
                    se = 1;
                    #(15*CYCLE);
                    se = 0;
                end
                repeat(10) begin
                    #(20*CYCLE);
                    se = 1;
                    #(20*CYCLE);
                    se = 0;
                end
                repeat(10) begin
                    #(25*CYCLE);
                    se = 1;
                    #(25*CYCLE);
                    se = 0;
                end
                repeat(10) begin
                    #(30*CYCLE);
                    se = 1;
                    #(30*CYCLE);
                    se = 0;
                end
                repeat(10) begin
                    #(35*CYCLE);
                    se = 1;
                    #(35*CYCLE);
                    se = 0;
                end
					 $stop;
            end

            endmodule

