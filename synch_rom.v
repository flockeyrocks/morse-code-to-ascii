`timescale 1ns / 1ps

module synch_rom(
    input clk,
    input [7:0] addr,
    output reg [7:0] data
    );
    
    (*rom_style = "block"*) reg [7:0] rom [0:255];
    
    initial
        $readmemh("bin2ascii.mem", rom); 
    
    always @(posedge clk)
        data <= rom[addr];
endmodule
