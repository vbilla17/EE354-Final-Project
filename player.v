`timescale 1ns / 1ps
module Player (
    input clk,
    input reset,
    input start,
    input btn_left,
    input btn_right,
    output reg [9:0] player_h,
    output reg [9:0] player_v
);

// Set 1-hot state encoding
localparam INIT  = 4'b0001,
            IDLE  = 4'b0010,
            RIGHT = 4'b0100,
            LEFT  = 4'b1000;

reg [3:0] state;

// Logic
always @(posedge clk, posedge reset)
begin
    if (reset || start)
        state <= INIT;
    else
    begin
        case (state)
            INIT:
            begin
                player_h <= 10'd399;
                player_v <= 10'd475;
                state <= IDLE;
            end
            IDLE:
                if (btn_right)
                        state <= RIGHT;
                else if (btn_left)
                    state <= LEFT;
            RIGHT:
                begin
                    if (player_h < 10'd749)
                        player_h <= player_h + 10'd50;
                    state <= IDLE;
                end
            LEFT:
                begin
                    if (player_h > 10'd50)
                        player_h <= player_h - 10'd50;
                    state <= IDLE;
                end
        endcase
    end
end

endmodule
