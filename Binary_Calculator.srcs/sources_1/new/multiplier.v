`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2025 08:13:40 PM
// Design Name: 
// Module Name: multiplier
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


module multiplier(
        input [7:0] a,
        input [7:0] b,
        input clk,
        input clr,
        input reg start,
        output reg [15:0] mtp_out    
    );
    integer i;
    reg [15:0] shifted_a;
    reg [7:0] shifted_b;
    reg [3:0] count; // 4-bit counter (0 to 7)
    reg isDone; //flag to check if done multiplier

    always @(posedge clk or posedge clr) begin
        if (clr | ~start) begin
            mtp_out <= 0;
            shifted_a <= 0;
            shifted_b <= 0;
            count <= 0;
            isDone <= 0;
        end 
        else if (start & ~isDone) begin
            if (count == 0) begin
                shifted_a <= a;
                shifted_b <= b;
                mtp_out <= 0;
            end 
            else if (count <= 8) begin
                if (shifted_b[0] == 1) begin // grab LSB of b
                    mtp_out <= mtp_out + shifted_a; // accumulate sum
                end
                shifted_a <= shifted_a << 1; // shift multiplicand left
                shifted_b <= shifted_b >> 1; // shift multiplier right
            end
            else if (count > 8) begin
                isDone <= 1;
            end
            count <= count + 1;
        end
    end
    
endmodule
