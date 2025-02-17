module SegmentDisplay(
    input clk,             // System clock
    input [19:0] in,       // 20-bit input number
    input clr,             // Clear signal
    output reg [6:0] seg,  // 7-segment display segments
    output reg [3:0] an,   // Digit enable
    output dp              // Decimal point (not used)
);
    
    reg [3:0] digit;        // Current digit's display value
    reg [19:0] refresh_counter = 0; // Refresh rate counter
    reg scroll_state = 0;       // 0: show last 4 digits, 1: show first 4 digits
    wire [1:0] selected;       // Active digit index (0-3)
    reg [31:0] scroll_timer = 0;// Timer for scrolling effect
    
    assign dp = 1; // No decimal point
    
    // Counter for display refresh
    always @(posedge clk or posedge clr) begin
        if (clr)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end
    
    // Counter for scrolling effect (every 1 sec)
    always @(posedge clk or posedge clr) begin
        if (clr | in[19:16] == 0) begin
            scroll_timer <= 0;
            scroll_state <= 0;
        end else begin
         // Scroll only if the input has a 5th digit (in[19:16] is nonzero)
          scroll_timer <= scroll_timer + 1;
            if (scroll_timer == 100000000 ) begin  // 1 sec
                scroll_state <= ~scroll_state; // Toggle scrolling state
                scroll_timer <= 0;
            end
         end
    end
    
    assign selected = refresh_counter[19:18]; // Selects 1 of 4 digits
    
    // 7-Segment Decoder
    always @(*) begin
        case (digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0111111; // minus sign
            4'hB: seg = 7'b1001100; // r - remainder
            4'hC: seg = 7'b0000110; // e - in "error"
            default: seg = 7'b1111111; // Default off
        endcase
    end
    
    // Digit selection (supports scrolling)
    always @(posedge clk) begin
        case (selected) 
            2'b00: digit = scroll_state ? in[7:4]  : in[3:0];   // ONES
            2'b01: digit = scroll_state ? in[11:8] : in[7:4];  // TENS
            2'b10: digit = scroll_state ? in[15:12]: in[11:8]; // HUNDREDS
            2'b11: digit = scroll_state ? in[19:16]: in[15:12];// THOUSANDS (last digit in shift mode)
            default: digit = 4'h0;
        endcase
    end
    
    // Enable correct digit
    always @(*) begin
        an = 4'b1111; // Turn all off
        an[selected] = 0; // Turn on the active digit
    end

endmodule
