`timescale 1ns / 1ps
module Projectile (
    input clk,
    input reset,
    input start,
    input btn_shoot,
    input [9:0] player_h,
    input collision,
    output reg [9:0] projectile_h,
    output reg [9:0] projectile_v,
    output reg projectile_idle
);

// 1-hot state encoding
localparam IDLE       = 4'b0001,
            FIRING     = 4'b0010,
            HIT_TARGET = 4'b0100,
            OOB        = 4'b1000;

// State register
reg [3:0] state;

// Slow counter for projectile movement
reg [22:0] counter;
always @(posedge clk, posedge reset)
begin
    if (reset)
        counter <= 0;
    else
        counter <= counter + 1'b1;
end

// Logic
always @(posedge clk, posedge reset)
begin
    if (reset || start)
        begin
            state <= IDLE;
            projectile_idle <= 1;
        end
    else
    begin
        case (state)
            IDLE:
                begin
                    projectile_h <= player_h;
                    projectile_v <= 10'd475;
                    if (btn_shoot)
                        begin
                            state <= FIRING;
                            projectile_idle <= 0;
                        end
                end
            FIRING:
                begin
                    if (counter == 0)
                        projectile_v <= projectile_v - 25;
                    if (collision)
                        state <= HIT_TARGET;
                    if (projectile_v < 25)
                        state <= OOB;
                end
            HIT_TARGET, OOB:
                begin
                    state <= IDLE;
                    projectile_idle <= 1;
                end
        endcase
    end
end

endmodule
