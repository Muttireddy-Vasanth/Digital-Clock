module Digital_Clock(
    input clk,
    input reset,
    input ena,           // increment one second when high
    output reg pm,
    output reg [7:0] hh, // {tens, ones} BCD
    output reg [7:0] mm,
    output reg [7:0] ss
);

// Reset values: 12:00:00 AM (hh=8'h12, mm=ss=8'h00)
always @(posedge clk) begin
    if (reset) begin
        hh <= 8'h12;    // 12 BCD
        mm <= 8'h00;    // 00 BCD
        ss <= 8'h00;    // 00 BCD
        pm <= 0;        // AM
    end else if (ena) begin
        // Increment seconds
        if (ss[3:0] == 4'd9) begin
            if (ss[7:4] == 4'd5) begin // 59 reached
                ss <= 8'h00;
                // Increment minutes
                if (mm[3:0] == 4'd9) begin
                    if (mm[7:4] == 4'd5) begin // 59 reached
                        mm <= 8'h00;
                        // Increment hours
                        if (hh == 8'h11) begin // 11 to 12 (AM/PM toggle)
                            hh <= 8'h12;
                            pm <= ~pm;
                        end else if (hh == 8'h12) begin // 12 to 1
                            hh <= 8'h01;
                        end else if (hh[3:0] == 4'd9) begin // 09 to 10, 01-09/10-11
                            hh[3:0] <= 4'd0;
                            hh[7:4] <= hh[7:4] + 1'b1;
                        end else begin
                            hh[3:0] <= hh[3:0] + 1'b1; // simple increment
                        end
                    end else begin
                        mm[3:0] <= 4'd0;
                        mm[7:4] <= mm[7:4] + 1'b1;
                    end
                end else begin
                    ss <= 8'h00;
                    mm[3:0] <= mm[3:0] + 1'b1;
                end
            end else begin
                ss[3:0] <= 4'd0;
                ss[7:4] <= ss[7:4] + 1'b1;
            end
        end else begin
            ss[3:0] <= ss[3:0] + 1'b1;
        end
    end
    // If not ena, all values stay the same
end

endmodule
