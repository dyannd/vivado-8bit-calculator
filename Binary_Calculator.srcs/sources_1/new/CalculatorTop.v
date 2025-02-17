`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2025 07:45:31 PM
// Design Name: 
// Module Name: CalculatorTop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CalculatorTop(
    input [15:0] sw,
    input btnU, btnR, btnD, btnL, btnC,
    input clk,
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp
    );
    
    reg [15:0] result;      // common reg to share result 
    wire [7:0] number1;      
    wire [7:0] number2;
    reg cout;               // carry out if had one (sum & from subtraction with n1 < n2)
    reg isNeg = 0;          // negative flag for subtraction with n1 < n2
    wire [19:0] bcdout;     // binary coded decimal output (20 bits - 5 digits)
    wire clr = btnC;        // clr signal
    reg err = 0;           // err signal
    
    assign number1 = sw[15:8];
    assign number2 = sw[7:0];
    assign led[15:0] = sw[15:0]; // LEDs for switches
    
    // Sum signals
    wire [7:0] adder_sum;      // sum output
    wire adder_cout;           // sum carry out, in case 9th bit is needed
    
    // Difference Signals
    wire [7:0] zero_diff;      
    wire [7:0] twoC_diff;
    assign zero_diff[7:0] = adder_sum; // subtraction output
    assign twoC_diff[7:0] = ((~zero_diff) +8'b00000001);	// 2's complement of subtraction output
    
    // Multp Signals
    wire [15:0] mtp_out;
    wire mtp_cout;
    
    // calls adder module
    Adder adder(
            .a(number1),
            .b(number2),
            .clk(clk),
            .clr(clr),
            .sum(adder_sum),
            .add_select(btnU),
            .sub_select(btnR),
            .cout(adder_cout)
    );
    
    multiplier M (
            .a(number1),
            .b(number2),
            .clk(clk),
            .start(btnD),
            .clr(clr),
            .mtp_out(mtp_out)
    );
    
    wire [7:0] quotient;
    wire [7:0] remainder;    
    reg isDiv = 0;
   
    
    Divider div (
        .a(number1),
        .b(number2),
        .clk(clk),
        .clr(clr),
        .start(btnL),
        .quotient(quotient),
        .remainder(remainder)
    );
    
        // Convert Binary to Decimal 
    BinToDec bcd (
        .bin(result),
        .bcdout(bcdout),
        .isNeg(isNeg),
        .isDiv(isDiv),
        .clk(clk),
        .err(err)
    );
   
    // Display Logic
    SegmentDisplay segmentdisplay(
        .clk(clk),       // System clock
        .clr(clr),       // clear signal
        .in(bcdout),     // 16-bit input number
        .seg(seg),      // 7-segment display segments
        .an(an),        // Digit enable
        .dp(dp)         // Decimal point
    );
    


    
    always @(posedge clk or posedge clr) 
        begin
            if (clr) begin // clear signal and negative sign
                result <= 16'b0;
                isNeg <= 0;
                isDiv <= 0;
                err <= 0;
            end
            else begin
                if (btnU) begin // addition
                    isNeg <= 0;
                    result <= {adder_cout, adder_sum[7:0]};
                end
                if (btnR) begin // subtraction
                    if (number1 >= number2) result = {adder_sum[7:0]}; // nice case, n1 > n2, just a sum at this point
                    else begin
                        isNeg <= 1; //negative sign flag
                        result <= {adder_cout, twoC_diff[7:0]};
                    end
                end
                if (btnD) begin // multiplying
                    result <= mtp_out;
                end 
                if (btnL) begin // division
                    if (number2 == 0) err <= 1;
                    isDiv <= 1;
                    result <= {remainder, quotient};
                end
            end
        end
endmodule
