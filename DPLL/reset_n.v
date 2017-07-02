module reset_n( //Asynchronous reset synchronous release  
    clk    ,
    rst_n
    );

    input clk;

    output reg rst_n;

    reg       rst0;

    wire      sys_rst_n;

    assign sys_rst_n = 1'b1;

    always  @(posedge clk or negedge sys_rst_n)begin
        if(sys_rst_n==1'b0)begin
            rst0  <= 1'b0;
            rst_n <= 1'b0;
        end
        else begin
            rst0  <= 1'b1;
            rst_n <= rst0;
        end
    end

    initial begin   //Modelsim reset initialization
        rst0  = 1'b0;
        rst_n = 1'b0;
    end

    endmodule

