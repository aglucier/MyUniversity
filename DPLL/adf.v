module adf(  //aotu divide frequency
    dco_clk,    
    rst_n  ,
    fin_w  ,
    fout        
    );

    input               dco_clk ;
    input               rst_n   ;
    input [15:0]        fin_w   ;

    output reg          fout    ;

    reg  [14:0]         cnt     ;

    always  @(posedge dco_clk or negedge rst_n)begin    
        if(rst_n==1'b0)begin
            cnt <= 1'b0;
        end
        else if(cnt>=(fin_w/4)) begin 
            cnt <= 1'b0;
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end

    always@(posedge dco_clk or negedge rst_n)begin  
        if(rst_n==1'b0)begin
            fout <= 1'b0;
        end
        else if(cnt>=(fin_w/4)) begin 
            fout <= ~fout;
        end
        else begin
            fout <= fout; 
        end
    end

    endmodule

