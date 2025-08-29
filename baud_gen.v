module baud_gen #(parameter CLK_FREQ = 50000000, parameter BAUD_RATE = 9600)(
    input wire clk,
    input wire reset,
    output reg baud_tick
);

    localparam integer DIVISOR = CLK_FREQ / (BAUD_RATE * 16);
    reg [$clog2(DIVISOR)-1:0] counter = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            baud_tick <= 0;
        end else if (counter == DIVISOR - 1) begin
            counter <= 0;
            baud_tick <= 1;
        end else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end

endmodule
