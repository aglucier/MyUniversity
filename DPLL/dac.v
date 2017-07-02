module dac(     //digital artificial change数模转换模块，将数字信号转换为模拟信号
    fin_out,    //输入是fin或fout
    rst_n  ,
    dout
    );

    input               fin_out;
    input               rst_n  ;

    output reg [7:0]    dout   ;

    reg [7:0]           d      ;
    reg [5:0]           q      ;    //计数器，根据输入fin或fout的快慢，进行计数

    always@(posedge fin_out or negedge rst_n)begin  //计数器，根据输入fin或fout的快慢，进行计数
        if(rst_n==1'b0)begin
            q <= 1'b0;
        end
        else if(q<63) begin
            q <= q + 1'b1;
        end
        else begin
            q <= 1'b0;
        end
    end

    always  @(*)begin   //状态机
        case(q) //根据不同的值产生不同的值，对应模拟波形的值
          00:  d=255; 01:  d=254; 02:  d=252; 03:  d=249;
          04:  d=245; 05:  d=239; 06:  d=233; 07:  d=225;
          08:  d=217; 09:  d=207; 10:  d=197; 11:  d=186;
          12:  d=174; 13:  d=162; 14:  d=150; 15:  d=137;
          16:  d=124; 17:  d=112; 18:  d=99;  19:  d=87;
          20:  d=75;  21:  d=64;  22:  d=53;  23:  d=43;
          24:  d=34;  25:  d=26;  26:  d=19;  27:  d=13;
          28:  d=8;   29:  d=4;   30:  d=1;   31:  d=0;
          32:  d=0;   33:  d=1;   34:  d=4;   35:  d=8;
          36:  d=13;  37:  d=19;  38:  d=26;  39:  d=34;
          40:  d=43;  41:  d=53;  42:  d=64;  43:  d=75;
          44:  d=87;  45:  d=99;  46:  d=112; 47:  d=124;
          48:  d=137; 49:  d=150; 50:  d=162; 51:  d=174;
          52:  d=186; 53:  d=197; 54:  d=207; 55:  d=217;
          56:  d=225; 57:  d=233; 58:  d=239; 59:  d=245;
          60:  d=249; 61:  d=252; 62:  d=254; 63:  d=255;
          default : d=0;
        endcase
    end

    always  @(posedge fin_out or negedge rst_n)begin    //寄存器输出，减少毛刺
        if(rst_n==1'b0)begin
            dout <= 1'b0;
        end
        else begin
            dout <= d;
        end
    end

    endmodule

