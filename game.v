module Game
    (
    input clk,
    input reset,
    input start,
    output q_start,
    output q_playing,
    output q_game_over,
    output q_win,
    )

    // Inputs
        input clk;
        input reset;
        input start;

    // Outputs
        output q_start, q_playing, q_lose, q_win;
        reg [3:0] state;
        assign {q_start, q_playing, q_lose, q_win} = state;

    // Set 1-hot state encoding
        localparam
            START     =  4'b0001,
            PLAYING   =  4'b0010,
            LOSE      =  4'b0100,
            WIN       =  4'b1000;

    // Logic
        always @(posedge clk, posedge reset)
        begin
            if (reset)
                state <= START;
            else
                begin
                    case (state)
                        START:
                            if (start)
                                state <= PLAYING;
                        PLAYING:
                            if (win)
                                state <= WIN;
                            else if (lose)
                                state <= LOSE;
                        LOSE:
                            if (start)
                                state <= START;
                        WIN:
                            if (start)
                                state <= START;
                    endcase
                end
        end


