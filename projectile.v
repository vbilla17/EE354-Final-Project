module Projectile
    (
    clk,
    reset,
    btn_shoot,
    player_h,
    collision,
    out_of_bounds
    projectile_h,
    projectile_v,
    projectile_idle
    )

    // Inputs
        input clk;
        input reset;
        input btn_shoot;
        input [9:0] player_h;

    // Outputs
        output [9:0] projectile_h;
        output [9:0] projectile_v;
        output projectile_idle;

    // Local signals
        reg [9:0] projectile_h;
        reg [9:0] projectile_v;
        reg projectile_idle;

    // Set 1-hot state encoding
        localparam
            IDLE           =   4'b0001,
            FIRING         =   4'b0010,
            HIT_TARGET     =   4'b0100,
            OOB            =   4'b1000;

    // Logic
        always @(posedge clk, posedge reset)
        begin
            if (reset)
                state <= IDLE;
            else
                begin
                    case (state)
                        IDLE:
                            projectile_h <= player_h;
                            projectile_v <= player_v;
                            projectile_idle <= 1;
                            if (btn_shoot)
                                state <= SHOOT;
                        FIRING:
                            projectile_v <= projectile_v + 10;
                            projectile_idle <= 0;
                            if (collision)
                                state <= HIT_TARGET;
                            else if (out_of_bounds)
                                state <= OOB;
                        HIT_TARGET:
                            projectile_idle <= 1;
                            if (btn_shoot)
                                state <= IDLE;
                        OOB:
                            projectile_idle <= 1;
                            state <= IDLE;
                    endcase
                end
        end