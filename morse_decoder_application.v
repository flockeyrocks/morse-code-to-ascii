`timescale 1ns / 1ps

module morse_decoder_application
    //still a bit fast, change to 19_999_999 if not successful
    #(parameter TIMER_FINAL_VALUE = 9_999_999)(
    input b_noisy, read_noisy, clk, reset_n,
    output [7:0] AN,
    output [6:0] sseg,
    output DP, empty
    );
    
    wire b, read_debounced, read_edge, dot, dash, lg, wg, full;
    wire [4:0] Q;
    wire [7:0] data, hex, addr;
    wire [7:0] sym_concat;
    wire [5:0] I7, I6, I5, I4, I3, I2, I1, I0;
    reg [4:0] enable;
    reg wg_delayed;
    wire [2:0] count;
    
    debouncer_delayed b_debounce(
        .clk(clk),
        .reset_n(reset_n),
        .noisy(b_noisy),
        .debounced(b)
    );
    
    debouncer_delayed read_debounce(
        .clk(clk),
        .reset_n(reset_n),
        .noisy(read_noisy),
        .debounced(read_debounced)
    );
    
    //edge required to read one number at a time
    edge_detector read(
        .clk(clk),
        .reset_n(reset_n),
        .level(read_debounced),
        .p_edge(read_edge)
    );
    
    //provided more decoder
    morse_decoder #(.TIMER_FINAL_VALUE(TIMER_FINAL_VALUE)) morse(
        .b(b),
        .clk(clk),
        .reset_n(reset_n),
        .dot(dot),
        .dash(dash),
        .lg(lg),
        .wg(wg)
    );
    
    shift_register left_shift(
        .clk(clk),
        .reset_n(reset_n & ~(lg|wg)),
        .shift(dot^dash),
        .SI(dash),
        .Q(Q)
    );
    
    udl_counter #(.BITS(3)) digit_count(
        .clk(clk),
        .reset_n(reset_n & ~(lg|wg)),
        .enable(dot^dash),
        .up(1),
        .load(count == 5),
        .D(0),
        .Q(count)
    );
    
    //concatenate symbol count and symbol
    assign sym_concat = {count, Q};
    
    //conditional for addr in form (condition ? value if true : value if false)
    assign addr = (wg ? 8'b1110_0000 : sym_concat);
    
    //morse to ascii LUT
    synch_rom bin2ascii(
        .clk(clk),
        .addr(addr),
        .data(data)
    );
    
    //D flip-flop for wg_delayed
    always@(posedge clk)
    begin
        wg_delayed <= wg;
    end
    
     fifo_generator_0 sseg_fifo (
        .clk(clk),                          // input wire clk
        .srst(~reset_n),                    // input wire srst
        .din(data),                         // input wire [7 : 0] din
        .wr_en(~full&(lg|wg|wg_delayed)),   // input wire wr_en
        .rd_en(read_edge),                  // input wire rd_en
        .dout(hex),                         // output wire [7 : 0] dout
        .full(full),                        // output wire full
        .empty(empty)                       // output wire empty
    );
    
   
    
    //determine which 7segs are enabled from count
    always@(count)
    begin
        case(count)
            0: enable = 5'b00000;
            1: enable = 5'b00001;
            2: enable = 5'b00011;
            3: enable = 5'b00111;
            4: enable = 5'b01111;
            5: enable = 5'b11111;
            default: enable = 5'b00000;
        endcase
    end
    
    assign I7 = {~empty, hex[7:4], 1'b1};
    assign I6 = {~empty, hex[3:0], 1'b1};
//    used I5 to debug count
 //   assign I5 = {1'b1, {1'b0, count}, 1'b1};
    assign I4 = {enable[4], {3'b0, Q[4]}, 1'b1};
    assign I3 = {enable[3], {3'b0, Q[3]}, 1'b1};
    assign I2 = {enable[2], {3'b0, Q[2]}, 1'b1};
    assign I1 = {enable[1], {3'b0, Q[1]}, 1'b1};
    assign I0 = {enable[0], {3'b0, Q[0]}, 1'b1};
    
    sseg_driver driver (
        .I0(I0),
        .I1(I1),
        .I2(I2),
        .I3(I3),
        .I4(I4),
      //  .I5(I5),
        .I6(I6),
        .I7(I7),
        .clk(clk),
        .AN(AN),
        .bcd(sseg),
        .DP(DP)
    );
    
endmodule
