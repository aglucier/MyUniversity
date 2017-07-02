`timescale 1 ns/1 ns

module test_test();

reg  [3:0] rxd ;
reg  rxc ;
reg  rxdv ;
reg  clkin;

wire txc ;
wire txen ;
wire [3:0]txd ;

        parameter CYCLE    = 20;
        parameter CYCLE_R  = 8 ;

        test uut(
            .rxd          (rxd     ), 
            .rxc          (rxc     ),
            .rxdv         (rxdv    ),
            .clkin        (clkin   ),
            .txc          (txc     ),
            .txen         (txen    ),
            .txd          (txd     )
            );

            initial begin
                clkin = 0;
                forever
                #(CYCLE/2)
                clkin=~clkin;
            end

            initial begin
                rxc = 0;
                forever
                #(CYCLE_R/2)
                rxc=~rxc;
            end

            initial begin
                #1;
                rxd = 4'h0;
                rxdv = 0;
                #(10*CYCLE_R);
                rxdv = 1'b1;
                repeat (15) begin
                  #(CYCLE_R);
                  rxd = 4'h5;
                end
                #(CYCLE_R);
                rxd = 4'hd;
                repeat (1000) begin
                    #(CYCLE_R);
                    rxd = rxd + 1'b1;
                end
                rxdv = 0;
                repeat (10) begin
                #(1000*CYCLE_R);
                rxdv = 1'b1;
                repeat (15) begin
                  #(CYCLE_R);
                  rxd = 4'h5;
                end
                #(CYCLE_R);
                rxd = 4'hd;
                repeat (1000) begin
                    #(CYCLE_R);
                    rxd = rxd + 1'b1;
                end
                rxdv = 0;
            end
          end

            



            endmodule

