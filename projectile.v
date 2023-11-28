`timescale 1ns / 1ps
module Projectile (
    input clk,
    input reset,
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

// Logic
always @(posedge clk or posedge reset)
begin
    if (reset)
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
                projectile_v <= 10'd75;;
                if (btn_shoot)
                begin
                    state <= FIRING;
                    projectile_idle <= 0;
                end
            end
            FIRING:
            begin
                projectile_v <= projectile_v + 10;
                if (collision)
                begin
                    state <= HIT_TARGET;
                    projectile_idle <= 1;
                end
                else if (projectile_v > 524)
                begin
                    state <= OOB;
                    projectile_idle <= 1;
                end
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
