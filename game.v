`timescale 1ns / 1ps
module Game
    (
    input clk,
    input reset,
    input start_btn,
    input win,
    input lose,
    output q_start,
    output q_playing,
    output q_lose,
    output q_win
    );

    // Outputs
        reg [3:0] state;
        assign {q_start, q_playing, q_lose, q_win} = state;

    // Set 1-hot state encoding
        localparam
            WIN     =  4'b0001,
            LOSE   =  4'b0010,
            PLAYING      =  4'b0100,
            START       =  4'b1000;

    // Logic
        always @(posedge clk, posedge reset)
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
                            if (win)
                                state <= WIN;
                            else if (lose)
                                state <= LOSE;
                        LOSE:
                            if (start_btn)
                                state <= START;
                        WIN:
                            if (start_btn)
                                state <= START;
                    endcase
                end
        end
endmodule

