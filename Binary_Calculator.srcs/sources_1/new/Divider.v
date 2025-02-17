`timescale 1ns / 1ps

module Divider(
    input [7:0] a,  // dividend
    input [7:0] b,  // divisor
    input clk,
    input clr,
    input start,
    output [7:0] quotient,
    output [7:0] remainder
);

    reg [7:0] R;  
    reg [7:0] Q;
    integer i;
    
    assign quotient = Q;
    assign remainder = R;
    
    // resotring division algo
    always @(posedge clk or posedge clr) begin
        if (clr) begin
            R <= 8'b0;
            Q <= 8'b0;

        end
        else if (start) begin
            R = 8'b0;
            Q = a;
            
            for (i=0; i<=7; i = i+1) begin
                R = R << 1;
                R[0] = Q[7];
                Q = Q << 1;
                
                Q[0] = 1'b0;
                
                if (R >= b) begin
                    R = R - b;
                    Q[0] = 1'b1;
                end
            end
            
        end
     end

//    always @(posedge clk or posedge clr) begin
//        if (clr) begin
//            R <= 8'b0;
//            Q <= 8'b0;
//            quotient <= 8'b0;
//            remainder <= 8'b0;
//            counter <= 0;
//            busy <= 0;
//        end
//        else if (start & ~busy) begin
//            // Initialize values
//            R <= 8'b0;
//            Q <= a;   // Load dividend
//            counter <= 8;
//            busy <= 1;
//        end
//        else if (busy) begin
//            // Shift left both remainder and quotient
//            R <= {R[6:0], Q[7]};
//            Q <= Q << 1;

//            // Subtract divisor
//            if (R >= b) begin
//                R <= R - b;
//                Q[0] <= 1;
//            end else begin
//                Q[0] <= 0;
//            end

//            // Decrement counter
//            counter <= counter - 1;

//            // Finish after 8 cycles
//            if (counter == 1) begin
//                quotient <= Q;
//                remainder <= R;
//                busy <= 0;
//            end
//        end
//    end

endmodule
