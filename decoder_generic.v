`timescale 1ns / 1ps

module decoder_generic
    #(parameter N = 3)(
    input [N - 1:0] w,
    input en,
    //** is "to the power of" since ^ is XOR
    output reg [2 ** N - 1 : 0] y
    );
    
    always @(w, en)
    begin
        y = 'b0;
        if (en)
            y[w] = 1'b1; 
        else
            y = 'b0;
    end
endmodule
