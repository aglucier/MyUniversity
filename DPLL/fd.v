module fd(  //frequency division
    clk    ,
    rst_n  ,
    clk_2
    );

    input               clk    ;
    input               rst_n  ;
	 
	 output reg 	    clk_2  ;

    always@(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            clk_2 <= 1'b0;
        end
        else begin
            clk_2 <= ~clk_2;
        end
    end

    endmodule

