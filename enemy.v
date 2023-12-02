module Enemy (
    input clk,
    input reset,
    input start,
    input [9:0] enemy_h,
    input [9:0] enemy_v,
    input [9:0] projectile_h,
    input [9:0] projectile_v,
    output reg hit
);

// 1-hot state encoding
localparam INIT = 3'b001,
            IDLE = 3'b010,
            HIT  = 3'b100;

reg [2:0] state;

// Logic
always @(posedge clk, posedge reset)
begin
    if (reset || start)
    begin
        state <= INIT;
    end
    else
    begin
        case (state)
            INIT:
                begin
                    hit <= 0;
                    if (start)
                        state <= IDLE;
                end
            IDLE:
                begin
                    hit <= 0;
                    // If projectile is within 25 pixels of enemy, hit
                    if (projectile_h >= enemy_h - 10'd50 && projectile_h <= enemy_h + 10'd50)
                        if (projectile_v >= enemy_v - 10'd50 && projectile_v <= enemy_v + 10'd50)
                            state <= HIT;
                end
            HIT:
                begin
                    hit <= 1;
                    if (start)
                    begin
                        state <= IDLE;
                        hit <= 0;
                    end
                end
        endcase
    end
end

endmodule
