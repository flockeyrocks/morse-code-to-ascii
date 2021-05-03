`timescale 1ns / 1ps

module sseg_driver
    //200Hz refresh rate
    #(parameter FINAL_VALUE = 50000, BITS = 4)(
    input [5:0] I0, I1, I2, I3, I4, I5, I6, I7,
    input clk,
    output [7:0] AN,
    output [6:0] bcd,
    output DP
    );
    
    wire [3:0] num;
    wire [2:0] X;
    reg [5:0] D_out, D_out_next;
    
    //slow clock for counter
    timer_parameter #(FINAL_VALUE) clk_div (
        .clk(clk),
        .reset_n(1),
        .enable(1),
        .done(slow_clk)
    );
    
    //simple 0-7 counter for active digit and input
    udl_counter #(BITS)(
        .clk(clk),
        .reset_n(1),
        .enable(slow_clk),
        .up(1),
        .load(0),
        .D(0),
        .Q(X)
    );
    
    //determmines mux output of the I inputs
    always @(posedge clk)
    begin
        D_out <= D_out_next;
    end
    always @(*)
    begin
        D_out_next = D_out;
        case(X)
            0 : D_out_next = I0;
            1 : D_out_next = I1;
            2 : D_out_next = I2;
            3 : D_out_next = I3;
            4 : D_out_next = I4;
            5 : D_out_next = I5;
            6 : D_out_next = I6;
            7 : D_out_next = I7;
        endcase
    end
    
    //get bcd value from chosen input
    assign num = D_out[4:1];
    
    first_sseg_driver driver(
    .num(num),
    .active_digit(X),
    .DP_ctrl(D_out[0]),
    .en(D_out[5]),
    .bcd(bcd),
    .AN(AN),
    .DP(DP)
    );
    
endmodule
