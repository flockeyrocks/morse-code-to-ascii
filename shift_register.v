`timescale 1ns / 1ps

module shift_register
    #(parameter N = 5)(
        input clk, reset_n, shift, SI,
        output [N - 1:0] Q
    );
    
    reg [N - 1:0] Q_reg, Q_next;
    
    always @(posedge clk, negedge reset_n)
    begin
        if(~reset_n)
            Q_reg <= 0;
        else
            Q_reg <= Q_next;
    end
    
    //next state logic
    always @(*)
    begin
        case (shift)
            1'b1: Q_next = {Q_reg[N - 2:0], SI};
            1'b0: Q_next = Q_reg;
        endcase
    end
    
    //output logic
    assign Q = Q_reg;
    
endmodule
