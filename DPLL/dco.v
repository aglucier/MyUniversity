module dco( //digital control oscillator  
    clk_2  ,
    clk    ,
    rst_n  ,
    add    ,
    sub    ,
    dco_clk
    );
    
    input               clk_2  ;
    input               clk    ;
    input               rst_n  ;
    input               add    ;
    input               sub    ;
    
    output reg          dco_clk;
    
    reg                 div_4  ;   

    always  @(posedge clk_2 or negedge rst_n)begin    
        if(rst_n==1'b0)begin
            div_4 <= 1'b0;
        end
        else begin
            div_4<= ~div_4;
        end
    end

    always  @(posedge clk or negedge rst_n)begin    
        if(rst_n==1'b0)begin
            dco_clk= 1'b0;
        end
        else if((clk_2==1&&(div_4==1||add==1))&&sub!=1) begin   
            dco_clk= 1'b1;
        end
        else begin
            dco_clk= 1'b0;
        end
    end
    
endmodule

