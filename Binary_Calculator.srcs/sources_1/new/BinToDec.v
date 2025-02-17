`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/09/2025 05:46:32 PM
// Design Name: 
// Module Name: BinToDec
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


module BinToDec(
    input [15:0] bin, //16-bit bin number
    input isNeg, // check if negative sign
    input isDiv, // check if a division
    input clk,
    input err,
    output reg [19:0] bcdout //20-bit BCD, max 4 digits
    );
    
    // initialize shifting register
    reg [35:0] z; // 16 + 16/3 = 36
    integer i; // loop counter
    reg [31:0] QRTimer = 0;
    reg [15:0] number;
    reg isRem = 0;
    
    always @(posedge clk) begin
        if (isDiv) begin
            QRTimer <= QRTimer + 1;
            if (QRTimer == 100_000_000) begin // 1 sec passed             
                isRem <= ~isRem;           
                QRTimer <= 0;
            end
        end
    end
    
    always @(*)
        begin
            if (~err) begin
                 number = bin; //default
                if (isDiv & isRem) begin
                   number = {8'b0, bin[15:8]};
                end
                if (isDiv & ~isRem) begin
                    number = {8'b0, bin[7:0]};
                end
                
                for (i=0; i<=35; i = i+1) 
                    begin
                        z[i]=0; //initializes to 0
                    end
                    
                z[18:3] = number; // shift 3 bits left and assign
                    
                repeat(13) // perform 13 shifting
                    begin
                        // check ONES
                        if (z[19:16] >= 5)
                            z[19:16] =z[19:16] + 3;
                        // check TENS
                        if (z[23:20] >= 5)
                            z[23:20] = z[23:20] +3;
                        // check HUNDREDS
                        if (z[27:24] >= 5)
                            z[27:24] = z[27:24] + 3;
                        // check THOUNSANDS
                        if (z[31:28] >= 5)
                            z[31:28] = z[31:28] + 3;
                        // check TENTH THOUDSANDS
                        if (z[35:32] >= 5)
                            z[35:32] = z[35:32] + 3;
                            
                        // shifting 1 bit left
                        z[35:1] = z[34:0];
                      end
                   bcdout = z[35:16]; //omit 15 bits at the end     
                   if (isNeg == 1) bcdout[15:12] = 'hA; //if negative, can safely assume a 3-digit bcd, so put a minus sign up front
                   if (isDiv == 1 & isRem) bcdout [15:12] = 'hB; // if division, display a "r" when displaying remainder
                end
                else begin // error case, just throw a display of "err"
                    bcdout[3:0] = 'hB;
                    bcdout[7:4] = 'hB;
                    bcdout[11:8] = 'hC;
                end
        end 
endmodule
