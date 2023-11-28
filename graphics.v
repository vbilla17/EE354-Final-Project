module Graphics (
    input clk,
    input reset,
    input bright,
    input game_start,
    input game_playing,
    input game_lose,
    input game_win,
    input [9:0] player_h,
    input [9:0] player_v,
    input [9:0] projectile_h,
    input [9:0] projectile_v,
    input projectile_idle,
    input [9:0] enemy_h,
    input [9:0] enemy_v,
    input enemy1_hit,
    input enemy2_hit,
    input enemy3_hit,
    input [9:0] hCount,
    input [9:0] vCount,
    output reg [11:0] rgb
);

    // Define background color
    localparam background_color = 12'b000000000000;

    // State encoding for game states
    wire [3:0] state;
    assign state = {game_start, game_playing, game_lose, game_win};
    localparam WIN = 4'b0001;
    localparam LOSE = 4'b0010;
    localparam PLAYING = 4'b0100;
    localparam START = 4'b1000;

    // Get color maps from rom modules
    wire [11:0] player_color;
    wire [11:0] enemy_1_color;
    wire [11:0] enemy_2_color;
    wire [11:0] enemy_3_color;
    wire [11:0] win_color;
    wire [11:0] lose_color;
    wire [11:0] continue_color;
    wire [11:0] start_color;

    // Set position of text on screen
    wire [9:0] win_v, win_h;
    wire [9:0] lose_v, lose_h;
    wire [9:0] continue_v, continue_h;
    wire [9:0] start_v, start_h;

    assign win_v = 10'd275;
    assign win_h = 10'd425;
    assign lose_v = 10'd275;
    assign lose_h = 10'd425;
    assign continue_v = 10'd425;
    assign continue_h = 10'd225;
    assign start_v = 10'd275;
    assign start_h = 10'd425;

    // Set values for other two enemies
    reg [9:0] enemy2_h;
    reg [9:0] enemy3_h;

    always @(*)
    begin
        enemy2_h = enemy_h + 10'd150;
        enemy3_h = enemy_h + 10'd300;
    end

    wire player_fill, enemy1_fill, enemy2_fill, enemy3_fill, projectile_fill, win_fill, lose_fill, continue_fill, start_fill;

    assign player_fill = (vCount >= player_v) && (vCount <= (player_v + 10'd23)) && (hCount >= player_h) && (hCount < (player_h + 10'd38));
    assign enemy1_fill = (vCount >= enemy_v) && (vCount <= (enemy_v + 10'd38)) && (hCount >= enemy_h) && (hCount < (enemy_h + 10'd38));
    assign enemy2_fill = (vCount >= enemy_v) && (vCount <= (enemy_v + 10'd38)) && (hCount >= enemy2_h) && (hCount < (enemy2_h + 10'd38));
    assign enemy3_fill = (vCount >= enemy_v) && (vCount <= (enemy_v + 10'd38)) && (hCount >= enemy3_h) && (hCount < (enemy3_h + 10'd38));
    assign projectile_fill = (vCount >= projectile_v) && (vCount < (projectile_v + 10'd10)) && (hCount >= projectile_h) && (hCount < (projectile_h + 10'd10));
    assign win_fill = (vCount >= win_v) && (vCount < (win_v + 10'd33)) && (hCount >= win_h) && (hCount < (win_h + 10'd219));
    assign lose_fill = (vCount >= lose_v) && (vCount < (lose_v + 10'd33)) && (hCount >= lose_h) && (hCount < (lose_h + 10'd287));
    assign continue_fill = (vCount >= continue_v) && (vCount < (continue_v + 10'd15)) && (hCount >= continue_h) && (hCount < (continue_h + 10'd331));
    assign start_fill = (vCount >= start_v) && (vCount < (start_v + 10'd33)) && (hCount >= start_h) && (hCount < (start_h + 10'd170));

    // Instantiate rom modules
    player_50_rom pr (.clk(clk), .row(vCount - player_v), .col(hCount - player_h), .color_data(player_color));
    enemy_50_rom er1 (.clk(clk), .row(vCount - enemy_v), .col(hCount - enemy_h), .color_data(enemy_1_color));
    enemy_50_rom er2 (.clk(clk), .row(vCount - enemy_v), .col(hCount - enemy2_h), .color_data(enemy_2_color));
    enemy_50_rom er3 (.clk(clk), .row(vCount - enemy_v), .col(hCount - enemy3_h), .color_data(enemy_3_color));
    win_50_rom wr (.clk(clk), .row(vCount - win_v), .col(hCount - win_h), .color_data(win_color));
    game_over_50_rom lr (.clk(clk), .row(vCount - lose_v), .col(hCount - lose_h), .color_data(lose_color));
    continue_50_rom cr (.clk(clk), .row(vCount - continue_v), .col(hCount - continue_h), .color_data(continue_color));
    start_50_rom sr (.clk(clk), .row(vCount - start_v), .col(hCount - start_h), .color_data(start_color));

    // Different displays for different game states
    always @(*)
    begin
        if (~bright)
            begin
                rgb = 12'b000000000000;
            end
        else
            begin
                case (state)
                    START:
                        // Display start and continue sprites
                        if (start_fill && start_color != 12'b000000001111)
                            rgb = start_color;
                        else if (continue_fill && continue_color != 12'b000000001111)
                            rgb = continue_color;
                        else
                            rgb = background_color;
                    PLAYING:
                        // Display player sprite
                        if (player_fill && player_color != 12'b000000001111)
                            rgb = player_color;
                        // Display enemy sprites
                        else if (!enemy1_hit && enemy1_fill && enemy_1_color != 12'b000000001111)
                            rgb = enemy_1_color;
                        else if (!enemy2_hit && enemy2_fill && enemy_2_color != 12'b000000001111)
                            rgb = enemy_2_color;
                        else if (!enemy3_hit && enemy3_fill && enemy_3_color != 12'b000000001111)
                            rgb = enemy_3_color;
                        else if (!projectile_idle && projectile_fill)
                            rgb = 12'b001011000000;
                        else
                            rgb = background_color;
                    LOSE:
                        // Display lose and continue sprites
                        if (lose_fill && lose_color != 12'b000000001111)
                            rgb = lose_color;
                        else if (continue_fill && continue_color != 12'b000000001111)
                            rgb = continue_color;
                        else
                            rgb = background_color;
                    WIN:
                        // Display win and continue sprites
                        if (win_fill && win_color != 12'b000000001111)
                            rgb = win_color;
                        else if (continue_fill && continue_color != 12'b000000001111)
                            rgb = continue_color;
                        else
                            rgb = background_color;
                    default:
                        rgb = background_color;
                endcase
            end
    end
endmodule
