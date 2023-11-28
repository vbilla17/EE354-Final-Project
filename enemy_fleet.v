`timescale 1ns / 1ps
module EnemyFleet (
    input clk,
    input reset,
    input start,
    input [9:0] projectile_h,
    input [9:0] projectile_v,
    output reg [9:0] enemy_h,
    output reg [9:0] enemy_v,
    output reg enemy1_hit,
    output reg enemy2_hit,
    output reg enemy3_hit,
    output reg lose,
    output reg win,
    output reg collision
);

// Internal signals
reg [4:0] state;
reg [3:0] counter;
reg moving_right;
reg prev_enemy1_hit;
reg prev_enemy2_hit;
reg prev_enemy3_hit;

// Wires to connect hit signals from Enemy instances
wire enemy1_hit_from_enemy;
wire enemy2_hit_from_enemy;
wire enemy3_hit_from_enemy;

// Wires to track enemy hits within the module
wire enemy1_hit_internal;
wire enemy2_hit_internal;
wire enemy3_hit_internal;

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
        counter <= counter + 1;
end

// Instantiate enemy modules
Enemy enemy1(.clk(clk), .reset(reset), .start(start),
             .enemy_h(enemy_h), .enemy_v(enemy_v),
             .projectile_h(projectile_h), .projectile_v(projectile_v),
             .hit(enemy1_hit_from_enemy));
// Instantiate enemy 2 at the same vertical value, 150 pixels to the right
Enemy enemy2(.clk(clk), .reset(reset), .start(start),
             .enemy_h(enemy_h + 10'd150), .enemy_v(enemy_v),
             .projectile_h(projectile_h), .projectile_v(projectile_v),
             .hit(enemy2_hit_from_enemy));
// Instantiate enemy 3 at the same vertical value, 150 pixels to the right
Enemy enemy3(.clk(clk), .reset(reset), .start(start),
             .enemy_h(enemy_h + 10'd300), .enemy_v(enemy_v),
             .projectile_h(projectile_h), .projectile_v(projectile_v),
             .hit(enemy3_hit_from_enemy));

// Connect hit signals from Enemy instances to internal signals
assign enemy1_hit_internal = enemy1_hit_from_enemy;
assign enemy2_hit_internal = enemy2_hit_from_enemy;
assign enemy3_hit_internal = enemy3_hit_from_enemy;

// Logic (rest of your module remains the same)
always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        state <= INIT;
    end
    else
    begin
        case (state)
            INIT:
                begin
                    enemy_h <= 10'd50;
                    enemy_v <= 10'd475;
                    enemy1_hit <= 0;
                    enemy2_hit <= 0;
                    enemy3_hit <= 0;
                    win <= 0;
                    lose <= 0;
                    moving_right <= 1;
                    collision <= 0;
                    prev_enemy1_hit <= 0;
                    prev_enemy2_hit <= 0;
                    prev_enemy3_hit <= 0;
                    if (start)
                        state <= IDLE;
                end
            IDLE:
                // Use counter to move the enemy fleet slowly
                if (counter == 0)
                begin
                    if (moving_right && enemy_h < 10'd750)
                        state <= MOVE_RIGHT;
                    else if (moving_right && enemy_h >= 10'd750)
                    begin
                        moving_right <= 0;
                        state <= MOVE_DOWN;
                    end
                    else if (!moving_right && enemy_h > 10'd50)
                        state <= MOVE_LEFT;
                    else if (!moving_right && enemy_h <= 10'd50)
                    begin
                        moving_right <= 1;
                        state <= MOVE_DOWN;
                    end
                end
                else if (enemy1_hit_internal && enemy2_hit_internal && enemy3_hit_internal)
                    win <= 1;
                else if (enemy_v <= 10'd50)
                    lose <= 1;
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
                    enemy_v <= enemy_v - 10'd50;
                    state <= IDLE;
                end
        endcase

        // Detect collisions
        if (enemy1_hit && !prev_enemy1_hit)
            collision <= 1;
        else if (enemy2_hit && !prev_enemy2_hit)
            collision <= 1;
        else if (enemy3_hit && !prev_enemy3_hit)
            collision <= 1;
        else
            collision <= 0;

        prev_enemy1_hit <= enemy1_hit;
        prev_enemy2_hit <= enemy2_hit;
        prev_enemy3_hit <= enemy3_hit;
    end
end

endmodule
