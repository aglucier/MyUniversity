module atf(    //aotu track frequency
    clk    ,
    rst_n  ,
    fin_d  ,
    fin_w      
    );

    input               clk       ;
    input               rst_n     ;
    input               fin_d     ;

    output reg [15:0]   fin_w     ;

    reg [15:0]          cnt       ;
    reg                 fin_ff0   ; 
    reg [15:0]          cnt_reg   ; 

    wire                fin_p_flag; 
    wire                fin_n_flag; 

    always  @(posedge clk or negedge rst_n)begin    
        if(rst_n==1'b0)begin
            fin_ff0 <= 1'b0;
        end
        else begin
            fin_ff0 <= fin_d;
        end
    end

    assign fin_p_flag = (fin_d==1)&&(fin_ff0==0); 
    assign fin_n_flag = (fin_d==0)&&(fin_ff0==1);
    
    always@(posedge clk or negedge rst_n)begin  
        if(rst_n==1'b0)begin
            cnt <= 1'b0;
        end
        else if(fin_n_flag==1) begin   
            cnt <= 1'b0;
        end
        else if(fin_ff0==1) begin       
            cnt <= cnt + 1'b1;
        end
        else begin
            cnt <= cnt;
        end
    end

    always  @(posedge clk or negedge rst_n)begin    
        if(rst_n==1'b0)begin
            cnt_reg <= 1'b0;
        end
        else if(fin_n_flag==1) begin   
            cnt_reg <= cnt;
        end
        else begin
            cnt_reg <= cnt_reg;
        end
    end

    always  @(posedge clk or negedge rst_n)begin   
        if(rst_n==1'b0)begin
            fin_w <= 1'b0;
        end
        else if(fin_p_flag==1) begin    
            fin_w <= cnt_reg;
        end
        else begin
            fin_w <= fin_w;
        end
    end

    endmodule

