`timescale 1ns / 1ps

module space_invaders_top
    (
    input ClkPort, // 100 MHzIncoming clock signal
    input BtnL, BtnC, BtnR, BtnU,// Buttons to provide user input

	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,

    output MemOE, MemWR, RamCS, QuadSpiFlashCS,

    //SSD signal 
	output An0, An1, An2, An3, An4, An5, An6, An7,
	output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,

    // LED signals
    output Ld0, Ld1, Ld2, Ld3
    );

    // disable mamory ports
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

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
        reg [27:0]	DIV_CLK;
        wire [11:0] rgb;
        wire [3:0] anode;

    // Assign reset
        assign reset = BtnU;


    // Assign RGB signals
        assign vgaR = rgb[11:8];
        assign vgaG = rgb[7:4];
        assign vgaB = rgb[3:0];

    // Instantiate debounce modules for each button
        Debouncer debouncer_left(.CLK(ClkPort), .RESET(reset), .PB(BtnL), .DPB(), .SCEN(BtnL_SCEN), .MCEN(), .CCEN());
        Debouncer debouncer_center(.CLK(ClkPort), .RESET(reset), .PB(BtnC), .DPB(), .SCEN(BtnC_SCEN), .MCEN(), .CCEN());
        Debouncer debouncer_right(.CLK(ClkPort), .RESET(reset), .PB(BtnR), .DPB(), .SCEN(BtnR_SCEN), .MCEN(), .CCEN());

    // Instantiate VGA module
        display_controller dc(
            .clk(ClkPort),
            .hSync(hSync),
            .vSync(vSync),
            .bright(bright),
            .hCount(hCount),
            .vCount(vCount));

    // Instantiate game module
        Game game(
            .clk(ClkPort),
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
            .clk(ClkPort),
            .reset(reset),
            .start(game_start),
            .btn_left(BtnL_SCEN),
            .btn_right(BtnR_SCEN),
            .player_h(player_h),
            .player_v(player_v));

    // Instantiate projectile module
        Projectile projectile(
            .clk(ClkPort),
            .reset(reset),
            .start(game_start),
            .btn_shoot(BtnC_SCEN),
            .player_h(player_h),
            .collision(collision),
            .projectile_h(projectile_h),
            .projectile_v(projectile_v),
            .projectile_idle(projectile_idle));


    // Instantiate enemy fleet module
        EnemyFleet enemy_fleet(
            .clk(ClkPort),
            .reset(reset),
            .start(game_start),
            .playing(game_playing),
            .projectile_h(projectile_h),
            .projectile_v(projectile_v),
            .enemy_h(enemy_h),
            .enemy_v(enemy_v));

    // Instantiate collision module
        Collisions collision(
            .clk(ClkPort),
            .reset(reset),
            .start(game_start),
            .enemy_h(enemy_h),
            .enemy_v(enemy_v),
            .projectile_h(projectile_h),
            .projectile_v(projectile_v),
            .enemy1_hit(enemy1_hit),
            .enemy2_hit(enemy2_hit),
            .enemy3_hit(enemy3_hit),
            .lose(lose),
            .win(win),
            .collision(collision));

    // Instantiate graphics module
        Graphics graphics(
            .clk(ClkPort),
            .reset(reset),
            .bright(bright),
            .game_start(game_start),
            .game_playing(game_playing),
            .game_lose(game_lose),
            .game_win(game_win),
            .player_h(player_h),
            .player_v(player_v),
            .projectile_h(projectile_h),
            .projectile_v(projectile_v),
            .projectile_idle(projectile_idle),
            .enemy_h(enemy_h),
            .enemy_v(enemy_v),
            .enemy1_hit(enemy1_hit),
            .enemy2_hit(enemy2_hit),
            .enemy3_hit(enemy3_hit),
            .hCount(hCount),
            .vCount(vCount),
            .rgb(rgb)
            );

    reg [3:0]	SSD;
	wire [3:0]	SSD3, SSD2, SSD1, SSD0;
	reg [7:0]  	SSD_CATHODES;
	wire [1:0] 	ssdscan_clk;
	
	always @ (posedge ClkPort, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
	  else
			DIV_CLK <= DIV_CLK + 1'b1;
	end

    //------------
// SSD (Seven Segment Display)
	// reg [3:0]	SSD;
	// wire [3:0]	SSD3, SSD2, SSD1, SSD0;

    reg [3:0] BtnC_SCEN_counter;
    reg [3:0] BtnL_SCEN_counter;
    reg [3:0] BtnR_SCEN_counter;

    // Listen to BtnC_SCEN to start the game and display the button press on the SSD1
    always @ (posedge ClkPort, posedge reset)
    begin
        if (reset)
            BtnC_SCEN_counter <= 4'b0000;
        else if (BtnC_SCEN)
            BtnC_SCEN_counter <= BtnC_SCEN_counter + 1'b1;
    end

    // Listen to BtnL_SCEN to move the player left and display the button press on the SSD2
    always @ (posedge ClkPort, posedge reset)
    begin
        if (reset)
            BtnL_SCEN_counter <= 4'b0000;
        else if (BtnL_SCEN)
            BtnL_SCEN_counter <= BtnL_SCEN_counter + 1'b1;
    end

    // Listen to BtnR_SCEN to move the player right and display the button press on the SSD3
    always @ (posedge ClkPort, posedge reset)
    begin
        if (reset)
            BtnR_SCEN_counter <= 4'b0000;
        else if (BtnR_SCEN)
            BtnR_SCEN_counter <= BtnR_SCEN_counter + 1'b1;
    end
	
	//SSDs display 
	//to show how we can interface our "game" module with the SSD's, we output the 12-bit rgb background value to the SSD's
	assign SSD3 = BtnL_SCEN_counter;
	assign SSD2 = BtnC_SCEN_counter;
	assign SSD1 = BtnR_SCEN_counter;
	assign SSD0 = {game_lose, game_win, game_playing, game_start};


	// need a scan clk for the seven segment display 
	
	// 100 MHz / 2^18 = 381.5 cycles/sec ==> frequency of DIV_CLK[17]
	// 100 MHz / 2^19 = 190.7 cycles/sec ==> frequency of DIV_CLK[18]
	// 100 MHz / 2^20 =  95.4 cycles/sec ==> frequency of DIV_CLK[19]
	
	// 381.5 cycles/sec (2.62 ms per digit) [which means all 4 digits are lit once every 10.5 ms (reciprocal of 95.4 cycles/sec)] works well.
	
	//                  --|  |--|  |--|  |--|  |--|  |--|  |--|  |--|  |   
    //                    |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
	//  DIV_CLK[17]       |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|
	//
	//               -----|     |-----|     |-----|     |-----|     |
    //                    |  0  |  1  |  0  |  1  |     |     |     |     
	//  DIV_CLK[18]       |_____|     |_____|     |_____|     |_____|
	//
	//         -----------|           |-----------|           |
    //                    |  0     0  |  1     1  |           |           
	//  DIV_CLK[19]       |___________|           |___________|
	//

	assign ssdscan_clk = DIV_CLK[19:18];
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	=  !((ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	=  !((ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	// Turn off another 4 anodes
	assign {An7, An6, An5, An4} = 4'b1111;
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
				  2'b00: SSD = SSD0;
				  2'b01: SSD = SSD1;
				  2'b10: SSD = SSD2;
				  2'b11: SSD = SSD3;
		endcase 
	end

	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD) // in this solution file the dot points are made to glow by making Dp = 0
		    //                                                                abcdefg,Dp
			4'b0000: SSD_CATHODES = 8'b00000010; // 0
			4'b0001: SSD_CATHODES = 8'b10011110; // 1
			4'b0010: SSD_CATHODES = 8'b00100100; // 2
			4'b0011: SSD_CATHODES = 8'b00001100; // 3
			4'b0100: SSD_CATHODES = 8'b10011000; // 4
			4'b0101: SSD_CATHODES = 8'b01001000; // 5
			4'b0110: SSD_CATHODES = 8'b01000000; // 6
			4'b0111: SSD_CATHODES = 8'b00011110; // 7
			4'b1000: SSD_CATHODES = 8'b00000000; // 8
			4'b1001: SSD_CATHODES = 8'b00001000; // 9
			4'b1010: SSD_CATHODES = 8'b00010000; // A
			4'b1011: SSD_CATHODES = 8'b11000000; // B
			4'b1100: SSD_CATHODES = 8'b01100010; // C
			4'b1101: SSD_CATHODES = 8'b10000100; // D
			4'b1110: SSD_CATHODES = 8'b01100000; // E
			4'b1111: SSD_CATHODES = 8'b01110000; // F    
			default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
		endcase
	end	
	
	// reg [7:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};

    // Assign output of collisions to LEDs
    assign Ld0 = collision;
    assign Ld1 = enemy1_hit;
    assign Ld2 = enemy2_hit;
    assign Ld3 = enemy3_hit;

endmodule