`timescale 1ns / 1ps

module first_sseg_driver
    #(parameter N = 4)(
    input [3:0] num,
    input [2:0] active_digit,
    input DP_ctrl,
    input en,
    output [6:0] bcd,
    output [7:0] AN,
    output DP
    );
    
    wire [7:0] choose_bcd;
    
    //choose_bcd determines AN
    decoder_generic #(N) decoder 
    (
    .w(active_digit),
    .en(en),
    .y(choose_bcd)
    );
    
    hex2sseg convert(
    .hex(num),
    .sseg(bcd)
    );
    
    assign AN = ~choose_bcd;
    assign DP = DP_ctrl;
    
endmodule
