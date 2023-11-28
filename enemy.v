module Enemy 
    (
    clk,
    reset,
    start,
    enemy_h,
    enemy_v,
    projectile_h,
    projectile_v,
    hit
    )

    // Inputs
        input clk;
        input reset;
        input start;
        input [9:0] enemy_h;
        input [9:0] enemy_v;
        input [9:0] projectile_h;
        input [9:0] projectile_v;

    // Outputs
        output hit;

    // Local signals
        reg hit;
        reg [5:0] state;

    // 1-hot state encoding
        localparam
            INIT       = 3'b001,
            IDLE       = 3'b010,
            HIT        = 3'b100;


    // Logic
        always @(posedge clk, posedge reset)
        begin
            if (reset)
                state <= INIT;
            else
                begin
                    case (state)
                        INIT:
                            hit <= 0;
                            if (start)
                                state <= IDLE;
                        IDLE:
                            // If projectile is within 25 pixels of enemy, hit
                            if (projectile_h >= enemy_h - 25 && projectile_h <= enemy_h + 25 && projectile_v >= enemy_v - 25 && projectile_v <= enemy_v + 25)
                                state <= HIT;
                        HIT:
                            hit <= 1;
                            if (start)
                                begin
                                    state <= INIT;
                                    hit <= 0;
                                end
                    endcase
                end
        end