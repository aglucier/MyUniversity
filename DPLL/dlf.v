module dlf(    //digital loop frequency
    clk_2  ,
    rst_n  ,
    se     ,
    add    ,    
    sub
    );

    input               clk_2  ;
    input               rst_n  ;
    input               se     ;

    output wire         add    ;
    output wire         sub    ;

    reg  [3:0]          cnt    ;
    reg                 se_ff0 ;   

    wire                se_p   ;   
    wire                se_n   ;   

    parameter peak = 4'd15;         

    assign se_p = (se==1'b1)&&(se_ff0==1'b0);  
    assign se_n = (se==1'b0)&&(se_ff0==1'b1);  

    always  @(posedge clk_2 or negedge rst_n)begin   

        if(rst_n==1'b0)begin
            se_ff0 <= 1'b0;
        end
        else begin
            se_ff0 <= se;
        end
    end
     
    always@(posedge clk_2 or negedge rst_n)begin 
        if(rst_n==1'b0)begin
            cnt <= 1'b0;
        end
        else if((se_p==1'b1)||(se_n==1'b1)) begin  
            cnt <= 1'b0;
        end
        else if(!se) begin         
            if(cnt>=peak) begin    
                cnt <= 1'b0;
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
        else begin                
            if(cnt==0) begin      
                cnt <= peak;
            end 
            else begin
                cnt <= cnt - 1'b1;
            end
        end
    end

    assign add = (!se)&&(cnt==peak);   
    assign sub = (se)&&(cnt==0);       

    endmodule

