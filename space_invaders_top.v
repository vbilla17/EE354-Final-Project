module space_invaders_top
    (
    ClkPort, // 100 MHzIncoming clock signal
    BtnL, BtnC, BtnR, BtnD, // Buttons to provide user input
    );

    // Define inputs and outputs
        input ClkPort;
        input BtnL, BtnC, BtnR;

    // Define local signals
        wire         board_clk;
        wire         sys_clk;
        wire         reset;
        reg [26:0]   DIV_CLK;
        wire         game_start;
        wire         game_playing;
        wire         game_lose;
        wire         game_start;
        wire         collision;
        wire         bright;
        wire [11:0]  rgb;

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
        Debouncer debouncer_left(.CLK(sys_clk), .RESET(reset), .PB(BtnL), .DPB(), .SCEN(BtnL_SCEN), .MCEN(), .CCEN());\
        Debouncer debouncer_center(.CLK(sys_clk), .RESET(reset), .PB(BtnC), .DPB(), .SCEN(BtnC_SCEN), .MCEN(), .CCEN());\
        Debouncer debouncer_right(.CLK(sys_clk), .RESET(reset), .PB(BtnR), .DPB(), .SCEN(BtnR_SCEN), .MCEN(), .CCEN());\
        Debouncer debouncer_down(.CLK(sys_clk), .RESET(reset), .PB(BtnD), .DPB(), .SCEN(BtnD_SCEN), .MCEN(), .CCEN());\

    // Instantiate game module
        Game game(
            .clk(sys_clk),
            .reset(reset),
            .start(BtnC_SCEN),
            .q_start(game_start),
            .q_playing(game_playing),
            .q_lose(game_lose),
            .q_win(game_win));

    // Instantiate player module
        Player player(
            .clk(sys_clk),
            .reset(reset),
            .btn_left(BtnL_SCEN),
            .btn_right(BtnR_SCEN),
            .btn_shoot(BtnD_SCEN),
            .win(game_win),
            .lose(game_lose),
            .player_x(player_x),
            .player_y(player_y),
            .fire(fire));

    // Instantiate projectile module
        Projectile projectile(
            .clk(sys_clk),
            .reset(reset),
            .btn_shoot(BtnC_SCEN),
            .collision(collision)

endmodule