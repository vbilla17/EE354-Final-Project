`timescale 1ns / 1ps
module Game
    (
    input clk,
    input reset,
    input start_btn,
    input win,
    input lose,
    output reg q_start,
    output reg q_playing,
    output reg q_lose,
    output reg q_win
    );

    // State encoding
    localparam
        WIN     =  4'b0001,
        LOSE    =  4'b0010,
        PLAYING =  4'b0100,
        START   =  4'b1000;

    // State register
    reg [3:0] state;

    // Logic
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            state <= START;
        else
        begin
            case (state)
                START:
                    if (start_btn)
                        state <= PLAYING;
                PLAYING:
                    begin
                        if (win)
                            state <= WIN;
                        else if (lose)
                            state <= LOSE;
                    end
                LOSE:
                    if (start_btn)
                        state <= START;
                WIN:
                    if (start_btn)
                        state <= START;
            endcase
        end

        // Update output registers based on state
        q_start = (state == START);
        q_playing = (state == PLAYING);
        q_lose = (state == LOSE);
        q_win = (state == WIN);
    end
endmodule
