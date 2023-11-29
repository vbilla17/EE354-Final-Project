`timescale 1ns / 1ps
module EnemyFleet (
    input clk,
    input reset,
    input start,
    input playing,
    input [9:0] projectile_h,
    input [9:0] projectile_v,
    output reg [9:0] enemy_h,
    output reg [9:0] enemy_v
);

// Internal signals
reg [4:0] state;
reg [26:0] counter;
reg moving_right;

// 1-hot state encoding
localparam INIT       = 5'b00001,
            IDLE       = 5'b00010,
            MOVE_RIGHT = 5'b00100,
            MOVE_LEFT  = 5'b01000,
            MOVE_DOWN  = 5'b10000;

// Counter for enemy fleet movement
always @(posedge clk or posedge reset)
begin
    if (reset)
        counter <= 0;
    else
        counter <= counter + 1'b1;
end

// Logic (rest of your module remains the same)
always @(posedge clk, posedge reset)
begin
    if (reset || start)
        state <= INIT;
    else
    begin
        case (state)
            INIT:
                begin
                    enemy_h <= 10'd175;
                    enemy_v <= 10'd65;
                    moving_right <= 1;
                    if (playing)
                        state <= IDLE;
                end
            IDLE:
                // Use counter to move the enemy fleet slowly
                if (counter == 0)
                begin
                    if (moving_right && enemy_h < 10'd400)
                        state <= MOVE_RIGHT;
                    else if (moving_right && enemy_h >= 10'd400)
                    begin
                        moving_right <= 0;
                        state <= MOVE_DOWN;
                    end
                    else if (!moving_right && enemy_h > 10'd175)
                        state <= MOVE_LEFT;
                    else if (!moving_right && enemy_h <= 10'd175)
                    begin
                        moving_right <= 1;
                        state <= MOVE_DOWN;
                    end
                end
            MOVE_RIGHT:
                begin
                    enemy_h <= enemy_h + 10'd50;
                    state <= IDLE;
                end
            MOVE_LEFT:
                begin
                    enemy_h <= enemy_h - 10'd50;
                    state <= IDLE;
                end
            MOVE_DOWN:
                begin
                    enemy_v <= enemy_v + 10'd50;
                    state <= IDLE;
                end
        endcase
    end
end

endmodule
