module pll_top(
    clk     ,  
    fin     ,   
    fin_dac ,   
    fout_dac    
    );

    input               clk     ;
    input               fin     ;

    output [7:0]        fin_dac ;
    output [7:0]        fout_dac;

    reg                 fin_d   ;

    wire [15:0]         fin_w   ;   
    wire [15:0]         dout    ;   
	wire			    fout    ;   
    wire                sys_rst ;   
    wire                se      ;   
    wire                add     ;   
    wire                sub     ;   
    wire                dco_clk ;   
	wire				rst_n   ;
	wire     		    clk_2	;
     
    always  @(posedge clk or negedge rst_n)begin
        if(rst_n==1'b0)begin
            fin_d <= 1'b0; 
        end
        else begin
            fin_d <= fin;
        end
    end

    reset_n reset_n_u0( //Asynchronous reset synchronous release 
        .clk (clk   ),
        .rst_n(rst_n)
        );

    fd fd_u1(           //frequency division
        .clk_2(clk_2),
        .rst_n(rst_n),
        .clk  (clk  ) 
    );

    xordpd xordpd_u2(   //xor difital phase discriminator
        .fin_d(fin_d),
        .fout (fout ),
        .se   (se   )
        );

    dlf_1 dlf_1_u3(     //digital loop frequency 
        .clk  (clk  ),
        .rst_n(rst_n),
        .se   (se   ),
        .add  (add  ),
        .sub  (sub  )
        );

    dco dco_u4(         //digital control oscillator 
        .clk_2  (clk_2  ),
        .clk    (clk    ),
        .rst_n  (rst_n  ),
        .add    (add    ),
        .sub    (sub    ),
        .dco_clk(dco_clk)
    );
        
    atf atf_u5(         //aotu track frequency 
        .clk  (clk  ),
        .rst_n(rst_n),
        .fin_d(fin_d),
        .fin_w(fin_w) 
    );

    adf adf_u6(        //aotu divide frequency 
        .dco_clk(dco_clk),
        .rst_n  (rst_n  ),
        .fin_w  (fin_w  ),
        .fout   (fout   )
    );

    dac dac_u7(         //digital artificial change 
        .fin_out (fin_d  ),
        .rst_n   (rst_n  ),
        .dout    (fin_dac)
    );

    dac dac_u8(         //above same  
        .fin_out (fout    ),
        .rst_n   (rst_n   ),
        .dout    (fout_dac)
    );

    endmodule

