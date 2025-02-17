`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2025 06:51:08 PM
// Design Name: 
// Module Name: Calculator
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


module Calculator(
    input [15:0] sw,                    // switch inputs
    input btnU, btnR, btnD, btnL, btnC, // 5 buttons
    input clk,                          // clock
    output reg [15:0] result,            // 16 bit output
    output reg cout
    );
    
    assign number1 = sw[13:7];
    assign number2 = sw[6:0];
   
   wire [15:0] adder_sum;
   wire adder_cout;
    // calls adder module
    Adder adder(
            .a(number1),
            .b(number2),
            .clk(clk),
            .sum(adder_sum),
            .cout(adder_cout)
        );
            
    always @(posedge clk) 
    begin
        if (btnU) begin
            result <= adder_sum;
            cout <= adder_cout;
        end
         
            
//        else if (btnR)
//            result <= number1 - number2;
//        else if (btnD)
//            result <= number1 * number2;
//        else if (btnL)
//            result <= (number2 != 0) ? (number1 / number2): 16'hFFFF;
//        else if (btnC)
//            result <= (number2 != 0) ? (number1 % number2) : 16'hFFFF;
    end
endmodule
