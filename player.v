module Player
    (clk,
    reset,
    btn_left,
    btn_right,
    btn_shoot,
    win,
    lose,
    player_x,
    player_y,
    fire
    )

    // Inputs
        input clk;
        input reset;
        input btn_left;
        input btn_right;
        input btn_shoot;

    // Outputs
        output [9:0] player_x;
        output [9:0] player_y;
        output fire;

    // Local signals
        reg [9:0] player_x;
        reg [9:0] player_y;
        reg fire;

    // Set 1-hot state encoding
        localparam
            INIT           =   5'b00001,
            IDLE           =   5'b00010,
            RIGHT          =   5'b00100,
            LEFT           =   5'b01000,
            SHOOT          =   5'b10000;

    // Logic
        always @(posedge clk, posedge reset)
        begin
            if (reset)
                state <= INIT;
            else
                begin
                    case (state)
                        INIT:
                            player_x <= 0;
                            player_y <= 0;
                            state <= IDLE;
                        IDLE:
                            fire <= 0;
                            if (btn_shoot)
                                state <= SHOOT;
                            else if (btn_right)
                                state <= RIGHT;
                            else if (btn_left)
                                state <= LEFT;
                        RIGHT:
                            player_x <= player_x + 15;
                            state <= IDLE;
                        LEFT:
                            player_x <= player_x - 15;
                            state <= IDLE;
                        SHOOT:
                            fire <= 1;
                            state <= IDLE;
                    endcase
                end


endmodule
