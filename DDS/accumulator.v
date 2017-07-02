module accumulator( //generate address which reads rom
    clk_100m  ,
    rst_n     ,
    pha_ctrl  ,    //phase control word
    frq_ctrl  ,    //frequency control word
    rd_address     //rd_address which reads rom
    );

    input               clk_100m;
    input               rst_n   ;
    input [7:0]         pha_ctrl;   //normally is 0,if mobile phase assigns a value
    input [7:0]         frq_ctrl;   //maintain a certain value to output stable sine wave,if increase then output a higher frequency sine wave

    output reg [7:0]    rd_address;

    always@(posedge clk_100m or negedge rst_n)begin
        if(rst_n==1'b0)begin
            rd_address <= 8'h00;
        end
        else begin
            rd_address <= frq_ctrl + rd_address + pha_ctrl;
        end
    end

    endmodule

