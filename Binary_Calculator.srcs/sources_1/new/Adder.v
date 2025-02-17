`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 08:09:29 PM
// Design Name: 
// Module Name: Adder
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


module Adder(
    input [7:0] a,
    input [7:0] b,
    input clk, 
    input clr,
    input add_select,
    input sub_select,
    output reg [7:0] sum,
    output reg cout
    );
    
    reg [8:0] c = 0; // account for 9 bit adder
    integer i;   // counter
    reg done = 0;    // flag to stop
       
    always @(posedge clk or posedge clr) begin
        if (clr) begin
            c <= 0;
            done <= 0;
        end
        else begin
            if (add_select == 1 & ~done) begin
                c[0] = 0;
                for (i = 0; i <= 7; i = i + 1) begin
                    sum[i] = a[i] ^ b[i] ^ c[i]; // sum part, XOR everything
                    c[i+1] = (a[i]&b[i])|(a[i]&c[i])|(b[i]&c[i]); // carry part
                end
                cout = c[8];
                done <= 1;
            end
            else if (sub_select == 1 & ~done) begin                      // handle subtraction, basically just another sum
                c[0] = 1;                                   // add 1 to 2's complement of b (invert b)
                for (i = 0; i <= 7; i = i + 1) begin
                    sum[i] = a[i]^(~ b[i])^c[i];            // difference part, XOR everything
                    c[i+1]= (a[i]&(~b[i]))|(a[i]&c[i])|((~b[i])&c[i]);
                end           
                cout = c[8]; //signed bit if had one
                done <= 1;
            end
         end
    end
    
    
endmodule
