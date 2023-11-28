module space_invaders_top
    (
    input ClkPort, // 100 MHzIncoming clock signal
    input BtnL, BtnC, BtnR, BtnD, // Buttons to provide user input

	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,
    );

    // Local signals
        wire sys_clk;
        wire reset;
        wire BtnL_SCEN, BtnC_SCEN, BtnR_SCEN, BtnD_SCEN;
        wire [9:0] player_h, player_v;
        wire [9:0] projectile_h, projectile_v;
        wire [9:0] enemy_h, enemy_v;
        wire collision;
        wire enemy1_hit, enemy2_hit, enemy3_hit;
        wire win, lose;
        wire game_start, game_playing, game_lose, game_win;
        wire bright;
        wire [9:0] hCount, vCount;

    // Assign reset
        assign reset = BtnC;

    // Clock divider
        BUFGP BUFGP1 (board_clk, ClkPort);

        assign board_clk = ClkPort;

        always @(posedge board_clk, posedge reset)
            begin
                if (reset)
                    DIV_CLK <= 0;
                else
                    DIV_CLK <= DIV_CLK + 1'b1;
            end

        assign sys_clk = board_clk;

    // Instantiate debounce modules for each button
        Debouncer debouncer_left(.CLK(sys_clk), .RESET(reset), .PB(BtnL), .DPB(), .SCEN(BtnL_SCEN), .MCEN(), .CCEN());
        Debouncer debouncer_center(.CLK(sys_clk), .RESET(reset), .PB(BtnC), .DPB(), .SCEN(BtnC_SCEN), .MCEN(), .CCEN());
        Debouncer debouncer_right(.CLK(sys_clk), .RESET(reset), .PB(BtnR), .DPB(), .SCEN(BtnR_SCEN), .MCEN(), .CCEN());

    // Instantiate VGA module
        display_controller dc(
            .clk(sys_clk),
            .hSync(hSync),
            .vSync(vSync),
            .bright(bright),
            .hCount(hCount),
            .vCount(vCount));

    // Instantiate game module
        Game game(
            .clk(sys_clk),
            .reset(reset),
            .start_btn(BtnC_SCEN),
            .win(win),
            .lose(lose),
            .q_start(game_start),
            .q_playing(game_playing),
            .q_lose(game_lose),
            .q_win(game_win));

    // Instantiate player module
        Player player(
            .clk(sys_clk),
            .reset(reset),
            .start(game_start),
            .btn_left(BtnL_SCEN),
            .btn_right(BtnR_SCEN),
            .player_h(player_h),
            .player_v(player_v));

    // Instantiate projectile module
        Projectile projectile(
            .clk(sys_clk),
            .reset(reset),
            .btn_shoot(BtnC_SCEN),
            .player_h(player_h),
            .collision(collision),
            .projectile_h(projectile_h),
            .projectile_v(projectile_v),
            .projectile_idle(projectile_idle));


    // Instantiate enemt fleet module
        EnemyFleet enemy_fleet(
            .clk(sys_clk),
            .reset(reset),
            .start(game_start),
            .projectile_h(projectile_h),
            .projectile_v(projectile_v),
            .enemy_h(enemy_h),
            .enemy_v(enemy_v),
            .enemy1_hit(enemy1_hit),
            .enemy2_hit(enemy2_hit),
            .enemy3_hit(enemy3_hit),
            .lose(lose),
            .win(win),
            .collision(collision));

endmodule