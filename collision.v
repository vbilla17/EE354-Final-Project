module Collisions
(
    input clk,
    input reset,
    input start,
    input playing,
    input [9:0] enemy_h,
    input [9:0] enemy_v,
    input [9:0] projectile_h,
    input [9:0] projectile_v,
    output reg enemy1_hit,
    output reg enemy2_hit,
    output reg enemy3_hit,
    output reg lose,
    output reg win,
    output reg collision
);

    // Horizontal coordinates of other two enemies
    reg [9:0] enemy2_h;
    reg [9:0] enemy3_h;

    // Assign enemy2_h and enemy3_h
    always @(enemy_h)
    begin
        enemy2_h <= enemy_h + 10'd150;
        enemy3_h <= enemy_h + 10'd300;
    end

    // Local signals for determining collisions
    reg enemy1_hit_current;
    reg enemy2_hit_current;
    reg enemy3_hit_current;

    // Check for collisions
    always @(projectile_h, projectile_v, enemy_h, enemy_v, enemy2_h, enemy3_h)
    begin
        if (projectile_h >= enemy_h - 10'd25 && projectile_h <= enemy_h + 10'd25)
            if (projectile_v >= enemy_v - 10'd25 && projectile_v <= enemy_v + 10'd25)
                enemy1_hit_current <= 1;
            else
                enemy1_hit_current <= 0;
        else
            enemy1_hit_current <= 0;

        if (projectile_h >= enemy2_h - 10'd25 && projectile_h <= enemy2_h + 10'd25)
            if (projectile_v >= enemy_v - 10'd25 && projectile_v <= enemy_v + 10'd25)
                enemy2_hit_current <= 1;
            else
                enemy2_hit_current <= 0;
        else
            enemy2_hit_current <= 0;

        if (projectile_h >= enemy3_h - 10'd25 && projectile_h <= enemy3_h + 10'd25)
            if (projectile_v >= enemy_v - 10'd25 && projectile_v <= enemy_v + 10'd25)
                enemy3_hit_current <= 1;
            else
                enemy3_hit_current <= 0;
        else
            enemy3_hit_current <= 0;
    end

    // Temporary signals to store previous hit signals
    reg prev_enemy1_hit;
    reg prev_enemy2_hit;
    reg prev_enemy3_hit;

    // Calculate collision, win, and lose signals
    always @(posedge clk)
    begin
        if (~playing)
            begin
                collision <= 0;
                prev_enemy1_hit <= 0;
                prev_enemy2_hit <= 0;
                prev_enemy3_hit <= 0;
                win <= 0;
                lose <= 0;
                enemy1_hit <= 0;
                enemy2_hit <= 0;
                enemy3_hit <= 0;
            end
        else
            begin
                // Update previous hit signals
                prev_enemy1_hit <= enemy1_hit_current;
                prev_enemy2_hit <= enemy2_hit_current;
                prev_enemy3_hit <= enemy3_hit_current;

                // Check for collision
                if (enemy1_hit_current || enemy2_hit_current || enemy3_hit_current ||
                    (prev_enemy1_hit && !enemy1_hit_current) ||
                    (prev_enemy2_hit && !enemy2_hit_current) ||
                    (prev_enemy3_hit && !enemy3_hit_current))
                    collision <= 1;
                else
                    collision <= 0;

                if (enemy1_hit_current)
                    enemy1_hit <= 1;
                if (enemy2_hit_current)
                    enemy2_hit <= 1;
                if (enemy3_hit_current)
                    enemy3_hit <= 1;

                if (enemy1_hit && enemy2_hit && enemy3_hit)
                    win <= 1;
                if (enemy_v >= 10'd450)
                    lose <= 1;
            end
    end

endmodule
