`timescale 1ns / 1ps
module add_3(
    input [3:0] A,
    output reg [3:0] S
    );
    
    //if A>4, add 3 to it
    always@(A)
    case(A)
    0: S = A;
    1: S = A;
    2: S = A;
    3: S = A;
    4: S = A;
    5: S = A + 3;
    6: S = A + 3;
    7: S = A + 3;
    8: S = A + 3;
    9: S = A + 3;
    endcase
    
endmodule
