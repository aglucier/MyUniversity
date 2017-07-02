`timescale 1 ns/1 ns

module dco_tb();

    reg clk  ;
    reg rst_n;
    reg add  ;
    reg sub  ;

    wire      dco_clk;

        parameter CYCLE    = 20;

        parameter RST_TIME = 3 ;

        dco_1 dco_u0(  //digital control oscillator
            .clk    (clk    ),
            .rst_n  (rst_n  ),
            .add    (add    ),
            .sub    (sub    ),
            .dco_clk(dco_clk)
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
                add = 0;
                sub = 0;
                #(100*CYCLE);
                repeat(20) begin
                    add = 1;
                    #(CYCLE);
                    add = 0;
                    #(CYCLE);
                end
                repeat(20) begin
                    sub = 1;
                    #(CYCLE);
                    sub = 0;
                    #(CYCLE);
                end
                repeat(20) begin
                    add = 1;
                    #(5*CYCLE);
                    add = 0;
                    #(5*CYCLE);
                end
                repeat(20) begin
                    sub = 1;
                    #(5*CYCLE);
                    sub = 0;
                    #(5*CYCLE);
                end
                repeat(20) begin
                    add = 1;
                    #(10*CYCLE);
                    add = 0;
                    #(10*CYCLE);
                end
                repeat(20) begin
                    sub = 1;
                    #(10*CYCLE);
                    sub = 0;
                    #(10*CYCLE);
                end
                repeat(20) begin
                    add = 1;
                    sub = 0;
                    #(CYCLE);
                    add = 0;
                    sub = 1;
                    #(CYCLE);
                end
                repeat(20) begin
                    add = 1;
                    sub = 0;
                    #(5*CYCLE);
                    add = 0;
                    sub = 1;
                    #(5*CYCLE);
                end
                repeat(20) begin
                    add = 1;
                    sub = 0;
                    #(10*CYCLE);
                    add = 0;
                    sub = 1;
                    #(10*CYCLE);
                end
                $stop;
            end
            

            endmodule

