module xordpd(  //xor digital phase discriminator
    fin_d  ,    
    fout   ,    
    se          
    );

    input               fin_d  ;
    input               fout   ;

    output wire         se     ;

    assign se = fin_d ^ fout;

    endmodule

