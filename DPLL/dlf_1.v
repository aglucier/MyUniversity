module dlf_1(    //digital loop frequency
    clk    ,
    rst_n  ,
    se     ,
    add    ,
    sub
    );

    input               clk    ;
    input               rst_n  ;
    input               se     ;

    output reg          add    ;
    output reg          sub    ;

    reg  [3:0]          cnt    ;
    reg  [1:0]          state  ;

    parameter peak = 4'd15;

    localparam
        IDLE = 2'd0,
        SE_N = 2'd1,
        SE   = 2'd2;

    always  @(posedge clk or negedge rst_n)begin  
        if(rst_n==1'b0) begin
            state <= IDLE;
            cnt <= 1'b0;
        end
        else begin
            case(state)
                IDLE : begin
                    if(!se) begin
                        state <= SE_N;
                        cnt <= 4'd8;
                    end
                    else if(se) begin
                        state <= SE;
                        cnt <= 4'd7;
                    end
                    else begin
                        state <= IDLE;
                        cnt <= 1'b0;
                    end
                end
                SE_N : begin
                    if(se) begin
                        state <= SE;
                        cnt <= 4'd7;
                    end
                    else begin
                        if(cnt>=peak) begin
                            cnt <= 4'd8;
                        end
                        else begin
                            cnt <= cnt + 1'b1;
                            state<= SE_N;
                        end
                    end
                end
                SE : begin
                    if(!se) begin
                        state <= SE_N;
                        cnt <= 4'd8;
                    end
                    else begin
                        if(cnt==1'b0) begin
                            cnt <= 4'd7;
                        end
                        else begin
                            cnt <= cnt - 1'b1;
                            state<= SE;
                        end
                    end
                end
                default : state <= IDLE;
            endcase
        end
    end

    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            add <= 1'b0;
            sub <= 1'b0;
        end
        else begin
            add <= (!se)&&(cnt==peak);
            sub <= (se)&&(cnt==0);
        end
    end

    endmodule
