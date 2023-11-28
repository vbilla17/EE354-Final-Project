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
always @(posedge clk or posedge reset)
begin
    if (reset || start)
        state <= INIT;
    else
    begin
        case (state)
            INIT:
            begin
                player_h <= 10'd399;
                player_v <= 10'd75;
                state <= IDLE;
            end
            IDLE:
                if (btn_right)
                begin
                    player_h <= player_h + 50;
                    state <= RIGHT;
                end
                else if (btn_left)
                begin
                    player_h <= player_h - 50;
                    state <= LEFT;
                end
            RIGHT:
                state <= IDLE;
            LEFT:
                state <= IDLE;
        endcase
    end
end

endmodule
